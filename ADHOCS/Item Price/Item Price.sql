
select *
from (

	select *
			,ROW_NUMBER() OVER(PARTITION BY temp.item_name ORDER BY temp.effective_from desc) AS row_num
	from (
			select distinct i.item_type_rcd
					,itr.name_l as item_type_name 
			        ,i.item_code
					,i.name_l as item_name
					,ip.price
					,ip.effective_from_date_time as effective_from
					,pfn.display_name_l as changed_by
					,ip.lu_updated as changed_on
			from item_price ip left join item i on ip.item_id = i.item_id
								left join user_account ua on ip.lu_user_id = ua.user_id
								left join person_formatted_name_iview pfn on ua.person_id = pfn.person_id
								left join item_type_ref itr on i.item_type_rcd = itr.item_type_rcd
			where i.item_type_rcd in ('INV', 'SRV')
			      and i.active_flag = 1
			      --and i.item_code = '090-10-0010'
				  
	)as temp

)as tempb
where tempb.row_num <= 3
order by tempb.item_name, tempb.effective_from DESC