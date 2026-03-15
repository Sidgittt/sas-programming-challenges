data day11_dm;
    infile datalines dlm='|' dsd truncover;
	  length usubjid $10.;
    input studyid $ usubjid $ sex $ age;
datalines;
ABC101|ABC101-001|M|45
ABC101|ABC101-002|F|50
ABC101|ABC101-003|M|39
ABC101|ABC101-004|F|60
;
run;

data day11_ex;
    format exstdt date9.;
	length usubjid $10.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ exstdt :date9. dose;
datalines;
ABC101|ABC101-001|01JAN2024|100
ABC101|ABC101-001|02JAN2024|100
ABC101|ABC101-002|03JAN2024|200
ABC101|ABC101-005|05JAN2024|150
;
run;

data day11_ae;
    format aestdt date9.;
	length usubjid $10.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ aestdt :date9. aeterm $;
datalines;
ABC101|ABC101-001|02JAN2024|HEADACHE
ABC101|ABC101-003|04JAN2024|NAUSEA
ABC101|ABC101-006|06JAN2024|FEVER
;
run;

/*TASK 1 – Create Safety Population (Subjects with Any Exposure)*/

proc sql;
    create table task1 as
    select distinct
           studyid,
           usubjid,
           'Y' as saffl length=1
    from day11_ex;
quit;

/*TASK 2 – Identify Subjects in DM but Not in EX*/

proc sql;
	create table task2 as
	select *
	from day11_dm as a
	where usubjid NOT IN (select usubjid from day11_ex);
quit;

/*TASK 3 – Identify Subjects in EX but Not in DM*/

proc sql;
	create table task3 as
	select studyid, usubjid
	from day11_ex
	where usubjid NOT IN (select usubjid from day11_dm);
quit;

/*TASK 4 – Create Exposure Summary per Subject*/

proc sql;
    create table task4 as
    select studyid,
           usubjid,
           sum(dose)      as total_dose,
           count(*)       as n_exposure,
           min(exstdt)    as first_exdt format=date9.,
           max(exstdt)    as last_exdt  format=date9.
    from day11_ex
    group by studyid, usubjid;
quit;


/*TASK 5 – Create AE Flag in DM*/

proc sql;
    create table task5 as
    select  d.studyid,
            d.usubjid,
            case 
                when a.usubjid is not null then 'Y'
                else 'N'
            end as aefl length=1

    from day11_dm as d
    left join
         (select distinct usubjid from day11_ae) as a
    on d.usubjid = a.usubjid;
quit;


/*TASK 6 – Subjects Having AE but No Exposure*/

proc sql;
	create table task6 as
	select studyid,
		   usubjid
	from day11_ae
	where usubjid not in (select usubjid from day11_ex);
quit;

/*TASK 7 – Create Combined Subject Status Dataset*/
/*m: master dataset*/

proc sql;
	create table task7 as
	select m.studyid,
		   m.usubjid, 
		   case when d.usubjid is not null then 'Y'
		   else 'N'
		   end as in_dm length = 1,
		   case when a.usubjid is not null then 'Y'
		   else 'N'
		   end as in_ae length = 1,
		   case when e.usubjid is not null then 'Y'
		   else 'N'
		   end as in_ex length = 1

	from 
		(select studyid, usubjid from day11_dm
		 union
		 select studyid, usubjid from day11_ae
		 union
		 select studyid, usubjid from day11_ex) as m

	left join day11_dm as d
		on d.usubjid = m.usubjid
	left join day11_ae as a
		on a.usubjid = m.usubjid
	left join day11_ex as e
		on e.usubjid = m.usubjid
	order by m.usubjid;
quit;

/*Task 8 - subjects whose AE occurred before first exposure date*/

proc sql;
    create table task8 as
    select distinct a.studyid,
           		    a.usubjid
    from day11_ae as a
    inner join
         (select usubjid,
                 min(exstdt) as first_exdt
          from day11_ex
          group by usubjid) as e
    on a.usubjid = e.usubjid
    where a.aestdt < e.first_exdt;
quit;

