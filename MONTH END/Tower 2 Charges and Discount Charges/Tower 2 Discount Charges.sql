SELECT
	visit_code [Visit Code],
	upi [Patient HN],
	lname [Last Name],
	fname [First Name],
	CONVERT(DATE, charge_date) [Charge Date],
	item_group_code [Item Group Code],
	item_group_name [Item Group Name],
	item_desc [Item Name],
	SUM(CV.quantity) [Quantity],
	SUM(total_amt) [Total Amount],
	(SELECT
			name_l
		FROM AmalgaPROD.dbo.discount_posting_rule_nl_view
		WHERE discount_posting_rule_id = ARD.discount_posting_rule_id)
	[Discount Reason],
	SUM(discount_amount) [Discount Amount],
	MONTH(charge_date) [Month],
	visit_type [Visit Type],
	visit_type_after_move [Visit After Move],
	gl_acct_code_code [GL Account Code]

FROM HISViews.dbo.GEN_vw_charges_view CV
INNER JOIN AmalgaPROD.dbo.ar_invoice_detail_nl_view ARD
	ON ARD.charge_detail_id = CV.charge_detail_id
INNER JOIN (SELECT
		BEIV.ipd_room_id,
		BEIV.ipd_room_class_rcd,
		BEIV.ipd_room_code,
		BEIV.bed_id,
		BEIV.bed_code,
		BEIV.bed_type_rcd,
		BEIV.start_date_time,
		BEIV.cancelled_date_time,
		BEIV.ward_code,
		BEIV.ward_id,
		BEIV.ward_name_l,
		BEIV.planned_end_date_time,
		BEIV.active_flag,
		BEIV.in_census_flag,
		BEIV.patient_id,
		BEIV.patient_visit_id
	FROM AmalgaPROD.dbo.bed_entry_info_view BEIV
	INNER JOIN AmalgaPROD.dbo.area_floor_building_view AFBV
		ON BEIV.bed_code = AFBV.area_code
	WHERE (
	MONTH(BEIV.start_date_time) = @Month
	AND YEAR(BEIV.start_date_time) = @Year
	)
	AND AFBV.building_code = 'B2') BEIV1
	ON CV.patient_id = BEIV1.patient_id
WHERE delete_date IS NULL
AND (
MONTH(charge_date) = @Month
AND YEAR(charge_date) = @Year
)
AND ARD.discount_posting_rule_id IS NOT NULL
GROUP BY	item_group_code,
			item_group_name,
			item_desc,
			CONVERT(DATE, charge_date),
			upi,
			visit_code,
			lname,
			fname,
			visit_type,
			visit_type_after_move,
			gl_acct_code_code,
			ARD.discount_posting_rule_id,
			charge_date
ORDER BY upi, visit_code, CONVERT(DATE, charge_date)