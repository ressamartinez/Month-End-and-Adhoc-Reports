
select tempb.store as 'Store'
       ,tempb.itemgroup_name as 'Itemgroup'
	   ,tempb.item_code as 'Item Code'
	   ,tempb.item_name as 'Item Description'
	   ,tempb.changed_on as 'Changed on'

from (

	select temp.store
	       ,temp.itemgroup_name
		   ,temp.item_code
		   ,temp.item_name
		   ,temp.lu_updated as changed_on

	from (
		SELECT distinct
			   s.name_l as store
			   ,ig.item_group_code
			   ,ig.name_l as itemgroup_name
			   ,i.item_id
			   ,i.item_code
			   ,i.name_l as item_name 
			   ,lu_updated = (select top 1 _dcl.lu_updated
									from data_change_log _dcl
									  where _dcl.primary_key = dcl.primary_key
							  				and _dcl.table_name = 'item'
											and _dcl.data_change_type_rcd = 'U'
									  order by _dcl.lu_updated) 

		from item i left join data_change_log dcl on i.item_id = dcl.primary_key
					left join store_item si on i.item_id = si.item_id
					left join store s on si.store_id = s.store_id
					left join item_group ig on i.item_group_id = ig.item_group_id

		where table_name = 'item'
			  and dcl.data_change_type_rcd = 'U'
			  and i.active_flag = 1
			  and si.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'         --POS
			  and s.active_flag = 1
			  and ig.item_group_code in ('0832-1', '0832-2')
	)as temp

UNION ALL

	select temp.store
	       ,temp.itemgroup_name
		   ,temp.item_code
		   ,temp.item_name
		   ,temp.lu_updated as changed_on

	from (
		SELECT distinct
			   s.name_l as store
			   ,ig.item_group_code
			   ,ig.name_l as itemgroup_name
			   ,i.item_code
			   ,i.item_id
			   ,i.name_l as item_name
			   ,lu_updated = (select top 1 _i.lu_updated
									from item _i
									where _i.item_id = i.item_id) 

		from item i inner join store_item si on i.item_id = si.item_id
					inner join store s on si.store_id = s.store_id 
					inner join item_group ig on i.item_group_id = ig.item_group_id

		where
			  i.active_flag = 1
			  and si.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'         --POS
			  and s.active_flag = 1
			  and i.item_id not in (Select SUBSTRING(primary_key, 2, LEN(primary_key) - 2) from data_change_log
			                               where SUBSTRING(primary_key, 2, LEN(primary_key) - 2) = i.item_id
										         and table_name = 'item')
              and ig.item_group_code in ('0832-1', '0832-2')
	)as temp

)as tempb
where CAST(CONVERT(VARCHAR(10),tempb.changed_on,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2019',101) as SMALLDATETIME)
      --and tempb.item_code = '220000002'
order by tempb.item_name, tempb.changed_on
