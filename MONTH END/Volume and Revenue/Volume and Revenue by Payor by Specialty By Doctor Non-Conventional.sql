SELECT DISTINCT
	'Non Conventional'
	,CCS.year_id
	,CCS.month_id
	,CCS.charge_type_rcd
	,CCS.specialty
	,employee_nr = (SELECT employee_nr FROM OrionSnapshotDaily.dbo.employee E where E.employee_id = CCS.employee_id )
	,employee = (SELECT display_name_l FROM OrionSnapshotDaily.dbo.employee_formatted_name_iview WHERE person_id = CCS.employee_id)
	,COUNT(CCS.ar_invoice_id) as Invoice_Count
	,SUM(CCS.gross_amount) as Invoice_Amount
	,SUM(CCS.discount_amount) as Discount_Amount
FROM	
	HISReport.dbo.rpt_cpr_charge_summary_2 CCS
WHERE
	CCS.month_id = @Month
AND
	CCS.year_id = @Year
AND
	CCS.rpt_type = 'NC'
GROUP BY
	CCS.rpt_type 
	,CCS.year_id
	,CCS.month_id
	,CCS.charge_type_rcd
	,CCS.specialty
	,CCS.employee_id
ORDER BY
	 CCS.year_id	
	,CCS.month_id
	,CCS.charge_type_rcd
	,CCS.specialty