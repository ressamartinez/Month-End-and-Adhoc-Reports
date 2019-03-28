SELECT 
	a.transaction_text
	,b.costcentre_code
	,b.name_l as costcentre
	,c.gl_acct_code_code
	,c.name_l as gl_acct
	,debit = case when d.debit_flag = 1 then d.amount end
	--,credit = case when d.debit_flag = 0 then d.amount end
	,a.transaction_description
	,a.transaction_date_time
	,tran_type = (select name_l from user_transaction_type where user_transaction_type_id = a.user_transaction_type_id)
	,a.effective_date
	,a.gl_transaction_id

FROM
	gl_transaction_nl_view a, costcentre_nl_view b, gl_acct_code_nl_view c, gl_transaction_detail_nl_view d 
WHERE
	a.gl_transaction_id = d.gl_transaction_id 
AND  
	d.costcentre_id = b.costcentre_id 
AND
	d.gl_acct_code_id = c.gl_acct_code_id 

--AND a.transaction_text = 'PIMS-2018-000002'
AND debit_flag = 1
AND user_transaction_type_id = 'C7D86931-81DE-11DC-8E51-000E0C7F3FA3'
and year(effective_date) = 2018

order by transaction_text