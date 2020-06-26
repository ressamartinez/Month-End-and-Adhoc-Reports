

SELECT 
      sat.vendor_invoice_date_time as [Reference Date],
	  glt.transaction_text as PAP,
	  sat.transaction_text as Reference,
	  isnull((select transaction_text from swe_ap_transaction where ap_invoice_id = sat.from_ap_invoice_id),'') as [Related Invoice],
	  isnull((select vendor_invoice_date_time from swe_ap_transaction where ap_invoice_id = sat.from_ap_invoice_id),'') as [Related Invoice Date],
	  v.vendor_code as HN,
	  [Patient Name] = (CASE WHEN v.person_id IS NOT NULL then 
						  (select display_name_l from person_formatted_name_iview where person_id = v.person_id)
						  else (SELECT name_l from organisation WHERE organisation_id = v.organisation_id)
						  END),
	  REPLACE(REPLACE(satd.comment,'''','*'),'"','*') as Description,
	  satd.gross_amount - satd.discount_amount as Amount,
	  gac.gl_acct_code_code as [GL Account Code],
	  gac.name_l as [GL Account Name]

FROM swe_ap_transaction sat --ap_payment ap
				INNER JOIN gl_transaction glt ON glt.gl_transaction_id = sat.gl_transaction_id
				inner JOIN swe_ap_transaction_detail satd on sat.ap_invoice_id = satd.ap_invoice_id
				inner JOIN gl_acct_code gac on satd.gl_acct_code_debit_id =  gac.gl_acct_code_id
				inner JOIN transaction_status_ref tsr on sat.transaction_status_rcd = tsr.transaction_status_rcd
				left outer join vendor v on sat.vendor_id = v.vendor_id
				inner join ap_payment_type_ref aptr on sat.ap_payment_type_rid = aptr.ap_payment_type_rid

where 
		glt.company_code = 'AHI'
		and	glt.transaction_status_rcd = 'POS'
		and gac.gl_acct_code_code = '1130250'
	    AND glt.transaction_status_rcd NOT IN ('VOI', 'UNK')
		AND sat.transaction_status_rcd NOT IN ('VOI', 'UNK')
		--and sat.transaction_text = 'CMAP-2007-000306'

order BY sat.vendor_invoice_date_time