libname orion 'C:\Users\LukasHalim\Documents\My SAS Files\ECMAC1';

/*
When macro variable is assigned, leading and
trailing blanks are removed

The word scanner recognizes four types of tokens: 
literals, names, numerals, and special characters.

The word scanner recognizes the following token 
sequences as macro triggers: a percent sign (%) 
followed immediately by a name token and an 
ampersand (&) followed immediately by a name token.
*/

/*   MACRO FUNCTIONS               
Damta set variables aren't available at run
time, and so cannot be used with macro functions.

Four types: 
	character (%SUBSTR, %SCAN, %UPCASE, %INDEX)
	quoting 
	evaluation
	other
*/

/*runs out of characters, so throws warning*/
%put %substr(&date,3,9);

/*extracts year*/
/*if you don't specify the second number, the */
/*rest of the string is extracted*/
%put %substr(&sysdate,6,4);
%put %substr(&sysdate,6);

/*returns 15*/
%put %eval(%substr(&sysdate,6)+2);

/*warning message b/c can't handle floats*/
/*%EVAL */
/*	does not evaluate non integer expressions. */
/*	evaluates logical expressions as true or false. */
/*	truncates fractional results*/
%put %eval(1.3+2.2);
/*sysevalf handles floats*/
%put %sysevalf(1.3+2.2);

/*SYSFUNC allows you to call SAS functions from macros*/
/*%sysfunc(function(args),format);*/
%put %sysfunc(today());
%put %sysfunc(today(),weekdate.);

/*Macro variables with special characters*/
%let prog = %str(data new; x=1; run;);
%put &prog;
%let prog2 = data new%str(;) x=1%str(;) run%str(;));
%let s=%str(;);
%let prog3 = data new&s x=1&s run&s;

