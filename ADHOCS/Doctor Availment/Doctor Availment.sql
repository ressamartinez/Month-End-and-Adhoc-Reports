SELECT temp.claim_code as [Claim Code],
	   temp.created_date as [Created Date],
	   CONVERT(VARCHAR(20), temp.created_date,101) AS [Date Created],
	   FORMAT(temp.created_date,'hh:mm tt') AS [Time Created],
	   CAST((temp.claim_amount) AS DECIMAL(10,2)) as [Claim Amount],
	   temp.hn as HN,
	   temp.patient_name as [Patient Name],
	   temp.organisation_name as [Organisation Name],
	   CAST((temp.paid_amount) AS DECIMAL(10,2)) as [Paid Amount],
	   temp.invoice_no as [Invoice Number],
	   temp.invoice_date as [Invoice DateTime],
	   CONVERT(VARCHAR(20), temp.invoice_date,101) AS [Invoice Date],
		FORMAT(temp.invoice_date,'hh:mm tt') AS [Invoice Time],
	   temp.last_payment as [Last Payment DateTime],
	   	CONVERT(VARCHAR(20), temp.last_payment,101) AS [Last Payment Date],
		FORMAT(temp.last_payment,'hh:mm tt') AS [Last Payment Time],
	   CAST((temp.gross_amount) AS DECIMAL(10,2)) as [Gross Amount],
	   CAST((temp.discount_amount) AS DECIMAL(10,2)) as [Discount Amount],
	   CAST((temp.net_amount) AS DECIMAL(10,2)) as [Net Amount],
	   temp.policy_code as [Policy Code] ,
	   temp.visit_type_group_rcd as [Visit Type Group],
	   temp.visit_code as [Visit No.],
	   temp.visit_start as [Visit Start],
	   	CONVERT(VARCHAR(20), temp.visit_start,101) AS [Visit Start Date],
		FORMAT(temp.visit_start,'hh:mm tt') AS [Visit Start Time],
	   temp.closure_date as [Closure DateTime],
	   	CONVERT(VARCHAR(20), temp.closure_date,101) AS [Closure Date],
		FORMAT(temp.closure_date,'hh:mm tt') AS [Closure Time],
	   temp.diagnosis as Diagnosis
