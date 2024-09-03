*******************************************************************************************************************************************************************
PROJECT: IGEMS A50 Smoking Harmonized variables
PROGRAM NAME: C:\IGEMS\Harmonized Data\Health Behaviors\Smoking\a50_smk_26aug2024.sas
PURPOSE: Creating A50 smoking variables for one wave
         Only smoking cigarettes - no pipe, cigars or snuff
         
INPUT: C:\IGEMS\Administrative Data\Australia A50\admin_a50_04apr2024
	     C:\IGEMS\Unharmonized Data\A50+\a50_raw_20180123


YOUSMOKE Have you or your twin ever smoked? 1=yes, 2=no
FIRSAGEY if yes, at what age did you have your first cigarette?  
REGUAGEY  At what age did you start smoking regularly? 
STOPSMYO If you no longer smoke at what age did you stop? 

daily cigarettes-  we are taking the most recent report to keep in line with other studies.
also the difference between taking the most recent and the average is very large

CIGAYOU Respondent - past 12 months 
FOURTYS  Respondent - 40+ 
THIRTYS Respondent - 30-39
TWENTYS Respondent - 20-29
TEENS   Respondent - teenage years  	         	        

CIGADAD: this is only asked if R reports smoking so crosstab with smoke status, just to make sure we are getting all the smokers       	
  
OUTPUT: a50_smk_26aug2024 

  label
   ever_tobacco="Ever_tobacco: Ever used Tobacco"
   ever_smoke="Ever_smoke: Ever Smoked"
   ever_snuff="Ever_snuff: Ever used snuff/snus/chew"        
          
   tobacco_status="Tobacco_status:	Tobacco Status: 1=Never, 2=Former, 3=Current"
   smoke_status="Smoke_status: Smoking Status(excludes snuff): 1=Never, 2=Former, 3=Current"
   snuff_status="Snuff_status: Snuff/snus/chew only: 1=Never, 2=Former, 3=Current"        
  
   tobacco_packs="Tobacco_packs: Number of Tobacco packs consumed daily"
   smoke_packs="Smoke_packs: Number of Smoking packs consumed daily (excludes snuff)"
   snuff_packs="Snuff_packs: Number of Snuff/Snus/Chew packs consumed daily"
   
   smoke_start_age="smoke_start_age: smoking start age"
   tobacco_start_age="tobacco_start_age: tobacco start age"
   snuff_start_age="snuff_start_age: snuff/snus/chew start age"
   
   smoke_stop_age="smoke_stop_age: smoking stop age"
   tobacco_stop_age="tobacco_stop_age: tobacco stop age"
   snuff_stop_age="snuff_stop_age: snuff/snus/chew stop age"
   
   tobacco_yrs="Tobacco_yrs: Number of years twin has used tobacco"
   smoke_yrs="Smoke_yrs: Number of years twin has smoked"   
   snuff_yrs="Snuff_yrs: Number of years twin has used snuff/snus/chew"    
 
   tobacco_pkyr="Tobacco_pkyr: tobacco pack-years"
   smoke_pkyr="Smoke_pkyr: smoked tobacco pack-years"
   snuff_pkyr="Snuff_pkyr: snuff/snus/chew pack-years"
   year="Year: Assessment Year"
   wave="wave: IGEMS wave #/ 0=in,1-18=fu1-fu18" 
   

PROGRAMMER: Orla Hayden July 2024
NOTES: 
*******************************************************************************************************************************************************************;

options mprint nocenter ls=145 nofmterr ps=2000;    
                                                      
%include "C:\IGEMS\Data Requests\sascontents.mac";   
libname admin "C:\IGEMS\Administrative Data\Australia A50";
libname raw "C:\IGEMS\Unharmonized Data\A50+";
libname smoking "C:\IGEMS\Harmonized Data\Health Behaviors\Smoking";

proc sort data=raw.a50_raw_20180123 out=a50_raw_20180123;
  by pairid twin;
run;
proc sort data=admin.admin_a50_04apr2024 out=admin;
  by pairid twin;
run;

data a50_smoke;
  merge a50_raw_20180123(in=a) admin(in=b);
  by pairid twin;
  if a and b;
  
  wave=0;
  year=in_yy;
  
  array chars   (*) CIGAYOU FOURTYS THIRTYS TWENTYS TEENS ;
  array nums    (*) CIGAYOU2 FOURTYS2 THIRTYS2 TWENTYS2 TEENS2 ;
  
  FIRSAGEY2=input(FIRSAGEY, 8.);
  REGUAGEY2=input(REGUAGEY, 8.);
  if FIRSAGEY2 in (0 98 99) then FIRSAGEY2=.;
  if REGUAGEY2 in (0 98 99) then REGUAGEY2=.;
  
  do i=1 to dim(nums);
    nums(i)=input(chars(i), 8.);
    if nums(i) in (0 98 99) then nums(i)=.;
    if daily_smoke=. then daily_smoke=nums(i);    
  end;
  
  if REGUAGEY2 ne . then smoke_start_age=REGUAGEY2;
  else if FIRSAGEY2 ne . then smoke_start_age=FIRSAGEY2;
  
  smoke_stop_age=input(STOPSMYO,8.);
  if smoke_stop_age in (0 98 99) then smoke_stop_age=.;

  if YOUSMOKE=2 then smoke_status=1;
  else if YOUSMOKE=1 and smoke_stop_age ne . then smoke_status=2;
  else if YOUSMOKE=1 and smoke_stop_age =. then smoke_status=3;
  
  smoke_packs=daily_smoke/20;
  if smoke_status=2 then smoke_yrs=smoke_stop_age-smoke_start_age;
  else if smoke_status=3 then smoke_yrs=age_in-smoke_start_age;
  
  smoke_pkyr=smoke_yrs*smoke_packs;


  if smoke_status in (2 3) then Ever_Smoke=1; 
  else ever_Smoke=0;
  
  if smoke_status=. then delete;
