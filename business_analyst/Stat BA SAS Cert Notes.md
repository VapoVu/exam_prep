#Business Analyst Certification Notes - Predictive Modeling Using Logistic Regression

##Fitting a Model w/ PROC LOGISTIC

Sample Logistic Code...

<pre><code>proc logistic data=develop des;
class res (param=ref ref='S');
model ins = dda ddabal dep depamt
cashbk checks res
/ stb;
units ddabal=1000 depamt=1000;
run;</pre></code>

`DES` (short for descending) option is used to reverse the
sorting order for the levels of the response variable Ins.

`STB` displays the standardized estimates for the parameters for the continuous input variables. For the intercept parameters and parameters associated with a CLASS variable, the standardized estimates are set to missing.  For example, the variable RES has no standardized estimate because it is a class variable.


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

The linear combination produced by `PROC SCORE` (the variable Ins) estimates the logit, not the posterior probability. 

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
 - To standardize, leave this option off. Standardizing is used for when you are adding polynomial terms to the regression equation.  You need to stardardize the main effects before adding the polynomials (in a data step) to help prevent multi-colinearity.
- `method=mean` the method used to impute the values
- `out=imputed` output the data with the imputed values into a new data set called `imputed`.

Additional Options in the `PROC STDIZE` Statement

*Specify standardization methods*

- `NOMISS` omits observations with any missing values from computation
- `MISSING=` specifies the method or a numeric value for replacing missing values
- `REPLACE` replaces missing data with zero in the standardized data

*Alternative Method for Dealing with Missing Values*

 - Setup a dummy variable that indicates whether you imputed
 - Use Decision Trees to predict the value (alternate method to clustering)
 - Fit a regression line of that x with missing values vs. the other x's.  Use this regression line to predict the missing values and use these 
  - Note: there can be missing values within the new regression. Not sure how to deal with these...


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


###Variable Screening

Consolidate / Remove Variables with a high correlation and high Hoeffding D statistic

**Hoeffding** 

*What is the purpose?*
 
- another assessment of relationships between variables that works better on non-linear variables.
- Range: -.5 to 1 (lower is better for modeling)

*How to enable?*

<pre><code>ods output spearmancorr=spearman
hoeffdingcorr=hoeffding;

proc corr data=imputed spearman hoeffding rank;
	var &reduced;
	with ins;
run;</pre></code>

`rank` RANK option prints the correlation coefficients for
each variable in order from highest to lowest.


###Check non-linear relationship

Modeling Check list

**Model Prep**
1. Plot variables (ex. distribution). Note outliers and influential observations.
2. Plot diagnostics in `PROC REG` (variables against each other and against Y) to validate assumptions. output saves into new dataset. You can then read the residual data into `proc univariate` to conduct formal tests on (normality) assumptions.
3. Check for multi-colinearity and interactions via VIF, `PROC CORR` and model statement in `PROC GLM`
4. Check for non-linearity via `PROC REG` diagnostics and hoeffding d, Empirical Logits.  Use `PROC STDIZE` to standardize main effects and a `DATA STEP` to add the polynomial terms.  (Log) Transformations can be done in `PROC TRANSREG`
5. Impute Missing Values via `PROC STDIZE`

