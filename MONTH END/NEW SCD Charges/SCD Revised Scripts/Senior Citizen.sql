--select * from AHMC_DataAnalyticsDB.dbo.scd_test_summary

select distinct *
	   ,[20% Senior Discount] = (tempb.total_charge *.2)
	   ,[30% of 20% Senior Citizen Discount] = ((tempb.total_charge*.2)*.3)
	   ,[70% of 20% Senior Citizen Discount] = ((tempb.total_charge*.2)*.7)

from (

		select * 
		from (
		select distinct visit_code
			   ,[Vendor Name]
			   ,vendor_code
			   ,Principal
			   ,[Item Code]
			   ,[Item Description]
			   ,(select top 1 [Invoice Date] from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code = '90') as invoice_date
				,(select top 1 [Sales/Invoice Number] from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code = '90') as invoice_no 
				,(select top 1 policy_name from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code = '90') as policy_name 
				,(select top 1 [Retailer's Unit Price VAT In] from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code = '90') as vat_in
				,(select top 1 [Retailer's Unit Price VAT Ex] from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code = '90') as vat_ex
	 			,(select sum([Quantity Sold]) from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code = '90') as total_qty
	   			,(select sum([Charge Amount (VAT Ex)]) from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code = '90') as total_charge
			   ,HN
			   ,[Patient Name]
			   ,[OSCA ID No.]
			   ,Remarks
			   
 


		from scd_test_032719 scd
		where (select count(*) from scd_test_032719
				where visit_code = scd.visit_code
				and HN = scd.HN
				and policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2') > 0

		)as temp

		UNION ALL

		select * 
		from (
		select distinct visit_code
			   ,[Vendor Name]
			   ,vendor_code
			   ,Principal
			   ,[Item Code]
			   ,[Item Description]
			   ,(select top 1 [Invoice Date] from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411') or short_code is null) as invoice_date
				,(select top 1 [Sales/Invoice Number] from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411') or short_code is null) as invoice_no  
				,(select top 1 policy_name from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
				and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411')) as policy_name
				,(select top 1 [Retailer's Unit Price VAT In] from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and [Charge Detail ID] = scd.[Charge Detail ID]) as vat_in
				,(select top 1 [Retailer's Unit Price VAT Ex] from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and [Charge Detail ID] = scd.[Charge Detail ID]) as vat_ex
	 			,(select sum([Quantity Sold]) from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and [Charge Detail ID] = scd.[Charge Detail ID]) as total_qty
	   			,(select sum([Charge Amount (VAT Ex)]) from scd_test_032719
				where visit_code = scd.visit_code
					and HN = scd.HN
					and [Item Code] = scd.[Item Code]
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and [Charge Detail ID] = scd.[Charge Detail ID]) as total_charge
			   ,HN
			   ,[Patient Name]
			   ,[OSCA ID No.]
			   ,Remarks
 

		from scd_test_032719 scd
		where (select count(*) from scd_test_032719
				where visit_code = scd.visit_code
				and HN = scd.HN
				and policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2') = 0

		)as temp

)as tempb
where policy_name is not null
and month(invoice_date) = 3
order by invoice_date, HN