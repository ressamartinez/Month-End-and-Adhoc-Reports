SELECT 'Conventional' as rpt_type,
	 MainTable.year_id,
	MainTable.month_id,
	MainTable.charge_type_rcd,
	ISNULL(MainTable.policy,'No policy') as policy,
	sum(MainTable.gross_amount) as gross_amount,
	sum(MainTable.discount_amount) as discount_amount,
	sum(MainTable.net_amount) as net_amount,
	(SELECT visible_patient_id
		FROM patient_hospital_usage
		WHERE patient_id = MainTable.patient_id)
	AS [Hospital_no],
	(SELECT display_name_l
		FROM person_formatted_name_iview
		WHERE person_id = MainTable.patient_id)
	AS [Patient_Name],
	MainTable.Transaction_Text,
	MainTable.visit_type,
	MainTable.transaction_day
FROM 
(
	SELECT
		RCCS.ar_invoice_id,
		rpt_type,
		year_id,
		month_id,
		charge_type_rcd,
		policy_id,
		policy,
		specialty,
		gross_amount,
		discount_amount,
		(SELECT TOP 1
				patient_id
			FROM patient_visit
			WHERE patient_visit_id = (SELECT TOP 1
											  patient_visit_id
										FROM charge_detail
										WHERE charge_detail_id = (SELECT TOP 1
																		charge_detail_id
																	FROM ar_invoice_detail
																	WHERE ar_invoice_id = RCCS.ar_invoice_id)))
		AS [patient_id],
		(SELECT TOP 1
				transaction_text
			FROM ar_invoice_nl_view
			WHERE ar_invoice_id = RCCS.ar_invoice_id)
		AS [Transaction_Text],
		(SELECT vt.name_l as visit_type
		from OrionSnapshotDaily.dbo.ar_invoice ar INNER JOIN OrionSnapshotDaily.dbo.visit_type_ref vt on ar.visit_type_rcd = vt.visit_type_rcd
		where ar_invoice_id = RCCS.ar_invoice_id) as visit_type,
		(SELECT DAY(transaction_date_time)
		from ar_invoice
		where ar_invoice_id = RCCS.ar_invoice_id) as transaction_day,
		RCCS.gross_amount - RCCS.discount_amount as net_amount
	FROM HISReport.dbo.rpt_cpr_charge_summary_2 RCCS
	WHERE month_id = @Month
		 and year_id = @Year
	AND rpt_type = 'C'
) AS MainTable
GROUP by MainTable.year_id,
	     MainTable.month_id,
		 MainTable.charge_type_rcd,
		 MainTable.policy,
		 MainTable.patient_id,
		 MainTable.Transaction_Text,
		 MainTable.visit_type,
		 MainTable.transaction_day
ORDER BY MainTable.policy