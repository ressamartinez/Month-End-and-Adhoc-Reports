
select year(transaction_date_time)  as Year 
	   ,month(transaction_date_time) as Month
	   ,count(case when visit_type_rcd = 'V32' then 1 end) as 'Chrys'
	   ,count(case when visit_type_rcd in ('V34', 'V35') then 1 end) as 'OPP'
	   ,count(case when visit_type_rcd = 'V32' then 1
				   when visit_type_rcd in ('V34', 'V35') then 1 end) as 'Total'

from ar_invoice

where 
	  year(transaction_date_time) = 2019
      and month(transaction_date_time) between 1 and 8
	  --year(transaction_date_time) between 2016 and 2018

group by year(transaction_date_time), month(transaction_date_time)
         
