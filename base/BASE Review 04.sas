/*CHAPTER 4 - PROC PRINT*/

/*Use the datalines command to create data*/
data work.person;
   input name $ age salary HireDate MMDDYY6.;
   datalines;
John 23 1245 101513
Mary 37 40000 101599
Tom 53 60180 011490
William 37 77890 011405
Scott 39 80000 012411
Jessica 37 90105 011410
Liz 23 50000 011410
;
run;

/*basic*/
PROC PRINT data=work.person;
run;

/*list the variables you want to display with VAR, in this case just state and zip*/
PROC PRINT data=work.person;
	var name age;
run;

/*hide the obs column using NOOBS*/
PROC PRINT data=work.person noobs;
	var name age;
run;

/*Make "Name" the id column using ID*/
PROC PRINT data=work.person;
	id name; 
	var age;
run;

/*This does not work - we forgot something*/
PROC PRINT data=sashelp.zipcode  obs=10 ;
	var state zip;
run;

/*Only print the first 10 observations*/
PROC PRINT data=sashelp.zipcode (obs=10);
	var state zip;
run;

/*Use PROC SORT to order by age*/
/*Note that if you don't use the out= option, the sort command will overwrite your dataset.*/
/*In this case, since we did not use out=, work.person is sorted on age.*/
proc sort data=work.person;
	by age;
run;
proc print data=work.person;
run;

/*Now we use titles and footnotes*/
title1 'Proc Print';
title2 'on Work.Person';
title3 '(after sorting on age)';
footnote1 'My footnote1';
footnote2 'My footnote2';
footnote3 'My footnote3';
proc print data=work.person;
run;

/*now reset title2 and note that title3 is also removed (along with any higher numbered titles*/
title2;
/*and change footnote2.  This will remove footnote2 and any higher numbered footnotes*/
footnote2 'My Modified footnote2';
proc print data=work.person;
run;

/*Reset titles and footnotes*/
title;
footnote;

/*display the total salary using sum*/
proc print data=work.person;
	var name;
	sum salary;
run;

/*Attempting to format the date field */
/*Why doesn't this work?              */
proc print data=work.person noobs;
	format salary 5 HireDate MMDDYY;
run;

/*assign a temporary label            */
/*Format the date field               */
proc print data=work.person noobs;
	label name='Employee Name';
	format salary 5. HireDate MMDDYY.;
run;

/*Notice that the dollar symbol DOES NOT print for anyone other than John*/
/*This is because the width is 5.  All of the salaries except for John's require*/
/*the full width of 5, so there is no room for the dollar sign.*/
proc print data=work.person;
	label name='Employee Name';
	format salary dollar5. HireDate MMDDYY.;
run;

/*With a width of 7, we can show five-figure salaries with the dollar sign and comma*/
proc print data=work.person;
	label name='Employee Name';
	format salary dollar7. HireDate MMDDYY.;
run;

/*Similar problem with using the 5.2 format - the salaries are 5 digits, */
/*so we need a width of 7 to display them with the decimals*/
proc print data=work.person;
	label name='Employee Name';
	format salary 5.2 HireDate MMDDYY.;
run;

/*We need to make the width 8:*/
/*	5 slots for digits to the left of the decimal*/
/*  1 slot for the decimal*/
/*  2 slots to the right of the decimal*/
/*Also, we use Date7. and Date9. to display dates in the form 24FEB80 or 28FEB1980*/
/*The name field is formatted to show just the first 4 characters*/
proc print data=work.person;
	label name='Employee Name';
	format name $4. salary 8.2 HireDate DATE7.;
run;

/*What we just did was a temporary label.  Now we want to set up a permanant label */
data work.person;
	set work.person;
	label name='Employee Name';
	format name $4. salary dollar9.2 HireDate DATE7.;
run;

/*Now these formats are used automatically wit proc print*/
proc print data=work.person label;
run;

/*Oops - the four digit salary has a comma, the rest do not*/
/*We need to make the width 9:*/
/*  5 slots for digits to the left of the decimal, with one comma*/
/*	1 slot for the comma*/
/*  1 slot for the decimal*/
/*  2 slots to the right of the decimal*/
proc print data=work.person;
	label name='Employee Name';
	format salary comma9.2 HireDate MMDDYY.;
run;

/*assign a temporary label*/
/*Format the date field.  The 'w' in the format MMDDYYw. includes the separators */
proc print data=work.person;
	label name='Employee Name';
	format HireDate MMDDYY10.;
run;

/*In the above proc print, the label didn't show! */
/*This is because we forgot the label option.  We will add the label option this time*/
proc print data=work.person label;
	label name='Employee Name';
run;
