/*Chapter 18*/
/*If we leave out the "." at the end of the "date7", SAS will create*/
/*an extra variable called date7.*/
options yearcutoff=1910; 
data work.birthdays; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\birthdays.csv' dsd; 
   input Name $ Birthday date7;
run; 
proc print data=work.birthdays; 
   format Birthday worddate12.; 
run;

/*This time we correctly use the informat "date7"*/
options yearcutoff=1910; 
data work.birthdays; 
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\birthdays.csv' dsd; 
   input Name $ Birthday date7.;
run; 
proc print data=work.birthdays; 
   format Birthday worddate12.; 
run;
