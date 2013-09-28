/*Chapter 9*/
libname SasCert 'C:\Users\LukasHalim\Documents\My SAS Files\Base';

/*This creates a single html file*/
ods html 
	body='C:\Users\LukasHalim\Documents\GitHub\SASCert\body.html'
	contents='C:\Users\LukasHalim\Documents\GitHub\SASCert\contents.html'
	frame='C:\Users\LukasHalim\Documents\GitHub\SASCert\frame.html';
ods pdf file='C:\Users\LukasHalim\Documents\GitHub\SASCert\out.pdf';
proc print data=SasCert.employee;
run;
proc print data=SasCert.employee;
	format country $altcountryfmt.;
run;
ods _all_ close;
ods html;

/*Try the style option*/
ods html body='C:\Users\LukasHalim\Documents\GitHub\SASCert\styling.html'  
    style=Minimal; 
proc print data=SasCert.employee label; 
run; 
ods html close; 
ods html;
