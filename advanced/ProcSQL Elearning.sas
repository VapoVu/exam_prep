libname orion 'C:\Users\LukasHalim\Documents\My SAS Files\9.3';

/*
proc sql can read 
	sas data sets
	sas data views - receives code that retrieves sas data from other files
	dbms files
sql sql makes report by default, but can also create sas data sets or dbms table

proc sql is a compliment to the data step
	It can reduce the amount of coding you need to do
	Data step is necessary for reading raw text files
	Data step gives you more control
	Proc SQL creates a report by default, whereas the DATA step creates sas data set

In PROC SQL, you can include SAS enhancements, such as the ODS statement, 
that go beyond the ANSI standard

PROC SQL runs until it hits a QUIT statement, or a data or proc step

PROC SQL SELECT
	requires SELECT <col list> and FROM <table list>
	So Few Workers Go Home On-time - select from group having order by
	may have group by, having, and order by
	ORDER BY can sort within PROC SQL, so you don't need a separate PROC SORT
	Proc SQL processor determines most efficient way to run queries
*/

/*each select statement generates a report*/
proc sql ;
	select employee_id, employee_gender, salary 
		from orion.employee_payroll;
	select job_title, salary 
		from orion.staff;
quit;

/*output goes to the LOG, whereas proc contents would write a report*/
proc sql;
	describe table orion.employee_payroll;
quit;

/*use astericks to select all columns*/
/*the feedback option causes an expanded version of the query will be printed to the log*/
/*expanded version will contain TABLE_NAME.COLUMN_NAME for every column in the query*/
proc sql feedback;
	select * 
		from orion.employee_Payroll;
quit;

/*distinct keyword applies to all columns in select clause*/
/*unique is not ANSI standard, but in PROC SQL you can use it instead of distinct*/
proc sql;
	select distinct department
		from orion.employee_organization;
quit;

proc sql;
	select employee_id, job_title, salary
		from orion.staff
		where salary + bonus > 112000;
run;

/*
logical operations
	or |
	and &
	not ^ ¬
*/

/*
LIKE works with % for multiple characters and _ for a single character
You can escape the _ and % characters using the syntax below
The _ is treated as a literal, % is treated as 
*/
proc sql;
	select job_code
		from orion.employee_organization2
		where Job_code like 'SA/_%' escape '/';
quit;

/*one way to use the case expression*/
proc sql;
	select job_title,
/*		Using the space delimeter, take the right most word using scan*/
		case scan(job_title,-1,' ')
/*		determine the salary multiplier*/
			when 'I' then salary * .05
			when 'II' then salary * .07
			when 'III' then salary * .10
			when 'IV' then salary * .12
			else Salary*.08
		end as Bonus
		from orion.staff;
run;

/*second way to use the case function*/
proc sql;
	select job_title,
/*		Using the space delimeter, take the right most word using scan*/
		case 
/*		determine the salary multiplier*/
			when scan(job_title,-1,' ')='I' then salary * .05
			when scan(job_title,-1,' ')='II' then salary * .07
			when scan(job_title,-1,' ')='III' then salary * .10
			when scan(job_title,-1,' ')='IV' then salary * .12
			else Salary*.08
		end as Bonus
		from orion.staff;
quit;

/*This won't work*/
/*Log states - ERROR: The following columns were not found in the contributing tables: bonus.*/
PROC SQL;
	select salary * .10 as bonus
		from orion.staff
		where bonus < 3000;
quit;

/*this does work now that we put in the keyword "calculated" */
PROC SQL;
	select salary * .10 as bonus, calculated bonus / 2 as halfbonus 
		from orion.staff
		where calculated bonus < 3000;
quit;

/*using label= to set a column label*/
PROC SQL;
	select employee_id label='Employee Identifier'
		from orion.staff;
quit;

/*using format*/
PROC SQL;
	select "salary is: ", salary format=comma12.2, 25 as constant_number, 'constant text' label='Constant Text',
		"double quote constant text"
		from orion.employee_payroll;
quit;

/*flow=n m will set to at least n characters and at most m characters */
/*flow defaults to n=12 and m=200*/
PROC SQL number flow=6 10;
	select *
		from orion.staff;
quit;

/*double or nodouble defines line spacing for an output destination that has a physical*/
/*page limitiation*/
PROC SQL outobs=25 ;
	select *
		from orion.staff;
quit;

PROC SQL noprint;
	select *
		from orion.staff;
quit;

