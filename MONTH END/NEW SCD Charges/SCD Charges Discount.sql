if 	(@vendor_code in ('95', '13036')) or (@vendor_code in ('342', '13034'))
begin
                 if (@Principal) is not null
                 begin
			select * from (

--select temp.[Charge Detail ID], count(temp.[Charge Detail ID])
select distinct temp.[Vendor Name],
				case when UPPER(temp.[Vendor Name]) like 'ZUELLIG%' or UPPER(temp.[Vendor Name]) like 'METRO DRUG%' then PRINCIPAL
				else null end as Principal,
                CASE WHEN UPPER(temp.[Vendor Name]) like 'ZUELLIG%' and [VENDOR CODE] is not null then
				      (select si.[VENDOR CODE])
					  WHEN UPPER(temp.[Vendor Name]) like 'METRO DRUG%' and [VENDOR CODE] is not null then
					  (select si.[VENDOR CODE]) 
					  else (SELECT temp.[Item Code])
					  END as [Item Code],
				CASE WHEN UPPER(temp.[Vendor Name]) like 'ZUELLIG%' and [VENDOR CODE] is not null then 
					  (select si.[VENDOR ITEM NAME])
					  WHEN UPPER(temp.[Vendor Name]) like 'METRO DRUG%' and [VENDOR CODE] is not null then
					  (select si.[VENDOR ITEM NAME]) 
					  else (SELECT temp.[Item Description])
		              END as [Item Description],
				--temp.[Item Code],
				--temp.[Item Description],
				--temp.[Invoice Detail ID],
				temp.[Invoice Date],
				temp.[Invoice Number] as [Sales/Invoice Number],
				[Quantity Sold] = (temp.[Quantity Sold] * temp.[Credit Factor]),
				temp.[Unit Price] as [Retailer's Unit Price VAT Ex],
				[Retailer's Unit Price VAT In] = temp.[Unit Price] * 1.12,
				[Charge Amount (VAT Ex)] = (temp.Amount * temp.[Credit Factor]),
				[20% Senior Discount] = (temp.Amount * temp.[Credit Factor])*.2,
				[30% of 20% Senior Citizen Discount] = ((temp.Amount * temp.[Credit Factor])*.2)*.3,
				[70% of 20% Senior Citizen Discount] = ((temp.Amount * temp.[Credit Factor])*.2)*.7,
				--temp.[Credit Factor],
				temp.[Charge Detail ID],
				temp.HN,
				temp.[Patient Name],
				temp.[OSCA ID] as [OSCA ID No.],
				temp.[Policy Name],
				temp.Pharmacy,
				REMARKS as Remarks
				--case when temp.[Charge Detail ID] in (Select charge_detail_id from charge_detail_nl_view) then 
				--(select sum((quantity)*(ar.credit_factor)) from ar_invoice_detail ard
				--								inner join ar_invoice ar on ar.ar_invoice_id = ard.ar_invoice_id
				--where item_id = temp.[Item ID]
				--	  and charge_detail_id = temp.[Charge Detail ID]) else sum(temp.[Quantity Sold]) 
				--	  end as [Claim Quantity],
				--case when temp.[Charge Detail ID] in (Select charge_detail_id from charge_detail_nl_view) then 
				--(select sum((ard.gross_amount)*(ar.credit_factor)) from ar_invoice_detail ard
				--								inner join ar_invoice ar on ar.ar_invoice_id = ard.ar_invoice_id
				--where item_id = temp.[Item ID]
				--      and charge_detail_id = temp.[Charge Detail ID]) else sum(temp.[Unit Price]) 
				--	  end as [Total Amount Charged]

from

(select /*distinct*/ --si.VENDOR as [Vendor Name]
		[Vendor Name] = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id 
					  --and v.vendor_code = vendor_code
					  )
		,i.item_id as [Item ID]
       ,i.item_code collate sql_latin1_general_cp1_cs_as as [Item Code]
	   ,i.name_l collate sql_latin1_general_cp1_cs_as as [Item Description] 
	   ,ard.ar_invoice_detail_id as [Invoice Detail ID]
	   ,arh.transaction_date_time as [Invoice Date]
	   ,arh.transaction_text collate sql_latin1_general_cp1_cs_as as [Invoice Number]
	   ,cd.quantity as [Quantity Sold]
	   ,cd.unit_price as [Unit Price]
	   ,cd.amount as [Amount]
	   ,phu.visible_patient_id as [HN]
	   ,p.name_l as [Policy Name]
	   ,cd.charge_detail_id as [Charge Detail ID]

	   ,pfn.display_name_l collate sql_latin1_general_cp1_cs_as as [Patient Name]
	   ,(Select top 1 document_number from person_official_document 
			where person_id = pv.patient_id
				  and document_number is not null ) collate sql_latin1_general_cp1_cs_as as [OSCA ID]
	   --,ard.*
	   ,Pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
				   else 'Inpatient Pharmacy' end) collate sql_latin1_general_cp1_cs_as
		,arh.credit_factor as [Credit Factor]

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
	 --left join dbo.primary_service_ref psr on psr.primary_service_rcd = pv.primary_service_rcd
	 --inner join dbo.visit_type_ref vt on vt.visit_type_rcd = pv.visit_type_rcd

where arh.policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2' --SCD
      and arh.transaction_status_rcd not in  ('voi','unk')
	  and i.item_type_rcd = 'INV'
	  and i.sub_item_type_rcd in ('STK','EXP')
      and i.active_flag = 1
	  and month(arh.transaction_date_time) = @Month
	  and year(arh.transaction_date_time) = @Year
	  and cd.deleted_date_time is null
	  and pv.cancelled_date_time is null
	  and v.vendor_code in (@vendor_code)
	  and svi.default_item_flag = 1
	  and v.organisation_id is not null
) as temp


left outer join AHMC_DataAnalyticsDB.dbo.scd_items si on si.[AHI ITEM CODE] = temp.[Item Code]  collate SQL_Latin1_General_CP1_CI_AS
where temp.[Vendor Name] is not null
      and si.PRINCIPAL in (@Principal)
	 --and temp.[Patient Name] = 'Alon, Cornelia Galicia'
     --and [Item Code] = 'OPP-0700297'
	 --and temp.[Invoice Number] = 'PINV-2018-151172'

	  
--and temp.[Charge Detail ID] = 'EB7AD582-9E91-11E8-A2C4-FED5D85AAA23'
) as tempb
--order by tempb.[Patient Name], [Item Code]
                  end		
	  else
	  begin
		select * from (

--select temp.[Charge Detail ID], count(temp.[Charge Detail ID])
select distinct temp.[Vendor Name],
				case when UPPER(temp.[Vendor Name]) like 'ZUELLIG%' or UPPER(temp.[Vendor Name]) like 'METRO DRUG%' then PRINCIPAL
				else null end as Principal,
                CASE WHEN UPPER(temp.[Vendor Name]) like 'ZUELLIG%' and [VENDOR CODE] is not null then
				      (select si.[VENDOR CODE])
					  WHEN UPPER(temp.[Vendor Name]) like 'METRO DRUG%' and [VENDOR CODE] is not null then
					  (select si.[VENDOR CODE]) 
					  else (SELECT temp.[Item Code])
					  END as [Item Code],
				CASE WHEN UPPER(temp.[Vendor Name]) like 'ZUELLIG%' and [VENDOR CODE] is not null then 
					  (select si.[VENDOR ITEM NAME])
					  WHEN UPPER(temp.[Vendor Name]) like 'METRO DRUG%' and [VENDOR CODE] is not null then
					  (select si.[VENDOR ITEM NAME]) 
					  else (SELECT temp.[Item Description])
		              END as [Item Description],
				--temp.[Item Code],
				--temp.[Item Description],
				--temp.[Invoice Detail ID],
				temp.[Invoice Date],
				temp.[Invoice Number] as [Sales/Invoice Number],
				[Quantity Sold] = (temp.[Quantity Sold] * temp.[Credit Factor]),
				temp.[Unit Price] as [Retailer's Unit Price VAT Ex],
				[Retailer's Unit Price VAT In] = temp.[Unit Price] * 1.12,
				[Charge Amount (VAT Ex)] = (temp.Amount * temp.[Credit Factor]),
				[20% Senior Discount] = (temp.Amount * temp.[Credit Factor])*.2,
				[30% of 20% Senior Citizen Discount] = ((temp.Amount * temp.[Credit Factor])*.2)*.3,
				[70% of 20% Senior Citizen Discount] = ((temp.Amount * temp.[Credit Factor])*.2)*.7,
				--temp.[Credit Factor],
				temp.[Charge Detail ID],
				temp.HN,
				temp.[Patient Name],
				temp.[OSCA ID] as [OSCA ID No.],
				temp.[Policy Name],
				temp.Pharmacy,
				REMARKS as Remarks
				--case when temp.[Charge Detail ID] in (Select charge_detail_id from charge_detail_nl_view) then 
				--(select sum((quantity)*(ar.credit_factor)) from ar_invoice_detail ard
				--								inner join ar_invoice ar on ar.ar_invoice_id = ard.ar_invoice_id
				--where item_id = temp.[Item ID]
				--	  and charge_detail_id = temp.[Charge Detail ID]) else sum(temp.[Quantity Sold]) 
				--	  end as [Claim Quantity],
				--case when temp.[Charge Detail ID] in (Select charge_detail_id from charge_detail_nl_view) then 
				--(select sum((ard.gross_amount)*(ar.credit_factor)) from ar_invoice_detail ard
				--								inner join ar_invoice ar on ar.ar_invoice_id = ard.ar_invoice_id
				--where item_id = temp.[Item ID]
				--      and charge_detail_id = temp.[Charge Detail ID]) else sum(temp.[Unit Price]) 
				--	  end as [Total Amount Charged]

from

(select /*distinct*/ --si.VENDOR as [Vendor Name]
		[Vendor Name] = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id 
					  --and v.vendor_code = vendor_code
					  )
		,i.item_id as [Item ID]
       ,i.item_code collate sql_latin1_general_cp1_cs_as as [Item Code]
	   ,i.name_l collate sql_latin1_general_cp1_cs_as as [Item Description] 
	   ,ard.ar_invoice_detail_id as [Invoice Detail ID]
	   ,arh.transaction_date_time as [Invoice Date]
	   ,arh.transaction_text collate sql_latin1_general_cp1_cs_as as [Invoice Number]
	   ,cd.quantity as [Quantity Sold]
	   ,cd.unit_price as [Unit Price]
	   ,cd.amount as [Amount]
	   ,phu.visible_patient_id as [HN]
	   ,p.name_l as [Policy Name]
	   ,cd.charge_detail_id as [Charge Detail ID]

	   ,pfn.display_name_l collate sql_latin1_general_cp1_cs_as as [Patient Name]
	   ,(Select top 1 document_number from person_official_document 
			where person_id = pv.patient_id
				  and document_number is not null ) collate sql_latin1_general_cp1_cs_as as [OSCA ID]
	   --,ard.*
	   ,Pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
				   else 'Inpatient Pharmacy' end) collate sql_latin1_general_cp1_cs_as
		,arh.credit_factor as [Credit Factor]

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
	 --left join dbo.primary_service_ref psr on psr.primary_service_rcd = pv.primary_service_rcd
	 --inner join dbo.visit_type_ref vt on vt.visit_type_rcd = pv.visit_type_rcd

where arh.policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2' --SCD
      and arh.transaction_status_rcd not in  ('voi','unk')
	  and i.item_type_rcd = 'INV'
	  and i.sub_item_type_rcd in ('STK','EXP')
      and i.active_flag = 1
	  and month(arh.transaction_date_time) = @Month
	  and year(arh.transaction_date_time) = @Year
	  and cd.deleted_date_time is null
	  and pv.cancelled_date_time is null
	  and v.vendor_code in (@vendor_code)
	  and svi.default_item_flag = 1
	  and v.organisation_id is not null
) as temp


left outer join AHMC_DataAnalyticsDB.dbo.scd_items si on si.[AHI ITEM CODE] = temp.[Item Code]  collate SQL_Latin1_General_CP1_CI_AS
where temp.[Vendor Name] is not null
      --and si.PRINCIPAL is null
	 --and temp.[Patient Name] = 'Alon, Cornelia Galicia'
     --and [Item Code] = 'OPP-0700297'
	 --and temp.[Invoice Number] = 'PINV-2018-151172'

	  
--and temp.[Charge Detail ID] = 'EB7AD582-9E91-11E8-A2C4-FED5D85AAA23'
) as tempb
where tempb.Principal is null
order by tempb.[Patient Name], [Item Code]
 	  end
