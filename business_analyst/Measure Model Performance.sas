/*******************              Measure Model Performance      ***********************/
	/*Apply the principles of honest assessment to model performance measurement*/
		/*Section 4.1 in Predictive Modeling Using Logistic Regression */
/*			Overfitting is likely to be a problem with a small dataset and a flexible model*/
/*			Basic procedure for avoiding overfitting:*/
/*				Split data into training and validation*/
/*				Create model using training data*/
/*				Select best model using validation data set*/
/*				Once model is selected, refit with entire data set to get final values for coefficients */
/*			v-fold cross-validation:*/
/*				Time-consuming, but all data is used for both validation and assessment*/
/*				Good if you don't have a ton of data.*/
/*				Split data into v equal subsets.  */
/*				Do v model selections, using each subset as the holdout*/
/*				Average the resulting models*/
/*			Data can be split using PROC SURVEYSELECT*/
				 
	/*Assess classifier performance using the confusion matrix*/
		/*Section 4.2 in Predictive Modeling Using Logistic Regression */
			/* Confusing matrix is a 2X2 chart:
								Predicted	
							0			1		
				Actual	0	True Neg	False Pos
						1	False Neg	True Pos
			*/
			/*Accuracy: True Pos & Neg / Number of cases*/
			/*Missclassficiation: False Pos & False Neg / Number of Cases*/
			/*Sensitivity: True Pos / Predicted Pos*/
			/*Specificity: True Neg / Predicted Neg*/
			/*PV+: True Positives / Predicted Positives*/
			/*Depth: The depth of a classification rule is the total proportion of cases 
			that were allocated to class 1.*/
	/*Model selection and validation using training and validation data*/
	/*Create and interpret graphs (ROC, lift, and gains charts) for model comparison and selection*/
	/*Gain chart: 
		Graph of PV+ with Depth.  
		When cuttoff is high, depth is low and PV+ should be high.
		When cuttoff is low, model predicts lots of positives, so depth is high and PV+ should
		approach */

/*NOTE: Need a libname before this will run*/
proc logistic data=Logistic.penalty;
	class culp(param=ref ref='5');
	model death(event='1') = blackd whitvic culp /outroc=ROC;
	ROC 'Omit Culpability' blackd whitvic;
	ROC 'Omit Defendant Race' whitvic culp;
	ROC 'Omit Victim Race' blackd culp;
	ROCcontrast / estimate=allpairs;
	title 'Comparing ROC Curves';
run;

	/*Establish effective decision cut-off values for scoring*/
/*		In order to choose a cut-off, we needs a decision criteria to know how*/
/*		to balance sensitivity and specificity.*/
/*		Bayes's rule chooses optimal cuttoff if you assign costs to false negatives and positives*/
