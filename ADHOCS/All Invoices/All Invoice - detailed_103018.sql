
select rip.hn as HN
	   ,rip.patient_name as [Patient Name]
	   ,rip.policy_name as Payor
	   ,rip.invoice_no as [Invoice No]
	   ,rip.visit_type as [Visit Type]
	   --,rip.swe_payment_status_rcd
	   ,spsr.name_l as [Payment Status]
	   ,rip.transaction_date_time as [Transaction Date and Time]
	   ,rip.discharge_date_time as [Discharge Date and Time]
	   ,rip.philhealth as Philhealth
	   ,rip.philhealth_pf as [Philhealth PF]
	   ,rip.net_hb as [Net HB]
	   ,rip.discount_hb as [Discount HB]
	   ,rip.net_df as [Net DF]
	   ,rip.discount_df as [Discount DF]
	   ,rip.net_pf as [Net PF S23]
	   ,rip.discount_pf as [Discount PF S23]
	   ,rip.net_er_pf as [Net ER PF]
	   ,rip.discount_er_pf as [Discount ER PF]
	   ,rip.package_discount as [Package Discount]
	   ,rip.total_amt as [Gross Amount]

from HISReport.dbo.rpt_invoice_pf rip
	 left outer join swe_payment_status_ref spsr on spsr.swe_payment_status_rcd = rip.swe_payment_status_rcd
	 inner JOIN ar_invoice ar on ar.ar_invoice_id = rip.invoice_id
where CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'09/01/2018',101) as SMALLDATETIME)
      and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'09/30/2018',101) as SMALLDATETIME)
      and ar.transaction_status_rcd not in ('voi','unk')
      --and invoice_no = 'PINV-2018-262713'

order by rip.transaction_date_time