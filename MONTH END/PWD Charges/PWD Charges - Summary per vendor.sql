
select tempb.[Vendor Name]
	   ,tempb.vendor_code
	   ,tempb.[Item Code]
	   ,tempb.[Item Description]
	   ,tempb.[Retailer's Unit Price VAT In]
	   ,tempb.[Retailer's Unit Price VAT Ex]
	   ,total_qty = sum(tempb.total_qty)
	   ,total_charge = sum(tempb.total_charge)
	   ,[Total 20% PWD Discount] = (sum(tempb.total_charge))*.2
	   ,[Total Retailer's Share] = ((sum(tempb.total_charge))*.2)*.3
	   ,[Total	Manufacturer's Share] = ((sum(tempb.total_charge))*.2)*.7
	   ,[Total PWD Discount] = (sum(tempb.total_charge))*.2
	   ,tempb.[Item ID]
from (

select distinct temp.[Vendor Name]
	   ,temp.vendor_code
	   ,temp.[Item Code]
	   ,temp.[Item Description]
	   ,temp.[Retailer's Unit Price VAT In]
	   ,temp.[Retailer's Unit Price VAT Ex]
	   ,total_qty = sum(temp.total_qty)
	   ,total_charge = sum(temp.total_charge)
	   ,[20% PWD Discount] = (temp.total_charge *.2)
	   ,[30% of 20% PWD Discount] = ((temp.total_charge*.2)*.3)
	   ,[70% of 20% PWD Discount] = ((temp.total_charge*.2)*.7)
	   ,temp.[Item ID]

from (
select [Vendor Name]
	   ,vendor_code
	   ,Principal
	   ,[Item Code]
	   ,[Item Description]
	   ,[Invoice Date]
	   ,[Sales/Invoice Number]
	   ,[Retailer's Unit Price VAT In]
	   ,[Retailer's Unit Price VAT Ex]
	   ,total_qty = sum([Quantity Sold])
	   ,total_charge = sum([Charge Amount (VAT Ex)])
	   ,[Item ID]
	   --,HN
	   --,[Patient Name]
	   --,[OSCA ID No.]
	   --,Remarks

from AHMC_DataAnalyticsDB.dbo.pwd_charges
where --vendor_code in (@vendor_code)
      month([Invoice Date]) = 12
	  and year([Invoice Date]) = 2018
--where vendor_code in ('95')
--      and month([Invoice Date]) = 9
--	  and year([Invoice Date]) = 2018
	  --and HN = '00211766'
	  --and [Item Code] = '13028894'

group by [Vendor Name]
	   ,Principal
	   ,[Item Code]
	   ,[Item Description]
	   ,[Invoice Date]
	   ,[Sales/Invoice Number]
	   ,[Retailer's Unit Price VAT In]
	   ,[Retailer's Unit Price VAT Ex]
	   --,HN
	   --,[Patient Name]
	   --,[OSCA ID No.]
	   --,Remarks
	   ,vendor_code
	   ,[Item ID]

)as temp
--where temp.[Item Code] = '23001444'
group by temp.[Vendor Name]
	   ,temp.[Item Code]
	   ,temp.[Item Description]
	   ,temp.[Retailer's Unit Price VAT In]
	   ,temp.[Retailer's Unit Price VAT Ex]
	   ,temp.vendor_code
	   --,temp.[Invoice Date]
	   --,temp.[Sales/Invoice Number]
	   --,temp.total_qty
	   ,temp.total_charge
	   --,temp.HN
	   --,temp.[Patient Name]
	   --,temp.[OSCA ID No.]
	   --,temp.Remarks
	   ,temp.[Item ID]
)as tempb
group by tempb.[Vendor Name]
		 ,tempb.vendor_code
		 ,tempb.[Item Code]
		 ,tempb.[Item Description]
		 ,tempb.[Retailer's Unit Price VAT In]
		 ,tempb.[Retailer's Unit Price VAT Ex]
		 ,tempb.[Item ID]
order by [Item Description]