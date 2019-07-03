
select distinct arh.transaction_text,
       arh.transaction_date_time,
	   arh.gross_amount * arh.credit_factor as gross_amount,
	   arh.discount_amount * arh.credit_factor as discount_amount,
	   arh.net_amount * arh.credit_factor as net_amount,
	   i.item_code,
       i.name_l as item_name,
	   i.item_type_rcd,
	   i.sub_item_type_rcd,
	   cd.quantity * arh.credit_factor as quantity,
	   cd.unit_price * arh.credit_factor as unit_price,
       cd.amount * arh.credit_factor as charge_amount,
       phu.visible_patient_id as hn,
       pfn.display_name_l as patient_name

	    
from ar_invoice arh
	 LEFT OUTER join ar_invoice_detail ard on arh.ar_invoice_id = ard.ar_invoice_id
     LEFT outer JOIN charge_detail_nl_view cd on ard.charge_detail_id = cd.charge_detail_id
	 LEFT OUTER JOIN patient_visit_nl_view pv ON cd.patient_visit_id = pv.patient_visit_id
     LEFT OUTER JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
     LEFT OUTER join patient_hospital_usage phu on pv.patient_id = phu.patient_id
	 LEFT outer join dbo.item i on ard.item_id = i.item_id
     LEFT outer join dbo.swe_vendor_item svi on i.item_id = svi.item_id


where ard.discount_gl_acct_code_id = '4145912C-F671-11D9-A79A-001143B8816C'
	  and arh.transaction_status_rcd not in  ('voi','unk')
	  and i.active_flag = 1
      --and svi.default_item_flag = 1
	  and pv.cancelled_date_time is null
	  and cd.deleted_date_time is null
      and month(arh.transaction_date_time) = 5
	  and year(arh.transaction_date_time) = 2019 
	  --and arh.transaction_text = 'PINV-2019-146044'

order by arh.transaction_text
