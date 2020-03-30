--unpaid
SELECT DISTINCT dba.charge_id,
	   aih.transaction_text as [Invoice No],
	   aih.transaction_date_time as [Invoice Date], 
	   aidh.gross_amount as [Gross Amount],
	   aidt.discount_amount as [Discount Amount],
	   aidh.gross_amount - aidt.discount_amount as [Net Amount], 
	   dba.item_code as [Item Code],
	   dba.item_desc as [Item Description],   
	   --dba.total_amt as [Charge Amount],
	   dba.charge_date as [Charge Date],  
	   dba.employee_nr as [Employee No],
	   RTRIM(dba.caregiver_lname) + ', ' + RTRIM(dba.caregiver_fname) as [Doctor Name],
	   dba.upi as [HN No],
	   dba.lname + ', ' + dba.fname + ' ' + dba.mname as [Patient Name],
	   --dba.visit_type as [Visit Type],
	   --ISNULL(ppdh.gross_amount,0) as [Credited Gross Amount],
	   --case when ISNULL(ppdh.gross_amount,0) = 0 then aidh.gross_amount else 0 end as [Balance Amount],
	   gac.gl_acct_code_code as [GL Account Code],
	   gac.name_l as [GL Account Name],
	   aidh.ar_invoice_detail_id

from df_browse_all dba left join ar_invoice_detail_head aidh on aidh.charge_detail_id = dba.charge_id
					   left join ar_invoice_detail_tail aidt on aidt.ar_invoice_detail_id = aidh.ar_invoice_detail_id
					   left join ar_invoice_head aih on aih.ar_invoice_id = aidh.ar_invoice_id
					   left join ar_invoice_tail ait on ait.ar_invoice_id = aih.ar_invoice_id
					   --left join payment_period_detail_history ppdh on ppdh.ar_invoice_detail_id = aidh.ar_invoice_detail_id
					   --left join charge_detail cd on cd.account_id = ppdh.account_id
					   left join gl_acct_code gac on aidt.gl_acct_code_Credit_id = gac.gl_acct_code_id

where ait.transaction_status_rcd not in ('unk','voi')
     --and aih.user_transaction_type_id in ('F8EF2162-3311-11DA-BB34-000E0C7F3ED2', '30957FA1-735D-11DA-BB34-000E0C7F3ED2') 
	 and gac.gl_acct_code_code IN ('2152000', '2152100', '2152250')
	 --and CAST(CONVERT(VARCHAR(10),aih.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'12/01/2018',101) as SMALLDATETIME)
	 and CAST(CONVERT(VARCHAR(10),aih.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2019',101) as SMALLDATETIME)
	 --and ppdh.ar_invoice_detail_id = aidt.ar_invoice_detail_id
	 --and aih.transaction_text = 'PINV-2019-238552'