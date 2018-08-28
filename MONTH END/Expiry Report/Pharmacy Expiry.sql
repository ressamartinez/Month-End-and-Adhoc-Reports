

select 
		store as Store, 
		item_code as [Item Code],
		item as Item,
		cast(qty_on_hand as int) as Quantity,
		convert(varchar(20),cast(expiry_date as DATE),101) as [Expiry Date],
		DATEDIFF(dd,getdate(),expiry_date) as [Days before Expiry]
		from HISViews.dbo.vw_item_expiry_view
		where expiry_date <= DATEADD(dd,180,GETDATE()) and
		store like '%e-cart%'
		and store like '%pharmacy%'
		order by store