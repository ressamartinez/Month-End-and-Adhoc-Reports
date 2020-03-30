
SELECT aih.transaction_date_time as [Transaction Date],
	   aih.transaction_text as [Transaction No],
	   dba.employee_nr as [Employee No],
	   RTRIM(dba.caregiver_lname) + ', ' + RTRIM(dba.caregiver_fname) as [Doctor Name],
	   --dba.upi as [HN No],
	   --dba.lname + ', ' + dba.fname + ' ' + dba.mname as [Patient Name],
	   aidhh.gross_amount as [Gross Amount],
	   dba.item_code as [Item Code],
	   dba.item_desc as [Item Description],
	   ISNULL(ppdh.gross_amount,0) as [Credited Gross Amount],
	   case when ISNULL(ppdh.gross_amount,0) = 0 then aidhh.gross_amount else 0 end as [Balance Amount],
	   gac.gl_acct_code_code,
	   gac.name_l as gl_account_name

from df_browse_all dba inner join ar_invoice_detail_head_history aidhh on aidhh.charge_detail_id = dba.charge_id
					   inner join ar_invoice_detail_tail_history aidth on aidth.ar_invoice_detail_id = aidhh.ar_invoice_detail_id
					   inner join ar_invoice_head aih on aih.ar_invoice_id = aidhh.ar_invoice_id
					   inner join ar_invoice_tail ait on ait.ar_invoice_id = aih.ar_invoice_id
					   left outer join payment_period_detail_history ppdh on ppdh.ar_invoice_detail_id = aidhh.ar_invoice_detail_id
					   inner join gl_acct_code gac on gac.gl_acct_code_id = aidth.gl_acct_code_Credit_id

where ait.transaction_status_rcd not in ('unk','voi')
     and aih.user_transaction_type_id in ('F8EF2162-3311-11DA-BB34-000E0C7F3ED2', '30957FA1-735D-11DA-BB34-000E0C7F3ED2') 
	-- and ard.charge_detail_id = '931FEA08-72D8-11E8-A2C9-9E78655E10C3'
	 and dba.total_amt > 0 
	 and gac.gl_acct_code_code IN ('2152100', '2152250')
	 and CAST(CONVERT(VARCHAR(10),aih.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2019',101) as SMALLDATETIME)
	 and CAST(CONVERT(VARCHAR(10),aih.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'09/30/2019',101) as SMALLDATETIME)

order by aih.transaction_date_time