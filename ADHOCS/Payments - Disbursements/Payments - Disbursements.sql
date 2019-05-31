
select DISTINCT ap.transaction_text,
	   ap.payment_date_time,
	   ap.effective_date,
	   v.vendor_code,
	   c.customer_code,
	   ap.pay_to_name,
	   aptr.name_l as payment_type,
	   apstr.name_l as payment_subtype,
	   apv.net_amount,
	   ap.wth_tax_amount,
	   ap.pay_amount,
	   cr.name_l as currency,
	   tsr.name_l as status,
	   utt.name_l as transaction_type,
	   apcr.name_l as category
	    
from ap_payment ap left outer join vendor v on ap.vendor_id = v.vendor_id 
				   left outer join customer c on ap.customer_id = c.customer_id
				   left outer join ap_payment_type_ref aptr on ap.ap_payment_type_rid = aptr.ap_payment_type_rid
				   left outer join ap_payment_sub_type_ref apstr on ap.ap_payment_sub_type_rid = apstr.ap_payment_sub_type_rid
				   left outer join currency_ref cr on ap.currency_rcd = cr.currency_rcd
				   inner join gl_transaction gl on ap.gl_transaction_id = ap.gl_transaction_id
				   left outer join transaction_status_ref tsr on ap.transaction_status_rcd = tsr.transaction_status_rcd
				   left outer join user_transaction_type utt on ap.user_transaction_type_id = utt.user_transaction_type_id
				   left outer join ap_payment_category_ref apcr on ap.ap_payment_category_rcd = apcr.ap_payment_category_rcd
				   inner join ap_payment_vendor apv on ap.ap_payment_id = apv.ap_payment_id

where CAST(CONVERT(VARCHAR(10),ap.payment_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'06/15/2018',101) as SMALLDATETIME)
      and CAST(CONVERT(VARCHAR(10),ap.payment_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'07/31/2018',101) as SMALLDATETIME)
	  and ap.transaction_text = 'PMT-2018-005519'



