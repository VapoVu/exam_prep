/* Code for Chapter 13 */
data work.TextPrices;
   input Name $ 1-11 TextPrice $;
   datalines;
Pickles    2
Apples     3
Apples     4
;
run;

/*use the input function to convert Price from character to numeric*/
/*the INput function needs an INfomrmat*/
data work.NumericPrices;
	set work.TextPrices;
	AutoConvert = TextPrice * 2;
	NumPrice = input(TextPrice,1.);
run;

/*Now convert back to text*/
data work.ReTextPrices;
	set work.NumericPrices;
	ReTextPrice = put(NumPrice,1.);
run;

/*Text data is automatically converted to numeric when used in a calculation*/
data work.TextPrices;
	set work.TextPrices;
	AutoConverted = TextPrice * 2;
run;
proc print data=work.TextPrices;
run;

/*This works - testNum is converted to a string and appended to testChar*/
/*however, testNum is put in BEST12. format, which results in leading blanks*/
/*If we want to avoid this, we can use input to convert from numeric to character*/
/*with the desired format*/
data work.AutoNumToChar;
	testChar = 'ABC';
	testNum = 123;
	testAutoConcat = testChar || testNum;
	testInputConcat = testChar || ' ' || put(testNum,3.);
run;

data work.person;
   input name $ HireDate MMDDYY6.;
   datalines;
John 101512
Mary 101599
Tom 011490
;
run;

/*Date functions*/
/*INTCK can give the days, months, years or quarters*/
/*between dates*/
data work.person;
	set work.Person;
	Date1 = mdy(8,7,2013);
	Date2 = today();
	Experience = Date2 - HireDate;
	YearsOfWork = INTCK('Year',HireDate,Date2);
	Time = time();
run;

/*Format dates and select observations*/
/*Can't use subsetting if in proc print*/
/*instead we use a where statement*/
proc print data=work.person;
	format HireDate MMDDYY10. Date1 MMDDYY8. Date2 Date9.;
	where year(HireDate)=1990;
run;

/*String Functions*/
data work.person;
   input name $ 1-32;
   datalines;
SMiTh, John A.
Halim, Lukas
Goldberg, Lukas
;
run;

/*PropCase capitalizes first letters*/
/*Scan divides the string by specified (or default) delimiter and returns the specified nth word*/
/*Index finds the first occurrence of the specified string.  Find is a similar*/
data work.person(drop=FirstInitial Name);
	set work.person;
	LastName = PropCase(scan(name,1));
	FirstInitial = substr(scan(name,2),1,1);
	ReNamed = CatX(" ","Mr.",FirstInitial,"A.",LastName);
	Location = Index(Name,"Lukas");
	Location2 = Find(Name,"Lukas");
run;

data work.ThreeCols;
	input x1 x2 x3;
	datalines;
1.111 4.777 8.222
;
run;

/*The Round function rounds to the specified the precision.      */
/*  Default is nearest .01, but here we round to the nearest .02 */
/*Int strips off the decimals*/
data ThreeCols;
	set work.ThreeCols;
	SummedVal = sum(of x1-x3);
	RoundedX1 = round(x1,.02);
	IntX2 = Int(x2);
run;

/*More examples with FIND*/
/*Syntax: FIND (master_string, search_string, <’modifiers’>,<starting_position>);*/
data temp;
	/*succeeds*/
	pos_1 = find ("Sachin Tendulkar","kar");
	/*fails - case sensitive by default*/
	pos_2 = find ("Sachin Tendulkar","ten");
	/*succeeds - case insensitive option*/
	pos_3 = find ("Sachin Tendulkar","ten","i");
	/*fails - invalid start position*/
	pos_4 = find ("Sachin Tendulkar","kar",99);
run;
