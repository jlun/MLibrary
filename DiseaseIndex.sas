option symbolgen mlogic mprint;
/*
 * Take the records which match users' icd-9.
 * @param indata
 */
%MACRO TakeDisease(indata, outdata, datafrom, index, icd_code, prefix=);
    %IF &datafrom = cd %THEN %DO; 
        %LET diavar = ACODE_ICD9_1-ACODE_ICD9_3 ;
        %LET dianum = 3 ;
        %LET eventdt = FUNC_DATE;
    %END;
    %IF &datafrom = dd %THEN %DO; 
        %LET diavar = ICD9CM_CODE ICD9CM_CODE_1-ICD9CM_CODE_4 ;
        %LET dianum = 5 ;
        %LET eventdt = IN_DATE;
    %END;
    %IF &datafrom = hv %THEN %DO; 
        %LET diavar = ICD9CM_CODE DISE_CODE;
        %LET dianum = 2 ;
        %LET eventdt = APPL_DATE;
    %END;
    %LET codelen = %LENGTH(&icd_code);
    data &outdata;
        set &indata;
        ARRAY icd[&dianum] $ &diavar ;
        DO i = 1 TO &dianum ;
            if substr(icd[i], 1, &codelen ) in ( "&icd_code" ) then &prefix = 1;
        END;
        if &prefix = 1;
        datafrom = "&datafrom";
        eventdt = &eventdt ;
    run;
    PROC SORT DATA=&outdata; BY &index ; RUN;
%MEND TakeDisease;

/*
 * Take all records which match users' icd-9 before index date.
 */
%MACRO TakeDisease2(indata, outdata, datafrom, index, indexdt, icd_code, prefix);
    %IF &datafrom = cd %THEN %DO; 
        %LET diavar = ACODE_ICD9_1-ACODE_ICD9_3 ;
        %LET dianum = 3 ;
        %LET eventdt = func_date;
    %END;
    %IF &datafrom = dd %THEN %DO; 
        %LET diavar = ICD9CM_CODE ICD9CM_CODE_1-ICD9CM_CODE_4 ;
        %LET dianum = 5 ;
        %LET eventdt = in_date;
    %END;
    %IF &datafrom = hv %THEN %DO; 
        %LET diavar = ICD9CM_CODE ;
        %LET dianum = 1 ;
        %LET eventdt = appl_date;
    %END;
    %LET codelen = %LENGTH(&icd_code);
    data &outdata;
        set &indata;
        ARRAY icd[ &dianum ] $ &diavar ;
        IF &indexdt >= &eventdt ;
        DO i = 1 TO &dianum ;
            if substr(icd[i], 1, &codelen ) in ( &icd_code ) then &prefix = 1;
        END;
        &prefix = 1;
    run;
    PROC SORT DATA=&outdata; BY &index ; RUN;
%MEND TakeDisease2;
/*
 * Take all records which match users' icd-9 from event date to index date.
 * the event date must less then or equal index date.
 */
%MACRO TakeDisease3(indata, outdata,  index, indexdt, rankdays, icd_code, icdlen, prefix);
    data &outdata;
        set &indata;
        ARRAY icd[ &dianum ] $ &diavar ;
        IF 0 <= &indexdt - &eventdt <= &rankdays;
        DO i = 1 TO &dianum ;
            if substr(icd[i], 1, &icdlen ) in ( &icd_code ) then &prefix = 1;
        END;
    run;
    PROC SORT DATA=&outdata; BY &index ; RUN;
%MEND TakeDisease3;


/*
 * Take order records
 */