/*
Output Fromatting Options
You can use the LABEL= column modifier, or the ANSI column modifier, or both within the same SELECT clause.
 	 		
The RESET statement enables you to add, drop, or change the options in the PROC SQL step without restarting the procedure.
 	
The FLOW option affects output destinations with a physical page limitation.
	
The OUTOBS= option restricts the number of rows that a query outputs to a report or writes to a table.
	
The NONUMBER options controls whether the SELECT statement includes a column that displays row numbers as the first column of query output in the Output window or HTML output.
*/

/*HAVING can reference a summary function ex: count(*) or an alias created by a summary function*/

/*count(column) counts NONMISSING values only*/

/*ANSI and SAS SQL Difference:
Unlike most SAS summary functions, ANSI summary functions can take only a single argument.*/
proc sql;
	select count(*) as Count_Excluding_Missing_Qtr1,count(Qtr1) as CountAll from
		orion.employee_donations;
quit;

/*this does not cause an error.  HireMonth can be in the group by clause b/c it is not created
by a summary function */
proc sql;
	select Dependents,month(Employee_Hire_Date) as HireMonth, avg(Salary) as averageSalary
		from orion.employee_payroll
		group by HireMonth;
quit;

/*this does, because averageSalary IS created by a summary function*/
/*ERROR: Summary functions are restricted to the SELECT and HAVING clauses only.*/
proc sql;
	select Dependents, avg(Salary) as averageSalary
		from orion.employee_payroll
		group by averageSalary;
quit;

/*it doesn't work even when you add the "calculated" keyword*/
proc sql;
	select Dependents, avg(Salary) as averageSalary
		from orion.employee_payroll
		group by calculated averageSalary;
quit;

/*Subqueries - innermost subqueries are evaluated first*/
/*Noncorrelated subquery */
/*Correlated subquery*/
/*	requires one or more values to be passed to it before the subquery can return a value*/

/*This is an example of a correlated subquery*/
/*because the inner query references a value found*/
/*in the outer query*/
/*correlated subqueries cannot be run on their own*/
/*Joins are usually more efficient than correlated subqueries*/
proc sql;
	select Employee_ID, avg(salary) as MeanSalary
		from orion.employee_payroll as supervisors
		where 'AU'=
			(select Country
				from orion.employee_addresses
				where employee_addresses.Employee_id=supervisors.Employee_id);
quit;

/*you can use a subquery wherever you can use a column value*/
/*if you are using an operator that expects a single value, the*/
/*subquery must return a single value (ex > or =).  */
proc sql;
	select Job_Title, avg(Salary) as MeanSalary
		from orion.staff
		group by Job_Title
		having avg(Salary) >
			(select avg(Salary) from orion.staff);
quit;

/* *********** JOINS ******************
Proc SQL 
	can join up to 256 tables
	use ORDER BY clause to specify order
	does NOT overlay columns by default
		COALESCE lets you combine values
Data step MERGE
	there is no hard limit to the number of tables you
	can join
	Overlays columns by default
	
OUTER joins include nonmatching rows
INNER joins exclude nonmatching rows
CARTESIAN PRODUCT
	combining every row in every table
	with every row in every other table
	You can use the CROSS JOIN command
	select * from table_one CROSS JOIN table_two
	or just put commas between tables 
	select * from table_one, table_two

Two ways to specify inner join
	FROM <tables> where <join condition>=
	with INNER JOIN <tables> ON <join condition>

FULL JOIN, RIGHT JOIN, LEFT JOIN

IN-LINE VIEW
	An in-line view is a query-expression that is 
	nested in the FROM clause of another query. 
	You enclose the query-expression in parentheses. 
	You can also optionally assign the inline view 
	an alias, just like a table. Also, unlike a 
	standalone SELECT statement, a queryexpression 
	does not end with a semicolon.
	In-line views cannot contain an ORDER BY clause
*/

/* ************* SET OPERATIONS **************** */
/*Set Operations combine tables vertically*/
/* INTERSECT is normally evaluated first */
/*EXCEPT 
	selects rows in table1 that aren't in table2
	matches based on listed columns, or * for all
	ALL - do not begin by eliminating duplicate rows in each table
	CORR will have it match columns by name rather than by position
		if this is used, nonmatching column names won't be included in results
OUTER UNION
	Not required by ANSI standards	
	Different from the other set operators
	By default, doesn't remove columns
	CORR instructs PROC SQL to align any columns that the query results have in common 
		and display columns that have nonmatching names in the result set.
*/

