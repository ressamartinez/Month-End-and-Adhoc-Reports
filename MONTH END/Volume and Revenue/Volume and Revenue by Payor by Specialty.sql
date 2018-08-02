SELECT DISTINCT
	rpt_type
	,year_id
	,month_id
	,charge_type_rcd
	,policy_id
	,policy
	,specialty
	,COUNT(ar_invoice_id) AS [count]
	,SUM(gross_amount) AS [gross_amount]
	,SUM(discount_amount) AS [discount_amount]
INTO
	#temp_volume_and_revenue_by_payor_by_specialty
FROM	
	HISReport.dbo.rpt_cpr_charge_summary_2
WHERE
	month_id = @Month
AND
	year_id = @Year
AND
	rpt_type = 'C'
GROUP BY
	rpt_type 
	,year_id
	,month_id
	,charge_type_rcd
	,policy
	,specialty
	,policy_id
ORDER BY
	rpt_type
	,year_id	
	,month_id
	,charge_type_rcd
	,policy
	,specialty
	
SELECT
	'Conventional'
	,year_id
	,month_id
	,charge_type_rcd
	,policy_id
	,policy
	,specialty
	,[count]
	,[gross_amount]
	,[discount_amount]
FROM
	#temp_volume_and_revenue_by_payor_by_specialty