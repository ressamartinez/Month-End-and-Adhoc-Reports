SELECT  cc.costcentre_code as [Costcentre Code],
			 cc.name_l as [Costcentre],
	    i.item_code as [Item Code],
	   i.name_l as [Item Name],
	   (SELECT DISTINCT a.price
		from item_price a 
		where a.item_id =  i.item_id
		   and a.effective_to_date_time is NULL
		   ) as Price,
	   (SELECT item_code
		from item
		where item_id = ie.child_item_id) as [Exploding Item Code],
		(SELECT name_l as item_name
		from item
		where item_id = ie.child_item_id) as [Exploding Item Name],
		(SELECT DISTINCT a.price
		from item_price a
		where a.item_id =  (SELECT item_id
							from item
							where item_id = ie.child_item_id)
		   and a.effective_to_date_time is NULL
		   ) aS Price,
		(SELECT b.item_group_code
		from item_group_flat a inner JOIN item_group b on a.parent_item_group_id = b.item_group_id
		where  b.parent_item_group_id is NULL
			 and a.item_group_id = i.item_group_id),
			
			 igc.visit_type_group_rcd
from item i inner join item_exploding_nl_view ie on i.item_id = ie.item_id
			INNER JOIN item_group_costcentre igc on i.item_group_id = igc.item_group_id
			inner JOIN costcentre cc on igc.costcentre_id = cc.costcentre_id
where i.active_flag = 1
   and igc.visit_type_group_rcd = 'ipd'

   



   --and i.item_type_rcd = 'srv'
   --and i.sub_item_type_rcd = 'srv'
   --and i.item_code LIKE '100%'
  -- and (SELECT b.item_group_code
		--from item_group_flat a inner JOIN item_group b on a.parent_item_group_id = b.item_group_id
		--where  b.parent_item_group_id is NULL
		--	 and a.item_group_id = i.item_group_id) in ('110','100','120','140',
		--												'160','200','425','430',
		--												'440','900','092','094',
		--												'090',	'080','070')
														--and i.item_code = '050-20-0140'
order by [Costcentre Code],[Item Code]