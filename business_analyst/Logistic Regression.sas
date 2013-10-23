/********************             Logistic Regression			************************/
/*Libname to bring in the data sets from our logisitic class.*/
libname Logistic 'C:\Users\LukasHalim\Google Drive\Fall Coursework\Logistic\Logistic Data';
	/*Perform logistic regression with the LOGISTIC procedure*/
	/*General form of the LOGISTIC procedure: */
/*SYNTAX*/
PROC LOGISTIC DATA=SAS-data-set <options>;  
	CLASS variables </option>;  
	MODEL response=predictors </options>;  
	UNITS predictor1=list1 </option>;  
	SCORE <options>; 
RUN; 

/*EXAMPLE:*/
proc logistic data=Logistic.penalty plots(only)=(effect(clband showobs) oddsratio);
	model death(event='1') = blackd whitvic serious / clodds=pl;
	title 'Death Penalty Model';
run;

	/*Interpret the output of the LOGISTIC procedure*/

	/*Optimize model performance through input selection (forward, backward) */
/*SELECTION=SCORE does all models*/


/*Score new data sets using LOGISTIC and SCORE procedures (options and output)*/
PROC SCORE DATA=SAS-data-set <options>;  
	VAR variables; 
RUN; 
	/*Prepare Inputs for Predictive Model Performance*/
	/*Why spend the time reducing redundant inputs?*/
		/*Redundant inputs destabilizing the parameter estimates*/
		/*increasing the risk of overfitting*/
		/*confounding interpretation*/
		/*increasing computation time*/
		/*increasing scoring effort*/
		/*increasing the cost of data collection and augmentation. */


	/*PROC VARCLUS*/
/*Variable clustering is similar to Principal Component analysis, in that it
reduces numeric variables. However, 
"The chief advantage of variable clustering over principal components is the coefficients. 
The coefficients of the PCs (eigenvectors) are usually nonzero for all the original variables. 
Thus, even if only a few PCs were used, all the inputs would still have to be retained in 
the analysis. In contrast, the cluster component scores have nonzero coefficients on disjosint 
subsets of the variables." From 3-24 in Predictive Modeling Using Logistic Regression */

/*The VarClus algorithm starts by grouping all the variables in a single cluster, then does*/
/*binary splits until the eigenvalue of the 2nd principal component falls below a specified*/
/*threshold.  In other words, it splits until all the variables in the cluster are highly*/
/*correlated with each other.*/

/*The MAXEIGEN= option specifies largest permissible value of the 2nd eigenvalue in each cluster. */
/*short limits the output of the proc*/

/*dendrogram: tree diagram used to illustrate the results of hierarchical clustering. */

/*Using results of VARCLUS: you can either replace the variables with the cluster scores,*/
/*or choose variables which are highly correlated with their own cluster and */
/*uncorrlated with the other clusters*/
proc varclus data=Logistic.Travel MaxEigen=.7 short;
	var MODE TTME HINC PSIZE CHOICE TIME COST;
run;

	/*Training data/validation data/test data (~3 questions)*/
/*Simplest method: create models with training data, then validate*/
/*Three step: do a final test*/
/*Small data sets: v-fold cross validation.  Split data v ways, create models using 1 part*/
/*as test and the remainder as training.  Repeat v times, using a different part as the */
/*test data set each time.  Takes longer, but good when you don't have enough data*/
/*PROC SURVEYSELECT can be used to split data*/

	/*Effect/reference coding*/
/*By default, SAS will use effects coding. If we have low, medium, and high as categories, */
/*we need two dummy variables and have to set a reference level. If we select high as the */
/*reference variable, it is coded as -1 in the fields of the other variables. With */
/*reference coding, we are comparing one of the categories to the overall average. */
/*Is low income different, in the probability of doing something, versus the overall */
/*probability of doing something in all groups. With effects coding, we can only ask */
/*if the design variable levels are different. We cannot ask if the reference variable */
/*is different (we will do that in the fall).*/

	/*Interpretation of odds ratio*/
/*An odds ratio indicates how much more likely, with respect to odds, 
a certain event occurs in one group relative to its occurrence in another group.*/

	/*Calculate probability from odds ratio/logit*/
/*logit p_i = ln(p_i/1-pi)*/

	/*Confusion matrix*/
/*Confusion matrix is a 2X2 matrix showing correct/incorrect events/nonevents*/
/*accuracy: (true positives and negatives) / (total cases) */
/*error rate: (false positives and negatives) / (total cases) = 1 - accuracy*/
/*sensitivity: (true positives) / (total actual positives) */
/*Sensitivity: how many positives did you get at of those that were there*/
/*specificity: (true negatives) / (total actual negatives) */
/*how many many negatives did you get out of those that were there*/
/*positive predicted value (PV+): (true positives) / (total predicted positives)	*/
/*negative predicted value (PV-): (true negatives) / (total predicted positives) */


/*LIFT:*/
/*Essentially Lift is how much better your model is at predicted positives*/
/*than chance.*/
/*Note that if you just assume everything is an event, then lift will be 1*/
/*PV+ / Prior Probability */
/*Confidence / Expected Confidence */
/*(Correctly Predicted Events / Total Predicted Events) / (# of Actual Events / # Possible Events) */

/*SCORE statement in PROC Logistic*/
/*The SCORE statement in the LOGISTIC procedure will correct predicted probabilities */
/*back to the population scale. The option to do this is PRIOREVENT=. */
