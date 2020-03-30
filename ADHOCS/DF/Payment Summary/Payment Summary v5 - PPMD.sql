SELECT 
       tempb.ar_invoice_detail_id,
       tempb.period_date as [Period Date],	
	   tempb.employee_nr as [Employee NR],
	   tempb.Caregiver as [Caregiver Name],
       tempb.[Tax Rate],
	   tempb.[Gross Amount],
	   tempb.[Adjustment Amount],
	   tempb.[Split Net Amount],
	   tempb.[Tax Amount],
	   tempb.[Merchant Discount],
	   --tempb.[Write-off Amount],
	   tempb.[Credited Amount],
	   tempb.[Invoice No],
	   tempb.[Invoice Date],
	   tempb.[Charge Date],
	   tempb.[Item Code],
	   tempb.[Item Description],
	   tempb.HN,
	   tempb.[Patient Name],
	   tempb.[Validated Datetime],
	   tempb.[GL Account Code],
	   tempb.[GL Account Name]
from
(
SELECT DISTINCT
	  -- sum(temp.credited_amount)
	   temp.period_date,
	   temp.employee_nr,
	   temp.caregiver_name as Caregiver,
	   temp.w_tax as [Tax Rate],
	   temp.gross_amount as [Gross Amount],
	   temp.adjustment_amount as [Adjustment Amount],
	   temp.split_net_amount as [Split Net Amount],
	   temp.tax_amount as [Tax Amount],
	   temp.mer_disc as [Merchant Discount],
	   --temp.writeoff_amt as [Write-off Amount],
	   temp.credited_amount as [Credited Amount],
	   temp.invoice_no as [Invoice No],
	   temp.invoice_date as [Invoice Date],
	   temp.charge_date as [Charge Date],
	   temp.item_code as [Item Code],
	   temp.item_desc as [Item Description],
	   temp.period_id,
	   temp.HN,
	   temp.patient_name as [Patient Name],
	   temp.validated_datetime as [Validated Datetime],
	   temp.gl_acct_code_code as [GL Account Code],
	   temp.gl_acct_name as [GL Account Name]
	   ,temp.ar_invoice_detail_id
from
(
SELECT
	DISTINCT ppdh.ar_invoice_detail_id,
	PPDH.period_id
	,c.department_name_l
	,PPDH.employee_nr
	--,title = (SELECT title FROM doctor WHERE employee_nr = PPDH.employee_nr)
	,c.caregiver_name
	,PPDH.tax_rate as w_tax
    ,bank = ppdh.bank_name
	,PPDH.bank_account_no
	,PPDH.gross_amount AS gross_amount
	,PPDH.net_amount AS split_net_amount
	,PPDH.tax_amount AS tax_amount
	,PPDH.merchant_discount AS mer_disc
	,PPDH.adjustment_amount
	--,writeoff_amt = isnull((SELECT sum(temp.adjustment_amount)
	--						from (
	--						SELECT case when debit_flag = 1  then adjustment_amount * -1 else adjustment_amount end as adjustment_amount,
	--								employee_nr,
	--								period_id
	--						from direct_adjustments
	--						where employee_nr = ppdh.employee_nr
	--							and period_id = ppdh.period_id
	--						) as temp),'')
	,PPDH.credited_amount as credited_amount  -- (CASE WHEN (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) IS NULL THEN 0 ELSE (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) END) AS credited_amount
	,ar.transaction_text as invoice_no
	,ar.transaction_date_time as invoice_date
	,ppdh.policy_group
	,ppdh.item_desc
	,s.credit_date_start as period_date
	,PPDH.hospital_number as HN
	,PPDH.pname as patient_name
	,i.item_code
	,ppdh.charge_date
	,validated_datetime = (Select top 1 updated_datetime from dbo.charge_audit_trail where charge_id = PPDH.charge_id order by updated_datetime desc)
	,gac.gl_acct_code_code
	,gac.name_l as gl_acct_name

FROM
	dbo.payment_period_details_history PPDH INNER JOIN	PayProcessMD.dbo.caregiver_view c ON c.employee_nr = PPDH.employee_nr
										   INNER join dbo.ar_invoice_details ard on ppdh.ar_invoice_detail_id = ard.ar_invoice_detail_id
										   INNER join dbo.ar_invoices ar on ard.ar_invoice_id = ar.ar_invoice_id
										   inner JOIN payment_period pp on ppdh.period_id = pp.period_id
										   inner join dbo.schedule s on pp.schedule_id = s.schedule_id
										   INNER join PayProcessMD.dbo.items i on ard.item_id = i.item_id
										   INNER join PayProcessMD.dbo.gl_acct_code gac on ard.gl_acct_code_Credit_id = gac.gl_acct_code_id

where CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'12/01/2019',101) as SMALLDATETIME) 
   and CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME)  <= CAST(CONVERT(VARCHAR(10),'12/31/2019',101) as SMALLDATETIME) 
   and PPDH.policy_group <> 'Manual Entry'
) as temp
UNION ALL
SELECT DISTINCT
	  -- sum(temp.credited_amount)
	   temp.period_date,
	   temp.employee_nr,
	   temp.caregiver_name as Caregiver,
	   temp.w_tax as [Tax Rate],
	   temp.gross_amount as [Gross Amount],
	   temp.adjustment_amount as [Adjustment Amount],
	   temp.split_net_amount as [Split Net Amount],
	   temp.tax_amount as [Tax Amount],
	   temp.mer_disc as [Merchant Discount],
	   --temp.writeoff_amt as [Write-off Amount],
	   temp.credited_amount as [Credited Amount],
	   temp.invoice_no as [Invoice No],
	   temp.invoice_date as [Invoice Date],
	   temp.charge_date as [Charge Date],
	   temp.item_code as [Item Code],
	   temp.item_desc as [Item Description],
	   temp.period_id,
	   temp.HN,
	   temp.patient_name as [Patient Name],
	   temp.validated_datetime as [Validated Datetime],
	   temp.gl_acct_code_code as [GL Account Code],
	   temp.gl_acct_name as [GL Account Name]
	   ,temp.ar_invoice_detail_id