from
(
	SELECT DISTINCT inv.invoice_no,
		   ar.transaction_date_time as invoice_date,
		   p.short_code as policy_code,
		   p.name_l as policy_name,
		   pv.actual_visit_date_time as visit_start,
		   pv.closure_date_time as closure_date,
		   pc.claim_code,
		   pc.claim_amount,
		   pc.created_date,
		   phu.visible_patient_id as hn,
		   pfn.display_name_l as patient_name,
		   isnull((SELECT sum(a.net_amount) as paid_amount
				from swe_ar_instalment a inner JOIN ar_invoice b on a.ar_invoice_id = b.ar_invoice_id
										 inner JOIN remittance c on a.remittance_id = c.remittance_id
				where a.ar_invoice_id = inv.invoice_id
					and c.transaction_status_rcd not in ('voi','unk')),0) as paid_amount,
		  ISNULL((SELECT TOP 1  c.transaction_date_time
				from swe_ar_instalment a inner JOIN ar_invoice b on a.ar_invoice_id = b.ar_invoice_id
										 inner JOIN remittance c on a.remittance_id = c.remittance_id
				where a.ar_invoice_id = inv.invoice_id
					 and c.transaction_status_rcd not in ('voi','unk')
				order by c.transaction_date_time desc),'') last_payment,
		  pv.visit_code,
		 (SELECT description 
			FROM coding_system_element_description_nl_view 
			WHERE coding_system_rcd = pvd.coding_system_rcd AND code = pvd.code) as diagnosis,
		  ar.gross_amount,
		   ar.discount_amount,
		  ar.net_amount,
		  inv.patient_visit_id,
		  pvd.diagnosis_type_rcd,
		  pc.policy_subscription_id,
		  pc.visit_type_group_rcd,
		 case when ou.name_l = 'Asian Hospital' then 'Asian Hospital And Medical Center' else ou.name_l END as organisation_name
	from HISReport.dbo.rpt_invoice_pf_detailed inv inner JOIN ar_invoice_nl_view ar on inv.invoice_id = ar.ar_invoice_id
										     --  inner JOIN HISReport.dbo.rpt_invoice_pf_detailed invd on inv.invoice_id = invd.invoice_id
											  
											   inner JOIN patient_visit_nl_view pv on inv.patient_visit_id = pv.patient_visit_id
											   inner JOIN policy_claim_nl_view pc on pv.patient_visit_id = pc.patient_visit_id
											   inner JOIN patient_hospital_usage_nl_view phu on inv.patient_id = phu.patient_id
											   inner JOIN person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
											   LEFT outer JOIN patient_visit_diagnosis_view pvd on pv.patient_visit_id = pvd.patient_visit_id 
											   inner JOIN policy_subscription_nl_view ps on pc.policy_subscription_id = ps.policy_subscription_id
											   inner JOIN policy p on ps.policy_id = p.policy_id
											   inner JOIN organizational_unit ou on pv.facility_id = ou.organizational_unit_id
	where--   MONTH(pc.created_date) = 1 --and MONTH(inv.transaction_date_time) <= 2
		 YEAR(pc.created_date) >= @From and  YEAR(pc.created_date) <= @To
		and ar.system_transaction_type_rcd = 'INVR'
		and p.short_code in ('335',
							 '398',
							 '339',
							 '399',
							 '271',
							 '272',
							 '297')
		and pc.claim_status_rcd = 'CLO'
		and pvd.current_visit_diagnosis_flag = 1
		and pvd.diagnosis_type_rcd = 'dis'
	    and p.policy_id = inv.policy_id
	union ALL
	SELECT DISTINCT inv.invoice_no,
		   ar.transaction_date_time as invoice_date,
		   p.short_code as policy_code,
		   p.name_l as policy_name,
		   pv.actual_visit_date_time as visit_start,
		   pv.closure_date_time as closure_date,
		   pc.claim_code,
		   pc.claim_amount,
		   pc.created_date,
		   phu.visible_patient_id as hn,
		   pfn.display_name_l as patient_name,
		   isnull((SELECT sum(a.net_amount) as paid_amount
				from swe_ar_instalment a inner JOIN ar_invoice b on a.ar_invoice_id = b.ar_invoice_id
										 inner JOIN remittance c on a.remittance_id = c.remittance_id
				where a.ar_invoice_id = inv.invoice_id
					and c.transaction_status_rcd not in ('voi','unk')),0) as paid_amount,
		  ISNULL((SELECT TOP 1  c.transaction_date_time
				from swe_ar_instalment a inner JOIN ar_invoice b on a.ar_invoice_id = b.ar_invoice_id
										 inner JOIN remittance c on a.remittance_id = c.remittance_id
				where a.ar_invoice_id = inv.invoice_id
					 and c.transaction_status_rcd not in ('voi','unk')
				order by c.transaction_date_time desc),'') last_payment,
		  pv.visit_code,
		 '' as diagnosis,
		  ar.gross_amount,
		   ar.discount_amount,
		  ar.net_amount,
		  inv.patient_visit_id,
		  '' as diagnosis_type_rcd,
		  pc.policy_subscription_id,
		  pc.visit_type_group_rcd,
		  case when ou.name_l = 'Asian Hospital' then 'Asian Hospital And Medical Center' else ou.name_l END as organisation_name
	from HISReport.dbo.rpt_invoice_pf_detailed inv inner JOIN ar_invoice_nl_view ar on inv.invoice_id = ar.ar_invoice_id
										       inner JOIN patient_visit_nl_view pv on inv.patient_visit_id = pv.patient_visit_id
											   inner JOIN policy_claim_nl_view pc on pv.patient_visit_id = pc.patient_visit_id
											   inner JOIN patient_hospital_usage_nl_view phu on inv.patient_id = phu.patient_id
											   inner JOIN person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
											   LEFT outer JOIN patient_visit_diagnosis_view pvd on pv.patient_visit_id = pvd.patient_visit_id 
											   inner JOIN policy_subscription_nl_view ps on pc.policy_subscription_id = ps.policy_subscription_id
											   inner JOIN policy p on ps.policy_id = p.policy_id
											   inner JOIN organizational_unit ou on pv.facility_id = ou.organizational_unit_id
	where  -- MONTH(pc.created_date) = 1 --and MONTH(inv.transaction_date_time) <= 2
		YEAR(pc.created_date) >= @From and  YEAR(pc.created_date) <= @To
		and ar.system_transaction_type_rcd = 'INVR'
		and p.short_code in ('335',
							 '398',
							 '339',
							 '399',
							 '271',
							 '272',
							 '297')
		and pc.claim_status_rcd = 'CLO'
		and p.policy_id = inv.policy_id
		and ar.ar_invoice_id not in (SELECT DISTINCT inv.invoice_id
									from HISReport.dbo.rpt_invoice_pf_detailed inv inner JOIN ar_invoice_nl_view ar on inv.invoice_id = ar.ar_invoice_id
										      inner JOIN patient_visit_nl_view pv on inv.patient_visit_id = pv.patient_visit_id
											   inner JOIN policy_claim_nl_view pc on pv.patient_visit_id = pc.patient_visit_id
											   inner JOIN patient_hospital_usage_nl_view phu on inv.patient_id = phu.patient_id
											   inner JOIN person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
											   LEFT outer JOIN patient_visit_diagnosis_view pvd on pv.patient_visit_id = pvd.patient_visit_id 
											   inner JOIN policy_subscription_nl_view ps on pc.policy_subscription_id = ps.policy_subscription_id
											   inner JOIN policy p on ps.policy_id = p.policy_id 
									where   --MONTH(pc.created_date) = 1 --and MONTH(inv.transaction_date_time) <= 2
										YEAR(pc.created_date) >= @From and  YEAR(pc.created_date) <= @To
										and ar.system_transaction_type_rcd = 'INVR'
										and p.short_code in ('335',
															 '398',
															 '339',
															 '399',
															 '271',
															 '272',
															 '297')
										and pc.claim_status_rcd = 'CLO'
										and pvd.current_visit_diagnosis_flag = 1
										and pvd.diagnosis_type_rcd = 'dis'
										and p.policy_id = inv.policy_id)

) as temp
order by temp.created_date, temp.invoice_no