
select distinct gac.gl_acct_code_code,
	   gac.name_l as gl_acct_name,
	   phu.visible_patient_id as HN,
	   pfn.display_name_l as patient_name,
	   cd.charged_date_time,
	   i.item_code,
	   i.name_l as item_name,
	   ard.gross_amount,
	   ard.discount_amount,
	   ard.gross_amount - ard.discount_amount as net_amount,
	   case when ar.swe_payment_status_rcd = 'COM' then 'Completely Paid'
			when ar.swe_payment_status_rcd = 'UNP' then 'Unpaid'
			when ar.swe_payment_status_rcd = 'PART' then 'Partially Paid'
	   end as payment_status,    
	   ar.transaction_text as invoice_no,
	   ar.transaction_date_time

from ar_invoice ar inner join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
				   inner join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
				   inner join item i on ard.item_id = i.item_id
				   INNER JOIN dbo.patient_visit_nl_view AS pv ON cd.patient_visit_id = pv.patient_visit_id
				   INNER JOIN dbo.person_formatted_name_iview as pfn ON pv.patient_id = pfn.person_id
                   inner join dbo.patient_hospital_usage phu on pv.patient_id = phu.patient_id
				   inner join gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id 

where ar.transaction_status_rcd not in  ('voi','unk')
	  and cd.deleted_date_time is null
      and pv.cancelled_date_time is null
	  and MONTH(ar.transaction_date_time) = 1
      and YEAR(ar.transaction_date_time) = 2019
	  and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'
	  and gac.gl_acct_code_code = '2152100'
	  

--2152100 69,429,077.09
--4264000 17,442,420.86

--PF_ER - inner join gl_acct_code gac on cd.gl_acct_code_id = gac.gl_acct_code_id