data day8_sales;
    format saledt date9.;
    infile datalines dlm='|' dsd truncover;
    input region $ salesperson $ saledt :date9. amount;
datalines;
North|Amit|01JAN2024|100
North|Amit|05JAN2024|200
North|Amit|10JAN2024|150
North|Ravi|03JAN2024|300
North|Ravi|08JAN2024|100
South|Kiran|02JAN2024|400
South|Kiran|06JAN2024|200
South|Meera|04JAN2024|250
South|Meera|09JAN2024|300
;
run;

data day8_emp;
    infile datalines dlm='|' dsd truncover;
    input salesperson $ region $ join_year;
datalines;
Amit|North|2020
Ravi|North|2021
Kiran|South|2019
Meera|South|2022
;
run;

/*merge */

proc sort data = day8_sales; by salesperson region; run;
proc sort data = day8_emp; by salesperson region; run;

data day8_emp_sales;
	merge day8_emp 
		  day8_sales;
	by salesperson region;
run;

/*Task1: Total Sales per Salesperson*/

proc sql;
	create table task1 as select salesperson, region,
	sum(amount) as Total_Sales
	from day8_emp_sales
	group by salesperson
	having saledt = max(saledt);
quit;

/*TASK 2 – Highest Sale per Region*/

proc sort data = task1; by region; run;

proc sql;
	create table task2 as select Region,
	max(Total_Sales) as Max_count
	from task1
	group by Region;
quit;

/*TASK 3 – Salespersons with Total Sales > Regional Average*/

proc sql;
	create table ABOVE_AVG as select Region,salesperson,
	sum(amount) as Total_Sales,
	mean(amount) as REGION_AVG
	from day8_emp_sales
	group by salesperson, Region;
quit;

/*TASK 4 – Second Highest Sale Amount per Region (Single Sale, Not Total)*/

proc sql;
	create table task4 as select region,
	max(amount) as SECOND_HIGHEST_AMOUNT
	from day8_emp_sales s1
	where amount < (
		select max(amount)
		from day8_emp_sales s2
		where s1.region = s2.region
	)
	group by region;
run;

/*TASK 5 – Latest Sale Date per Salesperson*/

/*Trick to remember the code logic*/
/*WHERE date = (
		SELECT MAX(date) 
		FROM same_table 
		WHERE group matches)*/

proc sql;
	create table task5 as 
	select salesperson,
		   saledt as LAST_SALEDT,
		   amount as LAST_SALE_AMOUNT
	from day8_emp_sales s1
	where saledt = (
		select max(saledt)
		from day8_emp_sales s2
		where s1.salesperson = s2.salesperson
		);
quit;	

/*TASK 6 – Join EMP Dataset*/

proc sql;
    create table sales_with_tenure as
    select  s.salesperson,
            s.region,
            sum(s.amount) as total_sales,
            e.join_year,
            (2024 - e.join_year) as tenure
    from day8_sales s
    left join day8_emp e
        on s.salesperson = e.salesperson
    group by s.salesperson, s.region, e.join_year;
quit;

/*TASK 7 – Identify Salespersons Who Never Had a Sale Above 300*/

proc sql;
	create table task7 as 
	select
	distinct salesperson
	from day8_sales
	where salesperson not in (
		select distinct salesperson
		from day8_sales
		where amount > 300);
quit;
