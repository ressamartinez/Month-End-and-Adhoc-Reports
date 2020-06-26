
select distinct phu.visible_patient_id as HN,
       pfn.display_name_l as [Patient Name],
	   pv.visit_code as [Visit No.],
	   pv.actual_visit_date_time as [Visit Start],
	   pv.closure_date_time as [Discharged Date],
	   ar.transaction_text as [Invoice No.],
	   ar.transaction_date_time as [Invoice Date],
	   ar.gross_amount as [Gross Amount],
	   r.transaction_text as [Receipt No.],
	   r.transaction_date_time as [Payment Date],
	   --sai.net_amount as [Installment Amount],
	   r.received_amount as [Remittance Amount],
	   spsr.name_l as [Payment Status]

from ar_invoice ar inner join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
                   inner join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
				   inner join patient_visit pv on cd.patient_visit_id = pv.patient_visit_id
				   inner join patient_hospital_usage phu on pv.patient_id = phu.patient_id
				   inner join person_formatted_name_iview pfn on phu.patient_id = pfn.person_id
                   inner join swe_ar_instalment sai on ar.ar_invoice_id = sai.ar_invoice_id
                   inner join remittance r on sai.remittance_id = r.remittance_id
				   inner join swe_payment_status_ref spsr on ar.swe_payment_status_rcd = spsr.swe_payment_status_rcd

where CAST(CONVERT(VARCHAR(10),r.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'06/01/2020',101) as SMALLDATETIME)
      and CAST(CONVERT(VARCHAR(10),r.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'06/15/2020',101) as SMALLDATETIME)
      and ar.transaction_status_rcd not in ('voi','unk')
	  and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2' --PINV
	  --and ar.transaction_text = 'PINV-2020-093678'

order by r.transaction_date_time



