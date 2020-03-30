DECLARE @dFrom datetime
DECLARE @dTo datetime

SET @dFrom = /*@From*/ '01/01/2018 00:00:00.000'		--Jan 2018 = 22667
SET @dTo = /*@To*/ '09/30/2019 23:59:59.998'


Select s.name_l as [Store Name],
	   ig.name_l as [Item Group Name],
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
	   pfni.display_name_l as [User Name],
	   [Last Purchased Date] = (select top 1 sdp.ordered_on_date 
							from swe_delivery_performance sdp
							where sdp.item_id = im.item_id
							and cast(convert(varchar(10),sdp.ordered_on_date,101)as smalldatetime) <= cast(convert(varchar(10),@dTo,101)as smalldatetime)
							order by sdp.ordered_on_date desc),
	   [Last Delivery Date] = (select top 1 received_on_date 
							from swe_delivery_performance sdp
							where sdp.item_id = im.item_id
							and cast(convert(varchar(10),sdp.received_on_date,101)as smalldatetime) <= cast(convert(varchar(10),@dTo,101)as smalldatetime)
							order by sdp.received_on_date desc)
	   --sdp.ordered_on_date
	   --,sdp.received_on_date

from item_movement im
		 left join item i on i.item_id = im.item_id 
		 left join store s on s.store_id = im.store_id
		 left join item_movement_lot iml on iml.item_movement_id = im.item_movement_id
		 left join user_account ua on ua.user_id = im.user_id
		 left join person_formatted_name_iview pfni on pfni.person_id = ua.person_id
		 left join item_movement_type_ref imtr on imtr.item_movement_type_rcd = im.item_movement_type_rcd
		 left join uom_ref ur on ur.uom_rcd = i.uom_rcd
		 left join item_group ig on i.item_group_id = ig.item_group_id
		 --left join swe_delivery_performance sdp on im.item_id = sdp.item_id

where im.store_id = --'08CD273C-19CE-11DA-A79E-001143B8816C'           --Central Warehouse,  
                     '08CD273F-19CE-11DA-A79E-001143B8816C'          --POS
	  and ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'    --OR Supplies - Exclusive
      and CAST(CONVERT(VARCHAR(10),im.date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),im.date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)
	  --and year(im.date_time) = 2018
	  --and month(im.date_time) BETWEEN 1 AND 7
	  and imtr.item_movement_type_rcd IN (/*'ID', 'SDEL',*/ 'S')  --movement type
	  --and i.item_code = '588-0024'

order by [Item Name], [Date/Time]