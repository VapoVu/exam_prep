#Business Analyst Certification Notes - Predictive Modeling Using Logistic Regression

##Fitting a Model w/ PROC LOGISTIC

<pre><code>proc logistic data=develop des;
class res (param=ref ref='S');
model ins = dda ddabal dep depamt
cashbk checks res
/ stb;
units ddabal=1000 depamt=1000;
run;</pre></code>

The variable Res has no standardized estimate because it is a class variable.

###Scoring a Model on a Validation Data Set

**Within** `PROC LOGISTIC` **using the `OUTPUT` statement** 

<pre><code>proc logistic data=develop des;
	model ins=dda ddabal dep depamt cashbk checks;
	score data = pmlr.new out=scored;
run;</pre></code>

This has several disadvantages over using `PROC SCORE`

- it does not scale well with large data sets
- it requires a target variable (or some proxy)
- the adjustments for oversampling, discussed in the next section, are not automatically applied.

**Scoring Using PROC SCORE** (Recommended)

<pre><code>proc score data=pmlr.new out=scored score=betas1 type=parms;
	var dda ddabal dep depamt cashbk checks;
run;</pre></code>

`type=parms` is required for scoring regression models

The linear combination produced by PROC SCORE (the variable Ins) estimates the logit, not the
posterior probability. 

The logistic function (inverse of the logit) needs to be applied to compute the posterior probability.

<pre><code>data scored;
	set scored;
	p=1/(1+exp(-B^x));
run;</pre></code>

The math behind it...

![pic](pics/img_02.png)


###Oversampling (for rare events)

The SCORE statement in the LOGISTIC procedure will correct predicted probabilities back to the population scale. The option to do this is `PRIOREVENT=`.

<pre><code>proc logistic data=develop des;
	model ins=dda ddabal dep depamt cashbk checks;
	score data = pmlr.new out=scored priorevent=&pi1;
run;</pre></code>

`priorevent=.02` supplies the prior probability of the event occurring (instead of the over-sampled value)

Note: `OFFSET=` option in the MODEL statement names the offset variable.  It can also be used like 'priorevent` but it isn't as efficient. 


##Prepare Inputs for Predictive Model Performance

###Proc STDIZE 

*What is the purpose of PROC STDIZE?*

Replaces missing values by standardizing numeric variables by subtracting a location measure and dividing by a scale measure.  Some of the well-known standardization methods such as mean, median, standard deviation, range.

![pic](pics/img_01.png)

*What are the problems of missing values?*

The default setting for regression models is to use only complete cases (no missing values for an observation).  Much information will be lost as the number of missing values increases. This problem escalates exponentially as the number of input variables increases.

*To resolve:*  

- First, missing values need to be replaced with reasonable values. Missing indicator variables are also needed if missingness is related to the target. 
- If there are nominal input variables with numerous levels, the levels should be collapsed to reduce the likelihood of quasi-complete separation and to reduce the redundancy among the levels. 
- Furthermore, if
there are numerous input variables, variable clustering should be performed to reduce the redundancy among the variables. 
- Once the variables are clustered, you can take the mean of each cluster and impute the value for an observation based on which cluster they are in. 

*How does the computation play out and/or what are the representative code snippets?*

<pre><code>proc stdize data=develop1
	reponly
	method=median
	out=imputed;
var &inputs;
run; </pre></code>

- `reponly` replaces missing data with the location measure (does not standardize the data)
- `method=mean` the method used to impute the values
- `out=imputed` output the data with the imputed values into a new data set called `imputed`.

Additional Options in the `PROC STDIZE` Statement

*Specify standardization methods*

- `NOMISS` omits observations with any missing values from computation
- `MISSING=` specifies the method or a numeric value for replacing missing values
- `REPLACE` replaces missing data with zero in the standardized data

###Categorical Inputs 

**Clustering Levels**

![pic](pics/img_03.png)


**PROC CLUSTER**

*What is the purpose of* `PROC CLUSTER`?

Clustering levels of variables (i.e. to remove quasi-complete separation.) 

Note: add a small constant can also work if there are not many missing values.

*How does the computation play out?* *How do we measure the performance?*

The levels (rows) are
hierarchically clustered based on the reduction in the chi-squared test of association between the categorical variable and the target. At each step, the two levels that give the least reduction in the chisquared statistic are merged. The process is continued until the reduction in chi-squared drops below some threshold (for example, 99%).  This method was developed by Greenacre.

*What are the representative code snippets?* 

<pre><code> proc means data=imputed noprint nway;
	class branch;
	var ins;
	output out=level mean=prop;
run;

proc cluster data=level method=ward
		outtree=fortree;
	freq _freq_;
	var prop;
	id branch;
run;</pre></code>

- `method=ward` - needed for completing the reduction process
- `outtree=fortree` creates an output data set that can be used by the TREE procedure to draw a tree diagram.
- `freq _freq_`counts the number of cases

**Note: There is a detailed process in CH3 Pg 13-21 that walks through many steps in the variable reduction process.  Seems too detailed to be on the test, but it is a nice reference**

**Variable Clustering and Screening**

*What is the purpose of `Proc Varclus`?*

Reduce the number of variables through a technique similar to principal component analysis.

*How does the computation play out and/or what are the representative code snippets?*

<pre><code>proc varclus data=imputed
		maxeigen=.7
		outtree=fortree
		short;
	var &inputs brclus1-brclus4 miacctag
	miphone mipos miposamt miinv
	miinvbal micc miccbal miccpurc
	miincome mihmown milores mihmval
	miage micrscor;
run;</pre></code>

*How do we measure the performance of different {insert}?*

*How do you interpret the results?*

*What is the difference between {insert} and {similar models}?*






**WIP**
Variable Screening
Check non-linear relationship
Missing values and the implication on modeling and predicting
Sampling methods
