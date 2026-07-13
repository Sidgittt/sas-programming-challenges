data day6_vitals_wide;
    format visitdt date9.;
	length usubjid $10.;
    infile datalines dlm='|' dsd truncover;
    input studyid $ usubjid $ visit visitdt :date9.
          sysbp diabp pulse temp resp;
datalines;
ABC101|ABC101-001|1|01JAN2024|120|80|70|36.5|18
ABC101|ABC101-001|2|10JAN2024|125|82|72|36.7|19
ABC101|ABC101-002|1|03JAN2024|130|85|75|37.0|20
ABC101|ABC101-002|2|15JAN2024|128|84|74|36.8|18
ABC101|ABC101-003|1|05JAN2024|.|90|80|37.2|22
ABC101|ABC101-003|2|20JAN2024|135|88|78|.|21
;
run;

/*Task 1 – Convert Wide to Long using ARRAY*/

data vitals_long;
    set day6_vitals_wide;

    array vals{5} sysbp diabp pulse temp resp;
    array names{5} $8 _temporary_ ('SYSBP','DIABP','PULSE','TEMP','RESP');

    do i = 1 to 5;
        paramcd = names{i};
        aval    = vals{i};
        output;
    end;

    keep studyid usubjid visit visitdt paramcd aval;
run;

/*with proc transpose*/
proc sort data = day6_vitals_wide;
	by studyid usubjid visit visitdt;
run;

proc transpose data = day6_vitals_wide out = task1(rename=(col1=aval _name_=paramcd));
	by studyid usubjid visit visitdt;
	var sysbp diabp pulse temp resp;
run;


/*Task 2 – Replace Missing Values with -999 using ARRAY*/


data task2;
	set vitals_long;

	array v aval;

	do i = 1 to dim(v);	
		if v[i] = . then v[i] = -999;
	end;

	drop i;
run;

/*Task 3 – Count Number of Non-Missing Vital Signs per Record*/

proc sort data = task2; by usubjid paramcd visitdt;run;

data task3;
    set day6_vitals_wide;

    array vals{5} sysbp diabp pulse temp resp;

    nonmiss_count = 0;

    do i = 1 to 5;
        if not missing(vals{i}) then nonmiss_count + 1;
    end;

    drop i;
run;
	

/*Task 4 – Calculate Average of All Vital Signs per Record*/

data task4;
    set day6_vitals_wide;

    array vals{5} sysbp diabp pulse temp resp;

    sum_vals = 0;
    count_vals = 0;

    do i = 1 to 5;
        if not missing(vals{i}) then do;
            sum_vals + vals{i};
            count_vals + 1;
        end;
    end;

    if count_vals > 0 then avg_vitals = sum_vals / count_vals;
    else avg_vitals = .;

    drop i sum_vals count_vals;
run; 


/*Task5:Convert LONG to WIDE using ARRAY*/

proc sort data=vitals_long;
    by studyid usubjid visit;
run;

data Task5;
    set vitals_long;
    by studyid usubjid visit;

    array vitals[5] sysbp diabp pulse temp resp;

    if first.visit then call missing(of vitals[*]);

    select (paramcd);
        when ('SYSBP') vitals[1] = aval;
        when ('DIABP') vitals[2] = aval;
        when ('PULSE') vitals[3] = aval;
        when ('TEMP')  vitals[4] = aval;
        when ('RESP')  vitals[5] = aval;
        otherwise;
    end;

    if last.visit then output;

    keep studyid usubjid visit visitdt 
         sysbp diabp pulse temp resp;
run;
