SELECT temp.employee_nr as [Employee NR],
	   isnull(temp.caregiver,'No assigned physician') as [Doctor Name],
	   temp.upi as HN,
	   temp.patientname as [Patient Name],
	   temp.item_code as [Item Code],
	   temp.item_desc as [Item Desc],
	   temp.gross_amount as [Gross Amount],
	   temp.discount_amount as [Discount Amount],
	   temp.tax_amount as [Tax Amount],
	   temp.net_amount as [Net Amount],
	   temp.charge_date as [Charge Date]
from
(
select dba.employee_nr,
	   rtrim(dba.caregiver_fname) + ', ' + rtrim(dba.caregiver_fname) as caregiver,
	   dba.upi,
	   RTRIM(dba.lname) + ', ' + RTRIM(dba.fname) as patientname,
	   dba.item_code,
	   dba.item_desc,
	   ppdh.split_gross_amount as gross_amount,
	   ppdh.split_discount_amount_scd + ppdh.split_discount_amount_oth  as discount_amount,
	   ppdh.split_tax_amount as tax_amount,
	   ppdh.split_net_amount as net_amount,
	   dba.charge_date,
	   pp.pay_date,
	   cg.costcentre_group_description

from payment_period_detail_history ppdh inner JOIN df_browse_all dba on ppdh.charge_id = dba.charge_id
										inner join payment_period pp on ppdh.period_id = pp.period_id
										inner JOIN costcentre_group cg on dba.costcentre_group_id = cg.costcentre_group_id
where
 ppdh.period_id = 550
   --and 
    -- YEAR(pp.pay_date) = 2019   
   --dba.visit_type = 'Emergency Room'
  ) as temp
order by temp.pay_date,temp.employee_nr


SELECT *
from payment_period
order by period_id DESC


