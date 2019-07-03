
select DISTINCT 
	   gac.gl_acct_code_code,
	   gac.name_l as gl_acct_name,
	   d.employee_nr, 
       d.last_name_l,
	   d.first_name_l,
	   ppdh.upi as hn,
	   ppdh.pname as patient_name,
	   ppdh.charge_date,
	   ppdh.charge_amount,
	   pp.period_id,
	   pp.period_date,
	   arh.transaction_date_time as invoice_date,
	   arh.transaction_text as invoice_no,
	   ppdh.item_desc,
	   ppdh.charge_id,
	   ppdh.ar_invoice_detail_id

from payment_period_detail_history ppdh inner join doctor d on ppdh.employee_nr = d.employee_nr 
										inner JOIN ar_invoice_detail_head_history ardh on ppdh.ar_invoice_detail_id = ardh.ar_invoice_detail_id
										inner JOIN ar_invoice_detail_tail_history ardt on ardh.ar_invoice_detail_id = ardt.ar_invoice_detail_id
							     		inner JOIN ar_invoice_head arh on ardh.ar_invoice_id = arh.ar_invoice_id
										inner JOIN ar_invoice_body arhb on arh.ar_invoice_id = arhb.ar_invoice_id
										inner join gl_acct_code gac on ardt.gl_acct_code_Credit_id = gac.gl_acct_code_id
										inner join payment_period pp on ppdh.period_id = pp.period_id
										

where CAST(CONVERT(VARCHAR(10),pp.period_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2019',101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),pp.period_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'04/30/2019',101) as SMALLDATETIME)
	  and gac.gl_acct_code_code = '2152100'   --Physician's Fees Payable



order by pp.period_id