%MACRO TakeOrder(ordertable, colname, outdata, sourcelib);

    proc sql;
    create table tmpoo as
        select orders.*, oo.*
            from  &ordertable as orders, &sourcelib..oo as oo
            where orders.&colname = oo.drug_no;
    create table tmpdo as
        select orders.*, do.*
            from  &ordertable as orders,  &sourcelib..do as do
            where orders.&colname = do.order_code;
    create table tmpgo as
        select orders.*, go.*
            from  &ordertable as orders, &sourcelib..go as go
            where orders.&colname = go.drug_no;
    quit;
    run;

    proc sql;
      create table tmpoocd as
      select cd.*,  oo.*
        from  &sourcelib..cd as cd, tmpoo as oo
        where (
                    cd.fee_ym=oo.fee_ym and
                    cd.appl_type=oo.appl_type and
                    cd.hosp_id=oo.hosp_id and
                    cd.appl_date=oo.appl_date and
                    cd.case_type=oo.case_type and
                    cd.seq_no=oo.seq_no
                   );
    quit;
    proc sql;
      create table tmpdodd as
      select dd.*,  do.*
        from  &sourcelib..dd as dd, tmpdo as do
        where (
                    dd.fee_ym=do.fee_ym and
                    dd.appl_type=do.appl_type and
                    dd.hosp_id=do.hosp_id and
                    dd.appl_date=do.appl_date and
                    dd.case_type=do.case_type and
                    dd.seq_no=do.seq_no
                   );
    quit;
    run;

    proc sql;
      create table tmpgogd as
      select gd.*,  go.*
        from  &sourcelib..gd as gd, tmpgo as go
        where (
                    gd.fee_ym=go.fee_ym and
                    gd.appl_type=go.appl_type and
                    gd.hosp_id=go.hosp_id and
                    gd.appl_date=go.appl_date and
                    gd.case_type=go.case_type and
                    gd.seq_no=go.seq_no
                   );
    quit;
    run;

    data &outdata ;
        set tmpoocd (in=aa) tmpdodd (in=bb) tmpgogd (in=cc);
        if aa then do;
            dfrom = 'cd';
            eventdt = func_date;
        end;
        if bb then do;
            dfrom = 'dd';
            eventdt = in_date;
        end;
        if cc then do;
            dfrom = 'gd';
            eventdt = func_date;
        end;
        DRUG = 1;
    run;

%MEND TakeOrder;


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

/*
 * Get the total number of dianosis by physician.
 */
%MACRO GetCount(indata, outdata, group_index, prefix=);
    %IF %LENGTH(&prefix) = 0 %THEN %DO;
        %LET prefix = dia ;
    %END;
    PROC SORT DATA=&indata ; by &group_index ; run;
    DATA &outdata ;
        set &indata;
        by &group_index ;
        if first.&group_index then &prefix._nu = 1;
            else &prefix._nu + 1;
        if last.&group_index then &prefix._maxnu = &prefix._nu;
    run;
    PROC SORT data=&outdata ; by &group_index ; run;
    PROC PRINT DATA=&outdata (obs=10); run;
    *proc delete data=tmptable1 tmptable2 tmpf tmpf2 tmpl tmpl2; run;
%MEND GetCount;

/*
 * Get the max number of group index.
 */
%MACRO GMaxNum(indata, outdata, group_index, prefix=dia);
    %GetCount(&indata, tmpdata, &group_index, prefix=&prefix);
    data &outdata;
        set tmpdata;
        if &prefix._maxnu ^= .;
        &prefix = 1;
        keep &group_index &prefix &prefix._maxnu;
    run;
    PROC SORT data=&outdata ; by &group_index ; run;
    PROC PRINT DATA=&outdata (obs=10); run;
%MEND GMaxNum;


/*
 * Detect by diagnosed 3 times in one year.
 */
