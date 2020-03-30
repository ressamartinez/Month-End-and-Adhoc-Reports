select DISTINCT
	   gac.gl_acct_code_code,
	   gac.name_l as gl_acct_name,
	   cv.employee_nr,
	   cv.doctor_lname,
	   cv.doctor_fname,
	   ppdh.hospital_number as hn,
	   ppdh.pname as patient_name,
	   ppdh.charge_date,
	   ppdh.charge_amount,
	   pp.period_id,
	   s.credit_date_start as period_date,
	   ar.transaction_date_time as invoice_date,
	   ar.transaction_text as invoice_no,
	   ppdh.item_desc,
	   ppdh.charge_id,
	   ppdh.ar_invoice_detail_id

from dbo.payment_period_details_history ppdh 
	 inner JOIN dbo.caregiver_view cv on ppdh.employee_nr = cv.employee_nr 
	 inner join dbo.ar_invoice_details ard on ppdh.ar_invoice_detail_id = ard.ar_invoice_detail_id
	 inner join dbo.ar_invoices ar on ard.ar_invoice_id = ar.ar_invoice_id
	 inner join dbo.gl_acct_code gac on ard.gl_acct_code_Credit_id = gac.gl_acct_code_id
	 inner join dbo.payment_period pp on ppdh.period_id = pp.period_id
	 inner join dbo.schedule s on pp.schedule_id = s.schedule_id

where CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
	  and gac.gl_acct_code_code = '2152100'   --Physician's Fees Payable

--where pp.period_id = (Select top 1 period_id from dbo.payment_period
--order by period_id desc)
--and gac.gl_acct_code_code = '2152100'   --Physician's Fees Payable

order by pp.period_id