
select pp.period_id,
	   pp.period_date,
	   d.employee_nr,
	   RTRIM(ISNULL(d.last_name_l,0)) + ', ' + RTRIM(ISNULL(d.first_name_l,0)) + ' ' + RTRIM(ISNULL(d.middle_name_l,'')) as doctor_name,
	   ppdh.upi,
	   ppdh.pname,
       ppdh.item_desc,
       ppdh.charge_date,
	   ppdh.vat_rate,
	   ppdh.tax_rate,
	   ppdh.charge_amount,
	   ppdh.gross_amount,
	   ppdh.discount_amount,
	   ppdh.discount_amount_scd,
	   ppdh.discount_amount_oth,
	   ppdh.adjustment_amount,
	   ppdh.net_amount,
	   ppdh.vat_amount,
	   ppdh.tax_base_amount,
	   ppdh.tax_amount,
	   ppdh.commission_rate,
	   ppdh.merchant_discount,
	   ppdh.credited_amount,
	   ppdh.split_tax_rate,
	   ppdh.split_gross_amount,
	   ppdh.split_discount_amount_scd,
	   ppdh.split_discount_amount_oth,
	   ppdh.split_adjustment_amount,
       ppdh.split_net_amount,
	   ppdh.split_vat_amount,
	   ppdh.split_tax_base_amount,
	   ppdh.split_tax_amount,
	   ppdh.split_merchant_discount,
	   ppdh.split_credited_amount,
	   ppdh.accumulated_net_amount,
	   ppdh.policy_group,
       ppdh.prev_paid_amount


from payment_period_detail_history ppdh
	 left outer join payment_period pp on pp.period_id = ppdh.period_id
	 left outer join doctor d on d.employee_nr = ppdh.employee_nr

where year(pp.period_date) between 2017 and 2018
	  and ppdh.account_id is null

order by ppdh.period_id

