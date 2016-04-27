

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
