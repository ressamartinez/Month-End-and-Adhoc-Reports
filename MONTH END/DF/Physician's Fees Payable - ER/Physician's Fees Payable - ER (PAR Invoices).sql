

select gac.gl_acct_code_code,
       gac.name_l as gl_acct_name,
	   phu.visible_patient_id as HN,
	   pfn.display_name_l as patient_name,
	   cd.charged_date_time,
	   i.item_code,
	   i.name_l as item_name,
	   ard.gross_amount,
	   ar.transaction_date_time,
	   ar.transaction_text,
	   gt.transaction_text,
	   p.period_code

from ar_invoice ar inner join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
			       inner join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
				   inner join item i on ard.item_id = i.item_id
				   inner join patient_visit pv on cd.patient_visit_id = pv.patient_visit_id
				   INNER JOIN person_formatted_name_iview as pfn ON pv.patient_id = pfn.person_id
                   inner join patient_hospital_usage phu on pv.patient_id = phu.patient_id
				   left outer join gl_acct_code gac on cd.gl_acct_code_id = gac.gl_acct_code_id
				   left outer join gl_transaction gt on ar.gl_transaction_id = gt.gl_transaction_id
				   left outer join period p on gt.period_id = p.period_id

where ar.transaction_status_rcd not in  ('voi','unk')
	  and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'
	  and gt.period_id = '818D9E17-C49E-4145-99A4-000051B5D4B9'
	  and gac.gl_acct_code_code = '2152250'
	  --and gt.transaction_text = 'PAR-2019-000299'
	  and ard.gross_amount > 0

order by gt.transaction_text

