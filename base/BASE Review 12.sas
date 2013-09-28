/*Code for Chapter 12*/
data work.Prices;
   input Name $ 1-11 Price;
   datalines;
Pickles    20
Apples     15
Toothpaste 2
Cigarettes 5
Beer       10
Chicken    5
Diapers    5
Sprats     5
;
run;

data work.ShoppingList;
   input Name $ 1-11 Quantity;
   datalines;
Pickles    30
Apples     10
Toothpaste 10
Cigarettes 10
Beer       5
Not Chicken10
;
run;

/*This is called one-to-one merging*/
/*The number of observations will be equal to the number of observations in the*/
/*smaller of the two data sets... basically whenever SAS can't find another*/
/*row in either work.Prices or work.Shopping list, it stops iterating*/

/*Also note that the last observation has a Name of "Not Chicken"*/
/*Since both data sets include the Name variable, the second data set will*/
/*overwrite the Name values in the first data set.*/
data work.Groceries;
	set work.Prices;
	set work.ShoppingList;
run;

data work.MorePrices;
   input Name $ 1-11 Price;
   datalines;
Tuna       10
Nuts       15
Tape       2
Figs       5
Pears      10
;
run;



/*Now we will concatenate*/
/*Difficult to remember the differences between:											*/
/*	set dataset1 dataset2;		(concatenate)												*/
/*	set dataset1; set dataset2;	(join by obs #, until you run out of obs in either dataset)	*/
/*	merge dataset1 dataset2;	(like SQL inner join)										*/
data work.ConcatPrices;
	set work.Prices work.MorePrices;
run;

/*append does the same thing as concatenate, except it adds to the 				*/
/*data set selected with the base=dataset1 										*/
/*SAS doesn't read the data in the base data set, making append more efficient.	*/
/*also, it is more sensative than concatenate:									*/
/*concatenate will fail if you have different data types on the 				*/
/*same field, but concatenate doesn't mind if variables are different lengths 	*/
proc append base=work.Prices data=work.MorePrices;
run;

data work.SlightlyDifferentPrices;
   input Name $ 1-22 Price 24-25 Count;
   datalines;
Nut N Honey Cereal    10 5
Honey Bunches of Oats 5  5
;
run;

/*concatenate will combine; append will not */
/*See the log for details					*/
data work.ConcatMoreFlexibleThanAppend;
	set work.Prices work.SlightlyDifferentPrices;
run;
proc append base=work.Prices data=work.SlightlyDifferentPrices;
run;

data work.DifferentPrices;
   input Name $ 1-22 Price $ 24-25 Count;
   datalines;
Nut N Honey Cereal    10 5
Honey Bunches of Oats 5  5
;
run;

/*won't work!  There are THREE different warnings in the log*/
/*LongerPrices has longer with for the Name field*/
/*Price is numeric in Prices but text in LongerPrices*/
/*Count exists in LongerPrices but is missing in Prices*/
proc append base=work.Prices data=work.DifferentPrices;
run;

/*works with FORCE*/
/*notice the following: */
/*text values for Price DifferentPrices become missing values since there is a type mismatch */
/*since count doesn't exist in Prices, it is dropped from the resulting output */ 
/*longer names are truncated*/
proc append base=work.Prices data=work.LongerPrices FORCE;
run;

/*recreating data for interleaving*/
data work.Prices;
   input Name $ 1-11 Price;
   datalines;
Pickles    20
Apples     15
Apples     6
Toothpaste 2
Cigarettes 5
Beer       10
Chicken    5
Diapers    5
Sprats     5
Sprats     5
;
run;

/*interleaving*/
/*must sort on our BY variable*/
proc sort data=work.Prices;
	by name;
run;
proc sort data=work.MorePrices;
	by name;
run;

data work.InterlevPrices;
	set work.Prices work.MorePrices;
	by name;
run;

/*merge without a by is equivalent to set dataset1; set dataset2;*/
data work.PricesShoppingListMergeWithoutBy;
	merge work.Prices work.ShoppingList;
run;

/*match-merge*/
/*if we used set instead of merge, we would interleave				*/
/*notice the missing values in the resulting data set				*/
/*if the BY variable name is missing in one or the other data		*/
/*set, then the values from that data set are missing				*/
/*What SAS calls "interleaving" is basically concatenating + sort	*/
proc sort data=work.Prices;
	by name;
run;
proc sort data=work.ShoppingList;
	by name;
run;
data work.PricesShoppingListMerge;
	merge work.Prices work.ShoppingList;
	by name;
run;

/*Renaming*/
data work.Prices;
   input Name $ 1-11 Price;
   datalines;
Pickles    20
Apples     15
Peaches     6
;
run;

data work.MorePrices;
   input Name $ 1-11 Price;
   datalines;
Pickles    2
Apples     3
Apples     4
;
run;
proc sort data=work.Prices;
	by name;
run;
proc sort data=work.MorePrices;
	by name;
run;
/*Use the rename so that we can keep both sets of prices*/
/*otherwise the price info from MorePrices would be overwritten*/
data work.CombinedPrices;
	merge 	work.Prices (rename=(Price=Price1))
			work.MorePrices (rename=(Price=Price2));
	by name;
run;

/*Notice that the above merge is basically the same as a SQL outer join*/
/*Observations are included in the merged data set even if they are missing*/
/*from one or the other data set*/
/*If you want to do an inner join, selecting only if an observation*/
/*is included in BOTH data sets, you can use the method below*/
/*the in=VARNAME creates a variable that is true if data set*/
/*contributed to the current observation.  In this example, */
/*inPrices is 1 when there are values in Prices for the current value of Name*/
/*and inMorePrices is 1 when there are values in MorePrices for the */
/*current value of Name*/
data work.CombinedPricesInBoth;
	merge 	work.Prices (in=inPrices rename=(Price=Price1))
			work.MorePrices (in=inMorePrices rename=(Price=Price2));
	by name;
	if inPrices and inMorePrices;
run;

/*Don't drop the variable like this if you need its value during*/
/*iterations of the data step*/
/*Look at the result and see the missing values*/
data work.DoublePrices;
	set work.Prices(drop=Price);
	DoubledPrice = Price * 2;
run;

/*This will work since Price is only dropped at the conclusion of the*/
/*data step*/
data work.DoublePrices(drop=Price);
	set work.Prices;
	DoubledPrice = Price * 2;
run;
