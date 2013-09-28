/*Code Related to Chapter 2*/

/*Display metadata on all tables in library, supressing details using NODS*/
PROC CONTENTS DATA=work._all_ NODS;
RUN;

/*Display metadata on all tables in library, with details*/
PROC CONTENTS DATA=work._all_;
RUN;

/*Display metadata for individual table*/
/*By default, fields are listed in alphabetical order*/
PROC CONTENTS DATA=sashelp.zipcode;
RUN;

/*Display metadata for individual table*/
/*the varnum option lists the fields in the 'logical' order*/
PROC CONTENTS DATA=sashelp.zipcode varnum;
RUN;

/*Create test data*/
data work.person;
   input name $ age salary HireDate MMDDYY6.;
   datalines;
John 23 1245 101513
Mary 37 40000 101599
Tom 53 60180 011490
William 37 77890 011405
Scott 39 80000 012411
Jessica 37 90105 011410
Liz 23 50000 011410
Scott 39 80000 012411
Jessica 37 90105 011410
Liz 23 50000 011410
Jessica 37 90105 011410
Liz 23 50000 011410
Scott 39 80000 012411
Jessica 37 90105 011410
Liz 23 50000 011410
Jessica 37 90105 011410
Liz 23 50000 011410
Scott 39 80000 012411
Jessica 37 90105 011410
Liz 23 50000 011410
;
run;

/*We can also use proc datasets to get the descriptor portion*/
PROC DATASETS;
	contents DATA=work.person;
run;

/*don't show date stamp or page number*/
ods listing;
options nonumber nodate; 
proc print data=work.person;
run;

/*include date stamp and page number*/
/*show observations 2 through 4*/
ods listing;
options date number firstobs=2 obs=4; 
proc print data=work.person;
run;

/*I'm not seeing any effect from setting pagesize*/
/*check the log to see why*/
ods listing;
options date number firstobs=1 pagesize=5; 
proc print data=work.person;
run;

/*this does produce a pagebreak*/
ods listing;
options date number firstobs=1 pagesize=15; 
proc print data=work.person;
run;

