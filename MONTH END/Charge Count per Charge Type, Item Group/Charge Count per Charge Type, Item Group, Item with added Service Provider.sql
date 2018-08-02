--6985 / 7243 / 7242
SELECT
	b.charge_type_rcd,
	main_item_group = (SELECT
										name_l
										FROM AmalgaPROD.dbo.item_group_nl_view
										WHERE item_group_id = (SELECT
																					parent_item_group_id
																					FROM AmalgaPROD.dbo.item_group_nl_view
																					WHERE item_group_id = c.item_group_id)),
	item_group = (SELECT
								name_l
							FROM AmalgaPROD.dbo.item_group_nl_view
							WHERE item_group_id = c.item_group_id),
	c.item_code,
	c.name_l AS item_desc,
	SUM(a.quantity) AS qty
	--,cc.name_l
	--,(SELECT
	--				name_l
	--				FROM AmalgaPRODdbo.swe_payment_status_ref
	--				WHERE swe_payment_status_rcd = a.payment_status_rcd) as payment_status
	--,(SELECT
	--				name_l
	--				FROM AmalgaPRODdbo.item_type_ref
	--				WHERE item_type_rcd = c.item_type_rcd) as item_type
	,(SELECT DISTINCT name_l from costcentre where costcentre_id = a.service_provider_costcentre_id) as service_provider

FROM	AmalgaPROD.dbo.charge_detail_nl_view a,
			AmalgaPROD.dbo.patient_visit_nl_view b,
			AmalgaPROD.dbo.item_nl_view c
			--LEFT JOIN AmalgaPRODdbo.item_group_costcentre igc on c.item_group_id = igc.item_group_id 
			--LEFT JOIN AmalgaPRODdbo.costcentre cc on igc.costcentre_id = cc.costcentre_id

WHERE a.patient_visit_id = b.patient_visit_id
AND a.item_id = c.item_id
AND (
		MONTH(a.charged_date_time) = 05
		AND YEAR(a.charged_date_time) = 2018
		)
AND a.deleted_date_time IS NULL
AND a.patient_visit_package_id IS NULL


GROUP BY	b.charge_type_rcd,
					c.item_group_id,
					c.item_code,
					c.name_l 
					--,cc.name_l
					,a.service_provider_costcentre_id
					--,a.payment_status_rcd
					--,c.item_type_rcd
					
					UNION 
					
SELECT
	b.charge_type_rcd,
	main_item_group = (SELECT
										name_l
										FROM AmalgaPROD.dbo.item_group_nl_view
										WHERE item_group_id = (SELECT
																					parent_item_group_id
																					FROM AmalgaPROD.dbo.item_group_nl_view
																					WHERE item_group_id = a.service_provider_costcentre_id)),
	item_group = (SELECT
								name_l
							FROM AmalgaPROD.dbo.item_group_nl_view
							WHERE item_group_id = c.item_group_id),
	c.item_code,
	c.name_l AS item_desc,
	SUM(a.quantity) AS qty
	--,costcentre = (SELECT
	--				name_l
	--				FROM AmalgaPRODdbo.costcentre
	--				WHERE costcentre_id = (SELECT
	--																item_group_id
	--																FROM AmalgaPRODdbo.item_group_costcentre
	--																WHERE item_group_id = c.item_group_id))
	--,(SELECT
	--				name_l
	--				FROM AmalgaPRODdbo.swe_payment_status_ref
	--				WHERE swe_payment_status_rcd = a.payment_status_rcd) as payment_status
	--,(SELECT
	--				name_l
	--				FROM AmalgaPRODdbo.item_type_ref
	--				WHERE item_type_rcd = c.item_type_rcd) as item_type
	,(SELECT DISTINCT name_l from costcentre where costcentre_id = a.service_provider_costcentre_id) as service_provider

FROM	AmalgaPROD.dbo.charge_detail_nl_view a,
			AmalgaPROD.dbo.patient_visit_nl_view b,
			AmalgaPROD.dbo.item_nl_view c
			--LEFT JOIN AmalgaPRODdbo.item_group_costcentre igc on c.item_group_id = igc.item_group_id 
			--LEFT JOIN AmalgaPRODdbo.costcentre cc on igc.costcentre_id = cc.costcentre_id

WHERE a.patient_visit_id = b.patient_visit_id
AND a.item_id = c.item_id
AND (
		MONTH(a.charged_date_time) = 05
		AND YEAR(a.charged_date_time) = 2018
		)
AND a.deleted_date_time IS NULL
AND patient_visit_package_id IS NOT NULL
AND parent_charge_detail_id IS NULL

GROUP BY	b.charge_type_rcd,
			c.item_group_id,
			c.item_code,
			c.name_l
			,a.service_provider_costcentre_id
			--,a.payment_status_rcd
			--,c.item_type_rcd
