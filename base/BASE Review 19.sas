/*This version has errors*/
data work.employee;  
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee_multiline.txt'; 
   input Fname & $13. salary comma7. birthday date7. / 
         Address $29 / 
         City & $10. State $ Zip $; 
run;

/*Corrected */
/*We also write _n_ to the output - notice that _n_ is the output obs number, 		*/
/*not the input line number.														*/
data work.employee;  
   	infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee_multiline.txt'; 
   	input Name & $13.  @14 salary comma7. @24 birthday date7. / 
         Address & $29. / 
         City $10. State $ Zip $; 
	n = _n_;
run;

/*If we just want to get the address line.  */
/*We need #3 to ensure that three lines are read for each interation of the data set*/
data work.address;  
   infile 'C:\Users\LukasHalim\Documents\GitHub\SASCert\employee_multiline.txt'; 
   input #2 Address & $29. #3;
run;

proc print data=work.address;
run;
