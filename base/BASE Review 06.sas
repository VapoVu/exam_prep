/*Code related to chapter 6*/

/*create SASCERT*/
filename EMPLOYEE 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee.txt';
libname SasCert 'C:\Users\LukasHalim\Documents\GitHub\SASCert';
data SASCert.Employee;
	infile EMPLOYEE;
	input name $ age country $ baseSalary bonus hiredate;
run;

/*Invoke the debugger using the /debug command											*/
/*See http://www2.sas.com/proceedings/sugi25/25/btu/25p052.pdf for debugger commands	*/
/*In the debugger log window, try the following commands:								*/
/*	step																				*/
/*	examine age baseSalary																*/
/*	set age=29																			*/
/*	examine _all_																		*/
/*	list _all_																			*/
data SASCert.US_Employee /debug;
	infile EMPLOYEE;
	input name $ age country $ baseSalary bonus hiredate;
	totalSalary = baseSalary + baseSalary * bonus / 100;
	if country = "USA" then output;
run;

/*In addition to the /debug command, it can also be useful to write info	*/
/*to the log.  You do this with the put statement, as shown below.			*/
data SASCert.US_Employee;
	infile EMPLOYEE;
	input name $ age country $ baseSalary bonus hiredate;
	totalSalary = baseSalary + baseSalary * bonus / 100;
	if country = "USA" then output;
	if totalSalary < 35000 then put 'MY NOTE: Salary should be at least 35K.  Value of _n_:' _n_;
run;


