DECLARE @dFrom datetime
DECLARE @dTo datetime

SET @dFrom = /*@From*/  '05/01/2020 00:00:00.000'
SET @dTo = /*@To*/      '05/04/2020 23:59:59.998'


Select s.name_l as [Store Name],
	   --ig.name_l as [Item Group Name],
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
	   (Select top 1 lot_number from item_movement_lot where item_movement_id = im.item_movement_id) as [Lot Number],
	   im.date_time as [Date/Time],
	   pfni.display_name_l as [User Name],
	   case when imtr.item_movement_type_rcd = 'IS' then im.issue_requesting_store_name_l
	        when imtr.item_movement_type_rcd = 'ID' then im.issue_requesting_department_name_l
			end as [Requesting Store/Department]

from api_item_movement_view im
		 left join item i on i.item_id = im.item_id 
		 left join store s on s.store_id = im.store_id
		 --left outer join item_movement_lot iml on im.item_movement_id = iml.item_movement_id
		 inner join user_account ua on ua.user_id = im.user_id
		 inner join person_formatted_name_iview pfni on pfni.person_id = ua.person_id
		 inner join item_movement_type_ref imtr on imtr.item_movement_type_rcd = im.item_movement_type_rcd
		 inner join uom_ref ur on ur.uom_rcd = i.uom_rcd
		 inner join item_group ig on i.item_group_id = ig.item_group_id

where CAST(CONVERT(VARCHAR(10),im.date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),im.date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)
	  --and year(im.date_time) = 2018
	  --and month(im.date_time) BETWEEN 1 AND 7
	  and imtr.item_movement_type_rcd IN ('ID', 'IS')  --movement type
	  and i.item_code in (select [Item Code] collate sql_latin1_general_cp1_cs_as from AHMC_DataAnalyticsDB.dbo.ppe)

order by [Date/Time]

