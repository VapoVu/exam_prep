/*Chapter 8 - descriptive stats*/
data work.person;
   input name $ Gender $ x1 x2 x3;
   datalines;
John M 23 44 123
Liz F 31 23 312
John M 41 44 127
Liz F 51 25 312
John M 23 67 123
Liz F 33 22 312
Lisa F 27 54 123
Lisa F 38 25 317
;
run;

/*by default we get n, mean, std dev min max*/
proc means data=work.person;
	var x1 x2;
run;

/*what happens if we use a text variable?*/
proc means data=work.person;
	var name;
run;

/*override the default statistics - show clm (confidence interval for mean), median and max*/
proc means data=work.person clm median max maxdec=3;
	var x1 x2;
run;

/*use class to show descriptive stats by Name*/
proc means data=work.person clm median max maxdec=3;
	var x1 x2;
	class name;
run;

/*use class to show descriptive stats by Gender & Name*/
proc means data=work.person clm median max maxdec=3;
	var x1 x2;
	class gender name;
run;

/*This causes an error - check the log for detail*/
proc means data=work.person clm median max maxdec=3;
	var x1 x2;
	by gender name;
run;

/*This will work - first SORT on name, then use BY*/
proc sort data=work.person;
	by gender name;
run;
proc means data=work.person clm median max maxdec=3;
	var x1 x2;
	by gender name;
run;

/*Save the results of PROC MEANS to output using an "output out=" statement*/
/*The noprint option supresses printing - otherwise we get BOTH the print output*/
/*and the output to a dataset*/
proc means data=work.person clm median max maxdec=3 noprint;
	output out=meansOutput;
	var x1 x2;
	by gender name;
run;
proc print data=meansOutput;
run;

/*PROC SUMMARY is similar to proc means*/
/*When we try to run this we get the following error:*/
/*	ERROR: Neither the PRINT option nor a valid output statement has been given.*/
proc summary data=work.person clm median max maxdec=3;
	var x1 x2;
	by gender name;
run;

/*We add the print option:*/
proc summary data=work.person clm median max maxdec=3 print;
	var x1 x2;
	by gender name;
run;

/*Or the "output out=" statement:*/
proc summary data=work.person clm median max maxdec=3 noprint;
	output out=summaryOutput;
	var x1 x2;
	by gender name;
run;

/*PROC FREQ*/
/*by default produces frequency table for each variable*/
proc freq data=work.person;
run;

/*Using var does not work*/
proc freq data=work.person;
	var name x1;
run;

/*Instead, use "tables"*/
proc freq data=work.person;
	tables x1-x3;
run;
proc freq data=work.person;
	tables name;
run;

proc freq data=work.person;
	tables name /nocum nopercent ;
run;

/*Create bins with format*/
proc format;
	value agefmt 	low-19='Young'
					20-<30='Twenties'
					30-<30='Thirties'
					40-<50='Forties'
					50-High='Fifty+';
run;
/*two-way table*/
/*first variable (x1) will show up as table rows*/
/*second variable (gender) will show up as table columns*/
proc freq data=work.person;
	tables x1*gender;
	format x1 agefmt.;
run;
/*three-way table*/
/*first variable (gender) will show up as separate tables*/
/*second variable (x1) will show up as table rows*/
/*second variable (x2) will show up as table columns*/
proc freq data=work.person;
	tables gender*x1*x2;
	format x1 agefmt. x2 agefmt.;
run;

/*Using the list option, we get one combination of all three levels in each row*/
proc freq data=work.person;
	tables gender*x1*x2 /list;
	format x1 agefmt. x2 agefmt.;
run;
