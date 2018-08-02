SELECT temp.[Main Group Code],
	   temp.[Main Group Name],
	   temp.[Item Code],
	   temp.[Item Name],
	   temp.[Visit Type],
	   temp.[Service Requestor],
	   CAST((SUM(temp.Quantity)) AS DECIMAL(10,2)) as Quantity,
	   CAST((SUM(temp.Amount)) AS DECIMAL(10,2)) as Amount
from
(
	SELECT DISTINCT cd.charge_detail_id,
		   cd.charged_date_time as [Charge Date Time],
		   inv.main_itemgroupcode as [Main Group Code],
		   inv.main_itemgroup as [Main Group Name],
			inv.visit_type as [Visit Type],
		   (select name_l from costcentre where costcentre_id = cd.service_requester_costcentre_id) as [Service Requestor],
		   inv.item_code as [Item Code],
		   inv.itemname as [Item Name],
		   phu.visible_patient_id as HN,
		   cd.quantity as Quantity,
		   cd.amount as Amount
	from HISReport.dbo.rpt_invoice_pf_detailed inv inner JOIN charge_detail_nl_view cd on inv.charge_detail_id = cd.charge_detail_id
												  inner JOIN patient_hospital_usage phu on inv.patient_id = phu.patient_id
												  inner JOIN person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
	where -- MONTH(cd.charged_date_time) = 1
		 --YEAR(cd.charged_date_time) = 2016
		inv.gl_acct_code_code = '2152100'
		and inv.main_itemgroupcode <> 's23'
		and cd.deleted_date_time is NULL
		and inv.main_itemgroupcode in ('090','094','095')
and inv.item_code IN (@item_code)

) as temp
GROUP by temp.[Main Group Code],
	     temp.[Main Group Name],
	     temp.[Item Code],
	     temp.[Item Name],
	     temp.[Visit Type],
	     temp.[Service Requestor]
order by temp.[Main Group Code], 
		 temp.[Item Code],
		 temp.[Visit Type],
		 temp.[Service Requestor]