
select *
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
	   ,i.item_code
	   ,i.name_l as item_name
	   ,cd.quantity
	   --,cd.amount
	   --,(cd.amount * ar.credit_factor)*.2 as discount
	   --,ard.quantity
	   ,ard.gross_amount
	   ,ard.discount_amount
	   ,ard.discount_percentage
	   ,ar.transaction_text as invoice_no
	   ,ar.transaction_date_time as invoice_date
	   ,phu.visible_patient_id as hn
	   ,pfn.display_name_l as patient_name
	   ,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as age
	   ,(Select top 1 document_number from person_official_document 
                        where person_id = pv.patient_id
                        and document_number is not null ) as osca_id
       ,pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
                               else 'Inpatient Pharmacy' end)
	   ,cd.charge_detail_id
	   ,ar.policy_id
	   ,p.short_code
	   ,p.name_l as policy_name
	   ,ard.discount_posting_rule_id
	   ,dpr.name_l as discount_reason
	   ,gac.name_l as gl_discount_reason
	   ,ard.ar_invoice_detail_id
	   --,ar.ar_invoice_id


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
   --   and month(ar.transaction_date_time) = 5
	  --and year(ar.transaction_date_time) = 2019
	  and i.active_flag = 1
	  and v.organisation_id is not null
	  and svi.default_item_flag = 1
      --and ar.transaction_text = 'PINV-2019-134395'
	  --and i.item_type_rcd = 'INV'
) as temp
	where temp.main_group_code like '08%'         --Meidcal Supplies
	and temp.main_group_code not in ('084', '80')       --Medical Equipment, Women's Health


union


SELECT DISTINCT * from 
(
SELECT v.vendor_code
	   ,vendor_name = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id)
	   ,(Select item_group_code from item_group where item_group_id = ig.parent_item_group_id) as main_group_code
       ,(Select name_l from item_group where item_group_id = ig.parent_item_group_id) as main_group_name
	   ,ig.item_group_code
	   ,ig.name_l as item_group_name
	   ,i.item_code
	   ,i.name_l as item_name
	   ,cd.quantity
	   --,cd.amount
	   --,(cd.amount * ar.credit_factor)*.2 as discount
	   --,ard.quantity
	   ,ard.gross_amount
	   ,ard.discount_amount
	   ,ard.discount_percentage
	   ,ar.transaction_text
	   ,ar.transaction_date_time
	   ,phu.visible_patient_id as hn
	   ,pfn.display_name_l as patient_name
	   ,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as age
	   ,(Select top 1 document_number from person_official_document 
                        where person_id = pv.patient_id
                        and document_number is not null ) as osca_id
       ,pharmacy = (CASE WHEN i.item_code like '%OPP%' then 'Outpatient Pharmacy'
                               else 'Inpatient Pharmacy' end)
	   ,cd.charge_detail_id
	   ,ar.policy_id
	   ,p.short_code
	   ,p.name_l as policy_name
	   ,ard.discount_posting_rule_id
	   ,dpr.name_l as discount_reason
	   ,gac.name_l as gl_discount_reason
	   ,ard.ar_invoice_detail_id
	   --,ar.ar_invoice_id


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
   --   and month(ar.transaction_date_time) = 5
	  --and year(ar.transaction_date_time) = 2019
	  and i.active_flag = 1
	  and v.organisation_id is not null
	  and svi.default_item_flag = 1
      --and ar.transaction_text = 'PINV-2019-134395'
	  --and i.item_type_rcd = 'INV'
) as temp
	where temp.main_group_code = '06'    --Medicines

) as tempb


where month(tempb.invoice_date) = 5
      and year(tempb.invoice_date) = 2019
      --and tempb.hn = '00149154'
order by tempb.invoice_date, tempb.hn, tempb.main_group_code

