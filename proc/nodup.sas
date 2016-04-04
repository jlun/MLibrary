/*
 * Remove duplicate data
 */
%MACRO nodup(indata, outdata, group_index);
	PROC SORT DATA=&indata; by &group_index ; run;
	DATA &oudata;
		set &indata;
    	by &group_index;
    	IF FIRST.&group_index;
	RUN;
	PROC SORT DATA=&outdata; by &group_index ; run;
%MEND nodup;
