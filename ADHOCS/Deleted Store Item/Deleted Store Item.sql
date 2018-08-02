--DBPROD03 > AMALGAPROD
SELECT DISTINCT dcl.old_value,
		dcl.lu_updated,
		dcl.column_name,
		CONVERT(VARCHAR(20), dcl.lu_updated,101) AS [Last Updated Date],
		--CONVERT(VARCHAR(5), dcl.lu_updated,108) AS [Last Updated Time],
		FORMAT(dcl.lu_updated,'hh:mm tt') AS [Last Updated Time],
		s.name_l as store_name,
		(SELECT item_code
		from item
		where item_id = SUBSTRING(DCL.old_value, 2, LEN(DCL.old_value) - 2)) as item_code,
		(SELECT name_l
		from item
		where item_id = SUBSTRING(DCL.old_value, 2, LEN(DCL.old_value) - 2)) as item_name,
		(SELECT b.display_name_l
		from user_account a inner JOIN person_formatted_name_iview_nl_view b on a.person_id = b.person_id
		where a.user_id =  dcl.lu_user_id) as lu_user
from data_change_log dcl inner JOIN store s on SUBSTRING(DCL.primary_key, 2, LEN(DCL.primary_key) - 2) = s.store_id
							inner JOIN data_change_type_ref dct on dcl.data_change_type_rcd = dct.data_change_type_rcd
							inner JOIN store_item si on s.store_id = si.store_id
							inner JOIN item i on si.item_id = i.item_id
where table_name = 'store_item'
	and dcl.column_name = 'item_id'
	and dcl.data_change_type_rcd = 'D'
	and YEAR(dcl.lu_updated) = 2018
order by store_name,
	     item_code,
		 dcl.lu_updated

