/**************************************************************
  Simple sorting function.
 **************************************************************/

%MACRO ssort(indata, index);
PROC SORT DATA = &indata ;
  BY &index;
RUN;
%MEND ssort;
