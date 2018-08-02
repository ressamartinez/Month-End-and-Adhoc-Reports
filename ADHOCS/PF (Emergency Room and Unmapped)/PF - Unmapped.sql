SELECT
       DBA.employee_nr as [Employee NR],
       DBA.caregiver_lname as [Caregiver Last Name],
       DBA.caregiver_fname as [Caregiver First Name],
       DBA.caregiver_job_type as [Caregiver Job Type],
       DBA.upi as 'HN',
       DBA.lname as [Patient Last Name],
       DBA.fname as [Patient First Name],
       DBA.mname as [Patient Middle Name],
       DBA.item_code as [Item Code],
       DBA.item_desc as [Item Description],
       DBA.unit_price as [Unit Price],
       DBA.total_amt as [Total Amt],
       DBA.discount_amt as [Discount Amt],
       DBA.charge_date as [Charge DateTime],
	   CONVERT(VARCHAR(20), DBA.charge_date,101) AS [Charge Date],
	   substring(convert(varchar(20), DBA.charge_date, 9), 13, 5) + ' ' + 
	   substring(convert(varchar(30), DBA.charge_date, 9), 25, 2) AS [Charge Time],
       DBA.validated as Validated,
       DBA.processed as Processed,
       DBA.service_requestor as [Service Requestor],
       DBA.service_provider as [Service Provider]
FROM ITWORKSDS01.DIS.dbo.df_browse_all DBA
WHERE DBA.costcentre_group_id = 'E096E246-6DAF-499B-856F-FAB06E528D08'
AND DBA.charge_date BETWEEN @From and @To
and DBA.validated = 'N'
ORDER BY [Charge Date]

/*
SELECT *
from costcentre_group
--where costcentre_group_id = '710D6E5C-AADE-41DC-AF68-A71D87C798EA'
order by costcentre_group_description

SELECT *
from costcentre_group_costcentre
where costcentre_group_id = '710D6E5C-AADE-41DC-AF68-A71D87C798EA'

SELECT *
from costcentre
where name_l LIKE '%cardiac%'
*/