
%MACRO ssort(indata,index, other=);
    %IF %LENGTH(&other) ^= 0 %THEN %LET parameter = &other;
        %ELSE %LET parameter= ;

    PROC SORT DATA=&indata;
        BY &index &parameter;
    RUN;
%MEND ssort;