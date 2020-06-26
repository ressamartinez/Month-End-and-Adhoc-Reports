
DECLARE @From DATETIME
DECLARE @To DATETIME

SET @From = '05/01/2020 00:00:00.000'
SET @To = '05/31/2020 23:59:59.998'

select DISTINCT temp.[Visit Code],
		temp.[Admission Date],
		temp.[Discharge Date],
		temp.HN,
        temp.[Patient Name],
        sum(temp.[Gross Amount]) as [Gross Amount],
		temp.[Payor Type],
		temp.[Bed Code],
		temp.Age,
		temp.[Visit Type],
		temp.Status

from (

	select distinct 
			cast(convert(varchar(10),pv.actual_visit_date_time,101)as DATETIME) as [Admission Date],
			cd.amount as [Gross Amount],
			vtr.name_l as [Visit Type],
			phu.visible_patient_id as HN,
			--pfn.display_name_l as patient_name,
			--dpr.name_l as [Discount Policy],
			cast(convert(varchar(10),pv.closure_date_time,101)as DATETIME) as [Discharge Date],
			pv.visit_code as [Visit Code],
			'' as 'Payor Type',
			cp.[Patient Name],
			[Bed Code] = (Select admission_bed_code from api_patient_visit_view
			              where patient_visit_id = pv.patient_visit_id),
		    cp.Age,
		    cp.Status

	from charge_detail cd  inner join patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
							--inner join person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
							inner join patient_hospital_usage_nl_view phu on pv.patient_id = phu.patient_id
							inner join AHMC_DataAnalyticsDB.dbo.temp_covid_patients cp on cp.HN = phu.visible_patient_id collate sql_latin1_general_cp1_cs_as
							left join visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd

	where CAST(CONVERT(VARCHAR(10),cp.[Admission Date],101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
		    and CAST(CONVERT(VARCHAR(10),cp.[Admission Date],101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
	        and cd.deleted_date_time is null
			--and i.item_type_rcd = 'INV'
			--and dpr.discount_posting_rule_code in ('DPD', 'SCD')
			and cp.[Visit Code] = pv.visit_code collate sql_latin1_general_cp1_cs_as
			and cp.HN = phu.visible_patient_id collate sql_latin1_general_cp1_cs_as
			--and phu.visible_patient_id = '00016500'

)as temp
group by temp.[Visit Code],
         temp.[Admission Date],
		 temp.[Discharge Date],
		 temp.HN,
		 temp.[Patient Name],
		 temp.[Payor Type],
		 temp.[Bed Code],
		 temp.Age,
		 temp.[Visit Type],
		 temp.Status

order by temp.[Patient Name]





