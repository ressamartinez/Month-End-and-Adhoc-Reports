SELECT dba.employee_nr as [Employee NR],
	   RTRIM(dba.caregiver_lname) + ', ' + RTRIM(dba.caregiver_fname) as [Doctor Name],
	   dba.upi as HN,
	   dba.lname + ', ' + dba.fname + ', ' + ISNULL(dba.mname,'') as [Patient Name],
	   dba.charge_date as [Charge Date],
	   dba.item_code as [Item Code],
	   dba.item_desc as [Item Desc],
	   ard.gross_amount as [Gross Amount],
	   ardt.discount_amount as [Discount Amount],
	   ard.gross_amount - ardt.discount_amount as [Net Amount],
	   case when dba.validated = 'Y' then 'Validated'
			when dba.validated = 'N' then 'Unvalidated'
			when dba.validated = 'D' then 'Direct Settle'
			when dba.validated = 'X' then 'Rejected'
			when dba.validated = 'v' then 'For blocking'
	   end as [Validate Status],
	   case when arhb.swe_payment_status_rcd = 'COM' then 'Completely Paid'
			when arhb.swe_payment_status_rcd = 'UNP' then 'Unpaid'
			when arhb.swe_payment_status_rcd = 'PART' then 'Partially Paid'
	   end as [Payment Status],
	   arh.transaction_text as [Invoice No.],
	   arh.transaction_date_time as [Invoice Date],
	   'No' as credited,
	   null as credited_date
from df_browse_all  dba inner JOIN ar_invoice_detail_head ard on dba.charge_id = ard.charge_detail_id
						inner JOIN ar_invoice_detail_tail ardt on ard.ar_invoice_detail_id = ardt.ar_invoice_detail_id
						inner JOIN ar_invoice_head arh on ard.ar_invoice_id = arh.ar_invoice_id
						inner JOIN ar_invoice_body arhb on arh.ar_invoice_id = arhb.ar_invoice_id
						inner join gl_acct_code gac on ardt.gl_acct_code_Credit_id = gac.gl_acct_code_id
where MONTH(arh.transaction_date_time) = 1
   and YEAR(arh.transaction_date_time) = 2019
   and gac.gl_acct_code_code = '2152100'
   and ard.ar_invoice_detail_id not in (SELECT ar_invoice_detail_id
										from payment_period_detail_history
										where ar_invoice_detail_id = ard.ar_invoice_detail_id)
union all
SELECT dba.employee_nr as [Employee NR],
	   RTRIM(dba.caregiver_lname) + ', ' + RTRIM(dba.caregiver_fname) as [Doctor Name],
	   dba.upi as HN,
	   dba.lname + ', ' + dba.fname + ', ' + ISNULL(dba.mname,'') as [Patient Name],
	   dba.charge_date as [Charge Date],
	   dba.item_code as [Item Code],
	   dba.item_desc as [Item Desc],
	   ardh.gross_amount as [Gross Amount],
	   ardt.discount_amount as [Discount Amount],	   
	   ardh.gross_amount - ardt.discount_amount as [Net Amount],
	   case when dba.validated = 'Y' then 'Validated'
			when dba.validated = 'N' then 'Unvalidated'
			when dba.validated = 'D' then 'Direct Settle'
			when dba.validated = 'X' then 'Rejected'
			when dba.validated = 'v' then 'For blocking'
	   end as [Validate Status],
	   case when arhb.swe_payment_status_rcd = 'COM' then 'Completely Paid'
			when arhb.swe_payment_status_rcd = 'UNP' then 'Unpaid'
			when arhb.swe_payment_status_rcd = 'PART' then 'Partially Paid'
	   end as [Payment Status],
	   arh.transaction_text as [Invoice No.],
	   arh.transaction_date_time as [Invoice Date],
	   'Yes' as credited,
	   pp.period_date as credited_date
from df_browse_all dba inner JOIN payment_period_detail_history ppdh on dba.charge_id = ppdh.charge_id
					   inner JOIN payment_period pp on ppdh.period_id = pp.period_id
					   inner JOIN ar_invoice_detail_head_history ardh on ppdh.ar_invoice_detail_id = ardh.ar_invoice_detail_id
					   inner JOIN ar_invoice_detail_tail_history ardt on ardh.ar_invoice_detail_id = ardt.ar_invoice_detail_id
					   inner JOIN ar_invoice_head arh on ardh.ar_invoice_id = arh.ar_invoice_id
					   inner JOIN ar_invoice_body arhb on arh.ar_invoice_id = arhb.ar_invoice_id
					   inner join gl_acct_code gac on ardt.gl_acct_code_Credit_id = gac.gl_acct_code_id
where MONTH(arh.transaction_date_time) = 1
   and YEAR(arh.transaction_date_time) = 2019
   and gac.gl_acct_code_code = '2152100'
   and ardh.ar_invoice_detail_id  in (SELECT ar_invoice_detail_id
										from payment_period_detail_history
										where ar_invoice_detail_id = ardh.ar_invoice_detail_id)




