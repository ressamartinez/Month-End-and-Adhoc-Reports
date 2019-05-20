
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
			   ,(select top 1 [Invoice Date] from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code = '309') as invoice_date
				,(select top 1 [Sales/Invoice Number] from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code = '309') as invoice_no 
				,(select top 1 policy from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code = '309') as policy_name 
				,(select top 1 [Retailer's Unit Price VAT In] from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code = '309') as vat_in
				,(select top 1 [Retailer's Unit Price VAT Ex] from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code = '309') as vat_ex
	 			,(select sum([Quantity Sold]) from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code = '309') as total_qty
	   			,(select sum([Charge Amount (VAT Ex)]) from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code = '309') as total_charge
			   ,HN
			   ,[Patient Name]
			   ,Remarks
			   
 


		from pwd_test_040819 pwd
		where (select count(*) from pwd_test_040819
				where visit_code = pwd.visit_code
				and HN = pwd.HN
				and short_code = '309') > 0

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
			   ,(select top 1 [Invoice Date] from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code not in ('309', '91', '92', '93', '94', '95', '96', '411') or short_code is null) as invoice_date
				,(select top 1 [Sales/Invoice Number] from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code not in ('309', '91', '92', '93', '94', '95', '96', '411') or short_code is null) as invoice_no  
				,(select top 1 policy from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and short_code not in ('309', '91', '92', '93', '94', '95', '96', '411')) as policy_name
				,(select top 1 [Retailer's Unit Price VAT In] from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code not in ('309', '91', '92', '93', '94', '95', '96', '411') or short_code is null and [Charge Detail ID] = pwd.[Charge Detail ID]) as vat_in
				,(select top 1 [Retailer's Unit Price VAT Ex] from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code not in ('309', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and [Charge Detail ID] = pwd.[Charge Detail ID]) as vat_ex
	 			,(select sum([Quantity Sold]) from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code not in ('309', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and [Charge Detail ID] = pwd.[Charge Detail ID]) as total_qty
	   			,(select sum([Charge Amount (VAT Ex)]) from pwd_test_040819
				where visit_code = pwd.visit_code
					and HN = pwd.HN
					and [Item Code] = pwd.[Item Code]
					and short_code not in ('309', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and [Charge Detail ID] = pwd.[Charge Detail ID]) as total_charge
			   ,HN
			   ,[Patient Name]
			   ,Remarks
 

		from pwd_test_040819 pwd
		where (select count(*) from pwd_test_040819
				where visit_code = pwd.visit_code
				and HN = pwd.HN
				and short_code = '309') = 0

		)as temp
		

)as tempb
where policy_name is not null
--and tempb.HN = '00573908'
order by invoice_date, HN