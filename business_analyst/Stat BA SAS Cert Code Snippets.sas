*Business Analyst Certification Code Snippets;

*Imputing Missing Values;
proc stdize data=develop1
	reponly
	method=median
	out=imputed;
var &inputs;
run;

*Scoring Model;
proc logistic data=develop des;
	model ins=dda ddabal dep depamt cashbk checks;
	score data = pmlr.new out=scored;
run;

proc score data=pmlr.new out=scored score=betas1 type=parms;
	var dda ddabal dep depamt cashbk checks;
run;

*Converting logit to probability. ins is the target variable;
data scored;
	set scored;
	p=1/(1+exp(-ins));
run;

*Correcting for Oversampling;
proc logistic data=develop des;
	model ins=dda ddabal dep depamt cashbk checks;
	score data = pmlr.new out=scored priorevent=&pi1;
run;

*Clustering Levels of Variables;

proc cluster data=level method=ward
		outtree=fortree;
	freq _freq_;
	var prop;
	id branch;
run;


*Clustering Variables;
proc varclus data=imputed
		maxeigen=.7
		outtree=fortree
		short;
	var &inputs brclus1-brclus4 miacctag
	miphone mipos miposamt miinv
	miinvbal micc miccbal miccpurc
	miincome mihmown milores mihmval
	miage micrscor;
run;







*Predictive Modeling Using Logistic Regression - End of Book Exercises;
*Note: Need actual data set for this to be helpful because Dr. Dickey's data set is different.

libname _all_ clear;
libname stats 'C:\Users\sneola\Documents\SAS Training\BA';

*Ch2 Exercises

*Create a table of the mean, minimum, maximum, and count of missing for each numeric input.;

proc means data=stats.pva97nk mean min max nmiss;
	*var - by not including var, all the numeric variables are included. nice feature!;
run;

*Create tables of the categorical inputs. Do not create a table using CONTROL_NUMBER, the
identification key.;

proc freq data=stats.pva97nk;
	tables _character_ / missing;
run;
* MISSING treats missing values as a valid nonmissing level for all TABLES variables. 
	The MISSING option displays the missing levels in frequency 
	and crosstabulation tables and includes them in all calculations of percentages, tests, and measures.
By default, if you do not specify the MISSING or MISSPRINT option, an observation is excluded from a table 
	if it has a missing value for any of the variables in the TABLES request. 
When PROC FREQ excludes observations with missing values, it displays the total frequency of missing observations below the table. 

*Not sure how to include all character variables but exclude one;

*Create a macro variable to store p1, the proportion of responders in the population. 
This value is 0.05.;

%let pi1 = .05;

*The current model consists of PEP_STAR, RECENT_AVG_GIFT_AMT, and FREQUENCY_STATUS_97NK. 
Fit this model to the data. Use the SCORE statement to append
	the predicted probability to the data, correcting for oversampling. 
Investigate the minimum, maximum, and average predicted probability of response based on this model.;

proc logistic data=stats.pva97nk;
	model targetb = GiftAvgCard36 GiftCntCard36;
	score data=scored priorevent=&pi1;
run;

proc means data=scored min max mean;
	run;




