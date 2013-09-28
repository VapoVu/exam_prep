/*Code for Chapter 11*/

/*Create different version of the timecard datea*/
data work.TimeCard;
   input name $ age Hours;
   datalines;
John 23 15
Mary 37 60
Tom 53 30
William 37 35
Scott 39 40 
Jessica 37 40
Liz 23 40
John 23 15
Jessica 37 40
Liz 23 40
John 23 15
Mary 37 50
Tom 53 20
William 37 35
Scott 39 10 
Jessica 47 40
Liz 23 20
;
run;

proc sort data=work.timecard;
	by name;
run;

/*We use first. to detect when we are on the first occurrence of a given name*/
data work.timecard;
	set work.timecard;
	if first.name then TotalHrs = 0;
	TotalHrs + Hours;
run;

/*Using first.age will not work because the data isn't sorted on age*/
/*check the log to see the error message*/
data work.timecard;
	set work.timecard;
	if first.age then TotalHrs = 0;
	TotalHrs + Hours;
run;

/*timecard for demonstrating .first and .last with subgroups*/
data work.TimeCard;
   input Name $ Gender $ Hours;
   datalines;
John M 4
Tom M 3
Scott M 2
Tom M 5
Tom M 2
Jamie M 3
Jamie M 3
Jamie M 4
Jamie F 1
Jamie F 2
Liz F 4
Liz F 5
Lisa F 5
Ann F 2
;
run;

proc sort data=work.timecard;
	by Gender Name ;
Run;

/*this saves the first and last group and subgroup variables to the output data set*/
/*look at the data step to see how the subgroup first and last variables are set*/
/*notice that there are two separate cases where first.jamie is true: */
/*once for the male group and once for the female group*/
data work.timecard;
	set work.timecard;
	by Gender Name;
	firstGender = first.Gender;
	lastGender = last.Gender;
	firstName = first.Name;
	lastName = last.Name;
run;

/*this is to select the fifth observation*/
data work.ObFiveTimecard;
	set work.timecard point=5;
	output;
	stop;
run;

/*this is to get the last observation*/
data work.OnlyLast;
	set work.timecard end=last;
	if last then output;
run;

/*this is to get all observations except the last one*/
data work.NoLast;
	set work.timecard end=last;
	if last then delete;
run;

/* "if last;" is equivalent to "if last then output;" */
data work.OnlyLast2;
	set work.timecard end=last;
	if last;
run;
