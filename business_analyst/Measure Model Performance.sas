/**************************************	ANOVA ******************************************/
	/*Verify the assumptions of ANOVA*/
		/*Independence of Errors*/
			/*Good data collection designs help ensure the independence assumption. */
		/*Homogeneity of Variance among groups: 
			Use HOVTEST option to perform Levene?s test for homogeneity of variances. 
			The null hypothesis for this test is that the variances are equal. 
			Levene?s test is the default. */
		/*Errors are normally distributed*/
			/*Q-Q Plot*/
proc glm data=sasuser.MGGarlic plots(only)=diagnostics;    
	class Fertilizer;    
	model BulbWt=Fertilizer;    
	means Fertilizer / hovtest;    
	title 'Testing for ANOVA Assuptions with PROC GLM'; 
	title2 'Check Q-Q plot for normal distribution of errors';
	title3 "Check Levene's HOV test for homogeneity of variance.  Null hypothesis is equal variances.";
run; 
quit; 

	/*Analyze differences between population means using the GLM and TTEST procedures*/
	/*In this case, the p-value is too high - not enough evidence to reject the null hypothesis*/
proc glm data=sasuser.MGGarlic;    
	class Fertilizer;    
	model BulbWt=Fertilizer;    
	title 'Analyze differences between population means using the GLM procedure'; 
run; 
quit; 

	/* HOV test P-value is above .05, so we do not reject the null hypothesis of equal variances.	*/
	/* Q-Q Plot shows ~ normal */
proc ttest data=sasuser.German plots(shownull)=interval;    
	class Group;    
	var Change;    
	title "Analyze differences between population means using the TTEST procedure"; 
run;
quit; 
	/*Perform ANOVA post hoc test to evaluate treatment effect*/
	/*Detect and analyze interactions between factors*/

/********************             Linear Regression 			***********************/
	/*Fit a multiple linear regression model using the REG and GLM procedures*/
	/*Analyze the output of the REG procedure for multiple linear regression models*/
	/*Use the REG procedure to perform model selection*/
	/*Assess the validity of a given regression model through the use of diagnostic and residual analysis*/

/********************             Logistic Regression			************************/
	/*Perform logistic regression with the LOGISTIC procedure*/
	/*Optimize model performance through input selection*/
	/*Interpret the output of the LOGISTIC procedure*/
	/*Score new data sets using the LOGISTIC and SCORE procedures*/
	/*Prepare Inputs for Predictive Model Performance*/

/*************       Identify potential problems with input data ************************/
	/*Use the DATA step to manipulate data with loops, arrays, conditional statements and functions*/
	/*Reduce the number of categorical levels in a predictive model*/
	/*Screen variables for irrelevance using the CORR procedure*/
	/*Screen variables for non-linearity using empirical logit plots*/

/*******************              Measure Model Performance      ***********************/
	/*Apply the principles of honest assessment to model performance measurement*/
	/*Assess classifier performance using the confusion matrix*/
	/*Model selection and validation using training and validation data*/
	/*Create and interpret graphs (ROC, lift, and gains charts) for model comparison and selection*/
	/*Establish effective decision cut-off values for scoring*/
