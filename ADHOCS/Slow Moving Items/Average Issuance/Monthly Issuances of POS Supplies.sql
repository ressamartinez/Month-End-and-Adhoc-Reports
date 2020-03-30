
DECLARE @Year int

SET @Year =  2019


select temp.[Item Code]
	   ,temp.[Item Description]
	   ,temp.UOM
	   ,temp.[Min Qty]
	   ,temp.[Max Qty]
	   ,temp.Target
	   ,temp.[Reorder Point]
	   ,temp.[Replenishment Type]
	   ,temp.Jan
	   ,temp.Feb
	   ,temp.Mar
	   ,temp.Apr
	   ,temp.May
	   ,temp.Jun
	   ,temp.Jul
	   ,temp.Aug
	   ,temp.Sept
	   ,temp.Oct
	   ,temp.Nov
	   ,temp.Dec
	   ,Total = (temp.jan + temp.feb + temp.mar + temp.apr + temp.may + temp.jun + temp.jul + temp.aug + temp.sept + temp.oct + temp.nov + temp.dec)

from (

		select si.item_id
			   ,i.item_code as [Item Code]
			   ,i.name_l as [Item Description]
			   ,i.uom_rcd as UOM
			   ,si.min_qty as [Min Qty]
			   ,si.max_qty as [Max Qty]
			   ,si.target_qty as Target
			   ,si.reorder_point_qty as [Reorder Point]
			   ,rtr.name_l as [Replenishment Type]
			   ,si.store_id
			   ,s.name_l as Store
			   ,Jan = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 1), 0)
			   ,Feb = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 2),0)
			   ,Mar = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 3), 0)
			   ,Apr = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 4), 0)
			   ,May = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 5), 0)
			   ,Jun = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 6), 0)
			   ,Jul = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 7), 0)
			   ,Aug = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 8), 0)
			   ,Sept = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 9), 0)
			   ,Oct = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 10), 0)
			   ,Nov = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 11), 0)
			   ,Dec = isnull((select sum(sale) - sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 12), 0)


		from store_item si  left join item i on si.item_id = i.item_id
		                    left join item_group ig on i.item_group_id = ig.item_group_id
							left join store s on si.store_id = s.store_id
							left join replenishment_type_ref rtr on si.replenishment_type_rcd = rtr.replenishment_type_rcd
							  

		where i.active_flag = 1
			  and si.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'         --POS
			  and ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'    --OR Supplies - Exclusive
			  and s.active_flag = 1
			  --and im.date_time BETWEEN @From and @To
			  --and i.item_code = '588-0005'
			  and si.replenishment_type_rcd in ('O', 'N')
		
		group by si.item_id, 
			     i.item_code,
			     i.name_l,
				 i.uom_rcd,
				 si.store_id,
				 s.name_l,
				 si.min_qty,
				 si.max_qty,
				 si.target_qty,
				 si.reorder_point_qty,
				 rtr.name_l

)as temp
--where [Item Code] = '212024147'
order by temp.[Item Code]