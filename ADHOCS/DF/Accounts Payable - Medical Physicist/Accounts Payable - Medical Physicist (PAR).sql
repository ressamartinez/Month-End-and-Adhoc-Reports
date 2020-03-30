
SELECT temp.PAR,
       temp.[Invoice Number],
	   temp.[Invoice Date],
	   temp.[Related Invoice],
	   temp.[Related Invoice Date],
	   temp.[Item Code],
	   temp.[Item Name],
	   temp.[Costcentre Code],
	   temp.[Costcentre],
	   temp.[Qty],
	   temp.[Unit Price],
	   temp.[Gross Amount],
	   temp.[Discount Amount],
	   temp.[Net Amount],
	   temp.HN,
	   temp.[Patient Name],
	   temp.[Employee NR],
	   temp.[Caregiver Name],
	   temp.[Service Requestor],
	   temp.[GL Account Code],
	   temp.[Gl Account Name]
       
from (

	select glt.transaction_text as [PAR],
	   ar.transaction_text as [Invoice Number],
	   isnull((select transaction_text from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice],
	   isnull((select transaction_date_time from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice Date],
	   ar.transaction_date_time as [Invoice Date],
	   i.item_code as [Item Code],
	   i.name_l as [Item Name],
	   (select costcentre_code  from costcentre where costcentre_id = ard.costcentre_credit_id) as [Costcentre Code],
	   (select name_l from costcentre where costcentre_id = ard.costcentre_credit_id) as [Costcentre],
	   ard.quantity as [Qty],
	   ard.unit_price as [Unit Price],
	   ard.gross_amount  * ar.credit_factor as [Gross Amount],
	   ard.discount_amount as [Discount Amount],
	   (ard.gross_amount - ard.discount_amount) * ar.credit_factor as [Net Amount],
	   phu.visible_patient_id as HN,
	   pfn.display_name_l as [Patient Name],
	   (select employee_nr from employee_employment_info_view where person_id = cd.caregiver_employee_id) as [Employee NR],
	   (select RTRIM(last_name_l) + ', ' + RTRIM(first_name_l) from employee_employment_info_view where person_id = cd.caregiver_employee_id) as [Caregiver Name],
	   (select name_l from costcentre where costcentre_id = cd.service_requester_costcentre_id) as [Service Requestor],
	   gac.gl_acct_code_code as [GL Account Code],
	   gac.name_l as [Gl Account Name]
	   
	from gl_transaction glt inner JOIN ar_invoice_nl_view ar on glt.gl_transaction_id = ar.gl_transaction_id
							inner JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
							inner JOIN gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
							LEFT OUTER JOIN charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
							LEFT OUTER JOIN patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
					   		LEFT OUTER  JOIN patient_hospital_usage phu on pv.patient_id = phu.patient_id
							LEFT OUTER  JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
							LEFT OUTER JOIN policy p on ar.policy_id = p.policy_id
							LEFT OUTER JOIN item i on ard.item_id = i.item_id
							inner JOIN visit_type_ref vtr on ar.visit_type_rcd = vtr.visit_type_rcd
							inner JOIN transaction_status_ref tsr on ar.transaction_status_rcd = tsr.transaction_status_rcd
							--left outer JOIN discount_posting_rule dpr on ard.discount_posting_rule_id = dpr.discount_posting_rule_id
	where  
	--MONTH(ar.transaction_date_time) = 11
	--	 and YEAR(ar.transaction_date_time) = 2017
		CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2016',101) as SMALLDATETIME)
		and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'02/29/2020',101) as SMALLDATETIME)
		and ar.transaction_status_rcd not in ('unk','voi')
		AND gac.gl_acct_code_code IN ('2154940')	
		and cd.deleted_date_time is null
		and glt.user_transaction_type_id = '30957FA9-735D-11DA-BB34-000E0C7F3ED2'   --PAR
		and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'    --PINV
		--and ar.user_transaction_type_id in ('30957F9E-735D-11DA-BB34-000E0C7F3ED2', '30957F9F-735D-11DA-BB34-000E0C7F3ED2',   --CMAR, DMAR
		--                                    '30957FA1-735D-11DA-BB34-000E0C7F3ED2')   --CINV     
		--and ar.transaction_text = 'PINV-2016-014704'  
		                            
)as temp
order by temp.PAR
