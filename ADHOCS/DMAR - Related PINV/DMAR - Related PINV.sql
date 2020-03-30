

select DISTINCT
	   ar.transaction_date_time as date_of_dmar,
	   ar.transaction_text as dmar,
	   phu.visible_patient_id as hn,
	   pfn.display_name_l as patient_name,
	   ar.gross_amount,
	   ar2.transaction_text as related_invoice_no,
	   ar2.transaction_date_time as invoice_date


from ar_invoice ar left outer join ar_invoice ar2 on ar.related_ar_invoice_id = ar2.ar_invoice_id
				   left outer join ar_invoice_detail ard on ar2.ar_invoice_id = ard.ar_invoice_id
				   left outer join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
				   left outer join patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
				   left outer join person_formatted_name_iview pfn on pv.patient_id = pfn.person_id
				   LEFT OUTER join patient_hospital_usage phu on pv.patient_id = phu.patient_id

				   
where year(ar.transaction_date_time) between 2014 and 2019
      and ar.user_transaction_type_id = '30957F9F-735D-11DA-BB34-000E0C7F3ED2'    --DMAR
	  and ar2.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'   --PINV
      --and ar.transaction_text = 'DMAR-2014-000640'

order by dmar
