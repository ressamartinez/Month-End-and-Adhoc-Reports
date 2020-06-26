
SELECT ap.transaction_text as [Payment No.],
       ap.payment_date_time as [Payment Date],
	   ap.effective_date as [Effective Date],
	   sat.transaction_text as [Invoice No.],
       sat.vendor_invoice_no as [Vendor Invoice No.],
	   v.vendor_code as [Vendor Code],
	   [Payee / Vendor Name] = (CASE WHEN v.person_id IS NOT NULL then 
					   (select display_name_l from person_formatted_name_iview where person_id = v.person_id)
						else (SELECT name_l from organisation WHERE organisation_id = v.organisation_id)
						END),
	   gac.gl_acct_code_code as [GL Account Code],
	   gac.name_l as [GL Account Name],
	   satd.gross_amount - satd.discount_amount as [Net Amount],
	   satd.wth_tax_amount as [WTH Tax Amount],
	   ap.pay_amount as [Amount to Pay]

from ap_payment ap inner join ap_payment_instalment_mapping apim on ap.ap_payment_id = apim.ap_payment_id
                   inner join swe_ap_instalment sai on apim.instalment_id = sai.instalment_id
				   inner join swe_ap_transaction sat on sai.ap_invoice_id = sat.ap_invoice_id
				   inner JOIN swe_ap_transaction_detail satd on sat.ap_invoice_id = satd.ap_invoice_id
				   inner JOIN gl_acct_code gac on satd.gl_acct_code_debit_id =  gac.gl_acct_code_id
				   left outer join vendor v on sat.vendor_id = v.vendor_id

where ap.transaction_status_rcd NOT IN ('VOI', 'UNK')
      and sat.transaction_status_rcd NOT IN ('VOI', 'UNK')
	  --AND sat.user_transaction_type_id in ('30957F9D-735D-11DA-BB34-000E0C7F3ED2')		--APINV
	  and month(ap.payment_date_time) = 1
	  and year(ap.payment_date_time) = 2020 
	  and year(sat.vendor_invoice_date_time) = 2019
      --and ap.transaction_text = 'PMT-2020-000001'
	  --and sat.transaction_text = 'APINV-2019-001781'

order by vendor_invoice_date_time

