
--DECLARE @From DATETIME
--DECLARE @To DATETIME

--SET @From = '06/01/2020 00:00:00.000'
--SET @To = '06/30/2020 23:59:59.998'

select DISTINCT temp.[Charged Date],
                temp.[Item Code],
				temp.[Item Name],
				temp.[Costcentre Code],
				temp.Costcentre,
				temp.[GL Account Code],
				temp.[GL Account Name],
				temp.UOM,
				temp.Quantity,
				temp.AUC,
				temp.LUC,
				temp.[Unit Price],
				temp.[Gross Amount],
				temp.[Visit Type],
				--cp.[Admission Date],
				temp.[Admission Date],
				temp.[Discharge Date],
				temp.HN,
				temp.[Patient Name]

from (

	select distinct 
			cast(convert(varchar(10),pv.actual_visit_date_time,101)as DATETIME) as [Admission Date],
			i.item_code as [Item Code],
			i.name_l as [Item Name],
			c.costcentre_code as [Costcentre Code],
			c.name_l as Costcentre,
			gac.gl_acct_code_code as [GL Account Code],
			gac.name_l as [GL Account Name],
			u.name_l as UOM,
			cd.quantity as Quantity,
			AUC = (select top 1 ic.average_unit_cost from item_cost ic
					where i.item_id = ic.item_id
					order by ic.start_date_time desc),
			LUC = (select top 1 ic.last_unit_cost from item_cost ic
					where i.item_id = ic.item_id
					order by ic.start_date_time desc),
			cd.unit_price as [Unit Price],
			cd.amount as [Gross Amount],
			vtr.name_l as [Visit Type],
			phu.visible_patient_id as HN,
			--pfn.display_name_l as patient_name,
			cast(convert(varchar(10),pv.closure_date_time,101)as DATETIME) as [Discharge Date],
			pv.visit_code as [Visit Code],
			cp.[Patient Name],
			cd.charged_date_time as [Charged Date]

	from charge_detail cd inner join item i on cd.item_id = i.item_id
						  inner join costcentre c on cd.service_provider_costcentre_id = c.costcentre_id
						  inner join gl_acct_code gac on cd.gl_acct_code_id = gac.gl_acct_code_id
						  inner join patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
						  --inner join person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
						  inner join patient_hospital_usage_nl_view phu on pv.patient_id = phu.patient_id
						  inner join AHMC_DataAnalyticsDB.dbo.temp_covid_patients cp on phu.visible_patient_id = cp.HN collate sql_latin1_general_cp1_cs_as
						  left join uom_ref u on cd.uom_rcd = u.uom_rcd
						  left join visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd

	where /*CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
		    and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
			and*/ cd.deleted_date_time is null
	        and gac.company_code = 'AHI'
			and cp.[Visit Code] = pv.visit_code collate sql_latin1_general_cp1_cs_as
			and cp.HN = phu.visible_patient_id collate sql_latin1_general_cp1_cs_as

)as temp
where temp.[Discharge Date] is null
order by temp.[Admission Date],
         temp.[Patient Name],
		 temp.[Item Code]
