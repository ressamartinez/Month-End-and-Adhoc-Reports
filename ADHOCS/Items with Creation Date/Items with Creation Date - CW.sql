
select s.name_l as [Store]
       ,ig.item_group_code as [Itemgroup Code]
	   ,ig.name_l as [Itemgroup Name]
	   ,i.item_code as [Item Code]
	   ,i.name_l as [Item Name]
	   ,[Changed By] = (select top 1 modified_by
						from HISViews.dbo.RPT_vw_exc_item_change_history ich
						where ich.item_id = i.item_id
						order by modified_on)
	   ,[Changed On] = (select top 1 modified_on
						from HISViews.dbo.RPT_vw_exc_item_change_history ich
						where ich.item_id = i.item_id
						order by modified_on)  

from item i 
	 left join item_group ig on i.item_group_id = ig.item_group_id 
     left join store_item si on i.item_id = si.item_id
	 left join store s on si.store_id = s.store_id

where i.active_flag = 1
	  and si.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'         --Central Warehouse
      --and i.item_code = '03-28-805'

order by [Itemgroup Name], [Item Name]
