data day9_visits;
    format visitdt date9.;
	length usubjid $10.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ visit visitdt :date9.;
datalines;
ABC101|ABC101-001|1|01JAN2024
ABC101|ABC101-001|2|05JAN2024
ABC101|ABC101-001|3|20JAN2024
ABC101|ABC101-002|1|03JAN2024
ABC101|ABC101-002|2|10JAN2024
ABC101|ABC101-002|3|12JAN2024
ABC101|ABC101-003|1|02JAN2024
ABC101|ABC101-003|2|25JAN2024
;
run;

/*TASK 1 – Count Visits per Subject*/

proc sql;
	create table task1 as select
    usubjid,
	count(visit) as TOTAL_VISITS
	from day9_visits
	group by usubjid
	having visitdt = max(visitdt);
quit;

/*TASK 2 – Identify First Visit Date per Subject*/

proc sql;
	create table task2 as select
	usubjid,visitdt as FIRST_VISITDT
	from day9_visits
	group by usubjid
	having visitdt = min(visitdt);
quit;

/*TASK 3 – Identify Last Visit Date per Subject/*/

proc sql;
	create table task3 as select
	usubjid, visitdt as LAST_VISITDT
	from day9_visits
	group by usubjid
	having visitdt = max(visitdt);
quit;

/*TASK 4 – Calculate Gap Between Visits*/

proc sql;
    create table visit_gap as
    select  a.studyid,
            a.usubjid,
            a.visit,
            a.visitdt,
            b.visitdt as prev_visitdt,
            (a.visitdt - b.visitdt) as gap_days
    from day9_visits as a
    left join day9_visits as b
        on  a.usubjid = b.usubjid
        and a.visit   = b.visit + 1
    order by a.usubjid, a.visit;
quit;
	
/*TASK 5 – Identify Large Visit Gaps*/

/*by datastep*/
data task5;
	set visit_gap;
	if gap_days > 7 then GAP_FL = 'Y';
	else GAP_FL = 'N';
run;

/*by sql*/
proc sql;
    create table visit_gap_flag as
    select *,
           case 
               when gap_days > 7 then 'Y'
               else 'N'
           end as gap_fl
    from visit_gap;
quit; 

/*TASK 6 – Find Subjects with Any Gap > 10 Days*/

proc sql;
    create table task6 as
    select *
    from
    (
        select a.usubjid,
               (a.visitdt - b.visitdt) as gap_days
        from day9_visits as a
        left join day9_visits as b
            on a.usubjid = b.usubjid
            and a.visit   = b.visit + 1
    )
    where gap_days > 10;
quit;
