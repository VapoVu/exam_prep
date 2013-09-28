/*Chapter 1*/
/*Read "instream data" using the datalines feature */
data work.person;
   	input Name $;
   	datalines;
Jonathan
;
run;

/*this gives a warning in the log because the length statement needs to come earlier*/
data work.person;
	set work.person;
	Fullname = Name || ' FakeLastName';
	length fullname $ 33;
run;

/*the length statement works correctly here*/
data work.person;
	set work.person;
	length fullname $ 21;
	Fullname = Name || ' FakeLastName';
run;

/*Trying to referencing a SAS data file*/
/*This fails because the libname is too long*/
libname SasCertification 'C:\Users\LukasHalim\Documents\GitHub\SASCert';

/*Now use a valid libname*/
/*Once you run this, open up the SASCert library and look at the tables*/
libname SasCert 'C:\Users\LukasHalim\Documents\GitHub\SASCert';

