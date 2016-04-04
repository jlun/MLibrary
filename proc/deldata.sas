

%MACRO deldata(libsrc, dataset);
    PROC DATASETS nodetails nolist lib=&libsrc;
        DELETE &dataset  ;
    QUIT;
    RUN;
%MEND deldata;
