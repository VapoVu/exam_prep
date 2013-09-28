/*Chapter 17 Code*/
/*SAS sometimes uses its own specialized vocabulary when there are*/
/*perfectly suitable terms in common use that would be more easily*/
/*understandable.  In this case, SAS calls the data "Free format"*/
/*when most people would call it delimited data.*/
/*
Fixed Width
	Column (standard data)
	Formatted (standard and non-standard)
Free-Form (normally called delimited data)
	List Input
*/

/* List style of input */
data work.Employee_Free_Form; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee_free_form.txt' dlm=','; 
   input Name $ Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*Same as above, but using a file that has blanks rather than commas*/
/*the default delimiter is blank, so no need to use the dsm option*/
/*Notice that the Name values are truncated!!  By default, list input is only*/
/*eight characters.*/
data work.Employee_Free_Form; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\emp_free_form_blanks.txt'; 
   input Name $ Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*fix the truncaction*/
data work.Employee_Free_Form; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\emp_free_form_blanks.txt'; 
	length Name $ 11;
	input Name $ Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

data work.Employee_Free_Form; 
   	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\emp_free_form_blanks.txt'; 
	input Name $ 11. Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*Example of data file with missing values at the end of a line*/
/*See the note in the log:*/
/*NOTE: SAS went to a new line when INPUT statement reached past the end of a line.*/
data work.Employee_Free_Form; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\emp_missover.txt'; 
   input Name $ Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*Now do the same, but use the MISSOVER option*/
/*Missover only works if the missing data is at the END of the line*/
data work.Employee_Free_Form; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\emp_missover.txt' missover; 
   input Name $ Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*Example of data file with missing values in the middle of a line*/
/*Notice that SAS doesn't understand the two commas in the data set*/
/*represent a missing value.  All Country, Date1, Bonus, and Date2 are all*/
/*shifted to the left.  SAS tries to put "USA"in the age field, but since */
/*USA is text and Age is numeric, the value shows as missing*/
data work.Employee_Free_Form; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\emp_dsd.txt' dlm=','; 
   input Name $ Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*Fix this with the dsd option.  DSD means that SAS will impute a missing value*/
/*when it finds repeated delimiters.*/
data work.Employee_Free_Form; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\emp_dsd.txt' dsd; 
   input Name $ Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*The file emp_embedded_blanks uses double blanks "  " as delimiters.*/
/*Single blanks are allowed within a field, so "George Blank" should*/
/*be a single value, while "George  Blank" would be treated as two different*/
/*values.  */
/*However, embedded blanks won't work - they are treated as delimiters*/
data work.Employee_Free_Form; 
   	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\emp_embedded_blanks.txt'; 
	length Name $ 12;
	input Name $ Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*Now we use the ampersand.*/
/*The ampersand & character is used to allow us to handle embedded blanks within a value*/
/*when we are using blanks as our delimiter.  In order to mark the end of the an */
/*amperanded-value, we use two blanks rather than just one.*/
/*
Data:
	George Blank  23 USA 40104 4 021407
	Sam Blank  35 UK 55125 1 031405
*/
data work.Employee_Free_Form; 
   	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\emp_embedded_blanks.txt'; 
	length Name $ 12;
	input Name & Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*This also works: variable-name ampersand informat*/
data work.Employee_Free_Form; 
   	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\emp_embedded_blanks.txt'; 
	input Name & $12. Age Country $ Date1 Bonus Date2; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*How about nonstandard data, such as $250,000?*/
/*Trying to read $250,000 as numeric data results in missing values*/
data work.Employee_Free_Form; 
   	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee_nonStandard.txt'; 
	input Name  & $12. Salary; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*The output data set was missing salary info*/
/*how about adding an informat?*/
data work.Employee_Free_Form; 
   	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee_nonStandard.txt'; 
	input Name  & $12. Salary dollar.; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*The above code also failed*/
/*we need a colon to read nonstandard data (comma, currency)*/
/*and data that is longer than eight characters*/
data work.Employee_Free_Form; 
   	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee_nonStandard.txt'; 
	input 	Name & $12.
			Salary : Comma.; 
run; 
proc print data=work.Employee_Free_Form; 
run;

/*Now let's create free-format (delimited) data*/
data work.person;
   input name $ age salary HireDate MMDDYY6.;
   datalines;
John 23 1245 101513
Mary 37 40000 101599
Tom 53 60180 011490
;
run;

/*Creating a delimited file*/
data _null_; 
   set work.person; 
   file 'C:\Users\LukasHalim\Documents\GitHub\SASCert\person_delimited.txt'; 
   put name $ age salary HireDate MMDDYY6.;
run;

/*CSV*/
data _null_; 
   set work.person; 
   file 'C:\Users\LukasHalim\Documents\GitHub\SASCert\person_delimited.csv' dlm=','; 
   put name $ age salary HireDate MMDDYY6.;
run;

/*CSV with commas within fields*/
/*Open the resulting file - you will see that there is an extra column*/
/*because the commas in the salary field are confused with delimiters!*/
/*we need to prevent this with the DSD option*/
data _null_; 
   set work.person; 
   file 'C:\Users\LukasHalim\Documents\GitHub\SASCert\person_comma.csv' dlm=','; 
   put name $ age salary : comma6. HireDate MMDDYY6.;
run;

/*Open the resulting file and you will see that the commas in the */
/*salary field are handled correctly*/
data _null_; 
   set work.person; 
   file 'C:\Users\LukasHalim\Documents\GitHub\SASCert\person_dsd.csv' dsd; 
   put name $ age salary : comma6. HireDate MMDDYY6.;
run;
