SELECT DISTINCT
	rpt_type
	,year_id
	,month_id
	,charge_type_rcd
	,policy_id
	,ISNULL(policy,' No Policy') as policy
	,specialty
	,employee_id
	,employee_nr = (SELECT employee_nr FROM orionsnapshotdaily.dbo.employee_formatted_name_iview WHERE person_id = HISReport.dbo.rpt_cpr_charge_summary_2.employee_id)
	,employee = (SELECT display_name_l FROM orionsnapshotdaily.dbo.employee_formatted_name_iview WHERE person_id = HISReport.dbo.rpt_cpr_charge_summary_2.employee_id)
	,COUNT(ar_invoice_id) AS [count]
	,SUM(gross_amount) AS [gross_amt]
	,SUM(discount_amount) AS [discount_amt]
INTO
	#temp_volume_and_revenue_by_payor_by_specialty_by_doctor
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
	,policy_id
	,policy
	,specialty
	,employee_id
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
	,policy
	,specialty
	,employee_nr 
	,employee
	,[count]
	,[gross_amt]
	,[discount_amt]
FROM
	#temp_volume_and_revenue_by_payor_by_specialty_by_doctor