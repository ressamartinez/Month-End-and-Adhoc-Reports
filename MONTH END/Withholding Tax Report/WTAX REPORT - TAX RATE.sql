SELECT
	period_id,
	doctor.employee_nr,
	ISNULL(LTRIM(RTRIM(last_name_l)), '') + ', ' + ISNULL(LTRIM(RTRIM(first_name_l)), '') + ' ' + ISNULL(LTRIM(RTRIM(middle_name_l)), '') as [Name],
	item_desc,
	split_net_amount,
	split_tax_amount,
	tax_rate
FROM ITWORKSDS01.DIS.dbo.payment_period_detail_history
INNER JOIN ITWORKSDS01.DIS.dbo.doctor
	ON doctor.employee_nr = payment_period_detail_history.employee_nr
WHERE period_id >= @period_from AND period_id <= @period_to


--SELECT *
--FROM payment_period
