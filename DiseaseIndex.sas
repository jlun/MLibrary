option symbolgen mlogic mprint;




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
