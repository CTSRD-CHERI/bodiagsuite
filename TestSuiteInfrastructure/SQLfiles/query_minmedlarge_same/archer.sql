use thesis;
select count(*) from archer where (min=1 and (med=0 or large=0)) or 
                                  (med=1 and (min=0 or large=0)) or
                                  (large=1 and (min=0 or med=0));