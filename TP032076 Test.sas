Proc import datafile='/home/u43002267/Assignment/VehicleInsurance_test.csv'
OUT=CARTEST
DBMS=CSV
replace;
sheet='cartest';
GETNAMES=YES;
mixed=yes;
RUN;

options missing = ' ';
data cartest;
   set cartest;
   if missing(cats(of _all_)) then delete;
run;

PROC CONTENTS DATA=CARTEST;
RUN;

PROC FREQ DATA=CARTEST;
TABLE Age Job Marital Education Default HHInsurance CarLoan Communication NoOfContacts PrevAttempts Outcome 
CarInsurance;
RUN;

PROC UNIVARIATE DATA=CARTEST ROBUSTSCALE PLOT;
VAR Age Balance LastContactDay NoOfContacts DaysPassed PrevAttempts;
RUN;

* DATA PRE-PROCESSING;
DATA CARTEST;
SET CARTEST;
if Education = 'NA' then Education = 'secondary';
if Job = 'NA' then Job = 'management';
if Communication = 'NA' then Communication = 'cellular';
RUN;

*Time Format;
data cartest;
set cartest;
Callstarttime = input(cats(callstart,"00"), hhmmss.);
Callendtime = input(cats(callend,"00"), hhmmss.);
Format Callstarttime time10. Callendtime time10.;

*Final Clean data-drop every unclean column;
data cartest;
set cartest;
drop callstart callend;
run;

*Time Duration;
Data cartest;
Set cartest;
Callduration=callendtime-callstarttime;
Format Callduration 5.;
drop callendtime callstarttime;
run;

* FEATURE ENGINEERING;
* Quantitative to Qualitative ;
data carqual;
set cartest;
if Age > 0 and Age <= 14 then AgeGroup = 'Children';
if Age > 14 and Age <= 24 then AgeGroup = 'Youth';
if Age > 24 and Age <= 64 then AgeGroup = 'Adult';
if Age > 64 then AgeGroup = 'Senior';
run;

data carqual;
set carqual;
if Balance > 10000 then BalanceGroup = 'High';
if Balance > 5000 and Balance <= 10000 then BalanceGroup = 'Mid';
if Balance > 1 and Balance <= 5000 then BalanceGroup = 'Low';
if Balance <= 0 then BalanceGroup = 'NA';
run;

data carqual;
set carqual;
if Default = 1 then DefaultGroup = 'Yes';
if Default = 0 then DefaultGroup = 'No';
run;

Data carqual;
set carqual;
if HHInsurance = 1 then HHInsurance_Group = "Yes";
if HHInsurance = 0 then HHInsurance_Group = "No";
run;

Data carqual;
set carqual;
if CarLoan = 1 then CarLoan_Group = "Yes";
if CarLoan = 0 then CarLoan_Group = "No";
run;

data carqual;
set carqual;
if LastContactDay > 0 and LastContactDay <= 10 then LastContactDayGroup = 'Recent';
if LastContactDay > 10 and LastContactDay <= 20 then LastContactDayGroup = 'Normal';
if LastContactDay > 20  then LastContactDayGroup = 'Long';
run;

data carqual;
set carqual;
if NoOfContacts >= 1 and NoOfContacts <= 15 then NoOfContactsGroup = 'Low';
if NoOfContacts > 15 and NoOfContacts <= 30 then NoOfContactsGroup = 'Medium';
if NoOfContacts > 30 then NoOfContactsGroup = 'High';
run;

data carqual;
set carqual;
if PrevAttempts >= 0 and PrevAttempts <= 20 then PrevAttemptsGroup = 'Low';
if PrevAttempts > 20 and PrevAttempts <= 40 then PrevAttemptsGroup = 'Medium';
if PrevAttempts > 40 then PrevAttemptsGroup = 'High';
run;

