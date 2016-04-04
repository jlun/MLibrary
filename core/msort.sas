/**************************************************************
  Sorting data
 **************************************************************/

%MACRO msort(indata, index);
PROC SORT DATA = &indata ;
  BY &index;
RUN;
%MEND msort;
