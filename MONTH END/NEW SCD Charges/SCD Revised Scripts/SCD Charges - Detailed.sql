
select distinct *
	   ,total_qty = sum(temp.total_qty)
	   ,total_charge = sum(temp.total_charge)
	   ,[20% Senior Discount] = (temp.total_charge *.2)
	   ,[30% of 20% Senior Citizen Discount] = ((temp.total_charge*.2)*.3)
	   ,[70% of 20% Senior Citizen Discount] = ((temp.total_charge*.2)*.7)

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
	   ,HN
	   ,[Patient Name]
	   ,[OSCA ID No.]
	   ,Remarks

from AHMC_DataAnalyticsDB.dbo.scd_charges
--where vendor_code in (@vendor_code)
--      and month([Invoice Date]) = @Month
--	  and year([Invoice Date]) = @Year
where vendor_code in ('95')
      and month([Invoice Date]) = 9
	  and year([Invoice Date]) = 2018
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
	   ,HN
	   ,[Patient Name]
	   ,[OSCA ID No.]
	   ,Remarks
	   ,vendor_code
	   ,[Item ID]

)as temp
--where temp.[Item Code] = '23001444'
group by temp.[Vendor Name]
	   ,temp.Principal
	   ,temp.[Item Code]
	   ,temp.[Item Description]
	   ,temp.[Retailer's Unit Price VAT In]
	   ,temp.[Retailer's Unit Price VAT Ex]
	   ,temp.vendor_code
	   ,temp.[Invoice Date]
	   ,temp.[Sales/Invoice Number]
	   ,temp.total_qty
	   ,temp.total_charge
	   ,temp.HN
	   ,temp.[Patient Name]
	   ,temp.[OSCA ID No.]
	   ,temp.Remarks


order by Principal, [Item Description]