SELECT DISTINCT --COUNT(i.item_id), i.item_id, i.name_l,*
i.item_code as [Item Code],
	   i.name_l as [Item Name],
	   CAST((SELECT DISTINCT a.price
			from item_price a 
			where a.item_id =  i.item_id
			   and a.effective_to_date_time is NULL
			   ) AS DECIMAL(10,2)) as [Item Price],

	   (SELECT item_code
			from item
			where item_id = ie.child_item_id) as [Exploding Item Code],
			(SELECT name_l as item_name
			from item
			where item_id = ie.child_item_id) as [Exploding Item Name],

		CAST((SELECT DISTINCT a.price
			from item_price a
			where a.item_id =  (SELECT item_id
								from item
								where item_id = ie.child_item_id)
			   and a.effective_to_date_time is NULL
			   ) AS DECIMAL(10,2)) aS [Exploding Item Price],

		(SELECT b.item_group_code
		from item_group_flat a inner JOIN item_group b on a.parent_item_group_id = b.item_group_id
		where  b.parent_item_group_id is NULL
			 and a.item_group_id = i.item_group_id)
		
from item i inner join item_exploding_nl_view ie on i.item_id = ie.item_id
where i.active_flag = 1
   --and i.item_type_rcd = 'srv'
   --and i.sub_item_type_rcd = 'srv'
   --and i.item_code LIKE '100%'
   and (SELECT b.item_group_code
		from item_group_flat a inner JOIN item_group b on a.parent_item_group_id = b.item_group_id
		where  b.parent_item_group_id is NULL
			 and a.item_group_id = i.item_group_id) in ('110','100','120','140',
														'160','200','425','430',
														'440','900','092','094',
														'090',	'080','070')
														--and i.item_code = '050-20-0140'
														
order by [Item Name] --COUNT(i.item_id) desc