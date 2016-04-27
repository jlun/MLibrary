%MACRO s2t1(indata1, indata2, outdata, index, eventdt, prefix=dia);
    DATA &outdata;
        SET &indata1  &indata2;
        &prefix.dt = &eventdt;
        &prefix = 1;
        *keep id &prefix &prefix.dt;
    run;
    PROC SORT DATA=&outdata; by &index; RUN;
%MEND s2t1;
