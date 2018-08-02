SELECT DISTINCT cd.charge_detail_id,
		   cd.charged_date_time as [Charge Date Time],
		   CONVERT(VARCHAR(20), cd.charged_date_time,101) AS [Charge Date],
			FORMAT(cd.charged_date_time,'hh:mm tt') AS [Charge Time],
		   inv.main_itemgroupcode as [Main Group Code],
		   inv.main_itemgroup as [Main Group Name],
			inv.visit_type as [Visit Type],
		   (select name_l from costcentre where costcentre_id = cd.service_requester_costcentre_id) as [Service Requestor],
		   inv.item_code as [Item Code],
		   inv.itemname as [Item Name],
		   phu.visible_patient_id as HN,
		   pfn.display_name_l as [Patient Name],
		   CAST((cd.quantity) AS DECIMAL(10,2)) as Quantity,
		   CAST((cd.amount) AS DECIMAL(10,2)) as Amount
	from HISReport.dbo.rpt_invoice_pf_detailed inv inner JOIN charge_detail_nl_view cd on inv.charge_detail_id = cd.charge_detail_id
												  inner JOIN patient_hospital_usage phu on inv.patient_id = phu.patient_id
												  inner JOIN person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
												  inner JOIN ar_invoice ar on inv.invoice_id = ar.ar_invoice_id
	where MONTH(cd.charged_date_time) IN (@Month)
		and YEAR(cd.charged_date_time) = @Year
		and inv.gl_acct_code_code = '2152100'
		and inv.main_itemgroupcode <> 's23'
		and cd.deleted_date_time is NULL
		--and ar.transaction_status_rcd <> 'voi'
	ORDER BY cd.charged_date_time