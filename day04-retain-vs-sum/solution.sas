data day4_dose;
    format dosedt date9.;
	length usubjid $10.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid dosedt :date9. dose;
datalines;
ABC101|ABC101-001|01JAN2024|100
ABC101|ABC101-001|02JAN2024|100
ABC101|ABC101-001|03JAN2024|.
ABC101|ABC101-001|04JAN2024|150
ABC101|ABC101-002|01JAN2024|200
ABC101|ABC101-002|02JAN2024|.
ABC101|ABC101-002|03JAN2024|200
ABC101|ABC101-003|01JAN2024|.
ABC101|ABC101-003|02JAN2024|300
;
run;

/*Task 1 – Cumulative Dose using RETAIN*/

proc sort data = day4_dose out= day4_sorted; 
	by studyid usubjid dosedt;
run;

/*Total cumulative*/
data task1;
	set day4_sorted;
	by studyid usubjid dosedt;
	retain dose_cum;
	if first.studyid then dose_cum = dose;
	else dose_cum + dose;
run;

/*Total cumulative per usubjid*/

proc sort data = day4_dose out= day4_sorted; 
	by usubjid dosedt;
run;

data task1;
	set day4_sorted;
	by usubjid dosedt;
	retain dose_cum;
	if first.usubjid then dose_cum = dose;
	else dose_cum + dose;
run;

/*Task 2 – Cumulative Dose using SUM Statement*/

proc sort data = day4_dose out= day4_sorted; 
	by usubjid dosedt;
run;

data task2;
	set day4_sorted;
	by usubjid dosedt;
	if first.usubjid then dose_cum = 0;
	dose_cum + dose;
run;

/*Task 3 – Carry Forward Last Non-Missing Dose (LOCF)*/

proc sort data = day4_dose out = day4_sorted;
	by usubjid dosedt;
run;

data task3;
    set day4_sorted;
    by usubjid dosedt;

    retain locf;

    if first.usubjid then locf = .;

    if not missing(dose) then locf = dose;
    else dose = locf;
run;

/*or*/
proc sort data = day4_dose out = day4_sorted;
	by usubjid dosedt;
run;


data locf_dose;
    set day4_sorted;
    by usubjid dosedt;

    retain last_dose;

    if first.usubjid then last_dose = .;

    if not missing(dose) then last_dose = dose;

    locf_dose = last_dose;
run;

/*Task 4 – Count Non Missing Dose Records per Subject*/

proc sort data = Day4_dose out = Day4_sorted;
	by usubjid dosedt;
run;

data TOTAL_DOSE(keep=usubjid nmcount)
	 LAST_NONMISS_DOSE(keep=usubjid nmcount)
	 FIRST_NONMISS_DOSE(keep=usubjid nmcount);
    set day4_sorted;
    by usubjid dosedt;

    if first.usubjid then nmcount=0;

    if not missing(dose) then nmcount+1;

    if last.usubjid then output LAST_NONMISS_DOSE;
    if first.usubjid then output FIRST_NONMISS_DOSE;
	else output TOTAL_DOSE;
run;
