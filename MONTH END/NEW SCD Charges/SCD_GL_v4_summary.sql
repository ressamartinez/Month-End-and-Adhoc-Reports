
select *
       ,tempb.charge_amount * .20 as discount_amount
	   ,tempb.charge_amount * .20 * .30 as retailers_share
	   ,tempb.charge_amount * .20 * .70 as manufacturers_share
from (

select *
	   ,temp.vat_ex * temp.quantity as charge_amount 
from (

		SELECT DISTINCT
			   visit_code
			   ,vendor_code
			   ,vendor_name
			   ,principal
			   ,main_group_code
			   ,main_group_name
			   ,item_group_code
			   ,item_group_name
			   ,item_code
			   ,item_name
			   --,scd.[Organisation Type]
			   ,(select top 1 invoice_no from scd_detailed_062419 
					   where visit_code = scd.visit_code
							 and hn = scd.hn) as invoice_no
				,(select top 1 invoice_date from scd_detailed_062419 
					   where visit_code = scd.visit_code
							 and hn = scd.hn) as invoice_date
			   ,(select top 1 vat_in from scd_detailed_062419 
					   where visit_code = scd.visit_code
							 and hn = scd.hn
							 and item_code = scd.item_code) as vat_in
			   ,(select top 1 vat_ex from scd_detailed_062419 
					   where visit_code = scd.visit_code
							 and hn = scd.hn
							 and item_code = scd.item_code) as vat_ex
			   ,(select sum(quantity) from scd_detailed_062419 
					   where visit_code = scd.visit_code
							 and hn = scd.hn
							 and item_code = scd.item_code
							 and invoice_no = scd.invoice_no) as quantity
			   --,(select sum(charge_amount) from scd_detailed_062419 
					 --  where visit_code = scd.visit_code
						--	 and hn = scd.hn
						--	 and item_code = scd.item_code) as charge_amount
			   --,(select sum(discount_amount) from scd_detailed_062419 
					 --  where visit_code = scd.visit_code
						--	 and hn = scd.hn
						--	 and item_code = scd.item_code) as discount_amount
			   --,(select sum(retailers_share) from scd_detailed_062419 
					 --  where visit_code = scd.visit_code
						--	 and hn = scd.hn
						--	 and item_code = scd.item_code) as retailers_share
			   --,(select sum(manufacturers_share) from scd_detailed_062419 
					 --  where visit_code = scd.visit_code
						--	 and hn = scd.hn
						--	 and item_code = scd.item_code) as manufacturers_share
			   ,hn
			   ,patient_name
			   ,osca_id
			   ,remarks

		from scd_detailed_062419 scd
		)as temp

)as tempb
where month(tempb.invoice_date) = 6
and year(tempb.invoice_date) = 2019
--and hn = '00241493'
--and hn = '00040185'
--and tempb.item_code = '23001534'
order by tempb.hn, tempb.invoice_no, tempb.item_code