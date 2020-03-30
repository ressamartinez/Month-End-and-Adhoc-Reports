DECLARE @date1 DATETIME
DECLARE @date2 DATETIME
DECLARE @date0 datetime

SET @date0 =DATEADD(MONTH, -1, GETDATE())
SET @date1 = HISViews.dbo.GETFIRSTDATEOFMONTH(@date0)
SET @date2 = HISViews.dbo.GETLASTDATEOFMONTH(@date0)

select distinct case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as 'Organisation Type',
       tempb.vendor_code,
       tempb.vendor_name,
	   case when UPPER(tempb.vendor_name) like 'ZUELLIG%' or UPPER(tempb.vendor_name) like 'METRO DRUG%' then si.PRINCIPAL
				else null end as principal,
	   tempb.main_group_code,
	   tempb.main_group_name,
	   tempb.item_group_code,
	   tempb.item_group_name,
	   CASE WHEN UPPER(tempb.vendor_name) like 'ZUELLIG%' and si.[VENDOR CODE] is not null then
			  (select si.[VENDOR CODE])
			  WHEN UPPER(tempb.vendor_name) like 'METRO DRUG%' and si.[VENDOR CODE] is not null then
			  (select si.[VENDOR CODE]) 
			  else (SELECT tempb.item_code) END as item_code,
	   CASE WHEN UPPER(tempb.vendor_name) like 'ZUELLIG%' and si.[VENDOR CODE] is not null then 
              (select si.[VENDOR ITEM NAME])
              WHEN UPPER(tempb.vendor_name) like 'METRO DRUG%' and si.[VENDOR CODE] is not null then
              (select si.[VENDOR ITEM NAME]) 
              else (SELECT tempb.item_name)
              END as item_name,
	   tempb.quantity,
	   tempb.unit_price * 1.12 as vat_in,
	   tempb.unit_price as vat_ex,
	   tempb.charge_amount,
	   tempb.discount_amount,
	   tempb.discount_amount * .3 as retailers_share,
	   tempb.discount_amount * .7 as manufacturers_share,
	   tempb.discount_percentage,
	   tempb.invoice_no,
	   tempb.invoice_date,
	   tempb.hn,
	   tempb.patient_name,
	   tempb.age,
	   tempb.osca_id,
	   tempb.pharmacy,
	   si.REMARKS,
	   tempb.visit_code,
	   tempb.short_code,
	   tempb.policy_name,
	   tempb.gl_discount_reason,
	   tempb.charge_detail_id

