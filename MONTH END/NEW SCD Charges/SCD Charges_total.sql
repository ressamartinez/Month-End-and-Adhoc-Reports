

select distinct *, 
		 [20% Senior Discount] = [Total Charge Amount (VAT Ex)] *.2,
		 [30% of 20% Senior Citizen Discount] = ([Total Charge Amount (VAT Ex)]*.2)*.3,
	     [70% of 20% Senior Citizen Discount] = ([Total Charge Amount (VAT Ex)]*.2)*.7

from (

select distinct 
         scd.[Vendor Name],
		 scd.vendor_code,
         scd.Principal,
		 scd.[Item Code],
		 --scd.[Item ID],
		 scd.[Item Description],
		 scd.[Invoice Date],
		 scd.[Sales/Invoice Number],
		 scd.[Retailer's Unit Price VAT In],
		 scd.[Retailer's Unit Price VAT Ex],
       case when scd.[Sales/Invoice Number] in (Select transaction_text from ar_invoice) then 
				(select sum((cd.quantity)*(arh.credit_factor)) from dbo.charge_detail_nl_view cd
																LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
																LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
												
				where cd.item_id = scd.[Item ID]
					  and transaction_text = scd.[Sales/Invoice Number]
					  and ard.quantity >= 0) else sum(scd.[Quantity Sold]) 
					  end as [Total Quantity Sold],
		case when scd.[Sales/Invoice Number] in (Select transaction_text from ar_invoice) then 
				(select sum((cd.amount)*(arh.credit_factor)) from dbo.charge_detail_nl_view cd
																 LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
																 LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
				where cd.item_id = scd.[Item ID]
				      and transaction_text = scd.[Sales/Invoice Number]
					  and ard.quantity >= 0) else sum(scd.[Charge Amount (VAT Ex)]) 
					  end as [Total Charge Amount (VAT Ex)],
         scd.HN,
		 scd.[Patient Name],
		 scd.[OSCA ID No.],
		 --scd.Pharmacy,
		 scd.Remarks

from AHMC_DataAnalyticsDB.dbo.scd_charges scd


where scd.vendor_code = '95'
      and month(scd.[Invoice Date]) = 9
	  and year(scd.[Invoice Date]) = 2018
	  --and scd.[Sales/Invoice Number] = 'PINV-2018-255065'


group by scd.[Vendor Name],
         scd.Principal,
		 scd.[Item Code],
		 scd.[Item Description],
		 scd.[Invoice Date],
		 scd.[Sales/Invoice Number],
		 scd.[Retailer's Unit Price VAT In],
		 scd.[Retailer's Unit Price VAT Ex],
		 scd.[Quantity Sold],
		 scd.[Charge Amount (VAT Ex)],
		 scd.HN,
		 scd.[Patient Name],
		 scd.[OSCA ID No.],
		 --scd.Pharmacy,
		 scd.Remarks,
		 scd.[20% Senior Discount],
		 scd.[30% of 20% Senior Citizen Discount],
		 scd.[70% of 20% Senior Citizen Discount],
		 scd.[Item ID],
		 scd.vendor_code
	 
) as temp
order by Principal, [Patient Name], [Item Description]








/*
select tempb.*,		[20% Senior Discount] = [Charge Amount (VAT Ex)] *.2,
				[30% of 20% Senior Citizen Discount] = ([Charge Amount (VAT Ex)]*.2)*.3,
				[70% of 20% Senior Citizen Discount] = ([Charge Amount (VAT Ex)]*.2)*.7

from (
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
				temp.[Invoice Date],
				temp.[Invoice Number] as [Sales/Invoice Number],
				[Retailer's Unit Price VAT In] = temp.[Unit Price] * 1.12,
				temp.[Unit Price] as [Retailer's Unit Price VAT Ex],
				case when temp.[Invoice Number] in (Select transaction_text from ar_invoice) then 
				(select sum((cd.quantity)*(arh.credit_factor)) from dbo.charge_detail_nl_view cd
																LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
																LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
												
				where ard.item_id = temp.[Item ID]
					  and transaction_text = temp.[Invoice Number]) else sum(temp.[Quantity Sold]) 
					  end as [Quantity Sold],
				case when temp.[Invoice Number] in (Select transaction_text from ar_invoice) then 
				(select sum((cd.amount)*(arh.credit_factor)) from dbo.charge_detail_nl_view cd
																 LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
																 LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
				where ard.item_id = temp.[Item ID]
				      and transaction_text = temp.[Invoice Number]) else sum(temp.[Unit Price]) 
					  end as [Charge Amount (VAT Ex)],
				temp.HN,
				temp.[Patient Name],
				temp.[OSCA ID] as [OSCA ID No.],
				--temp.[Policy Name],
				--temp.Pharmacy,
				REMARKS as Remarks

from

(select 
		[Vendor Name] = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id 
					  )
		,i.item_id as [Item ID]
       ,i.item_code collate sql_latin1_general_cp1_cs_as as [Item Code]
	   ,i.name_l collate sql_latin1_general_cp1_cs_as as [Item Description] 
	   --,ard.ar_invoice_detail_id as [Invoice Detail ID]
	   ,arh.transaction_date_time as [Invoice Date]
	   ,arh.transaction_text collate sql_latin1_general_cp1_cs_as as [Invoice Number]
	   ,cd.quantity as [Quantity Sold]
	   ,cd.unit_price as [Unit Price]
	   ,cd.amount as [Amount]
	   ,phu.visible_patient_id as [HN]
	   --,p.name_l as [Policy Name]
	   --,cd.charge_detail_id as [Charge Detail ID]

	   ,pfn.display_name_l collate sql_latin1_general_cp1_cs_as as [Patient Name]
	   ,(Select top 1 document_number from person_official_document 
			where person_id = pv.patient_id
				  and document_number is not null ) collate sql_latin1_general_cp1_cs_as as [OSCA ID]
	   --,Pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
				--   else 'Inpatient Pharmacy' end) collate sql_latin1_general_cp1_cs_as
		,arh.credit_factor as [Credit Factor]

from dbo.charge_detail_nl_view cd
	 LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
	 LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
	 LEFT outer join dbo.item i on ard.item_id = i.item_id
	 inner JOIN dbo.policy p on arh.policy_id = p.policy_id
	 inner join dbo.swe_vendor_item svi on i.item_id = svi.item_id
	 inner join dbo.vendor v on svi.vendor_id = v.vendor_id
	 INNER JOIN dbo.patient_visit_nl_view AS pv ON cd.patient_visit_id = pv.patient_visit_id
	 INNER JOIN dbo.person_formatted_name_iview as pfn ON pv.patient_id = pfn.person_id
	 inner join dbo.patient_hospital_usage phu on phu.patient_id = pv.patient_id

where arh.policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2' --SCD
      and arh.transaction_status_rcd not in  ('voi','unk')
	  and i.item_type_rcd = 'INV'
	  and i.sub_item_type_rcd in ('STK','EXP')
      and i.active_flag = 1
	  and month(arh.transaction_date_time) = 10
	  and year(arh.transaction_date_time) = 2018
	  and cd.deleted_date_time is null
	  and pv.cancelled_date_time is null
	  --and v.vendor_code = '95'
	  and svi.default_item_flag = 1
	  and v.organisation_id is not null
) as temp


left outer join AHMC_DataAnalyticsDB.dbo.scd_items si on si.[AHI ITEM CODE] = temp.[Item Code]  collate SQL_Latin1_General_CP1_CI_AS
where temp.[Vendor Name] is not null

group by temp.[Vendor Name],
	     si.PRINCIPAL,
		 si.[VENDOR CODE],
		 temp.[Item Code],
		 si.[VENDOR ITEM NAME],
		 temp.[Item Description],
		 temp.[Invoice Date],
		 temp.[Invoice Number],
		 temp.[Unit Price],
		 temp.Amount,
		 temp.[Credit Factor],
		 temp.HN,
		 temp.[Patient Name],
		 temp.[OSCA ID],
		 --temp.[Policy Name],
		 --temp.Pharmacy,
		 si.REMARKS,
		 temp.[Item ID]

) as tempb
where tempb.[Item Code] = '13008974'
	  and tempb.HN = '00113378'
order by [Patient Name]
*/







/*
select tempb.*,		[20% Senior Discount] = [Charge Amount (VAT Ex)] *.2,
				[30% of 20% Senior Citizen Discount] = ([Charge Amount (VAT Ex)]*.2)*.3,
				[70% of 20% Senior Citizen Discount] = ([Charge Amount (VAT Ex)]*.2)*.7

from (
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
				temp.[Invoice Date],
				temp.[Invoice Number] as [Sales/Invoice Number],
				[Retailer's Unit Price VAT In] = temp.[Unit Price] * 1.12,
				temp.[Unit Price] as [Retailer's Unit Price VAT Ex],
				case when temp.[Invoice Number] in (Select transaction_text from ar_invoice) then 
				(select sum((cd.quantity)*(arh.credit_factor)) from dbo.charge_detail_nl_view cd
																LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
																LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
												
				where ard.item_id = temp.[Item ID]
					  and transaction_text = temp.[Invoice Number]) else sum(temp.[Quantity Sold]) 
					  end as [Quantity Sold],
				case when temp.[Invoice Number] in (Select transaction_text from ar_invoice) then 
				(select sum((cd.amount)*(arh.credit_factor)) from dbo.charge_detail_nl_view cd
																 LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
																 LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
				where ard.item_id = temp.[Item ID]
				      and transaction_text = temp.[Invoice Number]) else sum(temp.[Unit Price]) 
					  end as [Charge Amount (VAT Ex)],
				temp.HN,
				temp.[Patient Name],
				temp.[OSCA ID] as [OSCA ID No.],
				--temp.[Policy Name],
				--temp.Pharmacy,
				REMARKS as Remarks

from

(select 
		[Vendor Name] = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id 
					  )
		,i.item_id as [Item ID]
       ,i.item_code collate sql_latin1_general_cp1_cs_as as [Item Code]
	   ,i.name_l collate sql_latin1_general_cp1_cs_as as [Item Description] 
	   --,ard.ar_invoice_detail_id as [Invoice Detail ID]
	   ,arh.transaction_date_time as [Invoice Date]
	   ,arh.transaction_text collate sql_latin1_general_cp1_cs_as as [Invoice Number]
	   ,cd.quantity as [Quantity Sold]
	   ,cd.unit_price as [Unit Price]
	   ,cd.amount as [Amount]
	   ,phu.visible_patient_id as [HN]
	   --,p.name_l as [Policy Name]
	   --,cd.charge_detail_id as [Charge Detail ID]

	   ,pfn.display_name_l collate sql_latin1_general_cp1_cs_as as [Patient Name]
	   ,(Select top 1 document_number from person_official_document 
			where person_id = pv.patient_id
				  and document_number is not null ) collate sql_latin1_general_cp1_cs_as as [OSCA ID]
	   --,Pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
				--   else 'Inpatient Pharmacy' end) collate sql_latin1_general_cp1_cs_as
		,arh.credit_factor as [Credit Factor]

from dbo.charge_detail_nl_view cd
	 LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
	 LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
	 LEFT outer join dbo.item i on ard.item_id = i.item_id
	 inner JOIN dbo.policy p on arh.policy_id = p.policy_id
	 inner join dbo.swe_vendor_item svi on i.item_id = svi.item_id
	 inner join dbo.vendor v on svi.vendor_id = v.vendor_id
	 INNER JOIN dbo.patient_visit_nl_view AS pv ON cd.patient_visit_id = pv.patient_visit_id
	 INNER JOIN dbo.person_formatted_name_iview as pfn ON pv.patient_id = pfn.person_id
	 inner join dbo.patient_hospital_usage phu on phu.patient_id = pv.patient_id

where arh.policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2' --SCD
      and arh.transaction_status_rcd not in  ('voi','unk')
	  and i.item_type_rcd = 'INV'
	  and i.sub_item_type_rcd in ('STK','EXP')
      and i.active_flag = 1
	  and month(arh.transaction_date_time) = 10
	  and year(arh.transaction_date_time) = 2018
	  and cd.deleted_date_time is null
	  and pv.cancelled_date_time is null
	  --and v.vendor_code = '95'
	  and svi.default_item_flag = 1
	  and v.organisation_id is not null
) as temp


left outer join AHMC_DataAnalyticsDB.dbo.scd_items si on si.[AHI ITEM CODE] = temp.[Item Code]  collate SQL_Latin1_General_CP1_CI_AS
where temp.[Vendor Name] is not null

group by temp.[Vendor Name],
	     si.PRINCIPAL,
		 si.[VENDOR CODE],
		 temp.[Item Code],
		 si.[VENDOR ITEM NAME],
		 temp.[Item Description],
		 temp.[Invoice Date],
		 temp.[Invoice Number],
		 temp.[Unit Price],
		 temp.Amount,
		 temp.[Credit Factor],
		 temp.HN,
		 temp.[Patient Name],
		 temp.[OSCA ID],
		 --temp.[Policy Name],
		 --temp.Pharmacy,
		 si.REMARKS,
		 temp.[Item ID]

) as tempb
where tempb.[Item Code] = '13008974'
	  and tempb.HN = '00113378'
order by [Patient Name]
*/