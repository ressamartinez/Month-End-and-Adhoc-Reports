
select year(transaction_date_time)  as Year
	   ,count(case when visit_type_rcd = 'V32' then 1 end) as 'Chrys'
	   ,count(case when visit_type_rcd in ('V34', 'V35') then 1 end) as 'OPP'
	   ,count(case when visit_type_rcd = 'V32' then 1
				   when visit_type_rcd in ('V34', 'V35') then 1 end) as 'Total'

from ar_invoice

where 
	  year(transaction_date_time) = 2018
      and month(transaction_date_time) between 1 and 6
	  --year(transaction_date_time) between 2016 and 2018

group by year(transaction_date_time)
         
