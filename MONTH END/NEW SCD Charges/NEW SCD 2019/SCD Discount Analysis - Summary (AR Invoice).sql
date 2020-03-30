
select main_item_group_code,
       main_item_group,
	   item_group_code,
	   item_group,
	   sum(discount_amount)
from (

	select temp.visit_code,
		   temp.hospital_nr,
		   temp.patient_name,
		   temp.dob,
		   temp.admission_type,
		   temp.visit_type,
		   temp.visit_start,
		   temp.visit_end,
		   transaction_no = (Select top 1 transaction_nr from GEN_vw_ar_invoice
									where transaction_nr = temp.transaction_no),
		   temp.effective_date,
		   temp.main_item_group_code,
		   temp.main_item_group,
		   temp.item_group_code,
		   temp.item_group,
		   temp.item_code,
		   temp.item_desc,
		   temp.item_type,
		   temp.unit_cost,
		   quantity = sum(temp.quantity),
		   charge_amount = sum(temp.charge_amount),
		   discount_amount = sum(temp.discount_amount),
		   temp.credit_gl_acct_code,
		   temp.credit_gl_acct_desc,
		   temp.credit_costcentre_code,
		   temp.credit_costcentre_desc,
		   temp.vendor_code,
		   temp.vendor

	from (

	SELECT 
			GVAI.charge_detail_id
			,CD.item_id
			,PV.visit_code
			,hospital_nr = (SELECT visible_patient_id FROM AmalgaPROD.dbo.patient_hospital_usage_nl_view WHERE patient_id = PV.patient_id)
			,patient_name = (SELECT display_name_l FROM AmalgaPROD.dbo.person_formatted_name_iview_nl_view WHERE person_id = PV.patient_id)
			,dob = (SELECT date_of_birth FROM AmalgaPROD.dbo.person_formatted_name_iview_nl_view WHERE person_id = PV.patient_id)
			,admission_type = (SELECT visit_type_group_rcd FROM AmalgaPROD.dbo.visit_type_ref_nl_view WHERE visit_type_rcd = PV.visit_type_rcd)
			,visit_type = (SELECT name_l FROM AmalgaPROD.dbo.visit_type_ref_nl_view WHERE visit_type_rcd = PV.visit_type_rcd)
			,visit_start = PV.actual_visit_date_time
			,visit_end = PV.closure_date_time
			,transaction_no = GVAI.transaction_nr
			,GVAI.effective_date
			,charge_date = CD.charged_date_time
			,GVAI.main_item_group_code
			,GVAI.main_item_group
			,GVAI.item_group_code
			,GVAI.item_group
			,GVAI.item_code
			,GVAI.item_desc
			,GVAI.item_type_rcd
			,GVAI.item_type
			,unit_cost = CASE WHEN GVAI.credit_factor = 1
								THEN CD.unit_price
								ELSE CD.unit_price * -1
						END
			,quantity = CASE WHEN GVAI.credit_factor = 1
							THEN GVAI.quantity 
							ELSE GVAI.quantity * -1
						END
			,charge_amount = CASE WHEN GVAI.credit_factor = 1
								THEN GVAI.gross_amount 
								ELSE GVAI.gross_amount * -1
							END 
			,discount_amount = CASE WHEN GVAI.credit_factor = 1
								THEN GVAI.discount_amount 
								ELSE GVAI.discount_amount * -1
							END 
			,GVAI.credit_gl_acct_code
			,GVAI.credit_gl_acct_desc
			,GVAI.credit_costcentre_code
			,GVAI.credit_costcentre_desc
			,vendor_code  = CASE WHEN GVAI.item_type_rcd = 'INV' THEN (SELECT vendor_code FROM AmalgaPROD.dbo.vendor_name_view WHERE vendor_id = (SELECT vendor_id FROM AmalgaPROD.dbo.swe_vendor_item_nl_view WHERE item_id = CD.item_id AND default_item_flag = 1)) ELSE NULL END
			,vendor = CASE WHEN GVAI.item_type_rcd = 'INV' THEN (SELECT vendor_name_l FROM AmalgaPROD.dbo.vendor_name_view WHERE vendor_id = (SELECT vendor_id FROM AmalgaPROD.dbo.swe_vendor_item_nl_view WHERE item_id = CD.item_id AND default_item_flag = 1))  ELSE NULL END
			,last_unit_cost = CASE WHEN GVAI.item_type_rcd = 'INV' THEN  (SELECT luc_cost * -1 FROM AmalgaPROD.dbo.item_movement_nl_view WHERE source_id = CD.charge_detail_id) ELSE NULL END
			,GVAI.presplit_amount
		FROM
			GEN_vw_ar_invoice GVAI
		INNER JOIN
			AmalgaPROD.dbo.charge_detail_nl_view CD ON GVAI.charge_detail_id = CD.charge_detail_id
		INNER JOIN
			AmalgaPROD.dbo.patient_visit_nl_view PV ON CD.patient_visit_id = PV.patient_visit_id
		WHERE
			month(GVAI.effective_date) = 8
			and year(GVAI.effective_date) = 2019
			AND GVAI.discount_gl_acct_code = '4420000' -- SENIOR CITIZEN DISCOUNT GL ACCT CODE
			AND GVAI.discount_amount <> 0
			AND GVAI.main_item_group in ('Medicine', 
										'Medical Supplies', 
										'MSU Cathlab Consignment',
										'Medical Supplies Consignment Cardiac Implants',
										'OutPatient Pharmacy')
		)as temp
	group by temp.visit_code,
			 temp.hospital_nr,
			 temp.patient_name,
			 dob,
			 temp.admission_type,
			 temp.visit_type,
			 temp.visit_start,
			 temp.visit_end,
			 temp.transaction_no,
			 temp.effective_date,
			 temp.main_item_group_code,
			 temp.main_item_group,
			 temp.item_group_code,
			 temp.item_group,
			 temp.item_code,
			 temp.item_desc,
			 temp.item_type,
			 temp.unit_cost,
			 temp.credit_gl_acct_code,
			 temp.credit_gl_acct_desc,
			 temp.credit_costcentre_code,
			 temp.credit_costcentre_desc,
			 temp.vendor_code,
			 temp.vendor
)as tempb
group by tempb.main_item_group_code,
         tempb.main_item_group,
		 tempb.item_group_code,
	     tempb.item_group
order by tempb.item_group_code