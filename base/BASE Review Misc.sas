/*OUTPUTTING TO TWO DATA SETS*/

/*Create test data*/
data work.person;
   input name $ age salary HireDate MMDDYY6.;
   datalines;
John 23 1245 101513
Mary 37 40000 101599
Tom 53 60180 011490
;
run;

/*How many records in work.p1?  How many in work.p2?		*/
/*The "output;" statement outputs to BOTH p1 and p2 even 	*/
/*though we already output to p1							*/
/*We also save the values of _n_ to the output data sets	*/
data work.p1 work.p2;
	set work.person;
	n = _n_;
	if Name="John" then output work.p1;
	output;
run;
