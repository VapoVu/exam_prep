/*Chapter 21 - outputting diffrent lines in input data set to different output data sets*/
data work.Address;
	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\Address.txt';
	retain City State Zip;
	input type 1. @;
	if type=1 then do;
		input Number $ Street & $15.;
		output;
	end;
	if type=2 then input City $ State $ Zip;
run;
proc print data= work.address;
run;

/* Misc Code */
/* PROC REPORT */
data work.person;
   input Name $5. +1 Num 4.;
   datalines;
John  3533
Lukas 1233
Lukas 1633
;
run;
quit;

/*Order to avoid printing repeat values on each line*/
proc report data=work.person nowd;
	define Name/order;
	define Num/sum;
run;
quit;
/*Group to aggregate observations*/
proc report data=work.person nowd;
	define Name/group;
run;
quit;

