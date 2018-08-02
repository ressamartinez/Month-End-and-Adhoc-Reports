--ALL PWD DISCOUNT
SELECT temp.[Invoice Date] as ind,
		CONVERT(VARCHAR(20), temp.[Invoice Date],101) AS [Invoice Date],
		FORMAT(temp.[Invoice Date],'hh:mm tt') AS [Invoice Time],
	   temp.[Invoice No.],
	   temp.[Patient  Name],
	   temp.HN,
	   CONVERT(VARCHAR(20), temp.[Date of Birth],101) AS [Date of Birth],
	   temp.Age,
	   temp.[GL Account Code],
	   temp.[GL Account Name],
	   temp.[Policy Name],
	   temp.[Discount Rule],
	   temp.[Visit Type],
	   temp.[Visit Type Group],
	   temp.[Item Code],
	   temp.[Item Name],
	   temp.[Item Type],
	   CAST(SUM(temp.[Gross Amount]) as DECIMAL(10,2)) as [Gross Amount],
	   CAST(SUM(temp.[Discount Amount]) AS DECIMAL(10,2)) as [Discount Amount],
	   CAST(SUM(temp.[Net Amount]) AS DECIMAL(10,2)) as [Net Amount]
from 
(
	SELECT DISTINCT ard.ar_invoice_detail_id,
		   arh.transaction_date_time as [Invoice Date],
			arh.transaction_text as [Invoice No.],
			pfn.display_name_l as [Patient  Name],
			phu.visible_patient_id as HN,
			pfn.date_of_birth as [Date of Birth],
			DATEDIFF(dd, pfn.date_of_birth, GETDATE()) / 365 as Age,
			gac.gl_acct_code_code as [GL Account Code],
			gac.name_l as [GL Account Name],
			p.name_l as [Policy Name],
			dpr.name_l as [Discount Rule],
			vtr.name_l as [Visit Type],
			vtr.visit_type_group_rcd as [Visit Type Group],
			i.item_code as [Item Code],
			i.name_l as [Item Name],
			itr.name_l as [Item Type],
			ard.gross_amount as [Gross Amount],
			ard.discount_amount as [Discount Amount],
			(ard.gross_amount - ard.discount_amount) as [Net Amount]
	FROM dbo.charge_detail_nl_view AS cd INNER JOIN dbo.patient_visit_nl_view AS pv ON cd.patient_visit_id = pv.patient_visit_id
															LEFT OUTER JOIN dbo.patient_visit_policy as pvp ON pv.patient_visit_id = pvp.patient_visit_id
															LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
															LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
															inner JOIN dbo.policy p on arh.policy_id = p.policy_id
															inner join dbo.item i on ard.item_id = i.item_id
															INNER JOIN dbo.person_formatted_name_iview as pfn ON pv.patient_id = pfn.person_id
															LEFT OUTER JOIN dbo.patient_hospital_usage as phu ON pv.patient_id = phu.patient_id
															inner JOIN gl_acct_code gac on cd.gl_acct_code_id = gac.gl_acct_code_id
															inner JOIN visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd
															inner JOIN item_type_ref itr on i.item_type_rcd = itr.item_type_rcd
															inner JOIN discount_posting_rule dpr on ard.discount_posting_rule_id = dpr.discount_posting_rule_id
	WHERE --MONTH(arh.transaction_date_time) = 12
			 --YEAR(arh.transaction_date_time) >= @From and YEAR(arh.transaction_date_time) <= @To
			 --YEAR(arh.transaction_date_time) >= 2016 and YEAR(arh.transaction_date_time) <= 2018
			arh.transaction_date_time BETWEEN @From AND @To
			and ard.discount_posting_rule_id = '60AF2DE3-04C9-11DF-AA84-0021912231AF'
			and arh.transaction_status_rcd not in  ('voi','unk')
			AND arh.swe_payment_status_rcd IN ('UNP','COM')
			and cd.deleted_date_time is NULL
			and arh.user_transaction_type_id in ('F8EF2162-3311-11DA-BB34-000E0C7F3ED2','30957FA1-735D-11DA-BB34-000E0C7F3ED2')
			and ard.gross_amount > 0
) as temp
GROUP BY  temp.[Invoice Date],
	   temp.[Invoice No.],
	   temp.[Patient  Name],
	   temp.HN,
	   temp.[Date of Birth],
	   temp.Age,
	   temp.[GL Account Code],
	   temp.[GL Account Name],
	   temp.[Policy Name],
	   temp.[Discount Rule],
	   temp.[Visit Type],
	   temp.[Visit Type Group],
	   temp.[Item Code],
	   temp.[Item Name],
	   temp.[Item Type]
order by temp.[Invoice Date]