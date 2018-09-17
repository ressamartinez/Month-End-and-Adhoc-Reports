--374937 ALL
--44084 ALL APINV

SELECT 
	  CASE WHEN v.person_id IS NOT NULL THEN
									(SELECT display_name_l from person_formatted_name_iview where person_id = v.person_id)
								ELSE (SELECT name_l from organisation where organisation_id = v.organisation_id) END as [Vendor]
	  ,sat.transaction_text as [Invoice Number]
	  ,sat.vendor_invoice_date_time as [Invoice Date]
	  ,i.item_code as [Item Code]
	  ,i.name_l as [Item Name]
	  ,satd.gross_amount as [Gross Amount]
	  ,satd.discount_amount as [Discount Amount]
	  --,satd.gross_amount - satd.discount_amount as [Net Amount]
	  ,(satd.gross_amount + satd.tax_amount) - satd.discount_amount as  [Net Amount]
	  ,tsr.name_l as [Transaction Status]
	  ,gac.gl_acct_code_code as [GL Account Code]
	  ,gac.name_l as [GL Account Name]
	  ,glt.transaction_text as [Transaction Number]
	  ,glt.transaction_description as [Transaction Description]

	  --,glt.gl_transaction_id
	  --,satd.tax_amount
	 -- ,glt.transaction_date_time

	  
FROM swe_ap_transaction sat --ap_payment ap
				INNER JOIN gl_transaction glt ON glt.gl_transaction_id = sat.gl_transaction_id
				INNER JOIN vendor v ON sat.vendor_id = v.vendor_id
				inner JOIN swe_ap_transaction_detail satd on sat.ap_invoice_id = satd.ap_invoice_id
				LEFT outer JOIN item i on satd.item_id = i.item_id
				inner JOIN gl_acct_code gac on satd.gl_acct_code_debit_id =  gac.gl_acct_code_id
				inner JOIN transaction_status_ref tsr on sat.transaction_status_rcd = tsr.transaction_status_rcd

where 
			glt.user_transaction_type_id = '30957FAA-735D-11DA-BB34-000E0C7F3ED2'				--PAP
			AND sat.user_transaction_type_id in ('30957F9D-735D-11DA-BB34-000E0C7F3ED2','E27021D9-8F5A-11DE-B6C3-00237DBC514A')		--APINV
			--NOT IN ('30957F9C-735D-11DA-BB34-000E0C7F3ED2', 
			--'30957F9D-735D-11DA-BB34-000E0C7F3ED2', 
			--'30957F9A-735D-11DA-BB34-000E0C7F3ED2', 
			--'30957F9B-735D-11DA-BB34-000E0C7F3ED2',
			--'E27021D9-8F5A-11DE-B6C3-00237DBC514A')
			AND glt.transaction_status_rcd NOT IN ('VOI', 'UNK')
			AND sat.transaction_status_rcd NOT IN ('VOI', 'UNK')
			AND gac.gl_acct_code_code IN ('2152100', '4264000')		
			and month(sat.vendor_invoice_date_time) = 8
			and YEAR(sat.vendor_invoice_date_time) = 2018

			--AND glt.transaction_text = 'PAP-2018-000653'

order BY glt.transaction_date_time