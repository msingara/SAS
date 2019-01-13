/* Import data from the folder */
proc import datafile='G:\My Drive\DSBA-6201 Data\SAS Demo\Votes.xls'
DBMS=xls out=votes replace; 

TITLE 'VOTES';
 
proc print data=votes; 
run;

TITLE 'PROC UNIVARIATE FOR SAVINGS AND POVERTY';
proc univariate data=votes NORMAL PLOT;
 var savings poverty; 
run;

/*INCOME has longish tail, take a log transform, (use LINCOME = log(INCOME)) and then use LINCOME as one of predictor
Used Log for Savings also, as it has similar values as that of income*/
data votes; set votes;
   lincome = log(income);
   lsavings = log(savings);
run;

/* Keep the first 500 records as a training set (call it VOTETRAIN)*/
data VOTETRAIN;
   set votes (FIRSTOBS=1 OBS=500);
   run;

TITLE 'VOTETRAIN';

proc print data=VOTETRAIN;
run;

/* the remaining 232 will be used as a test set (VOTETEST).*/
data VOTETEST;
 set votes (FIRSTOBS=501 OBS=MAX);
 run;

 TITLE 'VOTETEST';
proc print data=VOTETEST;
run;

TITLE 'Developing Regression model using train model';
proc reg data=VOTETRAIN;
model votes = lincome  lsavings  female density poverty veterans / tol vif
collin;
plot r.*p.;
run;

TITLE 'Testing model';
data mod_test; set VOTETEST;
y_bar = -73.612 + (1.89198*lincome) + (0.41322*lsavings) + (1.36354 *female) +(0.00246*density) + (0.95097*poverty) + (0.56859*veterans);
Predicted_err = ((votes -y_bar)**2);
run;
proc print data=mod_test;
run;