FROM
(

			SELECT DISTINCT * from 
			(
			SELECT v.vendor_code
				   ,vendor_name = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id)
				   ,(Select item_group_code from item_group where item_group_id = ig.parent_item_group_id) as main_group_code
				   ,(Select name_l from item_group where item_group_id = ig.parent_item_group_id) as main_group_name
				   ,ig.item_group_code
				   ,ig.name_l as item_group_name
				   ,i.item_code collate sql_latin1_general_cp1_cs_as as item_code
				   ,i.name_l collate sql_latin1_general_cp1_cs_as as item_name
				   ,cd.quantity
				   ,cd.unit_price
				   --,cd.amount
				   --,(cd.amount * ar.credit_factor)*.2 as discount
				   --,ard.quantity
				   ,cd.quantity * cd.unit_price as charge_amount
				   ,(cd.quantity * cd.unit_price)*.20 as discount_amount
				   --,ard.gross_amount
				   --,ard.discount_amount
				   ,ard.discount_percentage
				   ,ar.transaction_text collate sql_latin1_general_cp1_cs_as as invoice_no
				   ,ar.transaction_date_time as invoice_date
				   ,phu.visible_patient_id as hn
				   ,pfn.display_name_l collate sql_latin1_general_cp1_cs_as as patient_name
				   ,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as age
				   ,(Select top 1 isnull(document_number,'') from person_official_document 
									where person_id = pv.patient_id
									and official_document_type_rcd = 'SCID'
									and deleted_date_time is null) collate sql_latin1_general_cp1_cs_as as osca_id
				   ,pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
										   else 'Inpatient Pharmacy' end) collate sql_latin1_general_cp1_cs_as
				   ,cd.charge_detail_id
				   ,ar.policy_id
				   ,p.short_code
				   ,p.name_l as policy_name
				   ,ard.discount_posting_rule_id
				   ,dpr.name_l as discount_reason
				   ,gac.name_l as gl_discount_reason
				   ,ard.ar_invoice_detail_id
				   ,ar.ar_invoice_id
				   ,pv.visit_code
				   ,ar.customer_id


			from ar_invoice ar left outer join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
							   left outer join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id 	
							   left outer join item i on ard.item_id = i.item_id
							   left outer join item_group ig on i.item_group_id = ig.item_group_id
							   LEFT OUTER JOIN patient_visit_nl_view pv ON cd.patient_visit_id = pv.patient_visit_id
							   LEFT OUTER JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
							   LEFT OUTER join patient_hospital_usage phu on pv.patient_id = phu.patient_id		
							   LEFT OUTER join policy p on ar.policy_id = p.policy_id
							   LEFT OUTER join discount_posting_rule dpr on ard.discount_posting_rule_id = dpr.discount_posting_rule_id
							   LEFT OUTER join gl_acct_code gac on ard.discount_gl_acct_code_id = gac.gl_acct_code_id
							   LEFT outer join dbo.swe_vendor_item svi on i.item_id = svi.item_id
							   LEFT outer join dbo.vendor v on svi.vendor_id = v.vendor_id
				   	       
			where discount_gl_acct_code_id = '4145912C-F671-11D9-A79A-001143B8816C'     --Senior Citizen Discount
				  and ar.transaction_status_rcd not in  ('voi','unk')
				  and cd.deleted_date_time is null
				  and pv.cancelled_date_time is null
				  and i.active_flag = 1
				  and v.organisation_id is not null
				  and svi.default_item_flag = 1
				  --and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'      --PINV
				  --and ar.transaction_text = 'PINV-2019-134395'

			) as temp
				where temp.main_group_code like '08%'         --Medical Supplies
				and temp.main_group_code not in ('084', '80')       --Medical Equipment, Women's Health
	        ---------------
			union
			---------------
			SELECT DISTINCT * from 
			(
			SELECT v.vendor_code
				   ,vendor_name = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id)
				   ,(Select item_group_code from item_group where item_group_id = ig.parent_item_group_id) as main_group_code
				   ,(Select name_l from item_group where item_group_id = ig.parent_item_group_id) as main_group_name
				   ,ig.item_group_code
				   ,ig.name_l as item_group_name
				   ,i.item_code collate sql_latin1_general_cp1_cs_as as item_code
				   ,i.name_l collate sql_latin1_general_cp1_cs_as as item_name
				   ,cd.quantity
				   ,cd.unit_price
				   --,cd.amount
				   --,(cd.amount * ar.credit_factor)*.2 as discount
				   --,ard.quantity
				   ,cd.quantity * cd.unit_price as charge_amount
				   ,(cd.quantity * cd.unit_price)*.20 as discount_amount
				   --,ard.gross_amount
				   --,ard.discount_amount
				   ,ard.discount_percentage
				   ,ar.transaction_text collate sql_latin1_general_cp1_cs_as as invoice_no
				   ,ar.transaction_date_time as invoice_date
				   ,phu.visible_patient_id as hn
				   ,pfn.display_name_l collate sql_latin1_general_cp1_cs_as as patient_name
				   ,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as age
				   ,(Select top 1 isnull(document_number,'') from person_official_document 
									where person_id = pv.patient_id
									and official_document_type_rcd = 'SCID'
									and deleted_date_time is null) collate sql_latin1_general_cp1_cs_as as osca_id
				   ,pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
										   else 'Inpatient Pharmacy' end) collate sql_latin1_general_cp1_cs_as
				   ,cd.charge_detail_id
				   ,ar.policy_id
				   ,p.short_code
				   ,p.name_l as policy_name
				   ,ard.discount_posting_rule_id
				   ,dpr.name_l as discount_reason
				   ,gac.name_l as gl_discount_reason
				   ,ard.ar_invoice_detail_id
				   ,ar.ar_invoice_id
				   ,pv.visit_code
				   ,ar.customer_id


			from ar_invoice ar left outer join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
							   left outer join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id 	
							   left outer join item i on ard.item_id = i.item_id
							   left outer join item_group ig on i.item_group_id = ig.item_group_id
							   LEFT OUTER JOIN patient_visit_nl_view pv ON cd.patient_visit_id = pv.patient_visit_id
							   LEFT OUTER JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
							   LEFT OUTER join patient_hospital_usage phu on pv.patient_id = phu.patient_id	
							   LEFT OUTER join policy p on ar.policy_id = p.policy_id
							   LEFT OUTER join discount_posting_rule dpr on ard.discount_posting_rule_id = dpr.discount_posting_rule_id
							   LEFT OUTER join gl_acct_code gac on ard.discount_gl_acct_code_id = gac.gl_acct_code_id
							   LEFT outer join dbo.swe_vendor_item svi on i.item_id = svi.item_id
							   LEFT outer join dbo.vendor v on svi.vendor_id = v.vendor_id	
				   	       
			where discount_gl_acct_code_id = '4145912C-F671-11D9-A79A-001143B8816C'     --Senior Citizen Discount
				  and ar.transaction_status_rcd not in  ('voi','unk')
				  and cd.deleted_date_time is null
				  and pv.cancelled_date_time is null
				  and i.active_flag = 1
				  and v.organisation_id is not null
				  and svi.default_item_flag = 1
				  --and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'      --PINV
				  --and ar.transaction_text = 'PINV-2019-134395'

			) as temp
				where temp.main_group_code = '06'    --Medicines
	        ---------------
			union
			---------------
			SELECT DISTINCT * from 
			(
			SELECT v.vendor_code
				   ,vendor_name = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id)
				   ,(Select item_group_code from item_group where item_group_id = ig.parent_item_group_id) as main_group_code
				   ,(Select name_l from item_group where item_group_id = ig.parent_item_group_id) as main_group_name
				   ,ig.item_group_code
				   ,ig.name_l as item_group_name
				   ,i.item_code collate sql_latin1_general_cp1_cs_as as item_code
				   ,i.name_l collate sql_latin1_general_cp1_cs_as as item_name
				   ,cd.quantity
				   ,cd.unit_price
				   --,cd.amount
				   --,(cd.amount * ar.credit_factor)*.2 as discount
				   --,ard.quantity
				   ,cd.quantity * cd.unit_price as charge_amount
				   ,(cd.quantity * cd.unit_price)*.20 as discount_amount
				   --,ard.gross_amount
				   --,ard.discount_amount
				   ,ard.discount_percentage
				   ,ar.transaction_text collate sql_latin1_general_cp1_cs_as as invoice_no
				   ,ar.transaction_date_time as invoice_date
				   ,phu.visible_patient_id as hn
				   ,pfn.display_name_l collate sql_latin1_general_cp1_cs_as as patient_name
				   ,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as age
				   ,(Select top 1 isnull(document_number,'') from person_official_document 
									where person_id = pv.patient_id
									and official_document_type_rcd = 'SCID'
									and deleted_date_time is null) collate sql_latin1_general_cp1_cs_as as osca_id
				   ,pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
										   else 'Inpatient Pharmacy' end) collate sql_latin1_general_cp1_cs_as
				   ,cd.charge_detail_id
				   ,ar.policy_id
				   ,p.short_code
				   ,p.name_l as policy_name
				   ,ard.discount_posting_rule_id
				   ,dpr.name_l as discount_reason
				   ,gac.name_l as gl_discount_reason
				   ,ard.ar_invoice_detail_id
				   ,ar.ar_invoice_id
				   ,pv.visit_code
				   ,ar.customer_id


			from ar_invoice ar left outer join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
							   left outer join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id 	
							   left outer join item i on ard.item_id = i.item_id
							   left outer join item_group ig on i.item_group_id = ig.item_group_id
							   LEFT OUTER JOIN patient_visit_nl_view pv ON cd.patient_visit_id = pv.patient_visit_id
							   LEFT OUTER JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
							   LEFT OUTER join patient_hospital_usage phu on pv.patient_id = phu.patient_id	
							   LEFT OUTER join policy p on ar.policy_id = p.policy_id
							   LEFT OUTER join discount_posting_rule dpr on ard.discount_posting_rule_id = dpr.discount_posting_rule_id
							   LEFT OUTER join gl_acct_code gac on ard.discount_gl_acct_code_id = gac.gl_acct_code_id
							   LEFT outer join dbo.swe_vendor_item svi on i.item_id = svi.item_id
							   LEFT outer join dbo.vendor v on svi.vendor_id = v.vendor_id
	
				   	       
			where discount_gl_acct_code_id = '4145912C-F671-11D9-A79A-001143B8816C'     --Senior Citizen Discount
				  and ar.transaction_status_rcd not in  ('voi','unk')
				  and cd.deleted_date_time is null
				  and pv.cancelled_date_time is null
				  and i.active_flag = 1
				  and v.organisation_id is not null
				  and svi.default_item_flag = 1
				  --and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'      --PINV
				  --and ar.transaction_text = 'PINV-2019-134395'

			) as temp
				where temp.main_group_code in ('047', '046')    --OutPatient Pharmacy, MSU Cathlab Consignment

) as tempb
left outer join AHMC_DataAnalyticsDB.dbo.scd_items si on si.[AHI ITEM CODE] = tempb.item_code  collate SQL_Latin1_General_CP1_CI_AS
left OUTER JOIN AmalgaPROD.dbo.customer c on tempb.customer_id = c.customer_id
LEFT OUTER JOIN AmalgaPROD.dbo.organisation o on c.organisation_id = o.organisation_id
LEFT OUTER JOIN AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on c.person_id = pfn.person_id
LEFT OUTER JOIN AmalgaPROD.dbo.organisation_role oor on o.organisation_id = oor.organisation_id
LEFT OUTER JOIN AmalgaPROD.dbo.organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd

where tempb.invoice_date between @date1 and @date2
      --month(tempb.invoice_date) = 5
      --and year(tempb.invoice_date) = 2019
	  and tempb.vendor_name is not null
      --and tempb.hn = '00241493'
order by tempb.invoice_no, tempb.hn, tempb.vendor_name