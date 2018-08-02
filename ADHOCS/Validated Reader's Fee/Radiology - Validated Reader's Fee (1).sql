
SELECT 
			--costcentre_group_id as [Costcentre Group ID]
			costcentre_group as [Costcentre Group]
			,employee_nr as [Employee NR]
			,caregiver_lname as [Caregiver Last Name]
			,caregiver_fname as [Caregiver First Name]
			,caregiver_job_type as [Caregiver Job Type]
			,upi as [HN]
			,lname as [Patient Last Name]
			,fname as [Patient First Name]
			,mname as [Patient Middle Name]
			,admission_date as [Admission Date and Time]
			,CONVERT(VARCHAR(20), admission_date,101) AS [Admission Date]
			,substring(convert(varchar(20), admission_date, 9), 13, 5) + ' ' + 
			substring(convert(varchar(30), admission_date, 9), 25, 2) AS [Admission Time]
			,admission_type as [Admission Type]
			,visit_type as [Visit Type]
			,item_code as [Item Code]
			,item_desc as [Item Description]
			,charge_date as [Charge Date and Time]
			,CONVERT(VARCHAR(20), charge_date,101) AS [Charge Date]
			,substring(convert(varchar(20), charge_date, 9), 13, 5) + ' ' + 
			substring(convert(varchar(30), charge_date, 9), 25, 2) AS [Charge Time]
			,validated as [Validated]
			,service_requestor as [Service Requestor]
			,service_provider as [Service Provider]
			--,validated_by_username as [Validated by Username]
			--,validated_by as [Validated By]
			--,validated_datetime as [Validated Date and Time]

			--,* +
FROM df_browse_validated

where validated = 'yes'
			and costcentre_group = 'radiology'
			AND year(charge_date) = 2018
			AND MONTH(charge_date) = 6
			--and CAST(CONVERT(VARCHAR(10), charge_date,101) as SMALLDATETIME) >=  CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
   -- and CAST(CONVERT(VARCHAR(10), charge_date,101) as SMALLDATETIME) <=  CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
order by [Charge Date and Time]



/******************************************/

SELECT COUNT(*) as [No. of Readings]
			,employee_nr as [Employee NR]
			,caregiver_lname as [Caregiver Last Name]
			,caregiver_fname as [Caregiver First Name]

FROM df_browse_validated

where validated = 'yes'
			and costcentre_group = 'radiology'
			AND year(charge_date) = 2018
			AND MONTH(charge_date) = 6
			--and CAST(CONVERT(VARCHAR(10), charge_date,101) as SMALLDATETIME) >=  CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
   -- and CAST(CONVERT(VARCHAR(10), charge_date,101) as SMALLDATETIME) <=  CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)

GROUP BY employee_nr,caregiver_lname,caregiver_fname
ORDER BY [Caregiver Last Name]