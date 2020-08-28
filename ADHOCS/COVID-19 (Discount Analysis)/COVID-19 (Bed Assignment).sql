
--DECLARE @From DATETIME
--DECLARE @To DATETIME

--SET @From = '05/01/2020 00:00:00.000'
--SET @To = '05/31/2020 23:59:59.998'

select DISTINCT 
        --temp.Status,
		temp.[Visit Code],
		temp.[Admission Date],
		temp.[Discharge Date],
		temp.HN,
        temp.[Patient Name],
		temp.Age,
		temp.[Visit Type],
		temp.[Bed Code],
		temp.[Start Date],
		temp.[End Date]

from (

	select distinct 
			cast(convert(varchar(10),pv.actual_visit_date_time,101)as DATETIME) as [Admission Date],
			vtr.name_l as [Visit Type],
			phu.visible_patient_id as HN,
			--pfn.display_name_l as patient_name,
			cast(convert(varchar(10),pv.closure_date_time,101)as DATETIME) as [Discharge Date],
			pv.visit_code as [Visit Code],
			cp.[Patient Name],
			be.ipd_room_code as [Bed Code],
			be.start_date_time as [Start Date],
			be.actual_end_date_time as [End Date],
		    cp.Age,
		    --cp.Status,
			pv.patient_visit_id

	from patient_visit_nl_view pv 
						--inner join person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
						left join patient_hospital_usage_nl_view phu on pv.patient_id = phu.patient_id
						left join bed_entry_info_view be on pv.patient_visit_id = be.patient_visit_id
						left join AHMC_DataAnalyticsDB.dbo.temp_covid_patients cp on cp.HN = phu.visible_patient_id collate sql_latin1_general_cp1_cs_as
						left join visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd

	where /*CAST(CONVERT(VARCHAR(10),cp.[Admission Date],101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
		    and CAST(CONVERT(VARCHAR(10),cp.[Admission Date],101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
			and*/ cp.[Visit Code] = pv.visit_code collate sql_latin1_general_cp1_cs_as
			and cp.HN = phu.visible_patient_id collate sql_latin1_general_cp1_cs_as  
			--and phu.visible_patient_id = '00559678'

)as temp

order by temp.[Patient Name],
         temp.[Start Date] desc

