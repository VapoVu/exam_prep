### Review for SAS Certified Statistical Business Analyst Using SAS 9: Regression and Modeling Credential

Based in part on [the SAS page about the exam](http://support.sas.com/certify/creds/sba.html).

Exam topics include:

**[ANOVA](#anova)**
- [Verify the assumptions of ANOVA](#verify-the-assumptions-of-anova)
- [Analyze differences between population means using the GLM and TTEST procedures](#analyze-differences-between-population-means-using-the-glm-and-ttest-procedures)
- Perform ANOVA post hoc test to evaluate treatment effect
- Detect and analyze interactions between factors

**[Linear Regression](#linear-regression)**
- Fit a multiple linear regression model using the REG and GLM procedures
- Analyze the output of the REG procedure for multiple linear regression models
- Use the REG procedure to perform model selection
- Assess the validity of a given regression model through the use of diagnostic and residual analysis

**[Logistic Regression](#logistic-regression)**
- Perform logistic regression with the LOGISTIC procedure
- Optimize model performance through input selection
- Interpret the output of the LOGISTIC procedure
- Score new data sets using the LOGISTIC and SCORE procedures

**[Prepare Inputs for Predictive Model Performance](#prepare-inputs-for-predictive-model-performance)**
- Identify potential problems with input data
- Use the DATA step to manipulate data with loops, arrays, conditional statements and functions
- Reduce the number of categorical levels in a predictive model
- Screen variables for irrelevance using the CORR procedure
- Screen variables for non-linearity using empirical logit plots

**[Measure Model Performance](#measure-model-performance)**
- Apply the principles of honest assessment to model performance measurement
- Assess classifier performance using the confusion matrix
- Model selection and validation using training and validation data
- Create and interpret graphs (ROC, lift, and gain charts) for model comparison and selection
- Establish effective decision cut-off values for scoring

**[Overview of SAS Procedures](#overview-of-sas-procedures)**
- [`PROC TTEST`](#proc-ttest)
- [`PROC GLM`](#proc-glm)
- `PROC REG`
- `PROC LOGISTIC`
- `PROC SCORE`
- `PROC CORR`
- DATA Step Manipulations
  - Loops
  - Arrays
  - Conditional Statements
  - Functions

----

#### ANOVA

*Analysis of variance (ANOVA)* is a statistical technique used to compare the means of two or more groups of observations or treatments. For this type of problem, you have the following:
- A continuous dependent variable, or *response* variable
- A discreet independent variable, also called a *predictor* or *explanatory* variable. 

Another way of asking: Does information about group membership help predict the level of a numeric response?

If you analyze the difference between two means using ANOVA, you reach the same conclusions as you reach using a pooled, two-group t-test. Performing a two-group mean comparison in `PROC GLM` gives you access to different graphical and assessment tools than performing the same comparison in `PROC TTEST`.

Possible ANOVA research questions:
- Do people spend different amounts depending on which type of credit card they have?
- Does the type of fertilizer used affect the average weight of garlic grown in Montana? 
  - If the researcher are only interested in these specific four fertilizers, this is known as a **fixed effect**. 
  - If the fertilizers used were a sample of many that can be used, the sampling variability of fertilizers would need to be taken into account in the model and the fertilizer variable would be treated as a **random effect**.

##### Verify the assumptions of ANOVA

The ANOVA assumptions are as follows:

1. **Independent Observations**: No observations provide any information about any other observation. For example, measurements are not repeated on the same subject.
2. **Normally Distributed Data for Each Group**: The assumption of normality can be relaxed if the data are approximately normally distributed or if enough data are collected. Examine plots of the data to verify.
3. **Errors are Normally Distributed**: Use diagnostic plots from `PROC GLM` to verify the assumption.
4. **Equal Variances for Each Group**: Use the Folded-F test. The null is that they are equal, so we want to fail to reject. The Folded-F test automatically appears when you run a t-test. To look for equal variances, first look for the p-value section of the *Equal Variance* t-test (Pooled) and then look for the p-value under *Equality of Variances Test (Folded-F)*. You can end up with different answers for these:
  1. Check the assumption of equal variances and then use the appropriate test for equal means. If you fail to reject the F statistic on the Folded F, there is not enough evidence to reject the null hypothesis of equal variances. If you reject the assumption of equal variances, then simply use the unequal variance line (instead of equal) for step 2.
  2. Use the equal variance t-test line in the output to test whether the means of the two populations are equal.
  3. If using `PROC GLM`, use the `HOVTEST` option in the `MEANS` statement. The null hypothesis is that the variances are equal for all populations.

When there are three or more levels for the grouping variable, a simple approach is to run a series of t-tests between all the pairs of levels. For example, you might be interested in T-cell counts in patients taking three medications (including one placebo). You could simply run a t-test for each pair of medications. A more powerful approach is to analyze all the data simultaneously. The mathematical model is called a *one-way analysis of variance* (ANOVA) and the test statistic is the *F* ratio, rather than the Student's *t* value.

With the F-test, the number of **degrees of freedom** can be thought of as the number of independent pieces of information:
- Model DF is the number of treatments minus 1
- Corrected total DF is the sample size minus 1
- Error DF is the sample size minus the number of treatments (or the difference between the corrected total DF and the Model DF).

##### Analyze differences between population means using the GLM and TTEST procedures

In the following example, the `SHOWNULL` option will include the reference line for the null hypothesis on the charts:
```
PROC TTEST DATA = sasuser.TestScores PLOTS(SHOWNULL) = INTERVAL;
    CLASS Gender;
    VAR   SATScore;
    TITLE "Two-Sample t-test Comparing Girls to Boys";
RUN;
```

In ANOVA with more than one predictor variable, the `HOVTEST` option is unavailable. In those circumstances, you can plot the residuals against their predicted values to visually assess whether the variability is constant across groups.

Here's an example of testing ANOVA assumptions with `PROC GLM`:
```
PROC GLM DATA = sasuser.MGGarlic PLOTS(ONLY) = DIAGNOSTICS;
    CLASS Fertilizer;
    MODEL BulbWt = Fertilizer;
    MEANS Fertilizer / HOVTEST;
    TITLE 'Testing for Equality of Means with PROC GLM';
RUN;
QUIT;
```
- `DIAGNOSTICS` produces a panel display of diagnostic plots for linear models.

Recall that the `Total Sum of Squares = Model Sum of Squares + Error Sum of Squares`.

The *Model Sum of Squares* is referred to as SSM or SS<sub>M</sub> or **Between Group Variation**. This is the **explained error**. The model explains it.

The *Error Sum of Squares* is referred to as SSE or SS<sub>E</sub> or **Within Group Variation**. This is the **unexplained error**.

**R<sup>2</sup>** - the *coefficient of determination* - is the *proportion of variance accounted for by the model*, and is calculated as SS<sub>M</sub>/SS<sub>T</sub>


##### Perform ANOVA post hoc test to evaluate treatment effect (p .2-51)

After you find a significant effect of an independent variable in ANOVA, you may want to perform pairwise comparisons.

When you control the comparisonwise error rate (CER), you fix the level of alpha for a single comparison, without taking into consideration all the pairwise comparisons that you are making.

The experimentwise error rate (EER) uses an alpha that takes into consideration all the pairwise comparisons that you are making. Presuming no differences exist, the chance that you falsely conclude that **at least one** difference exists is much higher when you consider all possible comparisons.

*If you want to make sure that the error rate is 0.05 for the entire set of comparisons, use a method that controls the experimentwise error rate at 0.05.*

All of these comparison methods are requested with options in the `LSMEANS` statement of [`PROC GLM`](#proc-glm).

For Comparisonwise Control: `LSMEANS /PDIFF=ALL ADJUST=T`

For Experimentwise Control: `LSMEANS /PDIFF=ALL ADJUST=TUKEY`
or `PDIFF=CONTROL('control level') ADJUST=DUNNETT`




##### Detect and analyze interactions between factors


----

#### Linear Regression
##### Fit a multiple linear regression model using the REG and GLM procedures
##### Analyze the output of the REG procedure for multiple linear regression models
##### Use the REG procedure to perform model selection
##### Assess the validity of a given regression model through the use of diagnostic and residual analysis

----

#### Logistic Regression
##### Perform logistic regression with the LOGISTIC procedure
##### Optimize model performance through input selection
##### Interpret the output of the LOGISTIC procedure
##### Score new data sets using the LOGISTIC and SCORE procedures

----

#### Prepare Inputs for Predictive Model Performance
##### Identify potential problems with input data
##### Use the DATA step to manipulate data with loops, arrays, conditional statements and functions
##### Reduce the number of categorical levels in a predictive model
##### Screen variables for irrelevance using the CORR procedure
##### Screen variables for non-linearity using empirical logit plots

----

#### Measure Model Performance
##### Apply the principles of honest assessment to model performance measurement
##### Assess classifier performance using the confusion matrix
##### Model selection and validation using training and validation data
##### Create and interpret graphs (ROC, lift, and gain charts) for model comparison and selection
##### Establish effective decision cut-off values for scoring

----

#### Overview of SAS Procedures

##### `PROC TTEST`

This is the general form of `PROC TTEST`:
```
PROC TTEST DATA = dataset;
    CLASS  variable;
    VAR    variables;
    PAIRED variable1*variable2;
RUN;
```

- `CLASS` specifies the two-level variable for the analysis. Only one variable is allowed in this statement. Gender is an example.
- `VAR` specifies numeric response variables for the analysis. If the `VAR` statement is not specified, the procedure analyzes all numeric variables in the input data set that are not listed in a `CLASS` or `BY` statement.
- `PAIRED` specifies pairs of numeric response variables from which different scores (variable 1 - variable 2) are calculated. A one-sample t-test is then performed on the difference scores. The example from the Analytics Primer was examining male vs. female salary, where the pairing was done by position level in a company (to ensure fair comparisons were made).

##### `PROC GLM`

This is the general form of `PROC GLM`:
```
PROC GLM DATA = dataset PLOTS = options;
    CLASS variables;
    MODEL dependent = independents </options>;
    MEANS effects </options>;
    LSMEANS effects </options>;
    OUTPUT OUT = dataset KEYWORD = variable;
RUN;
QUIT;
```

- `CLASS` specifies classification variables for the analysis
- `MODEL` specifies dependent and independent variables for the analysis
- `MEANS` computes unadjusted means of the dependent variables for each value of the specified effect
- `LSMEANS` produces adjusted means for the outcome variable, broken out by the variable specified and adjusting for any other explanatory variables included in the `MODEL` statement
- `OUTPUT` specifies an output data set that contains all variables from the input data set and variables that represent statistics from the analysis

For Comparisonwise Control: `LSMEANS /PDIFF=ALL ADJUST=T`

For Experimentwise Control: `LSMEANS /PDIFF=ALL ADJUST=TUKEY`
or `PDIFF=CONTROL('control level') ADJUST=DUNNETT`