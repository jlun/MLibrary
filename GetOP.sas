%MACRO gop(indata, outdata, datafrom, index, icd_code, prefix=);
    %IF &datafrom = cd %THEN %DO;
        %LET diavar = ICD_OP_CODE ;
        %LET dianum = 1;
        %LET eventdt = FUNC_DATE;
    %END;
    %IF &datafrom = dd %THEN %DO;
        %LET diavar = ICD_OP_CODE ICD_OP_CODE_1-ICD_OP_CODE_4 ;
        %LET dianum = 5 ;
        %LET eventdt = IN_DATE;
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
%MEND gop;

/**
 Get orders
*/
%MACRO gorder(indata, order_table, outdata, orders, datafrom);
    %IF &datafrom = oo %then %do;
        %let ordervar = drug_no;
    %end;
    %IF &datafrom = do %then %do;
        %let ordervar = order_code;
    %end;
    %IF &datafrom = go %then %do;
        %let ordervar = drug_no;
    %end;
    %LET len = %LENGTH(&orders);
    proc sql;
    create table &outdata as
        select orders.*, ori.*
            from &order_table as orders, &indata as ori
            WHERE substr(ori.&ordervar , 1, &len) = substr(orders.&orders , 1, &len) ;

    quit;
    run;
%MEND gorder;


%MACRO godx(indata, outdata, datafrom, order, prefix=);
    %IF &datafrom = oo %then %do;
        %let ordervar = drug_no;
    %end;
    %IF &datafrom = do %then %do;
        %let ordervar = order_code;
    %end;
    %IF &datafrom = go %then %do;
        %let ordervar = drug_no;
    %end;
    %LET codelen = %LENGTH(&order);
    DATA &outdata;
        set &indata;
        if substr(&ordervar, 1, &codelen ) in ( "&order" ) then &prefix = 1;
        if &prefix = 1;
    run;
%MEND godx;


%MACRO greco(indata1,indata2,outdata);
proc sql;
create table &outdata as
    select in1.*, in2.*
        from &indata1 as in1, &indata2 as in2
        where (
                    in1.fee_ym=in2.fee_ym and
                    in1.appl_type=in2.appl_type and
                    in1.hosp_id=in2.hosp_id and
                    in1.appl_date=in2.appl_date and
                    in1.case_type=in2.case_type and
                    in1.seq_no=in2.seq_no
                   );
quit;
%MEND greco;


%MACRO deldata(libsrc, dataset);
    proc datasets nodetails nolist lib=&libsrc;
        delete &dataset  ;
    run;
    quit;
%MEND deldata;


%macro sfreq(indata, freqtable);
    proc freq data=&indata;
        table &freqtable  ;
    run;
%mend sfreq;

%MACRO sprint(indata, obs= , var=);
    %IF %LENGTH(&var) ^= 0 %THEN %LET printvar=var &var;
        %ELSE %LET printvar= ;
    %IF %LENGTH(&obs) ^= 0 %THEN %LET printobs=(obs=&obs);
        %ELSE %LET printobs = ;
    proc print data=&indata &printobs;
        &printvar ;
    run;
%MEND sprint;


%MACRO scontent(indata);
    PROC CONTENTS DATA= &indata;
    run;
%MEND scontent;


%MACRO ssort(indata,index, other=);
    %IF %LENGTH(&other) ^= 0 %THEN %LET parameter = &other;
        %ELSE %LET parameter= ;

    PROC SORT DATA=&indata;
        BY &index &parameter;
    RUN;
%MEND ssort;
