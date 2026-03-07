data day2_visits;
    format visitdt date9.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ visit visitdt :date9. labval;
datalines;
ABC101|ABC101-001|1|01JAN2024|10
ABC101|ABC101-001|2|10JAN2024|12
ABC101|ABC101-001|3|20JAN2024|15
ABC101|ABC101-002|1|05JAN2024|20
ABC101|ABC101-002|2|18JAN2024|22
ABC101|ABC101-003|1|03JAN2024|30
ABC101|ABC101-003|2|08JAN2024|32
ABC101|ABC101-003|3|25JAN2024|35
ABC101|ABC101-003|4|01FEB2024|40
;
run;


/*Task 1 – Flag First and Last Visit per Subject*/

proc sort data=day2_visits out=day2_sorted;
    by usubjid visitdt;
run;

data first_last_flag;
    set day2_sorted;
    by usubjid visitdt;

    length first_visit last_visit $1;

    if first.usubjid then first_visit = 'Y';
    else first_visit = 'N';

    if last.usubjid then last_visit = 'Y';
    else last_visit = 'N';
run;


/*Task 2 – Create Visit Sequence Number*/

proc sort data=day2_visits out=task3_sorted;
    by usubjid visitdt;
run;

data task3_seq;
    set task3_sorted;
    by usubjid visitdt;
    if first.usubjid then visit_seq = 1;
    else visit_seq + 1;
run;


/*Task 3 – Count Total Visits per Subject*/

proc sort data=day2_visits out=day2_sorted;
    by usubjid;
run;

data visit_count(keep=usubjid total_visits);
    set day2_sorted;
    by usubjid;
    if first.usubjid then total_visits = 1;
    else total_visits + 1;
    if last.usubjid then output;
run;

/*or*/

data visit_count(keep=usubjid total_visits);
    set day2_sorted;
    by usubjid;
    retain total_visits;
    if first.usubjid then total_visits = 0;
    total_visits + 1;
    if last.usubjid then output;
run;


/*Task 4 – Create Subject Summary Dataset*/
proc sort data=day2_visits out=day2_sorted;
    by usubjid visitdt;
run;

data subject_summary(keep=usubjid first_visitdt last_visitdt total_visits);
    set day2_sorted;
    by usubjid visitdt;

    retain first_visitdt last_visitdt total_visits;

    if first.usubjid then do;
        first_visitdt = visitdt;
        total_visits = 0;
    end;

    total_visits + 1;

    if last.usubjid then do;
        last_visitdt = visitdt;
        output;
    end;

    format first_visitdt last_visitdt date9.;
run;
