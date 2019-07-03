
select DISTINCT
	   ard.ar_invoice_detail_id,
	   gac.name_l as debit,
	   gac2.name_l as credit,
	   ar.transaction_status_rcd,
	   tsr.name_l as transaction_status,
	   utt.name_l as transaction_type,
	   ar.transaction_text as invoice_no,
	   ar2.transaction_text as related_invoice_no,
       ard.gross_amount as debit_amount,
	   ard.gross_amount as net_amount,
	   ard.discount_amount,
	   --ar.gross_amount,
	   --ar.net_amount,
	   --ar.discount_amount,
	   ar.owing_amount,
	   ar.write_off_amount,
	   ar.currency_rcd,
	   ar.transaction_date_time,
	   ar.effective_date,
	   c.customer_code,
	   pfn.display_name_l as last_updated_by,
	   ar.lu_updated as last_updated


from ar_invoice ar left outer join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
				   left outer join ar_invoice ar2 on ar.related_ar_invoice_id = ar2.ar_invoice_id
				   left outer join gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
				   left outer join gl_acct_code gac2 on ar.gl_acct_code_debit_id = gac2.gl_acct_code_id
				   left outer join transaction_status_ref tsr on ar.transaction_status_rcd = tsr.transaction_status_rcd
				   left outer join user_transaction_type utt on ar.user_transaction_type_id = utt.user_transaction_type_id
				   left outer join customer c on ar.customer_id = c.customer_id
				   left outer join user_account ua on ar.lu_user_id = ua.user_id
				   left outer join person_formatted_name_iview pfn on ua.person_id = pfn.person_id

where ar.user_transaction_type_id = '30957F9E-735D-11DA-BB34-000E0C7F3ED2'   --CMAR
	  --and ar2.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'    --PINV
      and month(ar.transaction_date_time) between 1 and 5
	  and year(ar.transaction_date_time) = 2019
	  --and ar.transaction_status_rcd = 'POS'
	  --and ar2.transaction_text = 'CINV-2019-000012'

order by ar2.transaction_text
      


