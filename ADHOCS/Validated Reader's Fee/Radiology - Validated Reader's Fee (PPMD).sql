

SELECT cg.costcentre_group_description as [Costcentre Group],
       cd.doctor_id as [Employee NR],
	   cd.d_lname as [Caregiver Last Name],
	   cd.fname as [Caregiver First Name],
	   cd.caregiver_job_type as [Caregiver Job Type],
	   vc.hn as HN,
	   vc.patient_name as [Patient Name],
	   cd.admission_date as [Admission Date],
	   cd.admission_type as [Admission Type],
	   cd.visit_type as [Visit Type],
	   vc.item_code as [Item Code],
	   vc.item_desc as [Item Description],
	   cd.charge_date as [Charge Date],
	   'Yes' as Validated,
	   case when vc.posted_flag = 0 then 'No'
	        when vc.posted_flag = 1 then 'Yes'
	   end as Posted,
	   cd.service_requestor as [Service Requestor],
	   cd.service_provider as [Service Provider]

from dbo.validated_charges vc inner join dbo.charge_details cd on vc.charge_id = cd.charge_id
                              inner join dbo.costcentre_group cg on vc.costcentre_group_id = cg.costcentre_group_id
where blocked_flag = 0
      and CAST(CONVERT(VARCHAR(10), vc.charge_date,101) as SMALLDATETIME) >=  CAST(CONVERT(VARCHAR(10),'10/01/2019',101) as SMALLDATETIME)
      and CAST(CONVERT(VARCHAR(10), vc.charge_date,101) as SMALLDATETIME) <=  CAST(CONVERT(VARCHAR(10),'12/31/2019',101) as SMALLDATETIME)
      --and cg.costcentre_group_id IN (@costcentre_id)


/*SELECT COUNT(*) as [No. of Readings],
       cd.doctor_id as [Employee NR],
	   cd.d_lname as [Caregiver Last Name],
	   cd.d_fname as [Caregiver First Name]

from dbo.validated_charges vc inner join dbo.charge_details cd on vc.charge_id = cd.charge_id
                              inner join dbo.costcentre_group cg on vc.costcentre_group_id = cg.costcentre_group_id
where blocked_flag = 0
      and CAST(CONVERT(VARCHAR(10), vc.charge_date,101) as SMALLDATETIME) >=  CAST(CONVERT(VARCHAR(10),'10/01/2019',101) as SMALLDATETIME)
      and CAST(CONVERT(VARCHAR(10), vc.charge_date,101) as SMALLDATETIME) <=  CAST(CONVERT(VARCHAR(10),'10/31/2019',101) as SMALLDATETIME)
      --and cg.costcentre_group_id IN (@costcentre_id)
group by cd.d_fname, cd.doctor_id, cd.d_lname
order by cd.d_lname*/
