SELECT DISTINCT e.employee_nr,
	   pfn.display_name_l as employee_name,
	   jtl.name_l as job_title,
	   jt.name_l as job_type,
	   ou.name_l as department,
	   lt.name_l as license_type,
	   l.license_number,
	   o.name_l as orgranisation,
	   l.start_date as sdt,
	   CONVERT(VARCHAR(20), l.start_date,101) AS [Start Date],
	   l.end_date as edt,
	   CONVERT(VARCHAR(20), l.end_date,101) AS [End Date]
from employee e inner join patient_hospital_usage_nl_view phu on e.employee_id = phu.patient_id
			    inner join person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
			    inner JOIN employment_nl_view emp on e.employee_id = emp.employee_id
				inner join job_type jt on emp.job_type_code = jt.job_type_code
				inner join job_title jtl on emp.job_title_code = jtl.job_title_code
				inner JOIN organizational_unit ou on emp.department_id = ou.organizational_unit_id
				inner JOIN license l on e.employee_id = l.person_id
				inner join license_type_ref lt on l.license_type_rcd = lt.license_type_rcd
				inner join organisation o on l.organisation_id = o.organisation_id
where employee_termination_reason_rcd is NULL
	 and jt.job_category_code = 'DOC'
	 and CAST(CONVERT(VARCHAR(10),l.end_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),GETDATE(),101) as SMALLDATETIME)
	 and emp.department_id IN (@department_id)
order by employee_name, l.end_date