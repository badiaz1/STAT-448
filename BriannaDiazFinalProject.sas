ods html close; 
options nodate nonumber leftmargin=1in rightmargin=1in;

ods escapechar="~";

title "Final project ~n Brianna Diaz ";
title2;

ods graphics on / width=4in height=3in;
ods rtf file= '/home/u60717148/Stat 448/Homework/briannadiazFinalproject.rtf'
	nogtitle startpage=no;
ods noproctitle;
ods startpage = no;


data abalone;
	infile '/home/u60717148/Stat 448/abalone.data' dlm=',';
	input sex $ length diameter height whole_weight meat_weight gut_weight shell_weight rings;
run;

ods text = "The data presented here is a data set about abalones from the UCI’s Machine Learning Database. The data provides information on sex, length, diameter, height, whole weight, meat weight, gut weight, shell weight, and the rings (for age). The sex in the database is divided into 3 sexes, female, male and infant. The wholesaler is trying to determine similarities and differences between sexes-based size and meat. The wholesaler is trying to understand how to identify certain sexes based on measurements. The wholesaler also wants to know if his claims are correct on his assumptions about difference between the sexes. We are also looking at how the meat weight is related to other predictors apart from gut and shell weight. Lastly, we are trying to group the sexes based of significant predictors for similarities and differences. ";

/*1*/


proc sort data=abalone;
by sex;
run;

proc univariate data=abalone;
  var length--shell_weight;
  histogram length -- shell_weight;
  by sex;
  ods select Moments BasicMeasures Histogram;
run;

ods text = "";

/*2*/

data abalone2;
set abalone;
where sex= 'M' OR sex='F';
run;

data abalone2;
set abalone2;
Fvar = sex = "F";
diameter2 = diameter*10;
height2 = height * 10;
run;

proc logistic data = abalone2 desc;
	model Fvar = length diameter2 height2 whole_weight/ selection=backward;
	ods select OddsRatios ParameterEstimates 
		GlobalTests ModelInfo FitStatistics;
run;

ods text = "Used a logistic analysis to see how the femals and males compare to one another in order to see how to identify females. The predictors that as significant in helping determine if an abalone is a female or not are the diameter, height, and whole weight. Based on the findings, because we rescaled the units for diameter and height, for every 1/10 unit increase diameter would have an 89% increase in odds of an abalone being female, and for height it is 68% increase in odds of an abalone being female. For whole weight there is 35% odds increase in an abalone being female based on one unit increase. ";

/*3*/

proc stepdisc data=abalone sle=.05 sls=.05;
   	class sex;
   	var length--shell_weight;
	ods select Summary;
run;

proc discrim data=abalone pool=test crossvalidate manova;
  	class sex;
  	var length--gut_weight;
   	ods select ChiSq ClassifiedCrossVal ErrorCrossVal;
run;

ods text = "Used a discrimate analysis to evaluate the classifiactions of the sexes
with their predictors. All the size and weight, apart from shell weight, predictors are significant in determining similarities and differences between the sexes. Looking at the error count estimates we can see that infant has the smallest percentage in being misclassified at 13%. For males and females, the misclassifications are much higher, 58% and 69.3% respectively. Because of the high misclassifications for males and females, it shows that that have strong similarities which is why they are hard to classify. Based off the results, it supports the wholesaler’s claims. ";
/*4*/

proc genmod data=abalone;
class sex; 
model meat_weight = sex length diameter height whole_weight rings/ dist=gamma link=log type1 type3 scale=deviance; 
ods select ModelInfo ModelFit ParameterEstimates Type1 Type3;
run;

ods text = "";

/*5*/
proc cluster data=abalone method=average std ccc pseudo outtree=about print=15 plots=all;
   var length -- shell_weight;
   copy sex;
   ods select ClusterHistory Dendrogram CccPsfAndPsTSqPlot;
run;

proc tree data=about noprint ncl=6 out=newab; 
   copy length -- shell_weight sex;
run;

proc sort data= newab;
by cluster;
run;

proc freq data=newab;
  tables cluster*sex/ nopercent norow nocol;
run;

proc means data=newab;
 var length -- shell_weight;
 by cluster;
run;
ods text = "Approached with using cluster analysis including cluster means. Cluster 1 is the cluster with the most infant observations. The means in this cluster are also the smallest out of all the cluster thus supporting how the measurements from infants are notably different than females and males. We can see cluster 2 has the most number observations with males leading in the cluster. However, the observations seem to be evenly distributed. In cluster 3, females are the leading observations but not by much. Cluster shows to have higher overall means. Looking at the clusters, it seems that more female and males are kept together than the infants. Thus showing the males and females are bigger and heavier and the infants are smaller and weigh less. ";

ods text = "Based on the results, it can be concluded that male and female abalone 
have similar attributes to one anothere compared to the infants. 
";


ods rtf close;