run;

/*
proc freq data=a50_smoke;
   tables smoke_status*smoke_start_age*smoke_stop_age smoke_stop_age*age_in/list missing;
run;
*/

data smoking.a50_smk_26aug2024;
  set a50_smoke;
  
  ever_tobacco=ever_smoke;
  tobacco_status=smoke_status;
  tobacco_packs=smoke_packs;
  tobacco_start_age=smoke_start_age;
  tobacco_stop_age=smoke_stop_age;
  tobacco_yrs=smoke_yrs;
  tobacco_pkyr=smoke_pkyr;
  
  label
   ever_tobacco="Ever_tobacco: Ever used Tobacco"
   ever_smoke="Ever_smoke: Ever Smoked" 
          
   tobacco_status="Tobacco_status:	Tobacco Status: 1=Never, 2=Former, 3=Current"
   smoke_status="Smoke_status: Smoking Status(excludes snuff): 1=Never, 2=Former, 3=Current"
   tobacco_packs="Tobacco_packs: Number of Tobacco packs consumed daily"
   smoke_packs="Smoke_packs: Number of Smoking packs consumed daily (excludes snuff)"
   
   smoke_start_age="smoke_start_age: smoking start age"
   tobacco_start_age="tobacco_start_age: tobacco start age"
   
   smoke_stop_age="smoke_stop_age: smoking stop age"
   tobacco_stop_age="tobacco_stop_age: tobacco stop age"
   
   tobacco_yrs="Tobacco_yrs: Number of years twin has used tobacco"
   smoke_yrs="Smoke_yrs: Number of years twin has smoked"   
 
   tobacco_pkyr="Tobacco_pkyr: tobacco pack-years"
   smoke_pkyr="Smoke_pkyr: smoked tobacco pack-years"
   year="Year: Assessment Year"
   wave="wave: IGEMS wave #/ 0=in,1-18=fu1-fu18" ;
 
   
   keep pairid twin study igems_id ever_tobacco ever_smoke tobacco_status smoke_status tobacco_packs smoke_packs
       smoke_start_age tobacco_start_age smoke_stop_age tobacco_stop_age tobacco_yrs smoke_yrs tobacco_pkyr smoke_pkyr year wave ;
run;

proc freq data=smoking.a50_smk_26aug2024;
  tables ever_tobacco ever_smoke smoke_status*tobacco_status/list missing;
run;


proc means data=smoking.a50_smk_26aug2024 n min mean median max;
run;

%sascontents(a50_smk_26aug2024,lib=smoking,contdir=C:\IGEMS\Harmonized Data\Health Behaviors\Smoking\,opt=position,domeans=Y,retprt=PRINT);




/** Checks in development

proc freq data=smk_salt;
  tables smoke_status*used_tobacco_this_month_smoke*smoked_or_snuffed_Rokt_da_och_da*smoked_or_snuffed_Rokt_regelbund*smoked_or_snuffed_Festrokt
         smoke_status*used_tobacco_this_month_smoke*smoked_or_snuffed_Roker_da_och_d*smoked_or_snuffed_Roker_regelbun*smoked_or_snuffed_Festroker
  snuff_status*used_tobacco_this_month_snuff*smoked_or_snuffed_Snusat_da_och_*smoked_or_snuffed_Snusat_regelbu*smoked_or_snuffed_Snusar_da_och_*smoked_or_snuffed_Snusar_regelbu/list missing;
run;

proc means;
run;

proc freq data=smk_salt;
  tables tobacco_status*smoke_status*snuff_status /list missing;
run;

proc freq data=smk_salt;
    tables      
    tobacco_status*tobacco_yrs*tobacco_start_age*tobacco_stop_age
    smoke_status*smoke_yrs*smoke_start_age*smoke_stop_age
    
    snuff_status*snuff_yrs*snuff_start_age*snuff_stop_age
    
         /list missing;
run;
proc freq data=smk_salt;
  where smoke_status=2 and smoke_start_age>0  and smoke_yrs=.;
  tables smoked_or_snuffed_Rokt_da_och_da*smoked_or_snuffed_Rokt_regelbund*smoked_or_snuffed_Festrokt/list missing;
run;
***/
