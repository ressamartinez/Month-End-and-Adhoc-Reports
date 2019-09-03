

SELECT *
	   ,CASE WHEN aging >= 0 and aging <= 30 then '1 to 30 days'
			 WHEN aging >= 31 and aging <= 60 then '31 to 60 days'
			 WHEN aging >= 61 and aging <= 120 then '61 to 120 days'
			 WHEN aging > 120 then '>120 days'
	         end as classification

from (

	select distinct *
					,aging = DATEDIFF(day, temp.last_order_date_time, '05/31/2019') 
    from (
			select ig.name_l as item_group_name,
				   i.item_code,
				   i.name_l as item_name,
				   si.last_order_date_time,
				   si.qty_on_hand,
				   si.average_unit_cost,
				   si.qty_on_hand_cost,
				   s.name_l as store,
				   c.name_l as costcentre

			from store_item si left outer join item i on si.item_id = i.item_id
							   left outer join item_group ig on i.item_group_id = ig.item_group_id
							   left outer join store s on si.store_id = s.store_id
							   left outer join costcentre c on s.costcentre_id = c.costcentre_id
							   left outer join inventory_summary_day isd on si.item_id = isd.item_id

			where i.active_flag = 1
				  and si.qty_on_hand > 0
				  and si.last_order_date_time is not NULL
				  and cast(convert(varchar(10),si.last_order_date_time,101)as smalldatetime) <= cast(convert(varchar(10),'05/31/2019',101)as smalldatetime)
				  --and i.item_code = '206038009'
				  and s.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'            --Central Warehouse
				  --and s.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'          --POS
				  --and ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'    --OR Supplies - Exclusive

		) as temp


) as tempb
order by aging desc
