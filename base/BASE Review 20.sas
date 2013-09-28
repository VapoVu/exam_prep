/*Chapter 20 - single input observation/row => multiple output observations/rows */

/*The double @@ prevents SAS from moving to the next row when it*/
/*reaches the end of the data step.*/
/*It will only go to the next row when it runs out of data on the */
/*current row.*/
/*Also write _n_ to our output*/
data work.repeat; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\repeat.txt';
   input Country $ Numeric @@; 
   n = _n_;
run;
proc print data=work.repeat;
run;

/*The single @ prevents SAS from moving to the next row after each input	*/
/*Notice the difference with n in this case as compared with the case above	*/
data work.repeat; 
	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\repeat.txt';
	do i = 1 to 3;
		input Country $ Numeric @; 
		n = _n_;
		output;
	end;
run;
proc print data=work.repeat;
run;

/*This is confusing, but the code here handles the case when*/
/*there are variable number of repeating fields within an observation*/
/*
Data:
	USA 1 2 3 
	AUS 22 
	AUS 33 33 33 33 33 
*/
data work.repeat; 
	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\repeat_variable.txt' missover;
	input Country $ Numeric @; 
	do while(Numeric ne .);
		output;
		input Numeric @; 
	end;
run;
proc print data=work.repeat;
run;

/*This shows reading data without the truncover option*/
/*There is a note in the log that SAS went to a new line */
/*when the input statement reached past the end of the line*/
data scores;
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\truncover.txt';
   input TestNum 1-6;
run;
/*With the truncover option - SAS does not go to a new line*/
/*but instead stops even though the lines are shorter than the expected 6 characters */
data scores;
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\truncover.txt' truncover;
   input TestNum 1-6;
run;


/*Do loops do not need to incriment by 1.*/
/*Here, we incriment by 2 instead.*/
data work.DoBy;
	do  i = 1 to 10 by 2;
		output;
	end;
run;
