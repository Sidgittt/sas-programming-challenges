data day3_labs;
	length usubjid $12.;
    format labdt date9.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ labdt :date9. labval;
datalines;
ABC101|ABC101-001|01JAN2024|10
ABC101|ABC101-001|05JAN2024|15
ABC101|ABC101-001|10JAN2024|20
ABC101|ABC101-002|02JAN2024|5
ABC101|ABC101-002|06JAN2024|10
ABC101|ABC101-002|12JAN2024|15
ABC101|ABC101-003|03JAN2024|25
ABC101|ABC101-003|08JAN2024|30
;
run;


/*Task 1 – Running Total per Subject (RETAIN Method)*/

proc sort data = day3_labs; by usubjid; run;

data task1;
	set day3_labs;
	by usubjid;	
	retain labval;
	if first.usubjid then Run_tot = labval;
	else Run_tot + labval;
run;

/*Task 2 – Running Total using SUM Statement*/

proc sort data = day3_labs; by usubjid labdt; run;

data task2;
	set day3_labs;
	Run_Tot_Sum + labval;
run;

/*Task 3 – Running Average per Subject*/

proc sort data=day3_labs out=day3_sorted;
    by usubjid labdt;
run;

data running_avg;
    set day3_sorted;
    by usubjid labdt;

    retain sum_lab count_lab;

    if first.usubjid then do;
        sum_lab = labval;
        count_lab = 1;
    end;
    else do;
        sum_lab + labval;
        count_lab + 1;
    end;

    run_avg = sum_lab / count_lab;
run;

/*Task 4 – Baseline Flag Creation (Clinical Standard)*/

proc sort data=day3_labs out=day3_sorted;
    by usubjid labdt;
run;

data task4;
	set day3_sorted;
	length BASELINE_FL $1. BASEVAL $4.;
    by usubjid labdt;
	retain BASEVAL;
	if first.usubjid then do;
		BASELINE_FL = 'Y';
		BASEVAL = labval;
	end;
	else BASELINE_FL = 'N';
run;

/*Task 5 – Change from Baseline*/

proc sort data=day3_labs out=day3_sorted;
    by usubjid labdt;
run;

data task5;
	set day3_sorted;
    by usubjid labdt;
	retain blvl;
	if first.usubjid then blvl = labval;
	chg = labval - blvl;
run;


