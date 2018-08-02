SELECT
	payment_period_detail_history.period_id,
	doctor.employee_nr,
	ISNULL(LTRIM(RTRIM(last_name_l)), '') + ', ' + ISNULL(LTRIM(RTRIM(first_name_l)), '') + ' ' + ISNULL(LTRIM(RTRIM(middle_name_l)), '') as [Name],
	item_desc,
	split_net_amount,
	split_tax_amount,
	tax_rate
	,payment_period.period_date		--added
FROM ITWORKSDS01.DIS.dbo.payment_period_detail_history
INNER JOIN ITWORKSDS01.DIS.dbo.doctor 
	ON doctor.employee_nr = payment_period_detail_history.employee_nr
INNER JOIN ITWORKSDS01.DIS.dbo.payment_period		--added
	ON payment_period_detail_history.period_id = payment_period.period_id
WHERE payment_period_detail_history.period_id >= 493 AND payment_period_detail_history.period_id <= 497




			