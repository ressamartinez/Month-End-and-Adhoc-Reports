DECLARE @table1 table
(
	visit_code varchar(20),
	vendor_name varchar(150),
	vendor_code varchar(40),
	principal varchar(255),
	item_code varchar(255),
	item_description varchar(450),
	invoice_date smalldatetime,
	invoice_number varchar(40),
	policy_name varchar(150),
	vat_in numeric(12,2),
	vat_ex money,
	quantity_sold numeric(12,2),
	charge_amount money,
	hn varchar(20),
	patient_name varchar(256),
	osca_id varchar(150),
	remarks varchar(255),
	short_code varchar(50),
	policy_id uniqueidentifier,
	charge_detail_id uniqueidentifier
)

INSERT into @table1 (visit_code,
					 vendor_name,
					 vendor_code,
					 principal,
					 item_code,
					 item_description,
					 invoice_date,
					 invoice_number,
					 policy_name,
					 vat_in,
					 vat_ex,
					 quantity_sold,
					 charge_amount,
					 hn,
					 patient_name,
					 osca_id,
					 remarks,
					 short_code,
					 policy_id,
					 charge_detail_id)

SELECT visit_code,
	   [Vendor Name] as vendor_name,
	   vendor_code,
	   Principal,
	   [Item Code] as item_code,
	   [Item Description] as item_description,
	   [Invoice Date] as invoice_date,
	   [Sales/Invoice Number] as invoice_number,
	   policy_name,
	   [Retailer's Unit Price VAT In] as vat_in,
	   [Retailer's Unit Price VAT Ex] as vat_ex,
	   [Quantity Sold] as quantity_sold,
	   [Charge Amount (VAT Ex)] as charge_amount,
	   HN,
	   [Patient Name] as patient_name,
	   [OSCA ID No.] as osca_id,
	   Remarks,
	   short_code,
	   policy_id,
	   [Charge Detail ID] as charge_detail_id
from AHMC_DataAnalyticsDB.dbo.scd_test_032719


select distinct *
	   ,[20% Senior Discount] = (tempb.total_charge *.2)
	   ,[30% of 20% Senior Citizen Discount] = ((tempb.total_charge*.2)*.3)
	   ,[70% of 20% Senior Citizen Discount] = ((tempb.total_charge*.2)*.7)

from (

		select * 
		from (
		select distinct visit_code
			   ,vendor_name
			   ,vendor_code
			   ,Principal
			   ,item_code
			   ,item_description
			   ,(select top 1 invoice_date from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code = '90') as invoice_date
				,(select top 1 invoice_number from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code = '90') as invoice_no 
				,(select top 1 policy_name from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code = '90') as policy_name 
				,(select top 1 vat_in from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code = '90') as vat_in
				,(select top 1 vat_ex from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code = '90') as vat_ex
	 			,(select sum(quantity_sold) from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code = '90') as total_qty
	   			,(select sum(charge_amount) from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code = '90') as total_charge
			   ,HN
			   ,patient_name
			   ,osca_id
			   ,Remarks
			   
 


		from @table1 t1
		where (select count(*) from @table1
				where visit_code = t1.visit_code
				and HN = t1.HN
				and policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2') > 0

		)as temp

		UNION ALL

		select * 
		from (
		select distinct visit_code
			   ,vendor_name
			   ,vendor_code
			   ,Principal
			   ,item_code
			   ,item_description
			   ,(select top 1 invoice_date from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411') or short_code is null) as invoice_date
				,(select top 1 invoice_number from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411') or short_code is null) as invoice_no  
				,(select top 1 policy_name from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411')) as policy_name
				,(select top 1 vat_in from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and charge_detail_id = t1.charge_detail_id) as vat_in
				,(select top 1 vat_ex from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and charge_detail_id = t1.charge_detail_id) as vat_ex
	 			,(select sum(quantity_sold) from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and charge_detail_id = t1.charge_detail_id) as total_qty
	   			,(select sum(charge_amount) from @table1
				where visit_code = t1.visit_code
					and HN = t1.HN
					and item_code = t1.item_code
					and short_code not in ('90', '91', '92', '93', '94', '95', '96', '411')  or short_code is null and charge_detail_id = t1.charge_detail_id) as total_charge
			   ,HN
			   ,patient_name
			   ,osca_id
			   ,Remarks
 

		from @table1 t1
		where (select count(*) from @table1
				where visit_code = t1.visit_code
				and HN = t1.HN
				and policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2') = 0

		)as temp

)as tempb
where policy_name is not null
and month(invoice_date) = 3
order by invoice_date, HN