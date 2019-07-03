

SELECT *
	   ,transaction_text = rtrim(temp.transaction_date_month_name) + '-' + rtrim(temp.transaction_year)

FROM
(
	select rdsa.upi as hn
		   ,rdsa.patient_name
		   ,rdsa.admission_type
		   ,rdsa.admission_type_after_move
		   ,rdsa.admitting_doctor
		   ,rdsa.bed
		   ,rdsa.order_owner
		   ,rdsa.order_owner_specialty
		   ,rdsa.order_owner_sub_specialty
		   ,rdsa.item_group_code
		   ,rdsa.item_group_name
		   ,rdsa.item_code
		   ,rdsa.item_desc
		   ,rdsa.item_type_rcd
		   ,rdsa.item_type_name
		   ,rdsa.visit_type_rcd
		   ,rdsa.visit_type_rcd_after_move
		   ,visit_type_category = (case when rdsa.visit_type_rcd = 'V4' then 'ER' else 'NON-ER' end)
		   ,visit_type_rcd_after_move_category = (case when rdsa.visit_type_rcd = 'V4' AND rdsa.visit_type_rcd_after_move = 'V1' then 'TO IPD' else 'NOT TO IPD' end)
		   ,rdsa.qty
		   ,rdsa.total_amount
		   ,rdsa.service_requestor
		   ,rdsa.service_provider
		   ,rdsa.service_category
		   ,rdsa.gl_acct_code_code
		   ,rdsa.gl_acct_name
		   ,rdsa.transaction_date_time
		   ,CONVERT(VARCHAR(20),rdsa.transaction_date_time,101) as transaction_date
		   ,FORMAT(rdsa.transaction_date_time,'hh:mm tt') as transaction_time
		   ,day(rdsa.transaction_date_time) as transaction_date_day
		   ,month(rdsa.transaction_date_time) as transaction_date_month
		   ,DATENAME(month,rdsa.transaction_date_time) as transaction_date_month_name
		   ,year(rdsa.transaction_date_time) as transaction_year
		   ,rdsa.transaction_type
		   ,rdsa.transaction_by
		   ,current_diagnosis = (SELECT top 1 csed.description 
										FROM AMALGAPROD.dbo.patient_visit_diagnosis_view pv left outer join AMALGAPROD.dbo.coding_system_element_description csed on pv.code = csed.code 
										WHERE patient_visit_id = rdsa.patient_visit_id AND current_visit_diagnosis_flag = 1 
										ORDER BY recorded_at_date_time DESC)
		   ,admitting_diagnosis = (SELECT top 1 csed.description 
										FROM AMALGAPROD.dbo.patient_visit_diagnosis_view pv left outer join AMALGAPROD.dbo.coding_system_element_description csed on pv.code = csed.code
										WHERE patient_visit_id = rdsa.patient_visit_id AND diagnosis_type_rcd = 'ADM' 
										ORDER BY recorded_at_date_time DESC)
		   ,discharge_diagnosis = (SELECT top 1 csed.description 
										FROM AMALGAPROD.dbo.patient_visit_diagnosis_view pv left outer join AMALGAPROD.dbo.coding_system_element_description csed on pv.code = csed.code
										WHERE patient_visit_id = rdsa.patient_visit_id AND diagnosis_type_rcd = 'DIS' 
										ORDER BY recorded_at_date_time DESC)


	from rpt_daily_statistics_all rdsa

) as temp
where --temp.transaction_date_month = 1
      temp.transaction_date_time between '01/01/2018 00:00:00.000'  and '12/31/2018 23:59:59.998'
      --and temp.transaction_year = 2018
	  and temp.item_type_rcd = 'PCK'

order by temp.transaction_date, temp.item_group_name, temp.item_desc, temp.transaction_type


