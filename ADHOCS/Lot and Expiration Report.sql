select sil.store_id
	   ,sil.item_id
	   ,i.name_l as [Item Name]
	   ,i.item_code
	   ,i.item_group_id
	   ,ig.name_l as [Item Group Name]
	   ,s.store_code
	   ,s.name_l as [Store Name]
	   ,sil.expiry_date_time
	   ,sil.lot_number
	   ,sil.qty_on_hand
	   ,(Select top 1 date_time from item_movement 
				where item_id = sil.item_id and store_id = sil.store_id
				order by date_time desc) as [Item Movement Date]
from store_item_lot sil
inner join store s on s.store_id = sil.store_id
inner join item i on i.item_id = sil.item_id
inner join item_group ig on i.item_group_id = ig.item_group_id
where i.active_flag = 1
	  and sil.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'     --POS
	  --and i.item_id ='BD4E7EFF-8F5E-40DE-9DE6-2CE89A24E8DC'
	  and ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'   --OR Supplies (Exclusive)
	  and (Select top 1 date_time from item_movement 
				where item_id = sil.item_id and store_id = sil.store_id
				order by date_time desc) <= '07/31/2018 23:59:59.998'

order by [Item Movement Date]