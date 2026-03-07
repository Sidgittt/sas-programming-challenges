data day5_dm;
    format trtsdt date9.;
	length usubjid $10.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ trtsdt :date9.;
datalines;
ABC101|ABC101-001|05JAN2024
ABC101|ABC101-002|10JAN2024
ABC101|ABC101-003|15JAN2024
;
run;

data day5_labs;
    format labdt date9.;
	length usubjid $10.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ labdt :date9. labval;
datalines;
ABC101|ABC101-001|01JAN2024|10
ABC101|ABC101-001|05JAN2024|15
ABC101|ABC101-001|08JAN2024|20
ABC101|ABC101-002|05JAN2024|25
ABC101|ABC101-002|10JAN2024|30
ABC101|ABC101-002|15JAN2024|35
ABC101|ABC101-003|10JAN2024|40
ABC101|ABC101-003|15JAN2024|45
ABC101|ABC101-003|20JAN2024|50
;
run;

/*Task 1 – Merge TRTSDT into Lab Dataset*/

proc sort data = day5_dm; by usubjid; run;
proc sort data = day5_labs; by usubjid; run;

data dm_labs;
	merge day5_dm
		  day5_labs;
	by usubjid;
run;

/*Task 2 – Create Analysis Date (ADT)*/

data ADT;
	set dm_labs;
	format adt date9.;
	adt = labdt;
run;
 
/*Task 3 – Create Analysis Day (ADY)*/

data ADY;
	set ADT;
	if adt > trtsdt then ady = adt - trtsdt +1;
	else ady = trtsdt - adt;
run;


/*Task 4 – Create Pre/Post Treatment Flag*/
 
proc sort data = ADY; by usubjid adt; run;

/*myapproach which is wrong completely since first and last logic is incorrect*/
data task4;
	set ADY;
	by usubjid adt;
	if first.usubjid and ady ^ = . then preflag = 'Y' ;
	if last.usubjid and ady ^ = . then postflag = 'Y';
run; 

/*chatgpt*/
data task4;
	set ADY;
	if adt > trtsdt then trtfl = 'Post';
		else if adt < trtsdt then trtfl = 'Pre';
		else if adt = trtsdt then trtfl = 'trtsdt';
run;

/*Task 5 – Create Baseline Flag*/
proc sort data=task4 out=ady_sorted;
    by usubjid adt;
run;

/* Step 1: Find the final last_pretrt_adt per subject */
data last_pre;
    set ady_sorted;
    by usubjid;
	format last_pretrt_adt DATE9.;
    retain last_pretrt_adt;

    if first.usubjid then last_pretrt_adt = .;

    if adt <= trtsdt then last_pretrt_adt = adt;

    if last.usubjid then output;

    keep usubjid last_pretrt_adt;
run;

/* Step 2: Merge back and assign BASEFL */
data baseline_flag;
    merge ady_sorted 
		  last_pre;
    by usubjid;

    length basefl $1;

    if adt = last_pretrt_adt then basefl='Y';
    else basefl='';
run;
