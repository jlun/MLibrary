%MACRO greco(indata1, indata2, outdata, datafrom);
proc sql;
create table &outdata as
    select in1.*, in2.*
        from &indata1 as in1, &indata2 as in2
        where (
                    in1.fee_ym=in2.fee_ym and
                    in1.appl_type=in2.appl_type and
                    in1.hosp_id=in2.hosp_id and
                    in1.appl_date=in2.appl_date and
                    in1.case_type=in2.case_type and
                    in1.seq_no=in2.seq_no
                   );
quit;
%MEND greco;
