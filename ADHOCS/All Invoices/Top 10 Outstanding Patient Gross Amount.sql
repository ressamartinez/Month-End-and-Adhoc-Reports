
select DISTINCT tempb.*
from (

	select DISTINCT temp.HN,
		   temp.[Patient Name],
		   temp.[Visit Code],
		   temp.[Visit Start],
		   temp.[Invoice Date],
		   temp.[Invoice No.],
		   temp.[Gross Amount],
		   temp.[Visit Type]

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
			   vtr.visit_type_group_rcd as [Visit Type]

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


	)as temp
	--where temp.HN = '00028157'
)as tempb
order by tempb.[Patient Name], tempb.[Invoice Date]