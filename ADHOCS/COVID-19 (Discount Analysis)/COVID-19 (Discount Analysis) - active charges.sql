
DECLARE @From DATETIME
DECLARE @To DATETIME

SET @From = '07/01/2020 00:00:00.000'
SET @To = '07/31/2020 23:59:59.998'

select DISTINCT temp.ar_invoice_detail_id,
                temp.[Charged Date],
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
				temp.[Discount Amount],
				temp.[Net Amount],
				temp.[Visit Type],
				temp.[Discount Policy],
				temp.[Invoice No.],
				temp.[Invoice Date],
				--cp.[Admission Date],
				temp.[Admission Date],
				temp.[Discharge Date],
				temp.HN,
				temp.[Patient Name]

from (

	select distinct 
			l.name_l as Type,
			cast(convert(varchar(10),pv.actual_visit_date_time,101)as DATETIME) as [Admission Date],
			i.item_code as [Item Code],
			i.name_l as [Item Name],
			c.costcentre_code as [Costcentre Code],
			c.name_l as Costcentre,
			gac.gl_acct_code_code as [GL Account Code],
			gac.name_l as [GL Account Name],
			u.name_l as UOM,
			ard.quantity as Quantity,
			AUC = (select top 1 ic.average_unit_cost from item_cost ic
					where i.item_id = ic.item_id
					order by ic.start_date_time desc),
			LUC = (select top 1 ic.last_unit_cost from item_cost ic
					where i.item_id = ic.item_id
					order by ic.start_date_time desc),
			ard.unit_price as [Unit Price],
			ard.gross_amount as [Gross Amount],
			ard.discount_amount as [Discount Amount],
			ard.gross_amount - ard.discount_amount as [Net Amount],
			vtr.name_l as [Visit Type],
			phu.visible_patient_id as HN,
			--pfn.display_name_l as patient_name,
			dpr.name_l as [Discount Policy],
			ar.transaction_text as [Invoice No.],
			ar.transaction_date_time as [Invoice Date],
			cast(convert(varchar(10),pv.closure_date_time,101)as DATETIME) as [Discharge Date],
			ard.ar_invoice_detail_id,
			pv.visit_code as [Visit Code],
			cp.[Patient Name],
			cd.charged_date_time as [Charged Date]

	from ar_invoice ar inner join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
						inner join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
						inner join item i on ard.item_id = i.item_id
						inner join costcentre c on ard.costcentre_credit_id = c.costcentre_id
						inner join gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
						--inner join gl_transaction_detail gtd on ar.gl_transaction_id = gtd.gl_transaction_id
						inner join patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
						--inner join person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
						inner join patient_hospital_usage_nl_view phu on pv.patient_id = phu.patient_id
						inner join AHMC_DataAnalyticsDB.dbo.temp_covid_patients cp on phu.visible_patient_id = cp.HN collate sql_latin1_general_cp1_cs_as
						left join uom_ref u on ard.uom_rcd = u.uom_rcd
						left join line_type_ref l on ard.line_type_rcd = l.line_type_rcd
						left outer JOIN discount_posting_rule dpr on ard.discount_posting_rule_id = dpr.discount_posting_rule_id
						left join visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd

	where CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
		    and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
			and ar.transaction_status_rcd not in ('voi', 'unk')  
	        and gac.company_code = 'AHI'
			and cp.[Visit Code] = pv.visit_code collate sql_latin1_general_cp1_cs_as
			and cp.HN = phu.visible_patient_id collate sql_latin1_general_cp1_cs_as
			and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2' --PINV    

)as temp

order by temp.[Admission Date],
         temp.[Patient Name],
		 temp.[Item Code]
