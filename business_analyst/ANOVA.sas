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
proc glm data=sasuser.Ads1 plots(only)=diffplot(center);    
	class Ad Area;    
	model Sales=Ad Area;    
	lsmeans Ad / pdiff=all adjust=tukey;    
	title 'Tukey Pairwise Differences for Ad Types on Sales'; 
	title2 'Examine diffogram to see which are different at alpha=.05';
	title3 'Or look at the table called "Least Squares Means for effect Ad."';
run; 
quit; 

	/*Tukey (above) compares each level to all other levels, while Dunnett uses a reference level*/
	/*Dunnett shows average sales for paper, people, and radio are significantly different than Display*/
proc glm data=sasuser.Ads1 plots(only)=controlplot;    
	class Ad Area;    
	model Sales=Ad Area;    
	lsmeans Ad / pdiff=control('display') adjust=dunnett;    
	title 'Dunnett Pairwise Sales Differences for Ad Types, using Display as a reference level'; 
run; 
quit; 

/*Detect and analyze interactions between factors*/
proc sgplot data=means;    
	series x=DrugDose y=BloodP_Mean / group=Disease markers;    
	xaxis integer;    
	title 'Plot of Stratified Means in Drug Data Set';    
	format DrugDose dosefmt.; 
run; 
