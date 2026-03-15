data day10_labs;
    format labdt date9.;
	length usubjid $10.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ paramcd $ labdt :date9. aval;
datalines;
ABC101|ABC101-001|ALT|01JAN2024|30
ABC101|ABC101-001|ALT|05JAN2024|35
ABC101|ABC101-001|ALT|10JAN2024|40
ABC101|ABC101-001|AST|02JAN2024|50
ABC101|ABC101-001|AST|12JAN2024|55
ABC101|ABC101-002|ALT|03JAN2024|20
ABC101|ABC101-002|ALT|08JAN2024|25
ABC101|ABC101-002|AST|04JAN2024|45
ABC101|ABC101-003|ALT|06JAN2024|60
ABC101|ABC101-003|AST|07JAN2024|65
ABC101|ABC101-003|AST|15JAN2024|70
;
run;


/*TASK 1 – Latest Lab Record per Subject and Parameter*/

proc sql;
	create table task1 as 
	select usubjid, 
		   labdt as latest_labdt,
		   paramcd as latest_paramcd,
		   aval 
	from day10_labs
	group by usubjid
	having labdt = max(labdt);
quit;

/*TASK 2 – Highest Lab Value per Subject and Parameter*/

proc sql;
	create table task2 as
	select *,
		   aval as highest_lab_value
	from day10_labs
	group by usubjid, paramcd
	having aval = max(aval);
quit;

/*TASK 3 – Records Where Lab Value Equals Subject-Parameter Maximum*/

proc sql;
    create table task3 as
    select *
    from day10_labs as a
    where aval =
        (
          select max(aval)
          from day10_labs as b
          where a.usubjid = b.usubjid and a.paramcd = b.paramcd
        );
quit;

/*TASK 4 – Count Number of Lab Tests per Subject*/

proc sql;
	create table task4 as 
	select distinct usubjid,
		   count(paramcd) as N_TESTS
	from day10_labs
	group by usubjid;
quit;

/*TASK 5 – Subjects Who Had ALT Test After AST Test*/

proc sql;
    create table task5 as
    select distinct a.usubjid, 
    from day10_labs as a
    inner join day10_labs as b
         on a.usubjid = b.usubjid
    where a.paramcd = 'ALT' and 
		  b.paramcd = 'AST' and
          a.labdt  > b.labdt;
quit;

/*TASK 6 – First Lab Date per Subject*/

proc sql;
	create table task6 as 	
	select *,
		   labdt as FIRST_LABDT
	from day10_labs
	group by usubjid, paramcd
	having labdt = min(labdt);
quit;

/*TASK 7 – Subjects Whose All Lab Values Are Above 25*/

proc sql;
	create table task7 as
	select distinct usubjid
	from day10_labs
	where aval > 25
	order by usubjid;
quit;

/*TASK 8 – subjects whose latest lab value is also their maximum value*/

proc sql;
	create table task8 as 
	select usubjid,
		   labdt,
		   paramcd,  
		   max(aval) as max_aval
	from day10_labs
	group by usubjid, paramcd
	having labdt = max(labdt);
quit;
