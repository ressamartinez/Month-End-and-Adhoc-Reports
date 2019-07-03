
select temp.* 

from (
		select rip.hn,
			   rip.patient_name,
			   p.name_l as payor,
			   ar_main.transaction_text as invoice_no,
			   ar_main.transaction_date_time as invoice_date,
			   ar.transaction_text as related_invoice_no,
			   ar.transaction_date_time as related_invoice_date,
			   ar.gross_amount,
			   r.transaction_text as remittance_invoice_no,
			   r.transaction_date_time as remittance_invoice_date,
			   sai.net_amount
		from ar_invoice ar_main inner join ar_invoice ar on ar_main.ar_invoice_id = ar.related_ar_invoice_id
								inner join swe_ar_instalment sai on ar.ar_invoice_id = sai.ar_invoice_id
								inner join remittance r on sai.remittance_id = r.remittance_id
								inner join HISReport.dbo.rpt_invoice_pf rip on ar.ar_invoice_id = rip.invoice_id
								inner join policy p on ar_main.policy_id = p.policy_id
		where ar_main.transaction_status_rcd not in ('unk','voi')
		and ar_main.policy_id = '1482D4FE-6EDF-11E3-84F9-78E3B58FDD66'
		--and hn = '00457994'
		--ar_main.transaction_text = 'PINV-2014-061917'
		and ar.user_transaction_type_id = '30957F9E-735D-11DA-BB34-000E0C7F3ED2'

)as temp
order by hn, invoice_no