data carqual;
set carqual;
if DaysPassed < 0 then DaysPassedGroup = 'Instant';
if DaysPassed > 0 and DaysPassed <= 365 then DaysPassedGroup = 'One';
if DaysPassed > 365 and DaysPassed <= 730 then DaysPassedGroup = 'Two';
if DaysPassed > 730 and DaysPassed <= 1095 then DaysPassedGroup = 'Three';
run;

data carqual;
set carqual;
drop Age Balance Default LastContactDay NoOfContacts PrevAttempts DaysPassed HHInsurance CarLoan;
run;

proc print data=carqual;
run;

* Qualitative to Quantitative ;
data carquant;
set cartest;
if LastContactMonth='jan' then ContactedMonth=1;
if LastContactMonth='feb' then ContactedMonth=2;
if LastContactMonth='mar' then ContactedMonth=3;
if LastContactMonth='apr' then ContactedMonth=4;
if LastContactMonth='may' then ContactedMonth=5;
if LastContactMonth='jun' then ContactedMonth=6;
if LastContactMonth='jul' then ContactedMonth=7;
if LastContactMonth='aug' then ContactedMonth=8;
if LastContactMonth='sep' then ContactedMonth=9;
if LastContactMonth='oct' then ContactedMonth=10;
if LastContactMonth='nov' then ContactedMonth=11;
if LastContactMonth='dec' then ContactedMonth=12;
run;

data carquant;
set carquant;
if Job = 'NA' then Job_NA = 1;
else Job_NA=0;
if Job = 'retired' then Job_retired = 1;
else Job_retired=0;
if Job='student' then Job_student = 1;
else Job_student=0;
if Job='unemployed' then Job_unemployed = 1;
else Job_unemployed=0;
if Job='services' then Job_services = 1;
else Job_services=0;
if Job='technician' then Job_technician = 1;
else Job_technician=0;
if Job='management' then Job_management = 1;
else Job_management=0;
if Job='admin.' then Job_admin = 1;
else Job_admin=0;
if Job='blue-collar' then Job_bluecollar = 1;
else Job_bluecollar=0;
if Job='housemaid' then Job_housemaid = 1;
else Job_housemaid=0;
if Job='self-employed' then Job_selfemployed = 1;
else Job_selfemployed=0;
if Job='entrepreneur' then Job_entrepreneur = 1;
else Job_entrepreneur=0;
run;

data carquant;
set carquant;
if Outcome = 'NA' then Outcome_NA = 1;
else Outcome_NA=0;
if Outcome = 'success' then Outcome_success = 1;
else Outcome_success=0;
if Outcome = 'failure' then Outcome_failure = 1;
else Outcome_failure=0;
if Outcome = 'other' then Outcome_other = 1;
else Outcome_other=0;
run;

data carquant;
set carquant;
if Marital = 'single' then Marital_single = 1;
Else Marital_single=0;
if Marital = 'married' then Marital_married = 1;
Else Marital_married=0;
if Marital = 'divorced' then Marital_divorced = 1;
Else Marital_divorced=0;
run;

data carquant;
set carquant;
if Education = 'NA' then EducationGroup = 0;
if Education = 'primary' then EducationGroup = 1;
if Education = 'secondary' then EducationGroup = 2;
if Education = 'tertiary' then EducationGroup = 3;
run;

data carquant;
set carquant;
if Communication = 'NA' then Communication_NA = 1;
Else Communication_NA=0;
if Communication = 'telephone' then Communication_telephone = 1;
Else Communication_telephone=0;
if Communication = 'cellular' then Communication_cellular = 1;
Else Communication_cellular=0;
run;

data carquant;
set carquant;
drop LastContactMonth Job Outcome Marital Education Communication;
run;

proc print data=carquant;
run;

*EDA;
PROC UNIVARIATE data=carquant ROBUSTSCALE PLOT;
VAR ContactedMonth Age Balance LastContactDay NoOfContacts DaysPassed PrevAttempts;
run;