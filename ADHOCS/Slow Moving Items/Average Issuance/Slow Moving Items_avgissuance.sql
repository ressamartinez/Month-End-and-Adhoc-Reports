DECLARE @From datetime
DECLARE @To datetime

SET @From =  '02/01/2019 00:00:00.000'
SET @To =  '02/28/2019 23:59:59.998'

SELECT tempb.store,
       tempb.costcentre,
	   tempb.item_group_name,
	   tempb.item_code,
	   tempb.item_name,
	   tempb.qty_on_hand,
	   tempb.average_unit_cost,
	   tempb.cost,
	   tempb.last_movement_date,
	   tempb.movement_qty,
	   tempb.last_movement_type

from (

	select distinct *
					,cost = temp.qty_on_hand * temp.average_unit_cost     --final qty_on_hand_cost
    from (

			select ig.name_l as item_group_name,
				   i.item_id,
				   i.item_code,
				   i.name_l as item_name,
				   --si.last_order_date_time,
				   qty_on_hand = (Select top 1 qty_on_hand
							from inventory_summary_day _spo 
							where _spo.item_id = isd.item_id
							and _spo.store_id = s.store_id
							and _spo.date_time BETWEEN @From and @To
							order by date_time desc),
			      average_unit_cost = (Select top 1 average_unit_cost
							from inventory_summary_day _spo 
							where _spo.item_id = isd.item_id
							and _spo.store_id = s.store_id
							and _spo.date_time BETWEEN @From and @To 
							order by date_time desc),
			      qty_on_hand_cost = (Select top 1 qty_on_hand_cost
							from inventory_summary_day _spo 
							where _spo.item_id = isd.item_id
							and _spo.store_id = s.store_id
							and _spo.date_time BETWEEN @From and @To 
							order by date_time desc),
				   s.name_l as store,
				   --s.store_id,
				   c.name_l as costcentre,
				   last_movement_date = (select top 1 _im.date_time 
							from item_movement _im left join item_movement_type_ref _imt on _im.item_movement_type_rcd = _imt.item_movement_type_rcd
							where _im.item_id = si.item_id
							and _im.store_id = si.store_id
							and _im.date_time BETWEEN @From and @To
							order by _im.date_time desc), 
				   movement_qty = (select top 1 _im.movement_qty
							from item_movement _im left join item_movement_type_ref _imt on _im.item_movement_type_rcd = _imt.item_movement_type_rcd
							where _im.item_id = si.item_id 
							and _im.store_id = si.store_id
							and _im.date_time BETWEEN @From and @To
							order by _im.date_time desc),
				   last_movement_type = (select top 1 _imt.name_l as movement 
							from item_movement _im left join item_movement_type_ref _imt on _im.item_movement_type_rcd = _imt.item_movement_type_rcd
							where _im.item_id = si.item_id 
							and _im.store_id = si.store_id
							and _im.date_time BETWEEN @From and @To
							order by _im.date_time desc),
				   last_movement_type_rcd = (select top 1 _im.item_movement_type_rcd 
							from item_movement _im left join item_movement_type_ref _imt on _im.item_movement_type_rcd = _imt.item_movement_type_rcd
							where _im.item_id = si.item_id 
							and _im.store_id = si.store_id
							and _im.date_time BETWEEN @From and @To
							order by _im.date_time desc)

			from store_item si left outer join item i on si.item_id = i.item_id
							   left outer join item_group ig on i.item_group_id = ig.item_group_id
							   left outer join store s on si.store_id = s.store_id
							   left outer join costcentre c on s.costcentre_id = c.costcentre_id
							   left outer join inventory_summary_day isd on si.item_id = isd.item_id

			where i.active_flag = 1
				  and s.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'            --Central Warehouse
				  --and s.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'          --POS
				  --and ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'    --OR Supplies - Exclusive
				  --and i.item_code = '201018334'

		) as temp
		where temp.qty_on_hand > 0
			  --and temp.last_order_date_time is not NULL
			  and temp.last_movement_type_rcd ='IS'
			  and temp.last_movement_date BETWEEN @From and @To

) as tempb
order by tempb.item_code