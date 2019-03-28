
select gac.gl_acct_code_code as 'GL Account Code',
	   gac.name_l as 'GL Account Name',
	   pb.opening_balance as 'Opening Balance',
	   pb.debit_movement as 'Debit Amount',
	   pb.credit_movement as 'Credit Amount',
	   pb.closing_balance - pb.opening_balance as 'Movement',
	   pb.closing_balance as 'Closing Balance'
from period_balance_cc pb inner join gl_acct_code gac on gac.gl_acct_code_id = pb.gl_acct_code_id
where period_id = '45DE5FA7-1CE5-E711-9EAC-00101898354E'		--dec_2018
	  and (pb.opening_balance <> 0 or debit_movement <> 0 or credit_movement <> 0  or closing_balance <> 0)
order by gac.gl_acct_code_code asc



/*
select * from period
order by start_date desc

*/