end
else
begin
	select * from (

--select temp.[Charge Detail ID], count(temp.[Charge Detail ID])
select distinct temp.[Vendor Name],
				case when UPPER(temp.[Vendor Name]) like 'ZUELLIG%' or UPPER(temp.[Vendor Name]) like 'METRO DRUG%' then PRINCIPAL
				else null end as Principal,
                CASE WHEN UPPER(temp.[Vendor Name]) like 'ZUELLIG%' and [VENDOR CODE] is not null then
				      (select si.[VENDOR CODE])
					  WHEN UPPER(temp.[Vendor Name]) like 'METRO DRUG%' and [VENDOR CODE] is not null then
					  (select si.[VENDOR CODE]) 
					  else (SELECT temp.[Item Code])
					  END as [Item Code],
				CASE WHEN UPPER(temp.[Vendor Name]) like 'ZUELLIG%' and [VENDOR CODE] is not null then 
					  (select si.[VENDOR ITEM NAME])
					  WHEN UPPER(temp.[Vendor Name]) like 'METRO DRUG%' and [VENDOR CODE] is not null then
					  (select si.[VENDOR ITEM NAME]) 
					  else (SELECT temp.[Item Description])
		              END as [Item Description],
				--temp.[Item Code],
				--temp.[Item Description],
				--temp.[Invoice Detail ID],
				temp.[Invoice Date],
				temp.[Invoice Number] as [Sales/Invoice Number],
				[Quantity Sold] = (temp.[Quantity Sold] * temp.[Credit Factor]),
				temp.[Unit Price] as [Retailer's Unit Price VAT Ex],
				[Retailer's Unit Price VAT In] = temp.[Unit Price] * 1.12,
				[Charge Amount (VAT Ex)] = (temp.Amount * temp.[Credit Factor]),
				[20% Senior Discount] = (temp.Amount * temp.[Credit Factor])*.2,
				[30% of 20% Senior Citizen Discount] = ((temp.Amount * temp.[Credit Factor])*.2)*.3,
				[70% of 20% Senior Citizen Discount] = ((temp.Amount * temp.[Credit Factor])*.2)*.7,
				--temp.[Credit Factor],
				temp.[Charge Detail ID],
				temp.HN,
				temp.[Patient Name],
				temp.[OSCA ID] as [OSCA ID No.],
				temp.[Policy Name],
				temp.Pharmacy,
				REMARKS as Remarks
				--case when temp.[Charge Detail ID] in (Select charge_detail_id from charge_detail_nl_view) then 
				--(select sum((quantity)*(ar.credit_factor)) from ar_invoice_detail ard
				--								inner join ar_invoice ar on ar.ar_invoice_id = ard.ar_invoice_id
				--where item_id = temp.[Item ID]
				--	  and charge_detail_id = temp.[Charge Detail ID]) else sum(temp.[Quantity Sold]) 
				--	  end as [Claim Quantity],
				--case when temp.[Charge Detail ID] in (Select charge_detail_id from charge_detail_nl_view) then 
				--(select sum((ard.gross_amount)*(ar.credit_factor)) from ar_invoice_detail ard
				--								inner join ar_invoice ar on ar.ar_invoice_id = ard.ar_invoice_id
				--where item_id = temp.[Item ID]
				--      and charge_detail_id = temp.[Charge Detail ID]) else sum(temp.[Unit Price]) 
				--	  end as [Total Amount Charged]

from

(select /*distinct*/ --si.VENDOR as [Vendor Name]
		[Vendor Name] = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id 
					  --and v.vendor_code = vendor_code
					  )
		,i.item_id as [Item ID]
       ,i.item_code collate sql_latin1_general_cp1_cs_as as [Item Code]
	   ,i.name_l collate sql_latin1_general_cp1_cs_as as [Item Description] 
	   ,ard.ar_invoice_detail_id as [Invoice Detail ID]
	   ,arh.transaction_date_time as [Invoice Date]
	   ,arh.transaction_text collate sql_latin1_general_cp1_cs_as as [Invoice Number]
	   ,cd.quantity as [Quantity Sold]
	   ,cd.unit_price as [Unit Price]
	   ,cd.amount as [Amount]
	   ,phu.visible_patient_id as [HN]
	   ,p.name_l as [Policy Name]
	   ,cd.charge_detail_id as [Charge Detail ID]

	   ,pfn.display_name_l collate sql_latin1_general_cp1_cs_as as [Patient Name]
	   ,(Select top 1 document_number from person_official_document 
			where person_id = pv.patient_id
				  and document_number is not null ) collate sql_latin1_general_cp1_cs_as as [OSCA ID]
	   --,ard.*
	   ,Pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
				   else 'Inpatient Pharmacy' end) collate sql_latin1_general_cp1_cs_as
		,arh.credit_factor as [Credit Factor]

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
	 --left join dbo.primary_service_ref psr on psr.primary_service_rcd = pv.primary_service_rcd
	 --inner join dbo.visit_type_ref vt on vt.visit_type_rcd = pv.visit_type_rcd

where arh.policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2' --SCD
      and arh.transaction_status_rcd not in  ('voi','unk')
	  and i.item_type_rcd = 'INV'
	  and i.sub_item_type_rcd in ('STK','EXP')
      and i.active_flag = 1
	  and month(arh.transaction_date_time) = @Month
	  and year(arh.transaction_date_time) = @Year
	  and cd.deleted_date_time is null
	  and pv.cancelled_date_time is null
	  and v.vendor_code in (@vendor_code)
	  and svi.default_item_flag = 1
	  and v.organisation_id is not null
) as temp


left outer join AHMC_DataAnalyticsDB.dbo.scd_items si on si.[AHI ITEM CODE] = temp.[Item Code]  collate SQL_Latin1_General_CP1_CI_AS
where temp.[Vendor Name] is not null
      --and si.PRINCIPAL is null
	 --and temp.[Patient Name] = 'Alon, Cornelia Galicia'
     --and [Item Code] = 'OPP-0700297'
	 --and temp.[Invoice Number] = 'PINV-2018-151172'

	  
--and temp.[Charge Detail ID] = 'EB7AD582-9E91-11E8-A2C4-FED5D85AAA23'
) as tempb
--where tempb.Principal is null
order by tempb.[Patient Name], [Item Code]
end