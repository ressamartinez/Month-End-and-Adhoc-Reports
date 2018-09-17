declare @table table
(
	ar_invoice_id uniqueidentifier,
	discharged_date_time smalldatetime,
	hospital_number varchar(20),
	patient_name varchar(500),
	payor varchar(500)
)


INSERT into @table(ar_invoice_id, discharged_date_time,hospital_number,patient_name,payor)
SELECT DISTINCT _ar.ar_invoice_id,
	   _pv.closure_date_time as discharged_date_time,
	    _phu.visible_patient_id as hn,
	   _pfn.display_name_l,
	   case when _p.policy_id is not null then _p.name_l else _pfn.display_name_l end as payor
	   
from ar_invoice_nl_view _ar inner JOIN ar_invoice_detail _ard on _ar.ar_invoice_id = _ard.ar_invoice_id
							inner JOIN charge_detail _cd on _ard.charge_detail_id = _cd.charge_detail_id
							inner JOIN patient_visit_nl_view _pv on _cd.patient_visit_id = _pv.patient_visit_id
							inner JOIn patient_hospital_usage_nl_view _phu on _pv.patient_id = _phu.patient_id
							inner JOIN person_formatted_name_iview_nl_view _pfn on _phu.patient_id = _pfn.person_id
							inner JOIN gl_acct_code _gac on _ard.gl_acct_code_credit_id = _gac.gl_acct_code_id
							left outer join policy _p on _ar.policy_id = _p.policy_id
where _gac.gl_acct_code_code in  ('2152100', '4264000')	
    and _ar.related_ar_invoice_id is NULL



SELECT case when phu.visible_patient_id is not NULL then phu.visible_patient_id ELSE		
				(select DISTINCT _t.hospital_number from @table _t where _t.ar_invoice_id = ar.related_ar_invoice_id) end as HN
	   
	    ,case when phu.visible_patient_id is not NULL then pfn.display_name_l ELSE		
				(select DISTINCT _t.patient_name from @table _t where _t.ar_invoice_id = ar.related_ar_invoice_id) end as [Patient Name]
		,case when phu.visible_patient_id is not null then pv.closure_date_time else (select DISTINCT _t.discharged_date_time from @table _t where _t.ar_invoice_id = ar.related_ar_invoice_id) end as [Discharge Date Time]
	   ,ar.transaction_text as [Invoice Number]
	   ,ar.transaction_date_time as [Invoice Date]
       ,i.item_code as [Item Code]
	   ,i.name_l as [Item Name]
	   ,cd.amount as [Total Amount]
	   ,ard.gross_amount * ar.credit_factor as [Allocation Gross Amount]
	   ,ard.discount_amount * ar.credit_factor as [Allocation Discount Amount]
	   ,(ard.gross_amount * ar.credit_factor) - ard.discount_amount as [Allocation Net Amount]
	   ,case when phu.visible_patient_id is not NULL then (case when p.name_l is null then  pfn.display_name_l else p.name_l end) ELSE
			(select DISTINCT _t.payor from @table _t where ar.related_ar_invoice_id = _t.ar_invoice_id) end as  [Payor Name]
		,(select employee_nr from employee_employment_info_view where person_id = cd.caregiver_employee_id) as [Employee NR]
		,isnull((select display_name_l from person_formatted_name_iview_nl_view where person_id = cd.caregiver_employee_id),'') as [Doctor Name]
		,tsr.name_l as [Invoice Status]	
	    ,vtr.name_l as [Visit Type]
		,gac.gl_acct_code_code as [GL Account Code]
		,gac.name_l as [Gl Account Name]
		,dpr.name_l as [Discount Name]
from ar_invoice_nl_view ar 
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
						left outer JOIN discount_posting_rule dpr on ard.discount_posting_rule_id = dpr.discount_posting_rule_id
where  MONTH(ar.transaction_date_time) = 8
	 and YEAR(ar.transaction_date_time) = 2018
	 and ar.transaction_status_rcd not in ('unk','voi')
	-- and ar.user_transaction_type_id not in  ('F8EF2162-3311-11DA-BB34-000E0C7F3ED2', '30957FA1-735D-11DA-BB34-000E0C7F3ED2')
	AND gac.gl_acct_code_code IN ('2152100', '4264000')	
	and cd.deleted_date_time is null
	--and phu.visible_patient_id is NULL
order by ar.transaction_date_time