data day1_raw;
    format visitdt date9. loadts datetime20.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ siteid usubjid $ visit visitdt :date9. 
          labval loadts :datetime20.;
datalines;
ABC101|101|ABC101-001|1|01JAN2024|10|01JAN2024:08:00:00
ABC101|101|ABC101-001|1|01JAN2024|10|01JAN2024:08:00:00
ABC101|101|ABC101-001|1|01JAN2024|11|01JAN2024:08:00:00
ABC101|101|ABC101-001|2|15JAN2024|15|15JAN2024:09:00:00
ABC101|101|ABC101-001|2|15JAN2024|15|15JAN2024:09:05:00
ABC101|102|ABC101-002|1|03JAN2024|20|03JAN2024:10:00:00
ABC101|102|ABC101-002|1|03JAN2024|22|03JAN2024:10:10:00
ABC101|102|ABC101-002|2|18JAN2024|25|18JAN2024:11:00:00
ABC101|103|ABC101-003|1|05JAN2024|30|05JAN2024:12:00:00
ABC101|103|ABC101-003|1|05JAN2024|30|05JAN2024:12:00:00
ABC101|103|ABC101-003|2|20JAN2024|35|20JAN2024:13:00:00
;
run;

/*? Task 1 – Remove Exact Duplicates*/

proc sort data=c
          out=day1_nodup
          noduprecs
          dupout=duplicates;
    by _all_;
run;

proc sort data=day1_raw
          out=day1_nodup
          nodupkey
          dupout=duplicates;
    by studyid siteid usubjid visit visitdt labval loadts;
run;

/*Task 2 – Keep Latest Record per Subject + Visit*/

proc sort data=day1_raw out=day1_latest;
    by usubjid visit descending loadts;
run;

data day1_latestx;
    set day1_latest;
    by usubjid visit;
    if first.visit;
run;

/*Task 3 – Identify Logical Duplicates*/

proc sort data=day1_raw out=day1_sorted;
    by usubjid visit visitdt;
run;

data logical_duplicates 
	 clean_records;
    set day1_sorted;
    by usubjid visit visitdt;
    if not (first.visitdt and last.visitdt) then output logical_duplicates;
    else output clean_records;
run;


/*Task 4 – Create Duplicate Summary Table*/
/*| USUBJID | TOTAL_RECORDS | UNIQUE_VISITS | DUP_COUNT |*/

proc sql;
    create table duplicate_summary as
    select  usubjid,
            count(*) as total_records,
            count(distinct visit) as unique_visits,
            calculated total_records - calculated unique_visits as dup_count
    from day1_raw
    group by usubjid;
quit;


/*or */

proc sort data=day1_raw out=day1_sorted;
    by usubjid visit;
run;

data duplicate_summary(keep=usubjid total_records unique_visits dup_count);
    set day1_sorted;
    by usubjid visit;

    retain total_records unique_visits;

    if first.usubjid then do;
        total_records = 0;
        unique_visits = 0;
    end;

    total_records + 1;

    if first.visit then unique_visits + 1;

    if last.usubjid then do;
        dup_count = total_records - unique_visits;
        output;
    end;
run;
