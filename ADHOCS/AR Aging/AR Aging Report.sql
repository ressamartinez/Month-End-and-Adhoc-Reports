
SELECT 
     --      rip.invoice_id,
		   case when MONTH(rip.transaction_date_time) = 1 then 'January'
				 when MONTH(rip.transaction_date_time) = 2 then 'February'
				 when MONTH(rip.transaction_date_time) = 3 then 'March'
			     when MONTH(rip.transaction_date_time) = 4 then 'April'
			     when MONTH(rip.transaction_date_time) = 5 then 'May'
				 when MONTH(rip.transaction_date_time) = 6 then 'June'
				 when MONTH(rip.transaction_date_time) = 7 then 'July'
				 when MONTH(rip.transaction_date_time) = 8 then 'August'
				 when MONTH(rip.transaction_date_time) = 9 then 'September'
				 when MONTH(rip.transaction_date_time) = 10 then 'October'
				 when MONTH(rip.transaction_date_time) = 11 then 'November'
				 when MONTH(rip.transaction_date_time) = 12 then 'December' end as Month,
		   case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as [Organisation Type],
		   rip.invoice_no as [Invoice Number],
		   rip.hn as [HN],
		   rip.patient_name as [Patient Name],
		   rip.transaction_date_time as [Invoice Date],
		   --case when rip.policy_name = '--' then rip.patient_name else rip.policy_name end as policy_name,
		   --rip.swe_payment_status_rcd,
		   rip.total_amt as [Invoice Amount],
		   --sai.instalment_id,
		   --r.remittance_id,
		   sai.swe_payment_status_rcd as sai_payment_status,
		   sai.net_amount as [Paid Amount],
		   r.transaction_date_time as [Payment Date],
		   DATEDIFF(DAY,rip.transaction_date_time,r.transaction_date_time) as aging
		   
		   --p.policy_id,
		   --case when c.person_id is not NULL then pfn.display_name_l else o.name_l end as payor_name
	from HISReport.dbo.rpt_invoice_pf rip LEFT OUTER JOIN AmalgaPROD.dbo.swe_ar_instalment sai on rip.invoice_id = sai.ar_invoice_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.remittance r on sai.remittance_id = r.remittance_id
										  inner JOIN AmalgaPROD.dbo.ar_invoice_nl_view ar on rip.invoice_id = ar.ar_invoice_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.policy p on ar.policy_id = p.policy_id
										  left OUTER JOIN AmalgaPROD.dbo.customer c on ar.customer_id = c.customer_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation o on c.organisation_id = o.organisation_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on c.person_id = pfn.person_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation_role oor on o.organisation_id = oor.organisation_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd
	where YEAR(rip.transaction_date_time) = 2015 --and 2017
	    and MONTH(rip.transaction_date_time) >= 1 and  MONTH(rip.transaction_date_time) <= 1
	   and ar.ar_invoice_id = sai.ar_invoice_id
	   and ar.user_transaction_type_id in ('F8EF2162-3311-11DA-BB34-000E0C7F3ED2','30957FA1-735D-11DA-BB34-000E0C7F3ED2')
	   and ar.transaction_status_rcd not in ('voi','unk')
	order by rip.transaction_date_time asc






/*SUM

select sum(tempb.[Invoice Amount])
from (
	select distinct temp.invoice_id, temp.[Invoice Amount] 
	from (
		SELECT 
				rip.invoice_id,
				case when MONTH(rip.transaction_date_time) = 1 then 'January'
					 when MONTH(rip.transaction_date_time) = 2 then 'February'
					 when MONTH(rip.transaction_date_time) = 3 then 'March'
					 when MONTH(rip.transaction_date_time) = 4 then 'April'
					 when MONTH(rip.transaction_date_time) = 5 then 'May'
					 when MONTH(rip.transaction_date_time) = 6 then 'June'
					 when MONTH(rip.transaction_date_time) = 7 then 'July'
					 when MONTH(rip.transaction_date_time) = 8 then 'August'
					 when MONTH(rip.transaction_date_time) = 9 then 'September'
					 when MONTH(rip.transaction_date_time) = 10 then 'October'
					 when MONTH(rip.transaction_date_time) = 11 then 'November'
					 when MONTH(rip.transaction_date_time) = 12 then 'December' end as Month,
				case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as [Organisation Type],
				rip.invoice_no as [Invoice Number],
				rip.hn as [HN],
				rip.patient_name as [Patient Name],
				rip.transaction_date_time as [Invoice Date],
				--case when rip.policy_name = '--' then rip.patient_name else rip.policy_name end as policy_name,
				--rip.swe_payment_status_rcd,
				rip.total_amt as [Invoice Amount],
				--sai.instalment_id,
				--r.remittance_id,
				sai.swe_payment_status_rcd as sai_payment_status,
				sai.net_amount as [Paid Amount],
				r.transaction_date_time as [Payment Date],
				DATEDIFF(DAY,rip.transaction_date_time,r.transaction_date_time) as aging
		   
				--p.policy_id,
				--case when c.person_id is not NULL then pfn.display_name_l else o.name_l end as payor_name
				from HISReport.dbo.rpt_invoice_pf rip LEFT OUTER JOIN AmalgaPROD.dbo.swe_ar_instalment sai on rip.invoice_id = sai.ar_invoice_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.remittance r on sai.remittance_id = r.remittance_id
										  inner JOIN AmalgaPROD.dbo.ar_invoice_nl_view ar on rip.invoice_id = ar.ar_invoice_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.policy p on ar.policy_id = p.policy_id
										  left OUTER JOIN AmalgaPROD.dbo.customer c on ar.customer_id = c.customer_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation o on c.organisation_id = o.organisation_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on c.person_id = pfn.person_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation_role oor on o.organisation_id = oor.organisation_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd
				where YEAR(rip.transaction_date_time) = 2015
						and MONTH(rip.transaction_date_time) >= 1 and  MONTH(rip.transaction_date_time) <= 1
						and ar.ar_invoice_id = sai.ar_invoice_id
						and ar.user_transaction_type_id in ('F8EF2162-3311-11DA-BB34-000E0C7F3ED2','30957FA1-735D-11DA-BB34-000E0C7F3ED2')
						and ar.transaction_status_rcd not in ('voi','unk')
						
		)as temp
			--where temp.aging >= 0 and temp.aging <= 30
)as tempb
	--order by temp.[Invoice Date] asc

*/