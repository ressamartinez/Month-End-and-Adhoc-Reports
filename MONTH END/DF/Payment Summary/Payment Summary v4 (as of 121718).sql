SELECT tempb.period_date as [Period Date],	
	   tempb.employee_nr as [Employee NR],
	   tempb.Caregiver as [Caregiver Name],
       tempb.[Tax Rate],
	   tempb.[Net Amount],
	   tempb.[Adjustment Amount],
	   tempb.[Split Amount],
	   tempb.[Tax Amount],
	   tempb.[Merchant Discount],
	   tempb.[Write-off Amount],
	   tempb.[Credited Amount],
	   tempb.[Invoice No],
	   tempb.[Invoice Date],
	   tempb.[Charge Date],
	   tempb.[Item Code],
	   tempb.[Item Description],
	   tempb.HN,
	   tempb.patient_name as [Patient Name]
from
(
SELECT 
	  -- sum(temp.credited_amount)
	   temp.period_date,
	   temp.employee_nr,
	   RTRIM(temp.last_name_l) + ', ' + RTRIM(temp.first_name_l) as Caregiver,
	   temp.w_tax as [Tax Rate],
	   temp.net_amount as [Net Amount],
	   temp.adjustment_amount as [Adjustment Amount],
	   temp.split_amount as [Split Amount],
	   temp.tax_amount as [Tax Amount],
	   temp.mer_disc as [Merchant Discount],
	   temp.writeoff_amt as [Write-off Amount],
	   temp.credited_amount as [Credited Amount],
	   temp.invoice_no as [Invoice No],
	   temp.invoice_date as [Invoice Date],
	   temp.charge_date as [Charge Date],
	   temp.item_code as [Item Code],
	   temp.item_desc as [Item Description],
	   temp.period_id,
	   temp.HN,
	   temp.patient_name
from
(
SELECT
	DISTINCT ardh.ar_invoice_detail_id,
	PPDH.period_id
	,department = (SELECT department_l from doctor WHERE employee_nr = PPDH.employee_nr)
	,PPDH.employee_nr
	,title = (SELECT title FROM doctor WHERE employee_nr = PPDH.employee_nr)
	,D.last_name_l
	,D.first_name_l
	,D.middle_name_l
	,PPDH.tax_rate as w_tax
	,bank = (SELECT DISTINCT CASE WHEN account_id IS NOT NULL THEN (SELECT bank_name FROM bank WHERE bank_id = (SELECT bank_id FROM doctor_account WHERE account_id = (SELECT DISTINCT account_id from payment_period_detail_history WHERE employee_nr = PPDH.employee_nr AND period_id = PPDH.period_id))) ELSE 'N/A' END from payment_period_detail_history WHERE employee_nr = PPDH.employee_nr AND period_id = PPDH.period_id)
	,PPDH.bank_account_no
	,PPDH.split_gross_amount AS net_amount
	,PPDH.split_net_amount AS split_amount
	,PPDH.split_tax_amount AS tax_amount
	,PPDH.split_merchant_discount AS mer_disc
	,PPDH.adjustment_amount
	,(CASE WHEN (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) IS NULL THEN 0 ELSE (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) END) AS writeoff_amt
	,PPDH.split_credited_amount as credited_amount  -- (CASE WHEN (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) IS NULL THEN 0 ELSE (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) END) AS credited_amount
	,arh.transaction_text as invoice_no
	,arh.transaction_date_time as invoice_date
	,ppdh.policy_group
	,ppdh.item_desc
	,pp.period_date
	,PPDH.upi as HN
	,PPDH.pname as patient_name
	,i.item_code
	,ppdh.charge_date
FROM
	dbo.payment_period_detail_history PPDH INNER JOIN	dbo.doctor D ON D.employee_nr = PPDH.employee_nr
										   LEFT outer JOIN ar_invoice_detail_head_history ardh on ppdh.ar_invoice_detail_id = ardh.ar_invoice_detail_id
										   LEFT outer JOIN ar_invoice_head arh on ardh.ar_invoice_id = arh.ar_invoice_id
										   inner JOIN payment_period pp on ppdh.period_id = pp.period_id
										   left outer join dbprod03.amalgaprod.dbo.item i on i.item_id = ardh.item_id

--where PPDH.period_id >= 553 and PPDH.period_id <= 553
--where PPDH.period_id >= @periodFrom and PPDH.period_id <= @periodTo
where CAST(CONVERT(VARCHAR(10),pp.period_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/25/2019',101) as SMALLDATETIME) 
   and CAST(CONVERT(VARCHAR(10),pp.period_date,101) as SMALLDATETIME)  <= CAST(CONVERT(VARCHAR(10),'01/25/2019',101) as SMALLDATETIME) 
   and PPDH.policy_group <> 'Manual Entry'
) as temp
where temp.bank = 'BPI'
UNION ALL
SELECT 
	  -- sum(temp.credited_amount)
	   temp.period_date,
	   temp.employee_nr,
	   RTRIM(temp.last_name_l) + ', ' + RTRIM(temp.first_name_l) as Caregiver,
	   temp.w_tax as [Tax Rate],
	   temp.net_amount as [Net Amount],
	   temp.adjustment_amount as [Adjustment Amount],
	   temp.split_amount as [Split Amount],
	   temp.tax_amount as [Tax Amount],
	   temp.mer_disc as [Merchant Discount],
	   temp.writeoff_amt as [Write-off Amount],
	   temp.credited_amount as [Credited Amount],
	   temp.invoice_no as [Invoice No],
	   temp.invoice_date as [Invoice Date],
	   temp.charge_date as [Charge Date],
	   temp.item_code as [Item Code],
	   temp.item_desc as [Item Description],
	   temp.period_id,
	   temp.HN,
	   temp.patient_name
from
(
SELECT
    PPDH.ar_invoice_detail_id,
	PPDH.period_id
	,department = (SELECT department_l from doctor WHERE employee_nr = PPDH.employee_nr)
	,PPDH.employee_nr
	,title = (SELECT title FROM doctor WHERE employee_nr = PPDH.employee_nr)
	,D.last_name_l
	,D.first_name_l
	,D.middle_name_l
	,PPDH.tax_rate as w_tax
	,bank = (SELECT DISTINCT CASE WHEN account_id IS NOT NULL THEN (SELECT bank_name FROM bank WHERE bank_id = (SELECT bank_id FROM doctor_account WHERE account_id = (SELECT DISTINCT account_id from payment_period_detail_history WHERE employee_nr = PPDH.employee_nr AND period_id = PPDH.period_id))) ELSE 'N/A' END from payment_period_detail_history WHERE employee_nr = PPDH.employee_nr AND period_id = PPDH.period_id)
	,PPDH.bank_account_no
	,PPDH.split_gross_amount AS net_amount
	,PPDH.split_net_amount AS split_amount
	,PPDH.split_tax_amount AS tax_amount
	,PPDH.split_merchant_discount AS mer_disc
	,PPDH.adjustment_amount
	,(CASE WHEN (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) IS NULL THEN 0 ELSE (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) END) AS writeoff_amt
	,PPDH.split_credited_amount as credited_amount  -- (CASE WHEN (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) IS NULL THEN 0 ELSE (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) END) AS credited_amount
	,arh.transaction_text as invoice_no
	,arh.transaction_date_time as invoice_date
	,ppdh.policy_group
	,ppdh.item_desc
	,pp.period_date
	,PPDH.upi as HN
	,PPDH.pname as patient_name
	,i.item_code
	,ppdh.charge_date
FROM
	dbo.payment_period_detail_history PPDH INNER JOIN	dbo.doctor D ON D.employee_nr = PPDH.employee_nr
										   LEFT outer JOIN ar_invoice_detail_head_history ardh on ppdh.ar_invoice_detail_id = ardh.ar_invoice_detail_id
										   LEFT outer JOIN ar_invoice_head arh on ardh.ar_invoice_id = arh.ar_invoice_id
										   inner JOIN payment_period pp on ppdh.period_id = pp.period_id
										   left outer join dbprod03.amalgaprod.dbo.item i on i.item_id = ardh.item_id

--where PPDH.period_id >= 553 and PPDH.period_id <= 553
--where PPDH.period_id >= @periodFrom and PPDH.period_id <= @periodTo
where CAST(CONVERT(VARCHAR(10),pp.period_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/25/2019',101) as SMALLDATETIME) 
   and CAST(CONVERT(VARCHAR(10),pp.period_date,101) as SMALLDATETIME)  <= CAST(CONVERT(VARCHAR(10),'01/25/2019',101) as SMALLDATETIME) 
--where pp.period_id = 502
   and PPDH.policy_group = 'Manual Entry'
) as temp
where temp.bank = 'BPI'
   ) as tempb
order by tempb.period_id,[Employee NR]

/*
SELECT period_id,
	   sum(due_amount)
from df_view_writeoff
where period_id >= 537 and period_id <= 526
group by period_id
order by period_id
*/

/*
SELECT period_id,
	   CONVERT(varchar(10),period_date,101) as period_date
FROM payment_period
where period_id >= 537 and period_id <= 536
order by period_id
*/