/*  ************** CREAE TABLES & VIEWS **************************
CREATE TABLE table-name AS query-expression;
CREATE VIEW view-name AS query-expression;
	ANSI method for avoiding relationship error
		use just table-name rather than libref.tablename and keep view in same place as table
	SAS enhanced method: using libname <libname> 'path'

/* ***************** MANAGING TABLES ****************************
Indexes helps SAS quickly read only specific rows rather than sequential processing
Speeds up both subsetting (for less than 15% of the table) and joining
options msglevel=i causes log to tell you which index was usd in query
*/
options msglevel=i;
proc sql;
   select Employee_Name, City, State, Country
      from orion.employee_addresses2
      where City in ('Philadelphia','San Diego');
/*INFO: Index Locale selected for WHERE clause optimization.*/
   select Employee_Name, City, State, Country
      from orion.employee_addresses2
      where Country ='US';
   select Employee_Name, City, State, Country
      from orion.employee_addresses2
      where City in ('Philadelphia','San Diego')
            and Country='US';
/*INFO: Index Locale selected for WHERE clause optimization.*/
quit;
options msglevel=n;

/* Add to table rows using:
INSERT INTO table-name SET column=value;
INSERT INTO table-name column-names VALUES(values)
INSERT INTO table-name SELECT columns FROM table-name

DROP TABLE - deletes the table and indexes, but NOT the associated views

DELETE FROM table-name WHERE expression

ALTER TABLE table-name
	ADD column-name column-data-type optional-width
	DROP column-name
	MODIFY column-name column-data-type optional-width
*/

/*   ************ TESTING PROC SQL ***************** */
/*
VALIDATE example
log shows - NOTE: PROC SQL statement has valid syntax.
*/
proc sql;
	validate select Job_Title, avg(Salary) as MeanSalary
		from orion.staff
		group by Job_Title
		having avg(Salary) >
			(select avg(Salary) from orion.staff);
quit;

/* NOEXEC*/
/*log shows - NOTE: Statement not executed due to NOEXEC option.*/
proc sql noexec;
	select Job_Title, avg(Salary) as MeanSalary
		from orion.staff
		group by Job_Title
		having avg(Salary) >
			(select avg(Salary) from orion.staff);
quit;


/*NOERRORSTOP option */
/*	default in interactive mode. */
/*	has an effect only if the EXEC option is also in effect*/
/*ERRORSTOP default in batch & noninteractive mode. */

/*INOBS example limits the number of input rows*/
proc sql inobs=3;
	select Job_Title, avg(Salary) as MeanSalary
		from orion.staff
		group by Job_Title;
quit;

/*OUTOBS example limits the number of output rows*/
proc sql outobs=3;
	select Job_Title, avg(Salary) as MeanSalary
		from orion.staff
		group by Job_Title;
quit;

/*FULLSTIMER example
note: default is STIMER */
options fullstimer;
proc sql;
	select Job_Title, avg(Salary) as MeanSalary
		from orion.staff
		group by Job_Title;
quit;
options nofullstimer;

/*Use CPU time rather than elapsed time
Run each program in a different session
Average several times, excluding outliers */


/*           DICTIONARY TABLES             */
/*tables are stored in special DICTIONARY library*/
/*
SAS creates special read-only dictionary tables 
and views that contain data or metadata about 
each SAS session or batch job. 
You can access the tables using PROC SQL or you 
can use traditional SAS programming to access the 
view.
*/

/*Describe the dictionary.dictionaries table*/
proc sql;
	describe table dictionary.dictionaries;
quit;

/*query dictionary for ORION metadata */
/*Note: sas functions in querying dictionary tables*/
/*degrades performance*/
proc sql;
	select memname, nobs from dictionary.tables 
		where libname="ORION";
quit;

/*Other dictionary tables:*/
/*	dictionaries.views*/
/*	dictionaries.catalogs*/
/*	dictionaries.indexes*/
/*	dictinaries.check_constraints*/
/*	dictinaries.referential_constraints*/
/*	dictionaries.titles*/
/*	dictionaries.macros*/
/*	etc*/

%let myMacroVar=MacroValue;
%let myTableName=employee_payroll
/*note that because of symbolgen, the value of the macro*/
/*is written to the log*/
options SYMBOLGEN;
title "My Title with Macro &MyMacroVar";
proc print data=orion.employee_payroll;
quit;
%put the value of myMacroVar is &myMacroVar;

proc sql;
	select avg(salary)
		into :AvgSalary 
		from orion.employee_payroll;
quit;

%put &AvgSalary;


proc sql;
	select salary
		into :AvgSalary 
		from orion.employee_payroll;
quit;

%put &AvgSalary;

/*Macro names start with letter or underscore. 
Rest can consist of letters, digits, or underscores.
Upper and lowercase allowed. */

/*Output macro variables to the log:*/
/*	%put statement*/
/*	SYMBOLGEN system option*/
/*	FEEDBACK proc sql option*/
