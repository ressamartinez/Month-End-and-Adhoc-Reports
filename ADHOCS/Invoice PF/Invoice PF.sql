SELECT hn as HN,
	patient_name as [Patient Name],
	invoice_no as [Invoice No.],
	policy_name as [Payor],
	visit_type as [Visit Type],
	transaction_date_time as [Transaction Date and Time],
	CONVERT(VARCHAR(20), transaction_date_time,101) AS [Transaction Date],
	FORMAT(transaction_date_time,'hh:mm tt') AS [Transaction Time],
	discharge_date_time as [Discharge Date and Time],
	CONVERT(VARCHAR(20), discharge_date_time,101) AS [Discharge Date],
	FORMAT(discharge_date_time,'hh:mm tt') AS [Discharge Time],
	philhealth as [Philhealth],
	philhealth_pf as [Philhealth PF],
	net_hb as [Net HB],
	discount_hb as [Discount HB],
	net_df as [Net DF],
	discount_df as [Discount DF],
	net_pf as [Net PF S23],
	discount_pf as [Discount PF S23],
	net_er_pf as [ER PF],
	discount_er_pf as [ER PF Discount]
from rpt_invoice_pf
where CAST(CONVERT(VARCHAR(10),discharge_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@FROM,101) as SMALLDATETIME)
	and CAST(CONVERT(VARCHAR(10),discharge_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@TO,101) as SMALLDATETIME)
	and swe_payment_status_rcd in ('part','partid','unp')
order by --patient_name, 
	discharge_date_time DESC
