
select distinct temp.[Vendor Name]
	   ,temp.vendor_code
	   ,temp.Principal
	   ,temp.[Item Code]
	   ,temp.[Item Description]
	   ,temp.[Retailer's Unit Price VAT In]
	   ,temp.[Retailer's Unit Price VAT Ex]
	   ,total_qty_scd = sum(temp.total_qty)
	   ,total_sales = sum(temp.total_charge)
	   ,[Total 20% Senior Discount] = sum(temp.total_charge *.2)
	   ,[Total Retailer's Share] = sum((temp.total_charge*.2)*.3)
	   ,[Total	Manufacturer's Share] = sum((temp.total_charge*.2)*.7)
	   ,[Total Senior Citizen Discount] = sum(temp.total_charge *.2)
from (
select [Vendor Name]
	   ,vendor_code
	   ,Principal
	   ,[Item Code]
	   ,[Item Description]
	   ,[Retailer's Unit Price VAT In]
	   ,[Retailer's Unit Price VAT Ex]
	   ,total_qty = sum([Quantity Sold])
	   ,total_charge = sum([Charge Amount (VAT Ex)])

from AHMC_DataAnalyticsDB.dbo.scd_charges
where vendor_code in ('95')
      and month([Invoice Date]) = 9
	  and year([Invoice Date]) = 2018

group by [Vendor Name]
	   ,Principal
	   ,[Item Code]
	   ,[Item Description]
	   ,[Sales/Invoice Number]
	   ,[Retailer's Unit Price VAT In]
	   ,[Retailer's Unit Price VAT Ex]
	   ,vendor_code
	   ,[Item ID]

)as temp
--where temp.[Item Code] = '23001444'
group by temp.[Vendor Name]
		 ,temp.vendor_code
		 ,temp.Principal
		 ,temp.[Item Code]
		 ,temp.[Item Description]
		 ,temp.[Retailer's Unit Price VAT In]
		 ,temp.[Retailer's Unit Price VAT Ex]

order by Principal, [Item Description]