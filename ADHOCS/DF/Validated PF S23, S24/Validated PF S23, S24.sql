
select temp.employee_nr as [Employee NR],
	   RTRIM(temp.caregiver_lname) + ', ' + RTRIM(temp.caregiver_fname) as [Doctor Name],
	   RTRIM(temp.department) as Department,
	   temp.specialty_name as Specialty,
	   temp.sub_specialty_name as [Sub-Specialty],
	   temp.upi as HN,
	   RTRIM(temp.lname) + ', ' + RTRIM(temp.fname) + ' ' + RTRIM(temp.mname) as [Patient Name],
	   temp.charge_date as [Charge Date],
	   temp.item_code as [Item Code],
	   RTRIM(temp.item_desc) as [Item Name]

from
(
select dba.employee_nr,
	   dba.caregiver_lname,
       dba.caregiver_fname,
	   department = (SELECT department_l from doctor WHERE employee_nr = dba.employee_nr),
	   dba.upi,
	   dba.lname,
	   dba.fname,
	   dba.mname,
	   dba.charge_date,
	   dba.item_code,
	   dba.item_desc,
	   CAST(REPLACE(esv.parent_clinical_specialty_name_l, '&', 'and') as VARCHAR(500)) AS specialty_name,
       CAST(REPLACE(esv.clinical_specialty_name_l, '&', 'and') as VARCHAR(500)) AS sub_specialty_name

from df_browse_all dba left outer join DBPROD03.AmalgaPROD.dbo.api_employee_specialty_view esv on esv.employee_nr = dba.employee_nr
where dba.validated = 'Y'
	  and CAST(CONVERT(VARCHAR(10),dba.charge_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2019',101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),dba.charge_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'02/28/2019',101) as SMALLDATETIME)

)as temp
where temp.department <> 'Rehabilitation Medicine'

order by temp.charge_date

