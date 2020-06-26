DECLARE @AsOFDate datetime

SET @AsOFDate =  '04/29/2020 23:59:59.998'

SELECT tempb.item_group_name,
       tempb.item_code,
	   tempb.item_name,
	   tempb.last_purchased_date,
	   tempb.qty_on_hand,
	   tempb.average_unit_cost,
	   tempb.cost,
	   tempb.store,
	   tempb.costcentre,
	   tempb.aging,
	   CASE WHEN aging >= 0 and aging <= 30 then '1 to 30 days'
			 WHEN aging >= 31 and aging <= 60 then '31 to 60 days'
			 WHEN aging >= 61 and aging <= 120 then '61 to 120 days'
			 WHEN aging > 120 then '>120 days'
	         end as classification,
	   tempb.last_movement_date,
	   tempb.last_movement_type,
	   tempb.last_delivery_date

from (

	select distinct *
					,cost = temp.qty_on_hand * temp.average_unit_cost     --final qty_on_hand_cost
					,aging = DATEDIFF(day, temp.last_purchased_date, @AsOFDate) 
    from (

			select ig.name_l as item_group_name,
				   i.item_id,
				   i.item_code,
				   i.name_l as item_name,
				   si.last_order_date_time as last_purchased_date,
				   qty_on_hand = (Select top 1 qty_on_hand
							from inventory_summary_day _spo 
							where _spo.item_id = isd.item_id
							and _spo.store_id = s.store_id
							and cast(convert(varchar(10),date_time,101)as smalldatetime) <= cast(convert(varchar(10),@AsOFDate,101)as smalldatetime) 
							order by date_time desc),
			      average_unit_cost = (Select top 1 average_unit_cost
							from inventory_summary_day _spo 
							where _spo.item_id = isd.item_id
							and _spo.store_id = s.store_id
							and cast(convert(varchar(10),date_time,101)as smalldatetime) <= cast(convert(varchar(10),@AsOFDate,101)as smalldatetime) 
							order by date_time desc),
			      qty_on_hand_cost = (Select top 1 qty_on_hand_cost
							from inventory_summary_day _spo 
							where _spo.item_id = isd.item_id
							and _spo.store_id = s.store_id
							and cast(convert(varchar(10),date_time,101)as smalldatetime) <= cast(convert(varchar(10),@AsOFDate,101)as smalldatetime) 
							order by date_time desc),
				   s.name_l as store,
				   --s.store_id,
				   c.name_l as costcentre,
				   last_movement_date = (select top 1 _im.date_time 
							from item_movement _im left join item_movement_type_ref _imt on _im.item_movement_type_rcd = _imt.item_movement_type_rcd
							where _im.item_id = si.item_id
							and _im.store_id = si.store_id
							and cast(convert(varchar(10),_im.date_time,101)as smalldatetime) <= cast(convert(varchar(10),@AsOFDate,101)as smalldatetime)
							order by _im.date_time desc), 
				   last_movement_type = (select top 1 _imt.name_l as movement 
							from item_movement _im left join item_movement_type_ref _imt on _im.item_movement_type_rcd = _imt.item_movement_type_rcd
							where _im.item_id = si.item_id 
							and _im.store_id = si.store_id
							and cast(convert(varchar(10),_im.date_time,101)as smalldatetime) <= cast(convert(varchar(10),@AsOFDate,101)as smalldatetime)
							order by _im.date_time desc),
				   last_delivery_date = (select top 1 received_on_date 
							from swe_delivery_performance sdp
							where sdp.item_id = si.item_id
							and cast(convert(varchar(10),sdp.received_on_date,101)as smalldatetime) <= cast(convert(varchar(10),@AsOFDate,101)as smalldatetime)
							order by sdp.received_on_date desc)

			from store_item si left outer join item i on si.item_id = i.item_id
							   left outer join item_group ig on i.item_group_id = ig.item_group_id
							   left outer join store s on si.store_id = s.store_id
							   left outer join costcentre c on s.costcentre_id = c.costcentre_id
							   left outer join inventory_summary_day isd on si.item_id = isd.item_id

			where i.active_flag = 1
				  and cast(convert(varchar(10),si.last_order_date_time,101)as smalldatetime) <= cast(convert(varchar(10),@AsOFDate,101)as smalldatetime)
				  --and s.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'            --Central Warehouse
				  and s.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'          --POS
				  and ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'    --OR Supplies - Exclusive
				  --and i.item_code = '213078371'

		) as temp
		where temp.qty_on_hand > 0
			  and temp.last_purchased_date is not NULL

) as tempb
order by aging desc
