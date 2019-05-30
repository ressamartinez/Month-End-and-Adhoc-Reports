
select distinct r.transaction_text as [Transaction Number],
	   gac.gl_acct_code_code as [GL Account Code],
	   gac.name_l as [GL Account Name], 
	   c.costcentre_code as [Costcentre Code],
	   c.name_l as [Costcentre Name],
	   glt.effective_date as [Effective Date],
	   glt.transaction_date_time as [Transaction Date],
	   glt.transaction_text as [Transaction Number (AR)],
	   glt.transaction_description as [Transaction Description],
	   sa.write_off as [Debit Amount]
	   ,glt.gl_transaction_id
	   ,sa.instalment_id

from gl_transaction glt inner join gl_transaction_detail gld on gld.gl_transaction_id = glt.gl_transaction_id
					   inner join gl_acct_code gac on gac.gl_acct_code_id = gld.gl_acct_code_id
					   inner join costcentre c on c.costcentre_id = gld.costcentre_id
					   left outer join remittance r on r.gl_transaction_id = glt.gl_transaction_id
					   left outer join swe_ar_instalment sai on sai.remittance_id = r.remittance_id
					   left outer join swe_allocation sa on sa.instalment_id = sai.instalment_id
					   

where gac.gl_acct_code_code = '2152100'
	  --and glt.transaction_text = 'PAR-2018-000896'
	  and year(glt.effective_date) = 2018
	  and month(glt.effective_date) = 11
	  and gld.debit_flag = 1
	  --and sa.write_off <> 0
	  and glt.user_transaction_type_id = '30957FA9-735D-11DA-BB34-000E0C7F3ED2'
	  --and r.user_transaction_type_id = '30957FA3-735D-11DA-BB34-000E0C7F3ED2'
	  and sai.instalment_id = sa.instalment_id
	  and r.remittance_id = sa.remittance_id

order by glt.transaction_text


