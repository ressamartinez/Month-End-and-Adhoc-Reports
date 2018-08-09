--CHARGE COUNT PER CHARGE TYPE, ITEM GROUP, ITEM with added SERVICE PROVIDER

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
	,(SELECT DISTINCT name_l from costcentre where costcentre_id = a.service_provider_costcentre_id) as service_provider

FROM	AmalgaPROD.dbo.charge_detail_nl_view a,
			AmalgaPROD.dbo.patient_visit_nl_view b,
			AmalgaPROD.dbo.item_nl_view c

WHERE a.patient_visit_id = b.patient_visit_id
AND a.item_id = c.item_id
AND (
		MONTH(a.charged_date_time) = @Month
		AND YEAR(a.charged_date_time) = @Year
		)
AND a.deleted_date_time IS NULL
AND a.patient_visit_package_id IS NULL


GROUP BY	b.charge_type_rcd,
					c.item_group_id,
					c.item_code,
					c.name_l 
					,a.service_provider_costcentre_id

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
	,(SELECT DISTINCT name_l from costcentre where costcentre_id = a.service_provider_costcentre_id) as service_provider

FROM	AmalgaPROD.dbo.charge_detail_nl_view a,
			AmalgaPROD.dbo.patient_visit_nl_view b,
			AmalgaPROD.dbo.item_nl_view c

WHERE a.patient_visit_id = b.patient_visit_id
AND a.item_id = c.item_id
AND (
		MONTH(a.charged_date_time) = @Month
		AND YEAR(a.charged_date_time) = @Year
		)
AND a.deleted_date_time IS NULL
AND patient_visit_package_id IS NOT NULL
AND parent_charge_detail_id IS NULL

GROUP BY	b.charge_type_rcd,
			c.item_group_id,
			c.item_code,
			c.name_l
			,a.service_provider_costcentre_id
