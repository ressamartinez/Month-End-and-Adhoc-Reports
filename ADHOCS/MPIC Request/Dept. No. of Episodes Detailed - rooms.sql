
select cd.charge_detail_id,
       pv.charge_type_rcd as [Charge Type],
	   cd.charged_date_time as [Charged Date],
       be.ward_name_l as Ward,
       irc.name_l as [IPD Room Name],
	   pv.visit_code as [Visit Code],
	   pv.actual_visit_date_time as [Visit Start],
	   pv.closure_date_time as [Closure Date],
	   phu.visible_patient_id as HN,
	   pfn.display_name_l as [Patient Name],
	   (select employee_nr from employee_employment_info_view where person_id = cd.caregiver_employee_id) as [Employee NR],
	   (select RTRIM(last_name_l) + ', ' + RTRIM(first_name_l) from employee_employment_info_view where person_id = cd.caregiver_employee_id) as [Caregiver Name]

from charge_detail cd inner join patient_visit pv on cd.patient_visit_id = pv.patient_visit_id
                      inner join bed_charge bc on bc.charge_detail_id = cd.charge_detail_id
					  inner join bed_entry_info_view be on cd.patient_visit_id = be.patient_visit_id
					  inner join ipd_room_class_ref irc on be.ipd_room_class_rcd = irc.ipd_room_class_rcd
					  inner join patient_hospital_usage phu on pv.patient_id = phu.patient_id
					  inner join person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id

where cd.deleted_date_time is NULL
      and pv.cancelled_date_time is NULL
	  and be.cancelled_date_time is NULL
      and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2020',101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'01/31/2020',101) as SMALLDATETIME)
	  --and cd.patient_visit_id = '0DB4EE85-2C96-11EA-8D85-001E0BACC260'
	  and be.ward_name_l = '8B'
	  and irc.name_l = 'Ward'

order by Ward, [IPD Room Name], [Patient Name], [Charged Date]
