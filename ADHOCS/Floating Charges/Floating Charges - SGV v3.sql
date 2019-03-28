SELECT 

 temp.item_group_code as [Item Group Code],
	   temp.itemgroupname as [Item Group Name],
	   temp.item_code as [Item Code],
	   temp.itemname as [Item Name],
	   temp.service_provider as [Service Provider],
	   temp.service_requestor as [Service Requestor],
	   temp.amount as [Amount],
	   temp.charged_date_time as [Charge Date],
	   temp.chargedby as [Charged By],
	   temp.visit_code as [Visit Code],
	   temp.hn as [HN],
	   temp.patient_name as [Patient Name],
	   temp.visit_type as [Visit Type]
from
(
SELECT DISTINCT cd.charge_detail_id, 
		  ig.item_group_code,
		  ig.name_l as itemgroupname,
		  i.item_code,
		  i.name_l as itemname,
		  service_provider = (SELECT name_l from costcentre where costcentre_id = cd.service_provider_costcentre_id),
		  service_requestor = (SELECT name_l from costcentre where costcentre_id = cd.service_requester_costcentre_id),
		  cd.amount,
		  cd.charged_date_time,
		  chargedby = (select display_name_l from person_formatted_name_iview_nl_view where person_id = cd.charged_by_employee_id),
		 
		  pv.visit_code,
		  phu.visible_patient_id as hn,
		  pfn.display_name_l as patient_name,
		  vtr.name_l as visit_type,
		
		cd.deleted_date_time
from charge_detail cd  inner JOIN item i on cd.item_id = i.item_id
						inner JOIN item_group ig on i.item_group_id = ig.item_group_id
						inner JOIN patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
						inner JOIN patient_hospital_usage phu on pv.patient_id = phu.patient_id
						inner JOIN person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
						inner JOIN visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd
where cd.serviced_date_time is NULL
   and cd.deleted_date_time is NULL
   and cd.charge_detail_id not in (SELECT charge_detail_id from ar_invoice_detail where charge_detail_id = cd.charge_detail_id)
   and cd.adjustment_flag = 0
 --   and MONTH(cd.charged_date_time) = 1
	--and YEAR(cd.charged_date_time) = 2018
	and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2018',101) as SMALLDATETIME)
) as temp
order by temp.charged_date_time

--123714

SELECT *
from charge_detail
where charge_detail_id in ('A79E23BE-25F9-41F8-A187-000312A93D84',
'D83ED8FA-B22A-4B18-9280-0008367BCA02',
'8829A461-1B9A-44F7-B6DB-000CF5C78466',
'D9BF4E89-0F61-11DE-AB3C-000E0C7F3FA3')