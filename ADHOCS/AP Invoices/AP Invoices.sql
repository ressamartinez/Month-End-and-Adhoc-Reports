

SELECT gac.gl_acct_code_code as [GL Account Code],
	  gac.name_l as [GL Account Name],
	  tsr.name_l as [Transaction Status],
	  sat.system_transaction_type_rcd as [Transaction Type],
	  glt.transaction_text as [Transaction No.],
	  --sat.transaction_text,
	  sat.vendor_invoice_no as [Vendor Invoice No.],
	  sat.swe_payment_status_rcd as [Payment Status],
	  sat.currency_rcd as Currency,
	  satd.gross_amount - satd.discount_amount as [Net Amount],
	  --(satd.gross_amount + satd.tax_amount) - satd.discount_amount as  [Net Amount],
	  sat.owing_amount as [Owing Amount],
	  sat.vendor_invoice_date_time as [Vendor Invoice Date],
	  sat.effective_date as [Effective Date],
	  v.vendor_code as [Vendor Code],
	  [Vendor Name] = (CASE WHEN v.person_id IS NOT NULL then 
						  (select display_name_l from person_formatted_name_iview where person_id = v.person_id)
						  else (SELECT name_l from organisation WHERE organisation_id = v.organisation_id)
						  END),
	  aptr.name_l as [Payment Type]

	  
FROM swe_ap_transaction sat --ap_payment ap
				INNER JOIN gl_transaction glt ON glt.gl_transaction_id = sat.gl_transaction_id
				inner JOIN swe_ap_transaction_detail satd on sat.ap_invoice_id = satd.ap_invoice_id
				LEFT outer JOIN item i on satd.item_id = i.item_id
				inner JOIN gl_acct_code gac on satd.gl_acct_code_debit_id =  gac.gl_acct_code_id
				inner JOIN transaction_status_ref tsr on sat.transaction_status_rcd = tsr.transaction_status_rcd
				left outer join vendor v on sat.vendor_id = v.vendor_id
				inner join ap_payment_type_ref aptr on sat.ap_payment_type_rid = aptr.ap_payment_type_rid

where 
			glt.user_transaction_type_id = '30957FAA-735D-11DA-BB34-000E0C7F3ED2'				--PAP
			AND sat.user_transaction_type_id in ('30957F9D-735D-11DA-BB34-000E0C7F3ED2','E27021D9-8F5A-11DE-B6C3-00237DBC514A')		--APINV, IAP
			AND glt.transaction_status_rcd NOT IN ('VOI', 'UNK')
			AND sat.transaction_status_rcd NOT IN ('VOI', 'UNK')
			and CAST(CONVERT(VARCHAR(10),sat.vendor_invoice_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'11/16/2019',101) as SMALLDATETIME)
			and CAST(CONVERT(VARCHAR(10),sat.vendor_invoice_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'01/15/2020',101) as SMALLDATETIME)


order BY sat.vendor_invoice_date_time
