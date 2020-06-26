	
select *
from (	
	
	select  DISTINCT 
				   gt.transaction_text as PAR,
				   gt.effective_date as [Effective Date],
				   r.transaction_text as [Transaction No.],
				   gac.gl_acct_code_code as [GL Account Code],
				   gac.name_l as [GL Account Name], 
				   ar.write_off_amount as [Debit Amount],
				   ar.transaction_text as [Related Invoice]

	from remittance r inner join swe_ar_instalment sai on r.remittance_id = sai.remittance_id
					  inner join ar_invoice ar on sai.ar_invoice_id = ar.ar_invoice_id
					  inner join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
					  --inner join gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
					  inner join gl_transaction gt on r.gl_transaction_id = gt.gl_transaction_id
					  inner join gl_transaction_detail gtd on gt.gl_transaction_id = gtd.gl_transaction_id
					  inner join gl_acct_code gac on gac.gl_acct_code_id = gtd.gl_acct_code_id

	where ar.transaction_status_rcd not in ('voi','unk')
		  and CAST(CONVERT(varchar(10),r.effective_date,101) as SMALLDATETIME) >= CAST(CONVERT(varchar(10),'05/01/2020',101) as SMALLDATETIME)
		  and CAST(CONVERT(varchar(10),r.effective_date,101) as SMALLDATETIME) <= CAST(CONVERT(varchar(10),'05/31/2020',101) as SMALLDATETIME)
		  and r.transaction_status_rcd <> 'VOI'
		  and gt.transaction_status_rcd <> 'VOI'
		  --and r.transaction_text = 'RCBC-2019-006599'
		  --and gt.transaction_text = 'PAR-2019-001120'
		  and gt.company_code = 'AHI'
		  and gac.gl_acct_code_code IN ('2152100', '2152250', '4264000')
		  --and gac2.gl_acct_code_code IN ('2152100', '2152250', '4264000')

) as temp
where temp.[Debit Amount] <> 0 

order by temp.PAR, temp.[Transaction No.]