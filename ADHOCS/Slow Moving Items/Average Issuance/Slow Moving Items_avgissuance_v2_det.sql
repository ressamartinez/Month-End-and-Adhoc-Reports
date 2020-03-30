DECLARE @From datetime
DECLARE @To datetime

SET @From =  '01/01/2019 00:00:00.000'
SET @To =  '12/31/2019 23:59:59.998'


select *
		,ROW_NUMBER() OVER(PARTITION BY temp.item_name ORDER BY item_name ASC) AS Row#

from (

	select distinct i.item_id
			,i.item_code
			,i.name_l as item_name
			,im.date_time as movement_date
			,im.movement_qty
			,imtr.name_l as item_movement_type
			,im.qty_on_hand
			--,si.last_order_date_time
			,ig.name_l as itemgroup_name


	from item_movement im left join item i on im.item_id = i.item_id
							left join store_item si on im.item_id = si.item_id
							left join item_group ig on i.item_group_id = ig.item_group_id
							left join store s on im.store_id = s.store_id
							left join costcentre c on s.costcentre_id = c.costcentre_id
							left join item_movement_type_ref imtr on im.item_movement_type_rcd = imtr.item_movement_type_rcd

	where i.active_flag = 1
			and s.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'            --Central Warehouse
			and im.date_time BETWEEN @From and @To
			--and i.item_code = '588-0029'
			--and i.item_id = '3151567B-F9AA-4E4C-80B9-25BB4306CAD6'

)as temp
where temp.item_movement_type = 'Issue to store'
order by temp.item_name, temp.movement_date desc
