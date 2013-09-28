/*Chapter 15 - ARRAYS*/

data work.ThreeCols;
	input x1 x2 x3;
	datalines;
1.111 4.777 8.222
;
run;

data ThreeCols;
	set ThreeCols;
	Array Predictors{*} x1 x2 x3;
	Array AnotherWay{*} _numeric_;
	Array ThirdWay{*} _All_;
	y = 0;
	x = 0;
	z = 0;
/*	use do loop to sum up all elements of the array*/
	do i = 1 to dim(Predictors);
		y = y + Predictors{i};
		x = x + AnotherWay{i};
		z = z + ThirdWay{i};
	end;
/*	sum(of ArrayName{*}) sums up all elements of the array*/
	w = sum(of Predictors{*});
run;

data TwoWeeks;
	input x1 x2 x3 x4 x5 x6 x7 x8 x9 x10;
	datalines;
8 8 9 9 8 8 9 8 8 0
8 8 9 7 7 8 7 9 8 8
;
run;

/*In Hours{2,5}, the 2 represents 2 rows, while the 5*/
/*represents 5 rows*/
/*
Table fills up one row at a time, from left to right.
Rows are added from top to bottom
Ex: 	x1	x2	x3	x4	x5
		x6	x7	x8	x9	x10
*/
/*When the code has an "output" command, you override the usual*/
/*behaviour - outputting at the end of each iteration of the data*/
/*step.  In this case, output occurs at the end of each row.   */
data TwoWeeks(drop=i j);
	set TwoWeeks;
	Array Hours{2,5} x1-x10;
	array AvgHrs{5} _temporary_ (8 8 8 8 7);
	do i = 1 to 2;
		Time = 0;
		Comparsion = 0;
		do j = 1 to 5;
			Time = Time + Hours{i,j};
			Comparision = Comparison + abs(Hours{i,j} - AvgHrs{j});
		end;
		Week = i;
		output;
	end;
run;
