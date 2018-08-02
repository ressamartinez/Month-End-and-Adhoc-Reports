SELECT temp_table.item_code as [Item Code]
	   ,temp_table.[Item Description]
	   ,temp_table.[Generic Name]
	   ,temp_table.[Item Group]
	   ,temp_table.item_group_code as [Group Code]
	   ,temp_table.uom_rcd as [Unit of Measure]
	   ,temp_table.conversion_factor as [Conversion Factor]
	   ,temp_table.[Inventory UOM]
	   ,temp_table.vendor_name as Vendor
	   ,temp_table.vendor_code as [Vendor Code]
	   ,temp_table.[Item Type]

FROM
(
	SELECT --COUNT(svi.vendor_item_id), i.name_l, v.vendor_code, svi.vendor_item_id

			i.item_id
		   ,svi.vendor_id
		   ,svi.vendor_item_id
		   ,ig.item_group_id
		   ,i.name_l as [Item Description]
		   ,i.item_code
		   ,ig.item_group_code
		   ,ig.name_l as [Item Group]
		   ,i.uom_rcd
		   ,i.item_type_rcd
		   ,itr.name_l as [Item Type]
		   ,sviu.conversion_factor
		   ,sviu.uom_rcd as [Inventory UOM]
		   ,svi.brand_name_l as [Generic Name]
		   ,v.vendor_code
		   ,vendor_name = (CASE WHEN v.person_id IS NOT NULL then 
						  (select display_name_l from person_formatted_name_iview where person_id = v.person_id)
						  else (SELECT name_l from organisation WHERE organisation_id = v.organisation_id)
						  END)


	FROM inventory_item ii
	INNER JOIN item i ON ii.item_id = i.item_id
	inner JOIN item_group ig ON i.item_group_id = ig.item_group_id
	INNER JOIN  swe_vendor_item svi on i.item_id = svi.item_id
	INNER JOIN swe_vendor_item_uom sviu ON svi.vendor_item_id = sviu.vendor_item_id
	INNER JOIN vendor v on svi.vendor_id = v.vendor_id
	INNER JOIN item_type_ref itr on i.item_type_rcd = itr.item_type_rcd

	WHERE i.active_flag = 1 
		  AND i.item_type_rcd = 'INV' 
		  and svi.active_flag = 1
		  AND sviu.active_flag = 1
		  --AND svi.vendor_item_id = '170BCD0F-856F-11DE-AFBF-000E0C7F3ED2'
		and v.vendor_id IN (@vendor_id)
		--and ig.item_group_code IN (@item_group_code)

	
) as temp_table
order by temp_table.[Item Description]