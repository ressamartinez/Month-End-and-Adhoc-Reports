
Select s.name_l as [Store Name],
	   i.item_code as [Item Code],
       i.name_l as [Item Name],
	   ur.short_name_l as [UOM],
	   --i.uom_rcd as [UOM],
	   imtr.name_l as [Movement Type],
	   --im.movement_qty as [Qty],
	   (case when im.movement_qty > 0 then im.movement_qty else 0 end) as [Qty In],
	   (case when im.movement_qty < 0 then im.movement_qty else 0 end) as [Qty Out],
	   im.actual_cost as [Movement Cost],
	   im.qty_on_hand as [On Hand],
	   iml.lot_number as [Lot Number],
	   im.date_time as [Date/Time],
	   pfni.display_name_l as [User Name]
from item_movement im
		 left join item i on i.item_id = im.item_id 
		 left join store s on s.store_id = im.store_id
		 left join item_movement_lot iml on iml.item_movement_id = im.item_movement_id
		 left join user_account ua on ua.user_id = im.user_id
		 left join person_formatted_name_iview pfni on pfni.person_id = ua.person_id
		 left join item_movement_type_ref imtr on imtr.item_movement_type_rcd = im.item_movement_type_rcd
		 left join uom_ref ur on ur.uom_rcd = i.uom_rcd
where im.store_id in (@store_id)
----im.item_id = 'C6D4290D-64F4-42C5-9370-30EBB13C6574'
--	  im.store_id in ('3EAAEEE6-5714-11DA-BB34-000E0C7F3ED2',         --Pharmacy Compounding
--                      '08CD273C-19CE-11DA-A79E-001143B8816C')         --Central Warehouse
	  and year(im.date_time) = @Year
	  and month(im.date_time) BETWEEN @MonthFrom AND @MonthTo
	  --and year(im.date_time) = 2018
	  --and month(im.date_time) BETWEEN 1 AND 7
	  and imtr.item_movement_type_rcd IN ('ID', 'SDEL', 'S')  --movement type
order by [Item Name], [Date/Time]