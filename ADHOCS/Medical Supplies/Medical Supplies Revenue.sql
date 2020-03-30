
SELECT distinct temp.[Main Itemgroup Code],
       temp.[Main Itemgroup Name],
	   temp.[Itemgroup Code],
	   temp.[Itemgroup Name],
	   temp.[Item Code],
	   temp.[Item Name],
	   Qty = sum(temp.Qty),
	   [Gross Amount] = sum(temp.[Gross Amount]),
	   [Discount Amount] = sum(temp.[Discount Amount]),
	   [Net Amount] = sum(temp.[Net Amount])

from (

	select
			ig2.item_group_code as [Main Itemgroup Code]
			,ig2.name_l as [Main Itemgroup Name]
			,ig.item_group_code as [Itemgroup Code]
			,ig.name_l as [Itemgroup Name]
			,i.item_code as [Item Code]
			,i.name_l as [Item Name]
			--,ar.transaction_text as [Invoice No.]
			--,ar.transaction_date_time as [Invoice Date]
			,ard.quantity as Qty
			,ard.gross_amount as [Gross Amount]
			,ard.discount_amount as [Discount Amount]
			,ard.gross_amount - ard.discount_amount as [Net Amount]


	from ar_invoice ar inner join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
					inner join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
					inner join item i on ard.item_id = i.item_id
					inner join item_group ig on i.item_group_id = ig.item_group_id
					inner join item_group ig2 on ig.parent_item_group_id = ig2.item_group_id


	where ar.transaction_status_rcd not in ('voi','unk')
			--and ar.system_transaction_type_rcd not in ('cdmr','dbmr')
			and cd.deleted_date_time is null
			and ig2.item_group_code in ('08', '087', '088', '089')
			and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2018',101) as SMALLDATETIME)
			and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2018',101) as SMALLDATETIME)

)as temp
group by temp.[Main Itemgroup Code],
		 temp.[Main Itemgroup Name],
		 temp.[Itemgroup Code],
		 temp.[Itemgroup Name],
		 temp.[Item Code],
		 temp.[Item Name]

order by temp.[Itemgroup Name], temp.[Item Name]
