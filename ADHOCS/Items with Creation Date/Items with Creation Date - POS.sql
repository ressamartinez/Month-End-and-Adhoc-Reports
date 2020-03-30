
select tempb.store
	   ,tempb.item_code
	   ,tempb.item_name
	   ,tempb.changed_by
	   ,tempb.changed_on

from (

	select temp.store
		   ,temp.item_code
		   ,temp.item_name
		   ,pfn.display_name_l as changed_by
		   ,temp.lu_updated as changed_on

	from (
		SELECT distinct
			   s.name_l as store
			   ,i.item_code
			   ,i.name_l as item_name
			   ,lu_user_id = (select top 1 _dcl.lu_user_id
									from data_change_log _dcl
									  where _dcl.primary_key = dcl.primary_key
											and _dcl.table_name = 'item'
											and _dcl.data_change_type_rcd = 'U'
									  order by _dcl.lu_updated) 
			   ,lu_updated = (select top 1 _dcl.lu_updated
									from data_change_log _dcl
									  where _dcl.primary_key = dcl.primary_key
							  				and _dcl.table_name = 'item'
											and _dcl.data_change_type_rcd = 'U'
									  order by _dcl.lu_updated) 

		from item i left join data_change_log dcl on i.item_id = dcl.primary_key 
					left join store_item si on i.item_id = si.item_id
					left join store s on si.store_id = s.store_id 

		where table_name = 'item'
			  and dcl.data_change_type_rcd = 'U'
			  --and i.item_code = '588-0022'
			  and i.active_flag = 1
			  and si.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'         --POS
	)as temp
		left join user_account ua on temp.lu_user_id = ua.user_id
		left join person_formatted_name_iview pfn on ua.person_id = pfn.person_id


UNION

	select temp.store
		   ,temp.item_code
		   ,temp.item_name
		   ,pfn.display_name_l as changed_by
		   ,temp.lu_updated as changed_on

	from (
		SELECT distinct
			   s.name_l as store
			   ,i.item_code
			   ,i.name_l as item_name
			   ,lu_user_id = (select top 1 _i.lu_user_id
									from item _i
									where _i.item_id = i.item_id) 
			   ,lu_updated = (select top 1 _i.lu_updated
									from item _i
									where _i.item_id = i.item_id) 

		from item i left join store_item si on i.item_id = si.item_id
					left join store s on si.store_id = s.store_id 

		where
			  --and i.item_code = '588-0022'
			  i.active_flag = 1
			  and si.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'         --POS
	)as temp
		left join user_account ua on temp.lu_user_id = ua.user_id
		left join person_formatted_name_iview pfn on ua.person_id = pfn.person_id

)as tempb
order by tempb.item_name, tempb.changed_on desc