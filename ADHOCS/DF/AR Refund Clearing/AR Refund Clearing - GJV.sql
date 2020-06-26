select 
	   temp.[Reference Date],
       temp.PAR,
	   temp.Reference,
	   temp.[Related Invoice],
	   temp.[Related Invoice Date],
	   phu.visible_patient_id as HN,
       pfn.display_name_l as [Patient Name],
	   temp.Description,
	   [Gross Amount] = temp.[Credit Amount] - temp.[Debit Amount],
	   temp.[GL Account Code],
	   temp.[Gl Account Name]

from  (

	select 		
				gac.gl_acct_code_code as [GL Account Code],
				gac.name_l as [GL Account Name],
				ar.transaction_date_time as [Reference Date],
				gt.transaction_text as [PAR],
				ar.transaction_text as Reference,
				isnull((select transaction_text from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice],
				isnull((select transaction_date_time from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice Date],
				[Debit Amount] = case when debit_flag = 1 then gtd.amount else '-' end,
				[Credit Amount] = case when debit_flag = 0 then gtd.amount else '-' end,
	            REPLACE(REPLACE(ard.comment,'''','*'),'"','*') as Description,
	            patient_visit_id = (select distinct _cd.patient_visit_id 
						   from ar_invoice _ar inner join ar_invoice_detail _ard on _ar.ar_invoice_id = _ard.ar_invoice_id
											   inner join charge_detail _cd on _ard.charge_detail_id = _cd.charge_detail_id
						   where _ar.ar_invoice_id = ar.related_ar_invoice_id)


	from		gl_transaction_nl_view gt
	inner join gl_transaction_detail_nl_view gtd on gtd.gl_transaction_id = gt.gl_transaction_id 
	inner join gl_acct_code_nl_view gac on gac.gl_acct_code_id = gtd.gl_acct_code_id
	left JOIN ar_invoice_nl_view ar on gt.gl_transaction_id = ar.gl_transaction_id
	left JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id

	where gt.company_code = 'AHI'
		and	gt.transaction_status_rcd = 'POS'
		and gt.user_transaction_type_id = '8566FA00-63FE-11DA-BB34-000E0C7F3ED2'    --GJV
		and gac.gl_acct_code_code = '1130250'
)as temp
left join patient_visit pv on temp.patient_visit_id = pv.patient_visit_id
left join person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
left join patient_hospital_usage_nl_view phu on pfn.person_id = phu.patient_id