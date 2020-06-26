
DECLARE @From DATETIME
DECLARE @To DATETIME

SET @From = '05/01/2020 00:00:00.000'
SET @To = '05/31/2020 23:59:59.998'

select DISTINCT temp.[Visit Code],
		temp.[Admission Date],
		temp.[Discharge Date],
		temp.HN,
        temp.[Patient Name],
        temp.[Gross Amount],
		temp.[Discount Amount],
		temp.[Net Amount],
		temp.[Invoice No.],
		temp.[Invoice Date],
		temp.Policy,
		temp.[Payor Type],
		temp.[Bed Code],
		temp.Age,
		temp.[Visit Type],
		temp.Status

from (

	select distinct 
			cast(convert(varchar(10),pv.actual_visit_date_time,101)as DATETIME) as [Admission Date],
			ar.gross_amount as [Gross Amount],
			ar.discount_amount as [Discount Amount],
			ar.gross_amount - ar.discount_amount as [Net Amount],
			vtr.name_l as [Visit Type],
			phu.visible_patient_id as HN,
			--pfn.display_name_l as patient_name,
			--dpr.name_l as [Discount Policy],
			p.policy_id,
			p.name_l as Policy,
			ar.transaction_text as [Invoice No.],
			ar.transaction_date_time as [Invoice Date],
			cast(convert(varchar(10),pv.closure_date_time,101)as DATETIME) as [Discharge Date],
			pv.visit_code as [Visit Code],
			case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as 'Payor Type',
			cp.[Patient Name],
			cp.[Bed Code],
		    cp.Age,
		    cp.Status

	from ar_invoice ar inner join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
						inner join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
						inner join patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
						--inner join person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
						inner join patient_hospital_usage_nl_view phu on pv.patient_id = phu.patient_id
						inner join AHMC_DataAnalyticsDB.dbo.covid_patients cp on cp.HN = phu.visible_patient_id collate sql_latin1_general_cp1_cs_as
						--left outer JOIN discount_posting_rule dpr on ard.discount_posting_rule_id = dpr.discount_posting_rule_id
						left join policy p on ar.policy_id = p.policy_id
						left join visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd
						left OUTER JOIN customer co on ar.customer_id = co.customer_id
						LEFT OUTER JOIN organisation o on co.organisation_id = o.organisation_id
						LEFT OUTER JOIN person_formatted_name_iview_nl_view pfn on co.person_id = pfn.person_id
						LEFT OUTER JOIN organisation_role oor on o.organisation_id = oor.organisation_id
						LEFT OUTER JOIN organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd

	where CAST(CONVERT(VARCHAR(10),cp.[Admission Date],101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
		    and CAST(CONVERT(VARCHAR(10),cp.[Admission Date],101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
	        and ar.transaction_status_rcd not in ('voi', 'unk')  
			--and i.item_type_rcd = 'INV'
			--and dpr.discount_posting_rule_code in ('DPD', 'SCD')
			and cp.[Visit Code] = pv.visit_code collate sql_latin1_general_cp1_cs_as
			and cp.HN = phu.visible_patient_id collate sql_latin1_general_cp1_cs_as
			and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2' --PINV    
			--and phu.visible_patient_id = '00016500'

)as temp

order by temp.[Patient Name]





