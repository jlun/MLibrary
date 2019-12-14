%MACRO deldata(libsrc, dataset);
    proc datasets nodetails nolist lib=&libsrc;
        delete &dataset  ;
    run;
    quit;
%MEND deldata;