/*Chapter 16 Reading Raw Data from Fixed-Fields*/
/*If we don't specify the length in the informat, it will just do one character*/
data work.Employee_Fixed; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee_formatted.txt'; 
   input Name $ @15 price comma.;
run;
proc print data=work.employee_fixed;
run;

/*Corrected*/
/*Notice that we must have a period at the end of the informat*/
data work.Employee_Fixed; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee_formatted.txt'; 
   input Name $13. @15 price comma7.;
run;
proc print data=work.employee_fixed;
run;
