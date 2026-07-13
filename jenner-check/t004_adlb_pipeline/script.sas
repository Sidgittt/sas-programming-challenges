data day7_dm;
    format trtsdt date9.;
	length usubjid $10.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ trtsdt :date9.;
datalines;
ABC101|ABC101-001|05JAN2024
ABC101|ABC101-002|10JAN2024
ABC101|ABC101-003|08JAN2024
;
run;

data day7_labs_raw;
    format labdt date9. loadts datetime20.;
	length usubjid $10.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ visit labdt :date9.
          paramcd $ aval loadts :datetime20.;
datalines;
ABC101|ABC101-001|1|01JAN2024|ALT|30|01JAN2024:08:00:00
ABC101|ABC101-001|1|01JAN2024|ALT|30|01JAN2024:08:00:00
ABC101|ABC101-001|2|05JAN2024|ALT|35|05JAN2024:09:00:00
ABC101|ABC101-001|3|10JAN2024|ALT|40|10JAN2024:10:00:00
ABC101|ABC101-002|1|05JAN2024|ALT|25|05JAN2024:11:00:00
ABC101|ABC101-002|2|10JAN2024|ALT|28|10JAN2024:12:00:00
ABC101|ABC101-002|3|15JAN2024|ALT|32|15JAN2024:13:00:00
ABC101|ABC101-003|1|05JAN2024|ALT|.|05JAN2024:09:00:00
ABC101|ABC101-003|2|08JAN2024|ALT|50|08JAN2024:10:00:00
ABC101|ABC101-003|3|12JAN2024|ALT|55|12JAN2024:11:00:00
;
run;

/*TASK 1 – Remove Exact Duplicates*/

proc sort data = day7_labs_raw noduprecs out = task1;
by usubjid;run;

/*TASK 2 – Merge Treatment Start Date*/

proc sort data= day7_dm; by usubjid;run;
proc sort data= task1; by usubjid;run;

Data Task2;
	merge day7_dm (in = a)
		  task1 (in = b);
	by usubjid;
	if a and b;
run;

/*TASK 3 – Derive ADT and ADY*/

Data task3;
	set Task2;
	format ADT date9.;
	ADT = labdt;
	if ADT > trtsdt then ADY = ADT - trtsdt +1;
	else ADY = trtsdt - ADT;
run;

/*TASK 4 – Identify Baseline Record*/

proc sort data = task3; by usubjid labdt; run;

data task4;	
	set task3;
	if ADT < trtsdt then baseline = 'Y';
	else baseline = 'N';
run;

/*TASK 5 – Create BASE Variable*/

proc sort data = task4; by usubjid; run;

data task5;
	set task4;
	by usubjid; 
	if baseline = 'Y' then BASE = aval;
	retain BASE;
run;

/*TASK 6 – Derive CHG*/

data task6;
	set task5;
	CHG = aval - BASE;
run;

/*TASK 7 – Derive PCHG*/

data task7;
	set task6;
	PCHG = (CHG/BASE)*100;
run;

/*TASK 8 – Create Final Dataset*/

data DAY7_ADLB;
	set task7;
keep 
STUDYID
USUBJID
VISIT
ADT
ADY
PARAMCD
AVAL
BASE
BASEFL
CHG
PCHG;
run;
