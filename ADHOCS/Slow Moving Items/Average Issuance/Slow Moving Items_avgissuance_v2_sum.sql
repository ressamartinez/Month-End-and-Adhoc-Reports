
DECLARE @From datetime
DECLARE @To datetime

SET @From =  '01/01/2019 00:00:00.000'
SET @To =  '12/31/2019 23:59:59.998'

select *
	   ,qty_on_hand_cost = temp.qty_on_hand * temp.average_unit_cost 

from (

		select im.item_id
		       ,ig.name_l as itemgroup_name
			   ,i.item_code
			   ,i.name_l as item_name
			   ,count_movement = (select count(_im.date_time) 
							from item_movement _im
							where _im.item_id = im.item_id 
							and _im.store_id = s.store_id
							and _im.item_movement_type_rcd = 'IS'   --Issue to store
							and _im.date_time BETWEEN @From and @To)
			   ,last_movement_date = (select top 1 _im.date_time
							from item_movement _im
							where _im.item_id = im.item_id 
							and _im.store_id = s.store_id
							and _im.date_time BETWEEN @From and @To
							order by _im.date_time desc)
			   ,last_movement_type = (select top 1 _imt.name_l as movement 
							from item_movement _im left join item_movement_type_ref _imt on _im.item_movement_type_rcd = _imt.item_movement_type_rcd
							where _im.item_id = im.item_id 
							and _im.store_id = s.store_id
							and _im.item_movement_type_rcd = 'IS'   --Issue to store
							and _im.date_time BETWEEN @From and @To
							order by _im.date_time desc)
			   ,last_movement_qty = (select top 1 _im.movement_qty
							from item_movement _im 
							where _im.item_id = im.item_id 
							and _im.store_id = s.store_id
							and _im.date_time BETWEEN @From and @To
							order by _im.date_time desc)
				,qty_on_hand = (select top 1 _im.qty_on_hand
							from item_movement _im 
							where _im.item_id = im.item_id 
							and _im.store_id = s.store_id
							and _im.date_time BETWEEN @From and @To
							order by _im.date_time desc)
			   ,average_unit_cost = (Select top 1 average_unit_cost
							from inventory_summary_day _spo 
							where _spo.item_id = im.item_id
							and _spo.store_id = s.store_id
							and _spo.date_time BETWEEN @From and @To
							order by date_time desc)

		from item_movement im left join item i on im.item_id = i.item_id
							  left join item_group ig on i.item_group_id = ig.item_group_id
							  left join store s on im.store_id = s.store_id
							  

		where s.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'        --Central Warehouse
			  --and i.item_id = '9A8460D6-F76E-41F1-BD1E-5D058E4DF5ED'
			  and im.date_time BETWEEN @From and @To
			  --and i.item_code = '588-107'
		
		group by im.item_id, 
				 ig.name_l,
			     i.item_code,
			     i.name_l,
				 s.store_id

)as temp
where temp.count_movement <> 0
order by temp.item_name