/*need to use % before quotes and parens with str*/
%let text = %str(Master%'s in Analytics); 

/*%nrstr is like %str, but also masks & and %*/
/*Can think of nr as "not resolve & and %"*/

%let a=a very long value;
%let b=%index(&a,v);
%put V appears at position &b..;

/*Creating Maco Variables During Execution Time*/
/*NOTE THAT CALL ALWAYS COMES BEFORE SYMPUTX*/
/*If you put in a third parameter 'G', you create a global variable */
data _null_;
	call symputx('Foot','No Internet Orders');
	%let foot=Some Intenet Orders;
run;
%put &foot;


/* SAMPLE CODE FOR CREATING A SERIES OF VALUES */
data _null_;
	set orion.customer;
	call symputx('Name'||left(customer_id),customer_name);
run;
/*print out one of the names*/
%put &Name45;

/*FORWARD RESCAN RULE
		By preceedig a macro variable with &&, 
		you delay processing until second scan
*/

/*CODE SAMPLE FOR FOWARD RESCAN RULE & SYMPUT
http://www.caliberdt.com/tips/May2006.htm */
data kids;
	input name $ age;
	call symput(name, age);
  datalines;
  Cora 21
  Emma 15
  Hannah 17
  William 23
  ;

  %let who = Hannah;

/*SAMPLE CODE FOR Creating macro variables resulting in multiple rows */
title1 "HOW Example 6b: Creating macro variables resulting in multiple rows";
title2 'Count of males';
title3 'Two part approach: value to save, macro variable names';
proc sql;
	select name as male
		from sashelp.class
		where sex = 'M';

	select name into :male_name separated by ', ' 
		from sashelp.class
		where sex = 'M';
quit;
%put 'Names of Males = ' &male_name;

title 'Creating macro variables from multiple rows';
proc sql;
	select n(distinct name) 
		into :num_students
		from sashelp.class;
	%let num_students=&num_students;
	select distinct name
		into :name1-:name&num_students
		from sashelp.class;
quit;
/*note the use of the double ampersand*/
%put &name1,&name2,&&name&num_students;

/*instead of creating multiple variables, create a comma separated list*/
proc sql;
	select distinct name
		into :names
		separated by ', '
		from sashelp.class;
quit;
%put &names;

/*write to the log the text that is sent to the compiler by macro execution*/
options mprint;
/*default option - don't write to log*/
options nomprint;


/*                 EXAMPLE MACRO PROGRAM                       */
options mcompilenote=all;
%macro customers;
   title "&type Customers";
   proc print data=orion.customer_dim;
      var Customer_Name Customer_Gender Customer_Age;
      where Customer_Group contains "&type";
   run;
   title;
%mend customers;

%let type=Gold;
%customers

%let type=Internet;

options mprint;
%customers

/*MACRO Parameters - positional parameters followed by key=value pairs*/

/*EXAMPLE:    Macro using key=value style paramter                    */
%macro customers(type=Club);
   title "&type Customers"; 
   proc print data=orion.customer_dim;
      var Customer_Name Customer_Gender Customer_Age; 
      where Customer_Group contains "&type"; 
   run; 
   title;
%mend customers;
%customers(type=Internet)
%customers()

/*
Explained in elearning "basic concepts" section of chapter 4
1) When you submit a call to a compiled macro, the macro is executed. 
2) When the macro processor receives the macro call, it searches the default catalog,
   Work.Sasmacr, for the entry corresponding to that macro. 
3) Then it executes any compiled macro language statements within the macro. 
4) When SAS language statements are encountered, the macro processor places these statements 
   onto the input stack and pauses while they are passed to the compiler and then executed. 
5) Then the macro processor continues to repeat these steps until the %MEND statement is reached.
*/

/*Debugging options*/
options MLOGIC MPRINT SYMBOLGEN;
/*
MCOMPILENOTE issues a note to the SAS log after a macro completes 
compilation 
MLOGIC writes messages that trace macro execution to the SAS log 
MPRINT specifies that the text that is sent to the compiler when a 
macro executes is printed in the SAS log 
SYMBOLGEN displays the values of macro variables as they resolve
*/
/*Production options*/
options NoMLOGIC NoMPRINT NoSYMBOLGEN;


/*                 CONDITIONAL PROCESSING EXAMPLE CODE                */
%macro listing(custtype);
   proc print data=orion.customer noobs;
   %if &custtype= %then %do;
      var customer_ID customer_name customer_type_ID;
      title "All Customers";
   %end;
   %else %do;
      where customer_type_id=&custtype;
      var customer_ID customer_name;
      title "Customer Type: &custtype";
   %end;
   run;
%mend listing;
%listing();
%listing(2010);

/*To use the macro IN operator, you must use the MINOPERATOR option with the %MACRO statement*/
%macro custtype(type)/minoperator;
   %let type=%upcase(&type);
   %if &type in GOLD INTERNET %then %do;
       proc print data=orion.customer_dim;
           var customer_group customer_name customer_gender
               customer_age;
           where upcase(customer_group) contains "&type";
           title "&type Customers";
       run;
   %end;
   %else %do;
      %put ERROR: Invalid Type: &type..;
      %put ERROR: Valid Type values are INTERNET or GOLD.;
   %end;
%mend custtype;
%custtype(internet)
%custtype(interet)


/*    CODE SAMPLE FOR GENERATING DATA DEPENDENT STEPS  */
title;
footnote;
%macro tops(obs=3);
   proc means data=orion.order_fact sum nway noprint;
      var total_retail_price;
      class customer_ID;
      output out=customer_freq sum=sum;
   run;

   proc sort data=customer_freq;
      by descending sum;
   run;

   data _null_;
      set customer_freq(obs=&obs);
      call symputx('top'||left(_n_), Customer_ID);
   run;

   proc print data=orion.customer_dim noobs;
      where customer_ID in (%do num=1 %to &obs; 
                            &&top&num %end;);
      var customer_ID customer_name customer_type;
      title "Top &obs Customers";
   run;
%mend tops;
%tops();

/*When using the NOT with the IN operator, NOT must precede the IN expression */
/*and the entire IN expression must be enclosed in parentheses.*/
/*EXAMPLE: %if not (&nvar in AU CA DE US);*/


/*CREATE GLOBAL MACRO VARIABLE*/
/*	use %Global var-name(s);*/


/*STORE THE MACRO IN THE ORION LIBRARY*/
options mstored sasmstore=orion;
%macro autocust /STORE;
   proc print data=orion.customer_dim;
      var customer_name customer_gender customer_age;
      title "Customers Listing as of &systime";      
   run;
%mend autocust;
%autocust;
