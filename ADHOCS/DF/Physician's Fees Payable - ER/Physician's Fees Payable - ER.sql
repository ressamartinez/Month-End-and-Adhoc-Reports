
select top 2
	   d.employee_nr, 
       d.last_name_l,
	   d.first_name_l,
	   ppdh.upi as hn,
	   ppdh.pname as patient_name,
	   ppdh.charge_date,
	   arh.transaction_date_time,
	   arh.transaction_text

from payment_period_detail_history ppdh inner join doctor d on ppdh.employee_nr = d.employee_nr 
										inner JOIN ar_invoice_detail_head_history ardh on ppdh.ar_invoice_detail_id = ardh.ar_invoice_detail_id
										inner JOIN ar_invoice_detail_tail_history ardt on ardh.ar_invoice_detail_id = ardt.ar_invoice_detail_id
										inner JOIN ar_invoice_head arh on ardh.ar_invoice_id = arh.ar_invoice_id
										inner JOIN ar_invoice_body arhb on arh.ar_invoice_id = arhb.ar_invoice_id
										inner join gl_acct_code gac on ardt.gl_acct_code_Credit_id = gac.gl_acct_code_id

where MONTH(arh.transaction_date_time) = 2 
      and year(arh.transaction_date_time) = 2019
	  and gac.gl_acct_code_code = '2152250'