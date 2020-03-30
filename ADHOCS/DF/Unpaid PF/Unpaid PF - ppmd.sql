
SELECT DISTINCT
	  ar.transaction_text as [Invoice No],
      ar.transaction_date_time as [Invoice Date],
	  ard.gross_amount * ar.credit_factor as [Gross Amount],
	  ard.discount_amount as [Discount Amount],
	  (ard.gross_amount - ard.discount_amount) * ar.credit_factor as [Net Amount],
	  cd.item_code as [Item Code],
	  cd.item_desc as [Item Description],
	  cd.charge_date as [Charge Date],
	  cv.employee_nr as [Employee NR],
	  cv.caregiver_name as [Caregiver],
	  cd.hospital_number as [Hospital Number],
	  cd.patient_name as [Patient Name],
	  --ppdh.credited_amount as [Credited Amount],
	  gac.gl_acct_code_code as [GL Account Code],
	  gac.name_l as [GL Account Name],
	  ard.ar_invoice_detail_id,
	  cd.charge_id

from charge_details_vw cd inner join ar_invoice_details ard on cd.charge_id = ard.charge_detail_id
                          inner join ar_invoices ar on ard.ar_invoice_id = ar.ar_invoice_id
						  inner JOIN caregiver_view cv on cd.doctor_id = cv.employee_nr
                          inner join gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id

where ar.transaction_status_rcd not in ('unk','voi')
     --CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2019',101) as SMALLDATETIME)
     and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2019',101) as SMALLDATETIME)
	 and gac.gl_acct_code_code IN ('2152000', '2152100', '2152250')
	 and ard.ar_invoice_detail_id not in (Select ar_invoice_detail_id from dbo.payment_period_details_history 
	                                             where ar_invoice_detail_id = ard.ar_invoice_detail_id)

order by ar.transaction_date_time