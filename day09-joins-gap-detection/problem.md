Day 9 – Joins, Self-Joins and Gap Detection

Objective:
Understand how to compare rows within the same subject and detect gaps in visit dates.

Tasks:
1. Count Visits per Subject
2. Identify First Visit Date per Subject
3. Identify Last Visit Date per Subject  
4. Calculate Gap Between Visits
5. Identify Large Visit Gaps
6. Find Subjects with Any Gap > 10 Days
7. Identify Consecutive Visits Missing

Datasets:

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
