%macro sfreq(indata, freqtable);
    proc freq data=&indata;
        table &freqtable  ;
    run;
%mend sfreq;
