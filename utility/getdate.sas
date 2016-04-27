**********************************************************;
* Program name :  GetDate
*
* Author : Michael Wu
*
* Date created :
*
* Study  : 001-001-001
*          Core-function
* Purpose : Determine the first and the last date.
*
* Template :
*
* Inputs :
*
* Outputs :
*
* Program completed : Yes/No
*
* Updated by : (Name) ??(Date):
* (Modification and Reason)
* <doc>
* @param indata
* @param outdata
* @param group_index
* @param eventdt
* @param prefix
* @param mincount
* </doc>
**********************************************************;
%MACRO GetDate(indata, outdata, group_index, eventdt, prefix=, mincount=);
   %IF %LENGTH(&prefix) = 0 %THEN %DO;
       %LET prefix = dia ;
   %END;
   %IF %LENGTH(&mincount) = 0 %THEN %DO;
       %LET mincount = 1 ;
   %END;

  PROC SORT data=&indata out=tmptable; by &group_index &eventdt; run;
  data tmptable2 ;
   set tmptable;
   by &group_index;
   if first.&group_index then do;
       &prefix.dtf = &eventdt;
       evf = 1;
       count = 1;
   end;
   else do;
       count + 1;
   end;
   if last.&group_index then do;
       &prefix.dtl = &eventdt;
       evl = 1;
       maxcount = count;
   end;
   data tmpf tmpl;
       set tmptable2;
       if evf = 1 then output tmpf;
       if evl = 1 then output tmpl;
   run;
   data tmpf2;
       set tmpf;
       keep &group_index &prefix.dtf ;
   run;
   data tmpl2;
       set tmpl;
       keep &group_index &prefix.dtl maxcount;
   run;
   proc sort data=tmpf2; by &group_index; run;
   proc sort data=tmpl2; by &group_index; run;
   data &outdata;
       merge tmpf2 tmpl2;
       by &group_index;
       if maxcount >= &mincount;
       &prefix = 1;
       &prefix.count = maxcount;
       format &prefix.dtf &prefix.dtl yymmdd10.;
       keep &group_index &prefix.dtf &prefix.dtl &prefix  &prefix.count ;
   run;
   proc sort data=&outdata ; by &group_index &prefix.dtf; run;
   /*proc print data=&outdata (obs=5); run; */
   proc delete data=tmptable tmptable2 tmpf tmpf2 tmpl tmpl2; run;
%MEND GetDate;
