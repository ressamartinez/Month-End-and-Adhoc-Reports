

SELECT temp.item_code,
	   temp.itemtype,
	   temp.item_type_rcd,
	   temp.sub_item_type,
	   temp.item_desc,
	   temp.modified_on,
	   CONVERT(VARCHAR(20), temp.modified_on,101) AS [Date Modified On],
	   FORMAT(temp.modified_on,'hh:mm tt') AS [Time Modified On],
	   temp.modified_by,
	   temp.column_name,
	   temp.old_value,
	   temp.new_value,
	   temp.itemgroup,
	   case when temp.column_name = 'active_flag' then (case when temp.new_value = 'Inactive' then 'Deactivate' else temp.change_type end) else temp.change_type END as change_type
from
(
		SELECT GVI.item_code,
		   ittr.name_l as item_type,
		   GVI.item_type_rcd,
		   GVI.sub_item_type,
		   GVI.item_desc,
		   DCS.modified_date_time AS modified_on,
		   (SELECT display_name_l
			FROM dbo.person_formatted_name_iview_nl_view
			WHERE person_id = (SELECT person_id
								FROM dbo.user_account_nl_view
								WHERE user_id = DCS.modified_by_user_id))
		   AS modified_by,
		  case WHEN DCL.column_name = 'active_flag' then 'Status'
			  WHEN DCL.column_name = 'name_e' or DCL.column_name = 'name_l' then 'Item Name'
			  WHEN DCL.column_name = 'item_code' then 'Item Code'
			  WHEN DCL.column_name = 'item_type_rcd' then 'Item Type'
			  WHEN DCL.column_name = 'sub_item_type_rcd' then 'Sub Item Type'
		  end as column_name,
		   case when DCL.column_name = 'active_flag' then (case when (case when DCL.old_value_l is NULL then DCL.old_value ELSE DCL.old_value_l end) = '1' then 'Active'
																when (case when DCL.old_value_l is NULL then DCL.old_value ELSE DCL.old_value_l end) = '0' then 'Inactive' end) 
				else (case when DCL.old_value_l is NULL then DCL.old_value ELSE DCL.old_value_l end) end as old_value,
		   case when DCL.column_name = 'active_flag' then (case when (case when DCL.new_value_l is NULL then DCL.new_value ELSE DCL.new_value_l end) = '1' then 'Active'
																when (case when DCL.new_value_l is NULL then DCL.new_value ELSE DCL.new_value_l end) = '0' then 'Inactive' end) 
				else (case when DCL.new_value_l is NULL then DCL.new_value ELSE DCL.new_value_l end) end as new_value,
		  ig.name_l as itemgroup,
		  ittr.name_l as itemtype,
		  case when dctr.name_l = 'Insert' then 'New' ELSE dctr.name_l end as change_type
	FROM dbo.data_change_session_nl_view DCS INNER JOIN dbo.data_change_log_nl_view DCL	ON DCS.data_change_session_id = DCL.data_change_session_id
											 INNER JOIN HISViews.dbo.GEN_vw_item GVI ON SUBSTRING(DCL.primary_key, 2, LEN(DCL.primary_key) - 2) = GVI.item_id
											 inner JOIN item_type_ref ittr on gvi.item_type_rcd = ittr.item_type_rcd
											 inner JOIN item_group_nl_view ig on gvi.item_group_id = ig.item_group_id
											 inner JOIN data_change_type_ref dctr on dcl.data_change_type_rcd = dctr.data_change_type_rcd
	WHERE DCL.table_name = 'item'
	   and MONTH(DCS.modified_date_time) = @Month
		and YEAR(DCS.modified_date_time) = @Year
		and GVI.item_type_rcd in ('INV','PCK','SRV')
		AND DCL.data_change_type_rcd <> 'I'
		and ig.parent_item_group_id not in ('9B78157F-360A-11DA-BB34-000E0C7F3ED2',
											'FEFA073D-7D4F-4388-A019-E0295B0CB140',
											'4F1E9D1F-7B92-4451-AE5B-3D5E82D6D044')
			and DCL.column_name in ('name_l',
								    'item_code',
								    'active_flag',
									'item_type_rcd',
									'sub_item_type_rcd')
	UNION all
	SELECT GVI.item_code,
		   ittr.name_l as item_type,
		   GVI.item_type_rcd,
		   GVI.sub_item_type,
		   GVI.item_desc,
		   DCS.modified_date_time AS modified_on,
		   (SELECT display_name_l
			FROM dbo.person_formatted_name_iview_nl_view
			WHERE person_id = (SELECT person_id
								FROM dbo.user_account_nl_view
								WHERE user_id = DCS.modified_by_user_id))
		   AS modified_by,
		    case WHEN DCL.column_name = 'active_flag' then 'Status'
			  WHEN DCL.column_name = 'name_e' or DCL.column_name = 'name_l' then 'Item Name'
			  WHEN DCL.column_name = 'item_code' then 'Item Code'
			  WHEN DCL.column_name = 'item_type_rcd' then 'Item Type'
			  WHEN DCL.column_name = 'sub_item_type_rcd' then 'Sub Item Type'
		  end as column_name,
		   case when DCL.column_name = 'active_flag' then (case when (case when DCL.old_value_l is NULL then DCL.old_value ELSE DCL.old_value_l end) = '1' then 'Active'
																when (case when DCL.old_value_l is NULL then DCL.old_value ELSE DCL.old_value_l end) = '0' then 'Inactive' end) 
				else (case when DCL.old_value_l is NULL then DCL.old_value ELSE DCL.old_value_l end) end as old_value,
		   case when DCL.column_name = 'active_flag' then (case when (case when DCL.new_value_l is NULL then DCL.new_value ELSE DCL.new_value_l end) = '1' then 'Active'
																when (case when DCL.new_value_l is NULL then DCL.new_value ELSE DCL.new_value_l end) = '0' then 'Inactive' end) 
				else (case when DCL.new_value_l is NULL then DCL.new_value ELSE DCL.new_value_l end) end as new_value,
		  ig.name_l as itemgroup,
		  ittr.name_l as itemtype,
		  case when dctr.name_l = 'Insert' then 'New' ELSE dctr.name_l end as change_type
	FROM dbo.data_change_session_nl_view DCS INNER JOIN dbo.data_change_log_nl_view DCL	ON DCS.data_change_session_id = DCL.data_change_session_id
											 INNER JOIN HISViews.dbo.GEN_vw_item GVI ON SUBSTRING(DCL.primary_key, 2, LEN(DCL.primary_key) - 2) = GVI.item_id
											 inner JOIN item_type_ref ittr on gvi.item_type_rcd = ittr.item_type_rcd
											 inner JOIN item_group_nl_view ig on gvi.item_group_id = ig.item_group_id
											 inner JOIN data_change_type_ref dctr on dcl.data_change_type_rcd = dctr.data_change_type_rcd
	WHERE DCL.table_name = 'item'
	  and MONTH(DCS.modified_date_time) = @Month
		and YEAR(DCS.modified_date_time) = @Year
		and GVI.item_type_rcd in ('INV','PCK','SRV')
		AND DCL.data_change_type_rcd = 'I'
		and ig.parent_item_group_id not in ('9B78157F-360A-11DA-BB34-000E0C7F3ED2',
											'FEFA073D-7D4F-4388-A019-E0295B0CB140',
											'4F1E9D1F-7B92-4451-AE5B-3D5E82D6D044')
		and DCL.column_name in ('name_l',
								'item_code',
								'active_flag',
								'item_type_rcd',
								'sub_item_type_rcd')
) as temp
order by temp.item_type_rcd,
	     temp.modified_on DESC,
		 temp.item_code