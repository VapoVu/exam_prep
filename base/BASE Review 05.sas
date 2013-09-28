/*Chapter 5 Creating SAS data sets from external files*/

/*Column input: 	data is fixed with and standard format		*/
/*				standard numeric format:						*/
/*					decimals									*/
/*					scientific notation							*/
/*					+ or - sign                             	*/
/*					NO commas, currency signs					*/

filename column 'C:\Users\LukasHalim\Documents\GitHub\SASCert\column.txt'; 

/*This doesn't work - why not?*/
/*Check the log to see the errors*/
data column; 
   infile column; 
   input CHAR $ 1-4 NUM 6-10; 
run;

/*This works except for the nonstandard numeric value: $290 is converted to missing*/
data column; 
   infile column; 
   input CHAR $ 1-4 NUM 6-9; 
run;

/*Use obs=2 to read in just the first two rows*/
data column; 
   infile column obs=2; 
   input CHAR $ 1-4 NUM 6-9; 
run;

/* with calculations and date variable */
data column; 
   	infile column obs=2; 
   	input CHAR $ 1-4 NUM 6-9; 
	Doubled = Num * 2;
	TestDate='01jan2000'd; 
run;

/* with subsetting if */
data subsetted; 
   	infile column; 
   	input CHAR $ 1-4 NUM 6-9; 
	if CHAR='ABC';
run;

/* if .... then delete 									*/
/* basically the opposite effect of a subsetting if		*/
data ifthenDelete; 
   	infile column; 
   	input CHAR $ 1-4 NUM 6-9; 
	if CHAR='ABC' then delete;
run;


/* What happens if we use a WHERE statement instead of a subsetting if? 	*/
/* Check the log after running this data step								*/
/* error b/c WHERE doesn't work with raw input data file 					*/
data ColumnWithWhere; 
   	infile column; 
   	input CHAR $ 1-4 NUM 6-9; 
	WHERE CHAR='ABC';
run;

/*This works - you can use WHERE in data step with variables from the input data step	*/
/*WHERE subsets before data enters the input buffer, while IF works on the PDV			*/
/*For more detail see http://www2.sas.com/proceedings/sugi31/238-31.pdf					*/
data ColumnWithWhere;
	set column;
	where CHAR='ABC';
run;

/*Create the SASCert libname*/
libname SasCert 'C:\Users\LukasHalim\Documents\GitHub\SASCert';

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

/*This is the syntax to create a data set		*/
/*Use PUT rather than INPUT						*/
/*Use FILE rather than INFILE					*/
data _NULL_;
   set work.person;
   file Person;
   put name $ age salary HireDate; 
run;

/*the filename statement creates a fileref 				*/
/*similar to how a libname statement creates a libref	*/
/*save the PDV values _n_ and _error_					*/
filename SASCert 'Person.dat';
data SASCert.Person;
	infile PERSON;
	input name $ age salary hiredate;
	n = _n_;
	error = _error_;
run;

/*the filename statement creates a fileref 								*/
/*similar to how a libname statement creates a libref					*/
/*In the data step, an infile statement will use the fileref as input	*/
filename EMPLOYEE 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee.txt';
data SASCert.Employee;
	infile EMPLOYEE;
	input name $ age country salary bonus hiredate;
run;

/*After we run the code above, the values in Country are missing 			*/
/*Country is missing because SAS tried to read it in as a numeric field.	*/
/*Check the log - see that _ERROR_ is incrimented for each row				*/
/*Correct this by adding the $												*/
filename EMPLOYEE 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee.txt';
data SASCert.Employee;
	infile EMPLOYEE;
	input name $ age country $ baseSalary bonus hiredate;
run;

/*Same as above, but with a sum and a subsetting if							*/
/*It could also be written without the "then output"						*/
data SASCert.US_Employee;
	infile EMPLOYEE;
	input name $ age country $ baseSalary bonus hiredate;
	totalSalary = baseSalary + baseSalary * bonus / 100;
	if country = "USA" then output;
run;

/*Reading data from Excel*/
libname RealEstate 'C:\Users\LukasHalim\Documents\GitHub\SASCert\RealEstateSales.xlsx';

/* didn't work because libname cannot be more than eight characters! */
libname RealEst 'C:\Users\LukasHalim\Documents\GitHub\SASCert\RealEstateSales.xlsx';

/*Attempt to create a new sas dataset from one of the worksheets in RealEstateSales.xlsx*/
/*Check the log to see the error*/
data Sales;
	set RealEst.'Sales Data$';
run;

/*create a new sas dataset from one of the worksheets in RealEstateSales.xlsx*/
data Sales;
	set RealEst.'Sales Data$'n;
run;

proc contents data=RealEst._all_;
run;

/*Get rid of SASCERT*/
libname SASCERT clear;

/*Create an Excel file */
libname XLOut 'C:\Users\LukasHalim\Documents\GitHub\SASCert\Output.xlsx';
data XLOut.person;
   set work.person;
run;
quit;
