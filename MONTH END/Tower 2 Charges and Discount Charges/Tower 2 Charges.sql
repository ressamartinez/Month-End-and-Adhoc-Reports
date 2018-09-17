SELECT
	visit_code [Visit Code]
	,upi [Patient Hn]
	,lname [Last Name]
	,fname [First Name]
	,CONVERT(DATE,charge_date) [Charge Date]
	,item_group_name [Item Group Name]
	,item_group_code [Item Group Code]	
	,item_desc [Item Name]
	,SUM(CV.quantity) [Quantity]
	,SUM(total_amt) [Total Amount]
	,visit_type [Visit Type]
	,visit_type_after_move [Visit Type After Move]
	,gl_acct_code_code [GL Account Code]
	,BEIV1.ward_code
	,BEIV1.ipd_room_class_rcd
	,BEIV1.ward_name_l
FROM
	HISViews.dbo.GEN_vw_charges_view CV
	INNER JOIN(
				SELECT
					 BEIV.ipd_room_id
					,BEIV.ipd_room_class_rcd
					,BEIV.ipd_room_code
					,BEIV.bed_id
					,BEIV.bed_code
					,BEIV.bed_type_rcd
					,BEIV.start_date_time
					,BEIV.cancelled_date_time
					,BEIV.ward_code
					,BEIV.ward_id
					,BEIV.ward_name_l
					,BEIV.planned_end_date_time
					,BEIV.active_flag
					,BEIV.in_census_flag
					,BEIV.patient_id
					,BEIV.patient_visit_id
				FROM 
					AmalgaPROD.dbo.bed_entry_info_view BEIV
					INNER JOIN AmalgaPROD.dbo.area_floor_building_view AFBV ON BEIV.bed_code = AFBV.area_code
				WHERE (
				month(BEIV.start_date_time) = @Month and
				year(BEIV.start_date_time) = @Year
				)
					  AND AFBV.building_code='B2'
					)BEIV1 ON CV.patient_id = BEIV1.patient_id		
WHERE
	delete_date IS NULL
	AND
	(
	MONTH(charge_date) = @Month
	and
	YEAR(charge_date) = @Year
	)
GROUP BY
	item_group_code
	,item_group_name
	,item_desc
	,CONVERT(DATE,charge_date)
	,upi,visit_code
	,lname
	,fname
	,visit_type
	,visit_type_after_move
	,gl_acct_code_code
	,BEIV1.ward_code
	,BEIV1.ipd_room_class_rcd
	,BEIV1.ward_name_l
ORDER BY 
	upi,visit_code,CONVERT(DATE,charge_date)