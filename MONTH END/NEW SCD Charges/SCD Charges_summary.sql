
select tempb.[Vendor Name],
	   tempb.Principal,
	   tempb.[Item Code],
	   tempb.[Item Description],
	   tempb.[Retailer's Unit Price VAT In],
	   tempb.[Retailer's Unit Price VAT Ex],
	   total_qty = sum(tempb.total_qty),
	   total_charge = sum(tempb.total_charge),
	   [Total 20% Senior Discount] = sum(tempb.[Total 20% Senior Discount]),
	   [Total Retailer's Share] = sum(tempb.[Total Retailer's Share]),
	   [Total	Manufacturer's Share] = sum(tempb.[Total	Manufacturer's Share]),
	   [Total Senior Citizen Discount] = sum(tempb.[Total Senior Citizen Discount]),
	   tempb.[Item ID]

       
from
(

select temp.[Vendor Name],
       temp.Principal,
	   temp.[Item Code],
	   temp.[Item Description],
	   temp.[Retailer's Unit Price VAT In],
	   temp.[Retailer's Unit Price VAT Ex],
	   total_qty = sum(temp.[Total Quantity Sold]),
	   total_charge = sum(temp.[Total Charge Amount (VAT Ex)]),
	   [Total 20% Senior Discount] = sum([Total Charge Amount (VAT Ex)] *.2),
	   [Total Retailer's Share] = sum(([Total Charge Amount (VAT Ex)]*.2)*.3),
	   [Total	Manufacturer's Share] = sum(([Total Charge Amount (VAT Ex)]*.2)*.7),
	   [Total Senior Citizen Discount] = sum([Total Charge Amount (VAT Ex)] *.2),
	   temp.[Item ID]
	   --temp.[Charge Detail ID]

from (

select distinct 
         scd.[Vendor Name],
		 scd.vendor_code,
         scd.Principal,
		 scd.[Item Code],
		 scd.[Item ID],
		 scd.[Item Description],
		 --scd.[Invoice Date],
		 scd.[Sales/Invoice Number],
		 scd.[Retailer's Unit Price VAT In],
		 scd.[Retailer's Unit Price VAT Ex],
       case when scd.[Sales/Invoice Number] in (Select transaction_text from AmalgaPROD.dbo.ar_invoice) then 
				(select sum((cd.quantity)*(arh.credit_factor)) from AmalgaPROD.dbo.charge_detail_nl_view cd
																LEFT OUTER join AmalgaPROD.dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id 
																LEFT outer JOIN AmalgaPROD.dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id 
												
				where cd.item_id = scd.[Item ID]
					  and transaction_text = scd.[Sales/Invoice Number]
					  and ard.quantity >= 0) else sum(scd.[Quantity Sold]) 
					  end as [Total Quantity Sold],
		case when scd.[Sales/Invoice Number] in (Select transaction_text from AmalgaPROD.dbo.ar_invoice) then 
				(select sum((cd.amount)*(arh.credit_factor)) from AmalgaPROD.dbo.charge_detail_nl_view cd 
																 LEFT OUTER join AmalgaPROD.dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id 
																 LEFT outer JOIN AmalgaPROD.dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id 
				where cd.item_id = scd.[Item ID]
				      and transaction_text = scd.[Sales/Invoice Number]
					  and ard.quantity >= 0) else sum(scd.[Charge Amount (VAT Ex)]) 
					  end as [Total Charge Amount (VAT Ex)]
   --      scd.HN,
		 --scd.[Patient Name],
		 --scd.[OSCA ID No.],
		 --scd.[Policy Name],
		 --scd.Pharmacy,
		 --scd.Remarks

		 --scd.[Charge Detail ID]

from AHMC_DataAnalyticsDB.dbo.scd_charges scd
--where scd.vendor_code = '95'
   --   --and scd.[Sales/Invoice Number] = 'PINV-2018-254573'
	  --[Item Code] = '290440862'
	  --[Item ID] = 'FDE77DF2-56E9-4449-8902-7F77A344C75E'


where scd.vendor_code in ('95')
      and month(scd.[Invoice Date]) = 9
	  and year(scd.[Invoice Date]) = 2018



group by scd.[Vendor Name],
         scd.Principal,
		 scd.[Item Code],
		 scd.[Item Description],
		 --scd.[Invoice Date],
		 scd.[Sales/Invoice Number],
		 scd.[Retailer's Unit Price VAT In],
		 scd.[Retailer's Unit Price VAT Ex],
		 scd.[Quantity Sold],
		 scd.[Charge Amount (VAT Ex)],
		 --scd.HN,
		 --scd.[Patient Name],
		 --scd.[OSCA ID No.],
		 --scd.[Policy Name],
		 --scd.Pharmacy,
		 --scd.Remarks,
		 scd.[20% Senior Discount],
		 scd.[30% of 20% Senior Citizen Discount],
		 scd.[70% of 20% Senior Citizen Discount],
		 scd.[Item ID],
		 scd.vendor_code
		 --scd.[Charge Detail ID]
	 
) as temp
group by temp.[Vendor Name],
         temp.Principal,
		 temp.[Item Code],
		 temp.[Item Description],
		 temp.[Retailer's Unit Price VAT In],
		 temp.[Retailer's Unit Price VAT Ex],
		 temp.[Total Quantity Sold],
		 temp.[Total Charge Amount (VAT Ex)],
		 temp.[Item ID]
		 --temp.[Charge Detail ID]

) as tempb
group by tempb.[Item ID],
		 tempb.[Vendor Name],
		 tempb.Principal,
		 tempb.[Item Code],
		 tempb.[Item Description],
		 tempb.[Retailer's Unit Price VAT In],
		 tempb.[Retailer's Unit Price VAT Ex]
order by Principal, [Item Description]
