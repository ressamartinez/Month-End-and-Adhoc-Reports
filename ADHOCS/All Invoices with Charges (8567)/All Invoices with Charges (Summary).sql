
select DISTINCT
	   --year(temp.[Transaction Date])  as Year 
	   --,month(transaction_date_time) as Month
	   temp.[Organisation Type]
	   ,case when temp.[Organisation Type] = 'Self Pay' then sum(temp.[Gross PF Amount]) 
	        when temp.[Organisation Type] = 'HMO' then sum(temp.[Gross PF Amount]) 
	        when temp.[Organisation Type] = 'Philhealth' then sum(temp.[Gross PF Amount]) 
	        when temp.[Organisation Type] = 'Corporate Account' then sum(temp.[Gross PF Amount])
	        when temp.[Organisation Type] = 'International Insurance' then sum(temp.[Gross PF Amount]) end as 'Total'


from (
		SELECT distinct case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as 'Organisation Type'
			   ,phu.visible_patient_id as HN
			   ,pfn.display_name_l as [Patient Name]
			   ,ar.transaction_text as [Invoice No.]
			   ,p.name_l as [Payor]
			   ,vtr.name_l as [Visit Type]
			   ,ar.transaction_date_time as [Transaction Date]
			   ,cd.closed_date_time as [Discharge Date]
			   ,ar.gross_amount as [Gross PF Amount]
			   ,ar.discount_amount as [Discount PF]
			   ,ar.gross_amount - ar.discount_amount as [Net PF Amount]
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
						   left OUTER JOIN customer c on ar.customer_id = c.customer_id
						   LEFT OUTER JOIN organisation o on c.organisation_id = o.organisation_id
						   LEFT OUTER JOIN person_formatted_name_iview_nl_view pfn1 on c.person_id = pfn1.person_id
						   LEFT OUTER JOIN organisation_role oor on o.organisation_id = oor.organisation_id
						   LEFT OUTER JOIN organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd

		where ar.transaction_status_rcd not in ('voi','unk')
			  and ar.gross_amount >= 0
			  --and ee.employee_nr in ('8567', '0003')
			  --and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2016',101) as SMALLDATETIME)
			  --and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2016',101) as SMALLDATETIME)
			  --and ar.transaction_text in ('PINV-2016-000068', 'PINV-2016-000122')

)as temp
where 
	  year(temp.[Transaction Date]) = 2016
      --and month(temp.[Transaction Date]) between 1 and 8
	  --year(transaction_date_time) between 2016 and 2018

group by temp.[Organisation Type]

/*
SELECT * FROM employee_employment_info_view
where employee_nr in ('8567', '0003')
*/