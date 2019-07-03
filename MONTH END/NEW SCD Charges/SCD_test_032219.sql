
select distinct visit_code,
	   HN,
	   [Patient Name]
	   ,[Item Description]
	   ,(select top 1 [Sales/Invoice Number] from scd_test_032219
		where visit_code = scd.visit_code
        and HN = scd.HN
	    and policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2') as invoice_no
from scd_test_032219 scd
where (select count(*) from scd_test_032219
		where visit_code = scd.visit_code
        and HN = scd.HN
	    and policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2') > 0
		and [Sales/Invoice Number] = 'PINV-2019-006910'



select visit_code,
	   HN,
	   [Patient Name]
	   ,Age
	   ,(select top 1 [Sales/Invoice Number] from scd_test_032219
			where visit_code = scd.visit_code
			and HN = scd.HN
			and policy_id not in ('AE27B927-5FF7-11DA-BB34-000E0C7F3ED2','C19FD081-632F-11DA-BB34-000E0C7F3ED2')) as invoice_no
	   ,(select top 1 policy_name from scd_test_032219
			where visit_code = scd.visit_code
			and HN = scd.HN
			and policy_id not in ('AE27B927-5FF7-11DA-BB34-000E0C7F3ED2','C19FD081-632F-11DA-BB34-000E0C7F3ED2')) as policy_name
from scd_test_032219 scd
where (select count(*) from scd_test_032219
		where visit_code = scd.visit_code
        and HN = scd.HN
	    and policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2') = 0
order by [Patient Name]

/*
select * from scd_test_032219
where visit_code = '218189'
      and HN = '00327247'
	  and policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2'



select count(*) from scd_test_032219
where visit_code = '218189'
      and HN = '00327247'
	  and policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2'


select [Sales/Invoice Number] from scd_test_032219
		where visit_code = '218189'
        and HN = '00327247'
	    and policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2'
*/