**Build & Evaluate Model**
1. Run Model Selection Techniques in `PROC REG` or `PROC LOGISTIC`
2. Evaluate Model Fit for REG: w/ Adj R-Squared, Mallow's Cp, AIC, SBC; for Logistic: KS, Wilcoxon via `PROC 
3. 1WAY` 
3. Run model on validation data set via `PROC SCORE` and evaluate model fit



###Subset Selection

 - Stepwise, Backward, Best

##Ch 4 - Measuring Classifier Performance

###Splitting Data into Training and Validation

*What is the purpose of Splitting the Data?*

To give you data with which you can test your model. 

*What procs split the data?*

`PROC SURVEYSELECT`

*What are the representative code snippets?*

<pre><code>proc sort data=develop out=develop;
	by ins;
run;

proc surveyselect noprint data = develop
		samprate=.6667
		out=develop
		seed=44444
		outall;
	strata ins;
run;</pre></code>

To create a stratified sample, the data must be sorted by the stratum variable.  See `PROC SORT` code.

`SAMPRATE=` option specifies what proportion of the develop data set should be selected.

`outall` option can be
used to return the initial data set augmented by a flag to indicate selection in the sample

###Honest Assessment

 - Split Data into Train, Validation, Test (optional)

###Misclassification

**Confusion Matrix**

 - Sensitivity
 - Specificity
 - Positive Predictive Value
 - Negative Predictive Value

**ROC Curve**

![pic](pics/img_06.png)

The ROC curve displays the sensitivity and specificity for the entire range of cutoff values. As the cutoff decreases, more and more cases are allocated to class 1; hence, the sensitivity increases and specificity decreases. As the cutoff increases, more and more cases are allocated to class 0, hence the sensitivity decreases and specificity increases. 

Consequently, the ROC curve intersects (0,0) and (1,1). If the posterior probabilities were arbitrarily assigned to the cases, then the ratio of false positives to true positives would be the same as the ratio of the total actual negatives to the total actual positives. Consequently, the baseline (random) model is a 45° angle going through the origin. 

As the ROC curve bows above the diagonal, the predictive power increases. A perfect model would reach the (0,1) point where both sensitivity and specificity equal 1.

**Gains Chart**

![pic](pics/img_05.png)

The *depth* of a classification rule is the total proportion of cases that were allocated to class 1. 

The (cumulative) gains chart displays the positive predicted value and depth for a range of cutoff values.

As the cutoff decreases, more and more cases are allocated to class 1; hence, the depth increases and the PV+ approaches the marginal event rate. When the cutoff is minimum, then 100% of the cases are selected and the response rate is ρ1. 

As the cutoff increases the depth decreases. A model with good predictive power would have increasing PV+ (response rate) as the depth decreases. If the posterior probabilities were arbitrarily assigned to the cases, then the gains chart would be a horizontal line at ρ1.

**Establishing Cutoffs- Bayes 4-48** - How to calculate?

**Adjustments for oversampling - 4-35** - How to calculate?

If the holdout data was obtained by splitting oversampled data, then it is oversampled as well. If the proper adjustments were made when the model was fitted, then the predicted posterior probabilities are correct. 

However, the confusion matrices would be incorrect (with regard to the population) because the event cases are over-represented. Consequently, PV+ (response rate) might be badly overestimated.

Sensitivity and specificity, however, are not affected by separate sampling because they do not depend on the proportion of each class in the sample.

###Imputing median values from Training into Validation data set

Use the `STDIZE` procedure with the `REPONLY` option to impute missing values on the training
data. In addition, specify the `OUTSTAT=` option to save the imputed values in a separate data set, called
med. 

<pre><code>proc stdize data = train out=train2
	method=median reponly
	OUTSTAT=med;
	var &inputs;
run;</pre></code>

After the med data set has been created, it can be used to impute for missing values in a different data set.

The code below creates a data set, valid2, based on the unimputed valid data, with the medians from the training data imputed. The option to specify the data set with the median information is
`METHOD=IN(data-set-name)`.

<pre><code>proc stdize data=valid out=valid2
	reponly method=in(med);
	var &inputs;
run;</pre></code>

##

Two specialized measures of classifier performance are sensitivity
(true positives) / (total actual positives)
and positive predicted value (PV+)
(true positives) / (total predicted positives).

The analogues to these measures for true negatives are specificity
(true negatives) / (total actual negatives)
and negative predicted value (PV–)
(true negatives) / (total predicted negatives).

###Allocation Rules

Assessing Model Fit

 - Optimization of Cost / Profit
 - MSE
 

##Assessing Ability to Discriminate - Overall Predictive Power

`PROC NPAR1WAY`

*What is the purpose of `PROC NPAR1WAY`?*

To assess the overall predictive power of the model...i.e. the best model should have a higher probability of scoring each observation correctly across the range of the distribution.   

Compute the following test statistics to see if two distributions (of probabilities) are different.

 - **T Test**: Nice test for comparing distributions of probabilities that are normal.  However, the distributions of the predicted posterior probabilities are typically asymmetric with unequal variance. 
 
 - **KS Test**: Measuring the maximum distance between two curves of cumulative distributions.  Goal is to have the largest distance (D) between the two curves. If the distance between the curves is 0, the probabilities are the same. 
   - Oversampling doesn't affect D because the empirical distribution function is unchanged if each case represents more than one case in the population.
   - is sensitive to all types of differences between the distributions – location, scale, and shape.
   - not particularly powerful at detecting location differences.
![pic](pics/img_04.png)

 - **Wilcoxon (C Statistic)**: nonparametric test that measures location differences well. The Wilcoxon-Mann-Whitney test statistic is also equivalent to the area under the ROC curve
  - Oversampling does not affect the area under the ROC curve because sensitivity and specificity are unaffected. 

*What are the representative code snippets?*

<pre><code> proc npar1way edf wilcoxon data=scoval;
	class ins;
	var p_1;
run;</pre></code>

`edf` requests KS 
`wilcoxon` requests wilcoxon

*How do you interpret the results?*
 
 - **T-Test**: H<sub>0</sub> is that the means are the same
 - **KS (D)**: Look for model with the largest D
 - **Wilcoxon (C)**: Score across a range of cutoffs. Higher C value the better as it is the area under the ROC curve. 




##Ch 5 - Generating and Evaluating Many Models

Alternative Method for Assessing Model Fit

 - Minimizing MSE (equivalently ASE) 
 
Note: A lot of code but doesn't seem to be relevant for the test.

#Stats Intro - Misc Notes

##Controlling Experiment-wise Error Rate

<pre><code>*Comparison Control: 

LSMEANS / PDIFF=ALL Adjust=T

*Experimentwise Control

LSMEANS / PDIFF = ALL ADJUST=TUKEY

LSMEANS / PDIFF = Control('control level') ADJUST = DUNNETT </pre></code>


![pic](pics/img_07.png)

![pic](pics/img_08.png)


###Testing for Interactions

Use `PROC GLM` to test the interactions

<pre><code>proc glm data =sasuser.drug order =internal;
    class DrugDose Disease;
    model Bloodp=DrugDose Disease DrugDose*Disease;
    lsmeans DrugDose*Disease / slice=Disease;
    title 'Analyze the Effects of DrugDose';
    title2 'at Each Level of Disease';
     format DrugDose dosefmt.;
run;
quit;</pre></code>

`class` needed for each categorical variable  

`*` indicates interaction  
`lsmeans` least squares means gives adjusted means
`slice` asks if there there a difference among drug doses at each level of the disease.  As if drug does is running its own ANOVA on each disease by itself.



#Practice Tests Question Follow ups

- Score statement in the logistic procedure returns only predicted probabilities, whereas the SCORE procedure returns only predicted logits.
- How to calculate the expected cell counts in chi-squared contingency table? row_tot*col_tot/total
- Empirical Logit
- Spearman in PROC CORR
- GLM: Model / Solution option
- REG: Model / LACKFIT option
- PROC SCORE vs. PROC Logistics
- Oversampling Bias - What is affected.
