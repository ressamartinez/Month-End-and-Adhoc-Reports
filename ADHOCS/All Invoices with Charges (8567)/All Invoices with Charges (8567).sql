
SELECT distinct phu.visible_patient_id as HN
       ,pfn.display_name_l as [Patient Name]
	   ,ar.transaction_text as [Invoice No.]
	   ,p.name_l as [Payor]
	   ,vtr.name_l as [Visit Type]
	   ,ar.transaction_date_time as [Transaction Date]
	   ,cd.closed_date_time as [Discharge Date]
	   ,ard.gross_amount as [Gross PF Amount]
	   ,ard.discount_amount as [Discount PF]
	   ,ard.gross_amount - ard.discount_amount as [Net PF Amount]
	   ,sp.name_l as [Payment Status] 

from ar_invoice ar left join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
				   left join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
				   left join employee_employment_info_view ee on cd.caregiver_employee_id = ee.person_id
				   left join patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
				   left join person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
				   left join patient_hospital_usage_nl_view phu on pfn.person_id = phu.patient_id
				   left join policy p on ar.policy_id = p.policy_id
				   left join visit_type_ref vtr on ar.visit_type_rcd = vtr.visit_type_rcd
				   left join swe_payment_status_ref sp on ar.swe_payment_status_rcd = sp.swe_payment_status_rcd

where ar.transaction_status_rcd not in ('voi','unk')
      and ard.gross_amount >= 0
      and ee.employee_nr in ('8567', '0003')
      and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2018',101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2018',101) as SMALLDATETIME)
	  --and ar.transaction_text = 'PINV-2019-133863'

order by [Transaction Date]




/*
SELECT * FROM employee_employment_info_view
where employee_nr in ('8567', '0003')
*/