
SELECT 
	   temp.department as Department,
	   temp.specialty_name_l as [Specialty],
	   temp.sub_specialty_name_l as [Subspecialty],
	   temp.employee_nr as [Employee NR],
	   RTRIM(temp.last_name_l) + ', ' + RTRIM(temp.first_name_l) as Caregiver,
	   temp.invoice_date as [Invoice Date],
	   temp.charge_date as [Charge Date],
	   temp.item_code as [Item Code],
	   temp.item_desc as [Item Description],
	   temp.HN,
	   temp.patient_name as [Patient Name]
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
	--,PPDH.tax_rate as w_tax
	--,bank = (SELECT DISTINCT CASE WHEN account_id IS NOT NULL THEN (SELECT bank_name FROM bank WHERE bank_id = (SELECT bank_id FROM doctor_account WHERE account_id = (SELECT DISTINCT account_id from payment_period_detail_history WHERE employee_nr = PPDH.employee_nr AND period_id = PPDH.period_id))) ELSE 'N/A' END from payment_period_detail_history WHERE employee_nr = PPDH.employee_nr AND period_id = PPDH.period_id)
	--,PPDH.bank_account_no
	--,PPDH.split_gross_amount AS net_amount
	--,PPDH.split_net_amount AS split_amount
	--,PPDH.split_tax_amount AS tax_amount
	--,PPDH.split_merchant_discount AS mer_disc
	--,PPDH.adjustment_amount
	--,(CASE WHEN (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) IS NULL THEN 0 ELSE (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) END) AS writeoff_amt
	--,PPDH.split_credited_amount as credited_amount  -- (CASE WHEN (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) IS NULL THEN 0 ELSE (SELECT due_amount FROM df_view_writeoff WHERE period_id = PPDH.period_id AND employee_nr = PPDH.employee_nr) END) AS credited_amount
	--,arh.transaction_text as invoice_no
	,arh.transaction_date_time as invoice_date
	--,ppdh.policy_group
	,ppdh.item_desc
	--,pp.period_date
	,PPDH.upi as HN
	,PPDH.pname as patient_name
	,i.item_code
	,ppdh.charge_date
	,CAST(REPLACE(esv.parent_clinical_specialty_name_l, '&', 'and') as VARCHAR(500)) AS specialty_name_l
    ,CAST(REPLACE(esv.clinical_specialty_name_l, '&', 'and') as VARCHAR(500)) AS sub_specialty_name_l

FROM
	dbo.payment_period_detail_history PPDH INNER JOIN	dbo.doctor D ON D.employee_nr = PPDH.employee_nr
										   LEFT outer JOIN ar_invoice_detail_head_history ardh on ppdh.ar_invoice_detail_id = ardh.ar_invoice_detail_id
										   LEFT outer JOIN ar_invoice_head arh on ardh.ar_invoice_id = arh.ar_invoice_id
										   inner JOIN payment_period pp on ppdh.period_id = pp.period_id
										   left outer join dbprod03.amalgaprod.dbo.item i on i.item_id = ardh.item_id
										   left outer join DBPROD03.AmalgaPROD.dbo.api_employee_specialty_view esv on esv.employee_nr = ppdh.employee_nr

--where PPDH.period_id >= 553 and PPDH.period_id <= 553
--where PPDH.period_id >= @periodFrom and PPDH.period_id <= @periodTo
where CAST(CONVERT(VARCHAR(10),pp.period_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'07/01/2018',101) as SMALLDATETIME) 
   and CAST(CONVERT(VARCHAR(10),pp.period_date,101) as SMALLDATETIME)  <= CAST(CONVERT(VARCHAR(10),'07/31/2018',101) as SMALLDATETIME) 
   and PPDH.policy_group <> 'Manual Entry'
) as temp