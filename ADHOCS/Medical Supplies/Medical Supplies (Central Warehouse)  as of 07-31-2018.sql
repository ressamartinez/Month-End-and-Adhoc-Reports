select
	   s.store_code
	   ,s.name_l as [Store Name]
	   ,i.item_group_id
	   ,ig.name_l as [Item Group Name]
	   ,i.item_code
	   ,sil.item_id
	   ,i.name_l as [Item Name]
	   ,i.uom_rcd
	   ,spod.ordered_qty
	   ,spod.received_qty
	   ,spo.ordered_on_date
	   ,spod.gross_amount
	   ,vendor_name = (CASE WHEN v.person_id IS NOT NULL THEN 
                                                                                        (SELECT display_name_l
                                                                                        FROM person_formatted_name_view
                                                                                        WHERE person_id = v.person_id) 
                                                                    ELSE (SELECT name_l
                                                                                FROM organisation
                                                                                WHERE organisation_id = v.organisation_id)
                                                                    END)
	   ,c.name_l as Costcentre
	   ,(Select top 1 actual_cost from item_movement 
				where item_id = sil.item_id and store_id = sil.store_id
				order by date_time desc) as [Actual Unit Cost]
	   ,sil.expiry_date_time
	   ,sil.lot_number
	   ,sil.qty_on_hand
	   ,(Select top 1 date_time from item_movement 
				where item_id = sil.item_id and store_id = sil.store_id
				order by date_time desc) as [Item Movement Date]
	   ,(Select top 1 movement_qty from item_movement 
				where item_id = sil.item_id and store_id = sil.store_id
				order by date_time desc) as [Movement Qty]
	   ,(Select name_l from item_movement_type_ref where item_movement_type_rcd = (
				select top 1 item_movement_type_rcd from item_movement 
				where item_id = sil.item_id and store_id = sil.store_id
				order by date_time desc)) as [Item Movement Type]
from store_item_lot sil
inner join store s on s.store_id = sil.store_id
inner join item i on i.item_id = sil.item_id
inner join item_group ig on i.item_group_id = ig.item_group_id
inner join swe_vendor_item svi on svi.item_id = sil.item_id
inner join swe_purchase_order_detail spod on spod.vendor_item_id = svi.vendor_item_id 
inner join swe_purchase_order spo on spo.purchase_order_id = spod.purchase_order_id
inner join vendor v on v.vendor_id = svi.vendor_id
inner join costcentre c on c.costcentre_id = s.costcentre_id
where i.active_flag = 1
	  and sil.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'          --Central Warehouse
	  --and i.item_id ='BD4E7EFF-8F5E-40DE-9DE6-2CE89A24E8DC'
	  --and ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'    --OR Supplies - Exclusive
	  and (Select top 1 date_time from item_movement 
				where item_id = sil.item_id and store_id = sil.store_id
				order by date_time desc) <= '07/31/2018 23:59:59.998'

order by [Item Movement Date]