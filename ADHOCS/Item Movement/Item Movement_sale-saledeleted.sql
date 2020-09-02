
DECLARE @Year int

SET @Year =  2020


select temp.[Item Code]
	   ,temp.[Item Description]
	   ,temp.UOM
	   ,temp.Sale_3
	   ,temp.[Sale Deleted_3]
	   ,temp.Sale_4
	   ,temp.[Sale Deleted_4]
	   ,temp.Sale_5
	   ,temp.[Sale Deleted_5]
	   ,temp.Sale_6
	   ,temp.[Sale Deleted_6]
	   ,temp.Sale_7
	   ,temp.[Sale Deleted_7]
	   ,temp.Sale_8
	   ,temp.[Sale Deleted_8]

from (

		select si.item_id
			   ,i.item_code as [Item Code]
			   ,i.name_l as [Item Description]
			   ,i.uom_rcd as UOM
			   ,si.store_id
			   ,s.name_l as Store
			   ,Sale_3 = isnull((select sum(sale)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 3 and DAY(_isd.date_time) between 15 and 30), 0)
			   ,[Sale Deleted_3] = isnull((select sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 3 and DAY(_isd.date_time) between 15 and 30), 0)
			   ,Sale_4 = isnull((select sum(sale)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 4), 0)
			   ,[Sale Deleted_4] = isnull((select sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 4), 0)
			   ,Sale_5 = isnull((select sum(sale)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 5), 0)
			   ,[Sale Deleted_5] = isnull((select sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 5), 0)
			   ,Sale_6 = isnull((select sum(sale)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 6), 0)
			   ,[Sale Deleted_6] = isnull((select sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 6), 0)
			   ,Sale_7 = isnull((select sum(sale)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 7), 0)
			   ,[Sale Deleted_7] = isnull((select sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 7), 0)
			   ,Sale_8 = isnull((select sum(sale)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 8), 0)
			   ,[Sale Deleted_8] = isnull((select sum(sale_deleted)
							from inventory_summary_day _isd
							where _isd.item_id = si.item_id
							and _isd.store_id = si.store_id
							and YEAR(_isd.date_time) = @Year and MONTH(_isd.date_time) = 8), 0)


		from store_item si  left join item i on si.item_id = i.item_id
		                    left join item_group ig on i.item_group_id = ig.item_group_id
							left join store s on si.store_id = s.store_id
							  
		where i.active_flag = 1
			  and si.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'         --POS
			  and ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'    --OR Supplies - Exclusive
			  and s.active_flag = 1
			  --and im.date_time BETWEEN @From and @To
			  --and i.item_code = '588-116'
		
		group by si.item_id, 
			     i.item_code,
			     i.name_l,
				 i.uom_rcd,
				 si.store_id,
				 s.name_l

)as temp
--where [Item Code] = '212024147'
order by temp.[Item Code]