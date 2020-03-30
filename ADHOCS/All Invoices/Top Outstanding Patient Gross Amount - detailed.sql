DECLARE @dFrom datetime
DECLARE @dTo datetime
SET @dFrom = /*@From*/ '01/01/2008 00:00:00.000'
SET @dTo = /*@To*/ '11/30/2019 23:59:59.998'

select DISTINCT tempb.HN,
       tempb.[Patient Name],
	   tempb.[Visit Code],
	   tempb.[Visit Start],
	   tempb.[Invoice Date],
	   tempb.[Invoice No.],
	   tempb.[Gross Amount],
	   tempb.[Visit Type]
	   --,tempb.[Visit Type Name]

from (

	select DISTINCT temp.HN,
		   temp.[Patient Name],
		   temp.[Visit Code],
		   temp.[Visit Start],
		   temp.[Invoice Date],
		   temp.[Invoice No.],
		   temp.[Gross Amount],
		   temp.[Visit Type],
	       temp.[Visit Type Name]

	from
	(
		SELECT DISTINCT
			   phu.visible_patient_id as HN,
			   pfn.display_name_l as [Patient Name],
			   pv.visit_code as [Visit Code],
			   pv.actual_visit_date_time as [Visit Start],
			   ar.transaction_date_time as [Invoice Date],
			   ar.transaction_text as [Invoice No.],
			   ar.gross_amount * ar.credit_factor as [Gross Amount],
			   vtr.visit_type_group_rcd as [Visit Type],
	           vtr.name_l as [Visit Type Name]

		from ar_invoice ar left JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
						   left join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
						   left join patient_visit pv on cd.patient_visit_id = pv.patient_visit_id
						   left join patient_hospital_usage phu on pv.patient_id = phu.patient_id
						   left join person_formatted_name_iview pfn on phu.patient_id = pfn.person_id
						   left JOIN visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd

		where ar.transaction_status_rcd not in ('voi','unk')
			  and ar.swe_payment_status_rcd = 'COM'
			  and cd.deleted_date_time is NULL
			  and pv.cancelled_date_time is NULL
			  and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'    --PINV
			  and phu.visible_patient_id not in ('00501729', '00503183',    --Pharmacy, OPD - Pharmacy, OPD 2
			                                     '00000001', '00000002')    --Retail Pharmacy 1, Test Patient - Retail, Pharmacy 2
			  and vtr.visit_type_rcd in ('V1', 'V2')

	)as temp

	UNION ALL

	select DISTINCT temp.HN,
		   temp.[Patient Name],
		   temp.[Visit Code],
		   temp.[Visit Start],
		   temp.[Invoice Date],
		   temp.[Invoice No.],
		   temp.[Gross Amount],
		   temp.[Visit Type],
		   temp.[Visit Type Name]

	from
	(
		SELECT DISTINCT
			   phu.visible_patient_id as HN,
			   pfn.display_name_l as [Patient Name],
			   pv.visit_code as [Visit Code],
			   pv.actual_visit_date_time as [Visit Start],
			   ar.transaction_date_time as [Invoice Date],
			   ar.transaction_text as [Invoice No.],
			   ar.gross_amount * ar.credit_factor as [Gross Amount],
			   vtr.visit_type_group_rcd as [Visit Type],
			   vtr.name_l as [Visit Type Name]

		from ar_invoice ar left JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
						   left join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
						   left join patient_visit pv on cd.patient_visit_id = pv.patient_visit_id
						   left join patient_hospital_usage phu on pv.patient_id = phu.patient_id
						   left join person_formatted_name_iview pfn on phu.patient_id = pfn.person_id
						   left JOIN visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd
						   left join costcentre c on cd.service_provider_costcentre_id = c.costcentre_id

		where ar.transaction_status_rcd not in ('voi','unk')
			  and ar.swe_payment_status_rcd = 'COM'
			  and cd.deleted_date_time is NULL
			  and pv.cancelled_date_time is NULL
			  and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'    --PINV
			  and phu.visible_patient_id not in ('00501729', '00503183',    --Pharmacy, OPD - Pharmacy, OPD 2
			                                     '00000001', '00000002')    --Retail Pharmacy 1, Test Patient - Retail, Pharmacy 2
			  and vtr.visit_type_group_rcd = 'OPD'
			  and c.costcentre_code in ('7345', '7300', '7190')

	)as temp

)as tempb
where CAST(CONVERT(VARCHAR(10),tempb.[Invoice Date],101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),tempb.[Invoice Date],101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)
order by tempb.[Patient Name], tempb.[Invoice Date]