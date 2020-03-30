
select temp.employee_nr as [Employee NR],
       temp.caregiver_name as [Doctor Name],
	   temp.department_name_l as Department,
	   temp.specialty as Specialty,
	   temp.sub_specialty as [Sub-specialty],
	   temp.hn as HN,
	   temp.patient_name as [Patient Name],
	   temp.charge_date as [Charge Date],
	   temp.item_code as [Item Code],
	   temp.item_desc as [Item Name],
	   temp.charge_id

FROM (

	SELECT distinct cv.employee_nr,
		   cv.caregiver_name,
		   cv.department_name_l,
		   specialty = (Select top 1 specialty_name_l from dbo.doctor_specialties
							   where employee_nr = cv.employee_nr),
		   sub_specialty = (Select top 1 sub_specialty_name_l from dbo.doctor_specialties
							   where employee_nr = cv.employee_nr),
		   vc.hn,
		   vc.patient_name,
		   cd.charge_date,
		   cd.item_code,
		   cd.item_desc,
		   cd.charge_id


	from dbo.validated_charges vc inner join dbo.charge_details_vw cd on vc.charge_id = cd.charge_id
								  inner join dbo.caregiver_view cv on cv.employee_nr = cd.employee_number
	where cd.validated = 1
		  and vc.blocked_flag = 0
		  and cd.deleted_date_time is NULL
		  and cv.termination_date is NULL
		  and cv.department_name_l <> 'Rehabilitation Medicine'
		  and month(vc.charge_date) = 9
		  and year(vc.charge_date) = 2019


)as temp
--where CAST(CONVERT(VARCHAR(10),temp.charge_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
--	  and CAST(CONVERT(VARCHAR(10),temp.charge_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
order by [Charge Date]

