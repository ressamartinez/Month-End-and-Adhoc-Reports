
select 
        tempb.[Vendor Name]
		,tempb.vendor_code
        ,tempb.Principal
		,tempb.[Item ID]
        ,tempb.[Item Code]
        ,tempb.[Item Description]
        ,tempb.[Invoice Date]
        ,tempb.[Sales/Invoice Number]
        ,tempb.[Quantity Sold]
        ,tempb.[Retailer's Unit Price VAT In]
        ,tempb.[Retailer's Unit Price VAT Ex]
        ,tempb.[Charge Amount (VAT Ex)]
        ,tempb.[20% PWD Discount]
        ,tempb.[30% of 20% PWD Discount]
        ,tempb.[70% of 20% PWD Discount]
        ,tempb.[Charge Detail ID]
        ,tempb.HN
        ,tempb.[Patient Name]
        --,tempb.[OSCA ID No.]
        --,tempb.[Policy Name]
        ,tempb.Pharmacy
        ,tempb.Remarks
		,tempb.discount_posting_rule_name
		,tempb.policy
		,tempb.visit_code
		,tempb.short_code

            from (
            --select temp.[Charge Detail ID], count(temp.[Charge Detail ID])
            select distinct temp.policy_name as policy,
                            temp.discount as discount_posting_rule_name,
                            temp.policy_id,
                            temp.discount_posting_rule_id,
                            temp.[Vendor Name],
							temp.vendor_code,
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
                            temp.[Item ID],
                            --temp.[Item Description],
                            --temp.[Invoice Detail ID],
                            temp.[Invoice Date],
                            temp.[Invoice Number] as [Sales/Invoice Number],
                            [Quantity Sold] = (temp.[Quantity Sold] * temp.[Credit Factor]),
                            [Retailer's Unit Price VAT In] = temp.[Unit Price] * 1.12,
                            temp.[Unit Price] as [Retailer's Unit Price VAT Ex],
                            [Charge Amount (VAT Ex)] = (temp.Amount * temp.[Credit Factor]),
                            [20% PWD Discount] = (temp.Amount * temp.[Credit Factor])*.2,
                            [30% of 20% PWD Discount] = ((temp.Amount * temp.[Credit Factor])*.2)*.3,
                            [70% of 20% PWD Discount] = ((temp.Amount * temp.[Credit Factor])*.2)*.7,
                            --temp.[Credit Factor],
                            temp.[Charge Detail ID],
                            temp.HN,
                            temp.[Patient Name],
                            --temp.[OSCA ID] as [OSCA ID No.],
                            --temp.[Policy Name],
                            temp.Pharmacy,
                            REMARKS as Remarks,
							temp.ar_invoice_id,
							temp.visit_code,
							temp.short_code
            from
            (select /*distinct*/ --si.VENDOR as [Vendor Name]
                    [Vendor Name] = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id 
                                  --and v.active_flag = 1
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
                   --,p.name_l as [Policy Name]
                   ,dpr.discount_posting_rule_id as [Policy Name]
                   ,cd.charge_detail_id as [Charge Detail ID]
                   ,pfn.display_name_l collate sql_latin1_general_cp1_cs_as as [Patient Name]
                   --,(Select top 1 document_number from person_official_document 
                   --     where person_id = pv.patient_id
                   --           and document_number is not null ) collate sql_latin1_general_cp1_cs_as as [OSCA ID]
                   --,ard.*
                   ,Pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
                               else 'Inpatient Pharmacy' end) collate sql_latin1_general_cp1_cs_as
                    ,arh.credit_factor as [Credit Factor]
                    ,p.policy_id
                    ,p.name_l AS policy_name
                    ,dpr.discount_posting_rule_id
                    ,dpr.name_l AS discount
					,v.vendor_code
					,arh.ar_invoice_id
					,pv.visit_code
					,p.short_code

            from dbo.charge_detail_nl_view cd
                 LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
                 LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
                 LEFT outer join dbo.item i on ard.item_id = i.item_id
                 left outer JOIN dbo.policy p on arh.policy_id = p.policy_id
                 inner join dbo.swe_vendor_item svi on i.item_id = svi.item_id
                 inner join dbo.vendor v on svi.vendor_id = v.vendor_id
                 --inner join dbo.organisation o on o.organisation_id = v.organisation_id
                 left outer join discount_posting_rule dpr on dpr.discount_posting_rule_id = ard.discount_posting_rule_id
                 INNER JOIN dbo.patient_visit_nl_view AS pv ON cd.patient_visit_id = pv.patient_visit_id
                 INNER JOIN dbo.person_formatted_name_iview as pfn ON pv.patient_id = pfn.person_id
                 inner join dbo.patient_hospital_usage phu on phu.patient_id = pv.patient_id
            where ard.discount_posting_rule_id = '60AF2DE3-04C9-11DF-AA84-0021912231AF' --PWD
                  and arh.transaction_status_rcd not in  ('voi','unk')
                  and i.active_flag = 1
				  and  month(arh.transaction_date_time) between 1 and 3
                  --and month(arh.transaction_date_time) = 3
                  and year(arh.transaction_date_time) = 2019
				  --and arh.transaction_date_time between @date1 and @date2
                  and cd.deleted_date_time is null
                  and pv.cancelled_date_time is null
                  --and v.vendor_code = '95'
                  and svi.default_item_flag = 1
                  and v.organisation_id is not null
				  and arh.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'
            ) as temp
            left outer join AHMC_DataAnalyticsDB.dbo.scd_items si on si.[AHI ITEM CODE] = temp.[Item Code]  collate SQL_Latin1_General_CP1_CI_AS
            where temp.[Vendor Name] is not null
                 --and (si.PRINCIPAL in (@Principal) or si.PRINCIPAL is null)
                 --and temp.[Patient Name] = 'Villagomez, Juanita Cambronero'
                 --and [Item ID] = 'FDE77DF2-56E9-4449-8902-7F77A344C75E'
                 --AND (temp.policy_name IS NOT NULL AND temp.discount IS NOT NULL)
     
            ) as tempb
			--where tempb.[Patient Name] = 'Saron, Joy George Peregrino'
order by tempb.HN