from
(
SELECT 
    DISTINCT PPDH.ar_invoice_detail_id,
	PPDH.period_id
	,c.department_name_l
	,PPDH.employee_nr
	--,title = (SELECT title FROM doctor WHERE employee_nr = PPDH.employee_nr)
	,c.caregiver_name
	,PPDH.tax_rate as w_tax
	,bank = ppdh.bank_name
	,PPDH.bank_account_no
	,PPDH.gross_amount AS gross_amount
	,PPDH.net_amount AS split_net_amount
	,PPDH.tax_amount AS tax_amount
	,PPDH.merchant_discount AS mer_disc
	,PPDH.adjustment_amount
	--,writeoff_amt = isnull((SELECT sum(temp.adjustment_amount)
	--						from (
	--						SELECT case when debit_flag = 1  then adjustment_amount * -1 else adjustment_amount end as adjustment_amount,
	--								employee_nr,
	--								period_id
	--						from direct_adjustments
	--						where employee_nr = ppdh.employee_nr
	--							and period_id = ppdh.period_id
	--						) as temp),'')
	,PPDH.credited_amount as credited_amount  -- (CASE WHEN (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) IS NULL THEN 0 ELSE (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) END) AS credited_amount
	,ar.transaction_text as invoice_no
	,ar.transaction_date_time as invoice_date
	,ppdh.policy_group
	,ppdh.item_desc
	,s.credit_date_start as period_date
	,PPDH.hospital_number as HN
	,PPDH.pname as patient_name
	,i.item_code
	,ppdh.charge_date
	,validated_datetime = (Select top 1 updated_datetime from dbo.charge_audit_trail where charge_id = PPDH.charge_id order by updated_datetime desc)
	,gac.gl_acct_code_code
	,gac.name_l as gl_acct_name

FROM
	dbo.payment_period_details_history PPDH INNER JOIN	PayProcessMD.dbo.caregiver_view c ON c.employee_nr = PPDH.employee_nr
										   left join dbo.ar_invoice_details ard on ppdh.ar_invoice_detail_id = ard.ar_invoice_detail_id
										   left join dbo.ar_invoices ar on ard.ar_invoice_id = ar.ar_invoice_id
										   left JOIN payment_period pp on ppdh.period_id = pp.period_id
										   left join dbo.schedule s on pp.schedule_id = s.schedule_id
										   left join PayProcessMD.dbo.items i on ard.item_id = i.item_id
										   inner join manual_entries me on ppdh.manual_entry_id = me.manual_entry_id
										   LEFT outer join gl_acct_code gac on me.gl_account_id = gac.gl_acct_code_id

where CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'12/01/2019',101) as SMALLDATETIME) 
   and CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME)  <= CAST(CONVERT(VARCHAR(10),'12/31/2019',101) as SMALLDATETIME) 
--where pp.period_id = 502
   and PPDH.policy_group = 'Manual Entry'
) as temp
   ) as tempb
   --where tempb.employee_nr = '10417'
   --where tempb.[Invoice No] = 'PINV-2019-295470'
order by tempb.period_id,[Employee NR]


