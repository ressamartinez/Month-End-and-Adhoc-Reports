
SELECT temp.[Reference Date],
       temp.PAR,
	   temp.Reference,
	   temp.[Related Invoice],
	   temp.[Related Invoice Date],
	   temp.Customer,
	   phu.visible_patient_id as HN,
       pfn.display_name_l as [Patient Name],
	   temp.Description,
	   temp.[Gross Amount],
	   temp.[GL Account Code],
	   temp.[Gl Account Name]
       
from (

	select glt.transaction_text as [PAR],
	       ar.transaction_text as Reference,
	       isnull((select transaction_text from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice],
	       isnull((select transaction_date_time from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice Date],
	       ar.transaction_date_time as [Reference Date],
	       ard.gross_amount  * ar.credit_factor as [Gross Amount],
	       gac.gl_acct_code_code as [GL Account Code],
	       gac.name_l as [Gl Account Name],
	       REPLACE(REPLACE(ard.comment,'''','*'),'"','*') as Description,
	       patient_visit_id = (select distinct _cd.patient_visit_id 
						   from ar_invoice _ar inner join ar_invoice_detail _ard on _ar.ar_invoice_id = _ard.ar_invoice_id
											   inner join charge_detail _cd on _ard.charge_detail_id = _cd.charge_detail_id
						   where _ar.ar_invoice_id = ar.related_ar_invoice_id),
	       Customer = (CASE WHEN ar.customer_id IS NOT NULL then 
						  (select display_name_l from person_formatted_name_iview where person_id = c.person_id)
						  else (SELECT name_l from organisation WHERE organisation_id = c.organisation_id)
						  END)
	   
	from gl_transaction glt inner JOIN ar_invoice_nl_view ar on glt.gl_transaction_id = ar.gl_transaction_id
							inner JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
							inner JOIN gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
							inner join customer c on ar.customer_id = c.customer_id

	where  
	--MONTH(ar.transaction_date_time) = 11
	--	 and YEAR(ar.transaction_date_time) = 2017
		ar.transaction_status_rcd not in ('unk','voi')
		and glt.transaction_status_rcd = 'POS'
		and glt.company_code = 'AHI'
		AND gac.gl_acct_code_code IN ('1130250')	
		--and glt.user_transaction_type_id = '30957FA9-735D-11DA-BB34-000E0C7F3ED2'   --PAR
		--and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'    --PINV
		--and ar.user_transaction_type_id in ('30957F9E-735D-11DA-BB34-000E0C7F3ED2', '30957F9F-735D-11DA-BB34-000E0C7F3ED2',   --CMAR, DMAR
		--                                    '30957FA1-735D-11DA-BB34-000E0C7F3ED2')   --CINV   
		--and ar.transaction_text = 'CMAR-2010-007684'   
		                            
)as temp
left join patient_visit pv on temp.patient_visit_id = pv.patient_visit_id
left join person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
left join patient_hospital_usage_nl_view phu on pfn.person_id = phu.patient_id


order by temp.[Related Invoice]
