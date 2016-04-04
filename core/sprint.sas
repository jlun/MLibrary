/*************************************
 Modify proc print.
 ************************************/

%MACRO sprint(indata, vars=, obs=);
    %IF %LENGTH(&obs) > 1 %THEN %LET pnum = (obs = &obs);
        %ELSE %LET pnum = ;
    %IF %LENGTH(&vars) > 1 %THEN %LET pvar = var &vars;
        %ELSE %LET pvar = ;
    PROC PRINT DATA=&indata &pnum;
        &pvar;
    RUN;
%MEND sprint;
