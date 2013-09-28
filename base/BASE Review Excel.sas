/*Chapter 5 - creating SAS data sets from external files*/
libname RealEst 'C:\Users\LukasHalim\Documents\GitHub\SASCert\RealEstateSales.xlsx';

/*You can also import Excel data using PROC IMPORT*/
proc import out=work.SalesData
	datafile='C:\Users\LukasHalim\Documents\GitHub\SASCert\RealEstateSales.xlsx';
	range='Sales Data$'n;
run;

/*If FromSAS.xlsx does not exist, SAS automatically creates it when you run this libname*/
libname FromSAS 'C:\Users\LukasHalim\Documents\GitHub\SASCert\FromSAS.xlsx';

proc copy in=work out=FromSAS;
	select SalesData;
run;
quit;

libname FromSAS2 'C:\Users\LukasHalim\Documents\GitHub\SASCert\FromSAS2.xlsx';
data FromSAS2.SalesData;
	set work.SalesData;
run;
