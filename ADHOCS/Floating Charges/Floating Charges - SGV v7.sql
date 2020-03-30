SELECT
       temp.item_group_code as [Item Group Code],
	   temp.itemgroupname as [Item Group Name],
	   temp.item_code as [Item Code],
	   temp.itemname as [Item Name],
	   temp.service_provider as [Service Provider],
	   temp.service_requestor as [Service Requestor],
	   temp.amount as [Amount],
	   temp.charged_date_time as [Charge Date],
	   --temp.chargedby as [Charged By],
	   temp.invoice_no as [Invoice No],
	   temp.invoice_date as [Invoice Date],
	   temp.visit_code as [Visit Code],
	   temp.hn as [HN],
	   --temp.patient_name as [Patient Name],
	   temp.visit_type as [Visit Type],
	   temp.orderstatus as [Order Status]
from
(
	SELECT DISTINCT 
	          cd.charge_detail_id, 
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
			  invoice_no =  (SELECT top 1 _ar.transaction_text
							from ar_invoice_nl_view _ar inner JOIN ar_invoice_detail _ard on _ar.ar_invoice_id = _ard.ar_invoice_id
							where _ard.charge_detail_id = cd.charge_detail_id
								and _ar.transaction_status_rcd not in ('unk','voi')
								and _ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'
							order by _ar.transaction_date_time),
			  invoice_date = (SELECT top 1 _ar.transaction_date_time
							from ar_invoice_nl_view _ar inner JOIN ar_invoice_detail _ard on _ar.ar_invoice_id = _ard.ar_invoice_id
							where _ard.charge_detail_id = cd.charge_detail_id
								and _ar.transaction_status_rcd not in ('unk','voi')
								and _ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'
							order by _ar.transaction_date_time),
			  cd.deleted_date_time,
			  cpos.name_l as orderstatus
			  

	from charge_detail cd   inner JOIN item i on cd.item_id = i.item_id
							inner JOIN item_group ig on i.item_group_id = ig.item_group_id
							inner JOIN patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
							inner JOIN patient_hospital_usage phu on pv.patient_id = phu.patient_id
							inner JOIN person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
							inner JOIN visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd
						    inner JOIN cpoe_placer_order_group cpog on pv.patient_visit_id = cpog.patient_visit_id
							inner JOIN cpoe_placer_order cpo on cpog.cpoe_placer_order_group_id = cpo.cpoe_placer_order_group_id
							left JOIN lab_work_order lwo on cd.charge_session_id = lwo.charge_session_id
							left JOIN lab_work_order_item lwoi on lwo.lab_work_order_id = lwoi.lab_work_order_id
						    --inner JOIN lab_process lp on lwoi.lab_process_id = lp.lab_process_id
							left JOIN cpoe_placer_order_status_ref cpos on cpo.cpoe_placer_order_status_rcd = cpos.cpoe_placer_order_status_rcd
						    left JOIN ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
							left JOIN ar_invoice_nl_view ar on ard.ar_invoice_id = ar.ar_invoice_id
	where cd.serviced_date_time is NULL
	   and cd.deleted_date_time is NULL
	   and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2006',101) as SMALLDATETIME)
	   and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2019',101) as SMALLDATETIME)
	  --and YEAR(cd.charged_date_time) = 2019
	  --and MONTH(cd.charged_date_time) = 2
	  and cpo.cpoe_placer_order_id = lwo.cpoe_placer_order_id
	  --and phu.visible_patient_id = '00453176'
	  --and cpo.placer_order_number = '5542391'
	  and ar.transaction_status_rcd not in ('unk','voi')
	  and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'	

) as temp
where temp.orderstatus in ('Verified')
order by [Invoice No]