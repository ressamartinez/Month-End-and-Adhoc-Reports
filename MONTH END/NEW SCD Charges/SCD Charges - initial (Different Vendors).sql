
select distinct *

from

(select /*distinct*/ --si.VENDOR as [Vendor Name]
		[Vendor Name] = (CASE WHEN v.person_id IS NOT NULL then 
					  (select display_name_l from person_formatted_name_iview where person_id = v.person_id)
					  else (SELECT name_l from organisation WHERE organisation_id = v.organisation_id and
																  v.vendor_code = vendor_code)
					  END)
		--,case when i.item_id in (select [ITEM ID] from AHMC_DataAnalyticsDB.dbo.scd_items) then PRINCIPAL
		--		else null end as Principal 
		--,[Charge Type] = (CASE WHEN i.ipd_chargeable_flag = 1 and opd_chargeable_flag = 1 then 'IPD, OPD'
		--					   WHEN i.ipd_chargeable_flag = 1 and opd_chargeable_flag = 0 then 'IPD'
		--					   WHEN i.ipd_chargeable_flag = 0 and opd_chargeable_flag = 1 then 'OPD'
		--					   ELSE 'NONE' END)
		--,ipd_chargeable_flag
		--,opd_chargeable_flag
		--,user_chargeable_flag
		--,psr.name_l as [Primary Service]
		--,pv.charge_type_rcd
		--,vt.name_l as [Visit Type]
		--,[AHI ITEM CODE] as [AHI Item Code]
	 --  ,[Vendor Item Code] = (CASE WHEN si.VENDOR = 'ZUELLIG PHARMA CORPORATION' or si.VENDOR = 'METRO DRUG INC.' then
		--			  (select si.[VENDOR CODE])
		--			  else (SELECT si.[AHI ITEM CODE])
		--			  END)
	 --  ,[Vendor Item Name] = (CASE WHEN si.VENDOR = 'ZUELLIG PHARMA CORPORATION' or si.VENDOR = 'METRO DRUG INC.' then 
		--			  (select si.[VENDOR ITEM NAME])
		--			  else (SELECT si.[AHI ITEM DESCRIPTION])
		--			  END)
       ,i.item_code as [Item Code]
	   ,i.name_l as [Item Description]
	   --,svi.vendor_item_code as [Vendor Item Code]
	   --,svi.vendor_item_name_l as [Vendor Item Name]
	   ,arh.transaction_date_time as [Invoice Date]
	   ,arh.transaction_text as [Invoice Number]
	   ,cd.quantity as [Quantity Sold]
	   ,cd.unit_price as [Unit Price]
	   ,cd.amount as [Amount]
	   --,v.vendor_code as [Vendor Code]
	   --,phu.visible_patient_id as [HN]
	   --,p.name_l as [Policy Name]
	   ,cd.charge_detail_id as [Charge Detail ID]
	   ,pfn.display_name_l as [Patient Name]
	   ,(Select top 1 document_number from person_official_document 
			where person_id = pv.patient_id
				  and document_number is not null )  as [OSCA ID]
	   --,ard.*
	   ,Remarks = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
				   else 'Inpatient Pharmacy' end)

from dbo.charge_detail_nl_view cd
	 LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
	 LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
	 LEFT outer join dbo.item i on ard.item_id = i.item_id
	 inner JOIN dbo.policy p on arh.policy_id = p.policy_id
	 inner join dbo.swe_vendor_item svi on i.item_id = svi.item_id
	 inner join dbo.vendor v on svi.vendor_id = v.vendor_id
	 --inner join dbo.organisation o on o.organisation_id = v.organisation_id
	 INNER JOIN dbo.patient_visit_nl_view AS pv ON cd.patient_visit_id = pv.patient_visit_id
	 INNER JOIN dbo.person_formatted_name_iview as pfn ON pv.patient_id = pfn.person_id
	 inner join dbo.patient_hospital_usage phu on phu.patient_id = pv.patient_id
	 --inner join dbo.person_official_document pod on pod.person_id = pfn.person_id
	 left join AHMC_DataAnalyticsDB.dbo.scd_items si on si.[AHI ITEM CODE] = i.item_code  collate SQL_Latin1_General_CP1_CI_AS
	 --left join dbo.primary_service_ref psr on psr.primary_service_rcd = pv.primary_service_rcd
	 --inner join dbo.visit_type_ref vt on vt.visit_type_rcd = pv.visit_type_rcd

where arh.policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2' --SCD
      and arh.transaction_status_rcd not in  ('voi','unk')
	  and i.item_type_rcd = 'INV'
	  and i.sub_item_type_rcd in ('STK','EXP')
      and i.active_flag = 1 
	  and year(arh.transaction_date_time) = 2018
	  and cd.deleted_date_time is null
	  and pv.cancelled_date_time is null
	  --and v.vendor_id not in ('C61A08A0-1F65-11DA-A79E-001143B8816C',   --Metro Drug
		 --          			  '846D719B-096F-11DA-A79C-001143B8816C')  --Zuellig
	  --and visible_patient_id = '00158132' '00511694'
	  --and i.item_code = 'OPP-0700326'
	  --and i.opd_chargeable_flag = 1
	  and svi.default_item_flag = 1

) as temp
--where [Item Code] = '0600668'
--and [Invoice Number] = 'PINV-2018-000113'
order by [Invoice Date]

