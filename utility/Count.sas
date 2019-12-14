/*
 * Get the total number of dianosis by physician.
 */
%MACRO Count(indata, outdata, group_index, prefix=);
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
    proc delete data=tmptable1 tmptable2 tmpf tmpf2 tmpl tmpl2; run;
%MEND Count;