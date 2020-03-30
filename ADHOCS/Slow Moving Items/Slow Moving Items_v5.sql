
DECLARE @From datetime
DECLARE @To datetime

SET @From =  '01/01/2019 00:00:00.000'
SET @To =  '12/31/2019 23:59:59.998'

select temp.item_code
	   ,temp.item_desc
	   ,temp.qty_on_hand
	   ,temp.last_movement_type
	   ,temp.average_unit_cost
	   ,total = temp.qty_on_hand * temp.average_unit_cost
	   ,temp.count_movement

from (

		select im.item_id
			   ,i.item_code
			   ,i.name_l as item_desc
			   ,qty_on_hand = (select top 1 _im.qty_on_hand
							from item_movement _im 
							where _im.item_id = im.item_id 
							and _im.store_id = si.store_id
							and _im.date_time BETWEEN @From and @To
							order by _im.date_time desc)
			   ,last_movement_type = (select top 1 _imt.name_l as movement 
							from item_movement _im left join item_movement_type_ref _imt on _im.item_movement_type_rcd = _imt.item_movement_type_rcd
							where _im.item_id = im.item_id 
							and _im.store_id = si.store_id
							and _im.item_movement_type_rcd in ('IS', 'ID')   --Issue to store, Issue to department
							and _im.date_time BETWEEN @From and @To
							order by _im.date_time desc)
			   ,average_unit_cost = (Select top 1 average_unit_cost
							from inventory_summary_day _spo 
							where _spo.item_id = im.item_id
							and _spo.store_id = si.store_id
							and _spo.date_time BETWEEN @From and @To
							order by date_time desc)
			   ,count_movement = (select count(_im.date_time) 
							from item_movement _im
							where _im.item_id = im.item_id 
							and _im.store_id = si.store_id
							and _im.item_movement_type_rcd in ('IS', 'ID')   --Issue to store, Issue to department
							and _im.date_time BETWEEN @From and @To)

		from item_movement im left join item i on im.item_id = i.item_id
							  left join item_group ig on i.item_group_id = ig.item_group_id
							  left join store_item si on im.item_id = si.item_id
							  left join store s on si.store_id = s.store_id
							  

		where i.active_flag = 1
		      and si.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'        --Central Warehouse
			  and im.date_time BETWEEN @From and @To
			  --and i.item_code = '588-107'
		
		group by im.item_id, 
				 ig.name_l,
			     i.item_code,
			     i.name_l,
				 si.store_id

)as temp
order by temp.item_code