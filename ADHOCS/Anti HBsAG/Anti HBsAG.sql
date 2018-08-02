SELECT distinct temp.hn,
	   temp.patient_name,
	   temp.created_date_time,
	   CONVERT(VARCHAR(20), temp.created_date_time,101) AS [Date Requested],
		--CONVERT(VARCHAR(20), temp.created_date_time,108) AS [Time Requested],
		FORMAT(temp.created_date_time,'hh:mm tt') AS [Time Requested],
	   temp.item,
	   temp.lab_process,
	   temp.observed_value,
	   case when temp.observed_value = '>1000.00' then '>1000.00 (Antibody Positive)' ELSE temp.observed_value end as observed_value_2
from
(
	SELECT DISTINCT lp.lab_process_id,
			phu.visible_patient_id as hn,
			pfn.display_name_l as patient_name,
			e.employee_nr,
			emp.job_type_code,
			jt.job_category_code,
			jtl.name_l as job_title,
			jt.name_l as job_type,
			i.name_l as item,
			lp.name_l as lab_process,
			employee_termination_reason_rcd,
			lsr.created_date_time,
			lo.observed_value,
			lo.numeric_value,
			lo.observation_response_rcd,
			lo.observation_result_type_rcd
	from employee e inner join patient_hospital_usage_nl_view phu on e.employee_id = phu.patient_id
					inner join person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
					inner JOIN employment_nl_view emp on e.employee_id = emp.employee_id
					inner join job_type jt on emp.job_type_code = jt.job_type_code
					inner join job_title jtl on emp.job_title_code = jtl.job_title_code
					inner join patient_visit pv on e.employee_id = pv.patient_id
					inner join lab_service_request lsr on pv.patient_visit_id = lsr.patient_visit_id
					inner JOIN lab_work_order lwo on lsr.lab_service_request_id = lwo.lab_service_request_id
					inner join lab_work_order_item lwoi on lwo.lab_work_order_id = lwoi.lab_work_order_id
					inner join charge_detail cd on pv.patient_visit_id = cd.patient_visit_id
					inner JOIN item i on cd.item_id = i.item_id
					inner JOIN lab_process_nl_view lp on lwoi.lab_process_id = lp.lab_process_id
					LEFT OUTER JOIN lab_observation lo on lwoi.lab_work_order_item_id = lo.lab_work_order_item_id
	where jt.job_category_code <> 'DOC'
		  and YEAR(lsr.created_date_time) = @Year
		  and MONTH(lsr.created_date_time) IN (@Month)
			and i.item_code = '090-30-1910'
			and lp.lab_process_code in ('IMM028',
										'IMM009',
										'IMM007') 
		 and lwo.cpoe_placer_order_status_rcd <> 'CANCL'
	UNION ALL
	SELECT DISTINCT lp.lab_process_id,
			phu.visible_patient_id as hn,
			pfn.display_name_l as patient_name,
			e.employee_nr,
			emp.job_type_code,
			jt.job_category_code,
			jtl.name_l as job_title,
			jt.name_l as job_type,
			i.name_l as item,
			lp.name_l as lab_process,
			employee_termination_reason_rcd,
			lsr.created_date_time,
			lo.observed_value,
			lo.numeric_value,
			lo.observation_response_rcd,
			lo.observation_result_type_rcd
	from employee e inner join patient_hospital_usage_nl_view phu on e.employee_id = phu.patient_id
					inner join person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
					inner JOIN employment_nl_view emp on e.employee_id = emp.employee_id
					inner join job_type jt on emp.job_type_code = jt.job_type_code
					inner join job_title jtl on emp.job_title_code = jtl.job_title_code
					inner join patient_visit pv on e.employee_id = pv.patient_id
					inner join lab_service_request lsr on pv.patient_visit_id = lsr.patient_visit_id
					inner JOIN lab_work_order lwo on lsr.lab_service_request_id = lwo.lab_service_request_id
					inner join lab_work_order_item lwoi on lwo.lab_work_order_id = lwoi.lab_work_order_id
					inner join charge_detail cd on pv.patient_visit_id = cd.patient_visit_id
					inner JOIN item i on cd.item_id = i.item_id
					inner JOIN lab_process_nl_view lp on lwoi.lab_process_id = lp.lab_process_id
					left OUTER JOIN lab_observation lo on lwoi.lab_work_order_item_id = lo.lab_work_order_item_id
	where jt.job_type_code in ('B1476',
							   'JT13',
							   'JT14',
							   'JT33')
		  and YEAR(lsr.created_date_time) = @Year
		  and MONTH(lsr.created_date_time) IN (@Month)
			and i.item_code = '090-30-1910'
			and lp.lab_process_code in ('IMM028',
										'IMM009',
										'IMM007') 
		 and lwo.cpoe_placer_order_status_rcd <> 'CANCL'
) as temp
order by temp.patient_name,temp.lab_process