/*Linear Regression for Business Analyst Test*/

/*A p-value measures the probability of observing a value as extreme 
  or more extreme than the one observed, simply by chance, given that
  the null hypothesis is true.*/

/*Assumptions of multiple linear regression*/
/*The means of the Ys is accurately modeled by a linear function of the Xs.
  The random error term has a normal distribution with a mean of 0.
  The random error term has constant variance.
  The errors are independent.
  No perfect collinearity.*/

/*Interpretation of Beta0: corresponds to the value of the response 
                           variable when the predictor is 0*/

/*Intepretation of Beta1: corresponds to the magnitude of change in the 
                          response variable given a one unit change in
                          the predictor variable*/

/*Interpretation of the intercept: mean value of y when x is 0
                                   (known as the baseline model)*/

/* PROC REG provides the following capabilities:
   multiple MODEL statements
   nine model-selection methods
   interactive changes both in the model and the data used to fit the model
   linear equality restrictions on parameters
   tests of linear hypotheses and multivariate hypotheses
   collinearity diagnostics
   predicted values, residuals, studentized residuals, confidence limits, and influence statistics
   correlation or crossproduct input
   requested statistics available for output through output data sets
   ODS Graphics is now available.*/

/*Fitting a Multiple Linear Regression Model*/
ods graphics off;
proc reg data=sasuser.fitness;
    model Oxygen_Consumption=Performance RunTime;
    title 'Multiple Linear Regression for Fitness Data';
run;
quit;

ods graphics on;

/*Interpreting the output: Here we can see that the overall F test is significant,
                           which implies that at least one Betai is not 0.
                           RunTime is also statistically significant.*/

/*PROC GLM GIVES SIMILAR RESULTS, but it also gives Type I and Type III stats, look at Type III for MLR*/
ods graphics off;
proc glm data=sasuser.fitness;
    model Oxygen_Consumption=Performance RunTime;
    title 'Multiple Linear Regression for Fitness Data';
run;
quit;

ods graphics on;

/*Difference between PROG REG and PROC GLM:
   Proc reg performs simple linear regression. The REG procedure allows several 
   MODEL statements and gives additional regression diagnostics, especially for 
   detection of collinearity, while proc GLM does not. Proc GLM also performs ANOVA
   and handles categorical variables with a CLASS statement.*/

/*Using PROC REG to perform model selection*/

/*The SELECTION = option in the model statement of PROC REG supports STEPWISE selection 
  methods (forward, backward, and stepwise) and also ALL POSSIBLE regressions ranked 
  using RSQUARE, ADJRSQ, or CP*/

/*Mallows CP - simple indicator of effective variable selection within a model.
  Look for models with Cp <= p where p is number of parameters in the model,
  INCLUDING THE INTERCEPT*/

/*Hocking's Criterion suggests Cp <= p for prediction and 
  Cp <= 2p - p(full) + 1 for parameter estimation, where 
  p(full) is all variables in the model*/

/*Best models using all-regression option*/
/*st103d05.sas*/  /*Part A*/
ods graphics / imagemap=on;

proc reg data=sasuser.fitness plots(only)=(rsquare adjrsq cp);
    ALL_REG: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=rsquare adjrsq cp;
    title 'Best Models Using All-Regression Option';
run;
quit;

/*can only use R square value to compare models of equal number
of parameters*/
/*We see from the output of these plots that the highest R square
 use 6 or 7 parameters*/

/*Now we look at only Cp stats to determine best model*/
ods graphics / imagemap=on;

proc reg data=sasuser.fitness plots(only)=(cp);
    ALL_REG: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=cp rsquare adjrsq best=20;
    title 'Best Models Using All-Regression Option';
run;
quit;

/*For Mallows Cp stat, look at points closest below or on the line
for the "best" model*/
/*The smallest model that falls under the Hocking line has 
  p = 6.  The model with the smaller Cp value will be 
  considered the "best" explanatory model*/


/*Stepwise Selection Techniques*/
proc reg data=sasuser.fitness plots(only)=adjrsq;
   FORWARD:  model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=forward;
   BACKWARD: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=backward;
   STEPWISE: model oxygen_consumption 
                    = Performance RunTime Age Weight
                      Run_Pulse Rest_Pulse Maximum_Pulse
            / selection=stepwise;
   title 'Best Models Using Stepwise Selection';
run;
quit;


/*Checking for multicollinearity*/

/* VIF – useful in determining which variables are involved in multicollinearity. 
Greater than 10 indicate the strong presence of multicollinearity.  
Can use VIF option in MODEL statement of PROC REG to get the variance inflation factor.*/

ods graphics off;
proc reg data=sasuser.fitness;
    model Oxygen_Consumption=Performance RunTime Age Weight Run_Pulse
                             Rest_Pulse Maximum_Pulse / VIF;
    title 'Multiple Linear Regression for Fitness Data';
run;
quit;

/*for PROC REG, have to create interaction terms using a data step*/
/*for PROC GLM, | creates interactions and @2 specifies only two way*/

ods graphics off;
proc glm data=sasuser.fitness;
    model Oxygen_Consumption=Performance | RunTime | Age | Weight | Run_Pulse | 
                             Rest_Pulse | Maximum_Pulse @2;
    title 'Multiple Linear Regression for Fitness Data';
run;
quit;

/*Diagnostic and Residual Analysis*/

/*NORMALITY: can look at QQ plot or do this:*/

options formdlim="_";
proc reg data=sasuser.school 
	plots (only)=diagnostics (unpack); /*Diagnostics default is 3x3 matrix of plots: unpack splits them into separate pictures*/
   	model reading3 = words1 letters1 phonics1; /*y = x2 x2 x3...xn*/
	output out=out r=residuals; /*output out=datasetname r=variablenameofresiduals (used to save residuals)*/
title 'School Data: Regression and Diagnostics';
run;
quit;                                

/*Shows us if residuals are normal.  Looks at Test for Normality and look at A-D or K-S test.
Null Hyp is normality*/
proc univariate data=out normal;
  var residuals;
run;

/*CONSTANT VARIANCE - want plots of residuals vs. predicted values or independent variables 
to appear random.  Can also use the Spearman Rank Correlation Coeff. in PROC CORR*/



