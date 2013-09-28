/*Code Related to Chapter 7 - Creating Unique Formats*/
libname base 'C:\Users\LukasHalim\Documents\My SAS Files\Base';
/*if you do not use lib= or library=, the format data will be placed in work.formats*/
/*Format name can be up to 32 characters and may NOT end in a number*/
/*for example, $countryfmt9 is not a valid format name*/
/*In the value statement, must not end with a period (.)*/
proc format;
 value $countryfmt
     'USA'='United States'
	 'RUS'='Russia'
	 'IL'='Israel';
run;

libname SASCert 'C:\Users\LukasHalim\Documents\GitHub\SASCert'; 
proc format library=SASCERT;
 value $altcountryfmt
     'USA'='United States'
	 'RUS'='Russia'
	 'IL'='Israel'
	 'UK'='United Kingdom';
run;

/*examples of errors*/
proc format;
 value $countryfmt.
     'USA'='United States';
 value $countryfmt9
 	'USA'='United States';	
run;

/*Create the dataset SASCert.Employee */
filename EMPLOYEE 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee.txt';
data SASCert.Employee;
	infile EMPLOYEE;
	input name $ age country $ baseSalary bonus hiredate;
run;
/*Apply the format to this data set*/
data SasCert.Employee;
	set SasCert.Employee;
	format country $countryfmt.;
run;
/*Apply the altcountyfmt format to this data set		*/
/*SAS will search through the available libraries until	*/
/*it finds Altcountryfmt in SAS.Formats					*/
data SasCert.Employee;
/*	options fmtsearch=(SasCert.formats Work.formats);*/
	set SasCert.Employee;
	format country $altcountryfmt.;
run;
/*print*/
proc print data=SasCert.employee;
run;
/*print with temporary format*/
proc print data=SasCert.employee;
	format country $altcountryfmt.;
run;
