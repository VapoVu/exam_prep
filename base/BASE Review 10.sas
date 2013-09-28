/*Code for Chapter 10 - Creating and Managing Variables*/
/*Create small dataset for use in this chapter*/
data work.TimeCard;
   input name $ age Week1 Week2 Week3 Week4;
   datalines;
John 23 15 20 15 20
Mary 37 60 40 20 40
Tom 53 30 30 35 30
William 37 35 35 30 30
Scott 39 40 40 40 42 38
Jessica 37 40 40 0 40
Liz 23 40 40 40 38
;
run;

/*the retain statement allows us to incriment over multiple iterations of the datastep*/
data work.TimeCard;
	set work.TimeCard;
	retain TotalWeek1Hours 150;
	TotalWeek1Hours+Week1;
	if Week1 > 40 then Type ='Working Overtime';
	if Week1 < 30 then Type = 'Working Part Time';
	if Week1 ge 30 and Week1 le 40 then Type = 'Working Full Time';
run;

/*Some values in Type are truncated!  Need to use the length command*/
/*The length command must prior to any other mention of the variable in the data step*/
data work.TimeCard;
	set work.TimeCard;
	length TypeRevised $ 20;
	retain TotalWeek1Hours 150;
	TotalWeek1Hours+Week1;
	if Week1 > 40 then TypeRevised ='Working Overtime';
	if Week1 < 30 then TypeRevised = 'Working Part Time';
	if Week1 ge 30 and Week1 le 40 then TypeRevised = 'Working Full Time';
run;

/*Sum week1 and week2, then drop them*/
data work.TimeCard(drop=Week1 Week2);
	set work.TimeCard;
	FirstTwoWeekTotal = Week1 + Week2;
run;

/*This does the same as above, but using the drop statement rather than        	*/
/*the drop option.  This works the same way - the variable is added to the PDV 	*/
/*but dropped from the output data set.*/
data work.TimeCard;
	set work.TimeCard;
	drop Week3 Week4;
	SecondTwoWeekTotal = Week3 + Week4;
run;

/*This fails because we have dropped the variable in the input data set,  		*/
/*and therefore the variable (SecondTwoWeekTotal) is not added to the PDV 		*/
/*as a result, we get an error message when we try to use SecondTwoWeekTotal	*/
data work.TimeCard;
	set work.TimeCard(drop=SecondTwoWeekTotal);
	SecondTwoWeekTotalPlus1 = SecondTwoWeekTotal + 1;
run;

data work.TimeCard;
	set work.TimeCard;
	select (name);
		when ("John") Gender="M";
		when ("Mary") Gender="F";
		when ("Tom") Gender="M";
		when ("William") Gender="M";
		when ("Scott") Gender="M";
		otherwise Gender="U";
	end;
run;