%MACRO T3Y1(indata, outdata, group_index, eventdt, prefix, mincount=3,days=365.25, mindays=0);
    %LET tmpcount = %EVAL(&mincount-1);
    %GetCount(&indata, tmpdmcd, &group_index, prefix=&prefix);
    proc transpose data=tmpdmcd
                   out=tmpdmcd1
                   prefix=date
                   name=transposed_by ;
                   var &eventdt;
                   by &group_index ;
    run;
    * Get the max number of date var;
    proc sql noprint;
        select max(count) into:max_c
            from (select count(*) as count from tmpdmcd group by &group_index);
    quit;
    data tmpdmcd2;
        set tmpdmcd1;
        %do i = 1 %TO %EVAL(&max_c - &tmpcount) ;
            %LET tmp = %EVAL(&i + &tmpcount);
            dif3time_&i = date&tmp - date&i ;
        %end;
    run;

    %LET tmp1= %EVAL(&max_c - &tmpcount);
    %PUT count &tmp1;
    proc transpose data=tmpdmcd2
                   out=tmpdmcd3
                   prefix=time1yr;
                   var dif3time_1-dif3time_&tmp1;
                   by &group_index ;
    run;
    data tmpdmcd4;
        set tmpdmcd3;
        if time1yr1 ne .;
        if &mindays <= time1yr1 <= &days ;
        daynu = input(scan(_NAME_,2,'_'),3.);
    run;
    proc sort data=tmpdmcd4; by &group_index daynu; run;
    data tmpdmcd5;
        set tmpdmcd4;
        by &group_index;
        if first.&group_index;
        &prefix = 1;
        keep &group_index &prefix daynu;
    run;
    proc sort data=tmpdmcd5; by &group_index;run;
    proc sql noprint;
        create table tmpdmcd6 as 
            select sample1.*, sample2.* from tmpdmcd5 as sample1, tmpdmcd as sample2
                where sample1.&group_index = sample2.&group_index and sample1.daynu = sample2.&prefix._nu;
    quit;
    proc sort data=tmpdmcd6; by &group_index &eventdt; run;
    * Take the event date;
    data tmpdmcd7;
        set tmpdmcd6;
        by &group_index;
        if first.&group_index;
        if daynu = &prefix._nu;
        &prefix._eventdt = &eventdt;
        if &prefix = 1;
        keep &group_index &prefix &prefix._eventdt;
    run;
    %m2t1(tmpdmcd7, &indata,tmpdmcd8, &group_index);
    %GetDate(tmpdmcd8, tmpdmcd9, id, &eventdt, prefix=&prefix, mincount=1);
    %m2t1(tmpdmcd7,tmpdmcd9, &outdata,&group_index);
    proc delete data=tmpdmcd tmpdmcd1-tmpdmcd9;run;
%MEND T3Y1;

/*
 * Remove duplicate data
 */
%MACRO nodup(indata, outdata, group_index, other=);

    PROC SORT DATA=&indata; by &group_index &other ; run;
    DATA &outdata;
        set &indata;
    by &group_index;
    IF FIRST.&group_index;
    RUN;
    PROC SORT DATA=&outdata; by &group_index ; run;
%MEND nodup;



%MACRO m2t1(master_data, indata, outdata, index, section=left );
    %if &section = left  %THEN %LET section2 = if aa;
    %if &section = right  %THEN %LET section2 = if bb;
    %if &section = inter  %THEN %LET section2 = if aa and bb ;
    %if &section = out %THEN %LET section2 = ;

    PROC SORT DATA=&master_data; by &index; RUN;
    PROC SORT DATA=&indata; by &index; RUN;
    DATA &outdata;
        MERGE &master_data (in=aa) &indata (in=bb);
        by &index;
        &section2 ;
    run;
    PROC SORT DATA=&outdata; by &index; RUN;
%MEND m2t1;


%MACRO s2t1(indata1, indata2, outdata, index, eventdt, prefix=dia);
    DATA &outdata;
        SET &indata1  &indata2;
        &prefix.dt = &eventdt;
        &prefix = 1;
        *keep id &prefix &prefix.dt;
    run;
    PROC SORT DATA=&outdata; by &index; RUN;
%MEND s2t1;




%macro comtwo(indata1, indata2, outdata, index, minyr=1996,prefix=dia);
data tmpindata;
    set  &indata1 (in=aa) &indata2 (in=bb);    
    if aa then  cddd = 'cd';
    if bb then  cddd = 'dd';
    &prefix.dtf=min(&prefix.cddtf, &prefix.dddtf);
    &prefix.dtl=max(&prefix.cddtl, &prefix.dddtl);
    if &prefix.cdcount = . then &prefix.cdcount = 0;
    if &prefix.ddcount = . then &prefix.ddcount = 0;
    &prefix.count=&prefix.cdcount + &prefix.ddcount;
run;
proc sort data=tmpindata; by &index &prefix.dtf; run;
data &outdata;
    set tmpindata;
    by &index;
    if first.&index;
    &prefix._yr = year(&prefix.dtf);
    &prefix = 1;
    if &prefix._yr >= &minyr;
    format &prefix.dtf  &prefix.dtl yymmdd10.;
    keep &index &prefix &prefix.dtf  &prefix.dtl  &prefix._yr &prefix.count cddd; 
run;

proc sort data=&outdata; by &index &prefix.dtf; run;
proc print data =&outdata (obs=5); run;
%mend comtwo;
