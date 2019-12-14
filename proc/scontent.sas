%MACRO scontent(indata);
    PROC CONTENTS DATA= &indata;
    run;
%MEND scontent;
