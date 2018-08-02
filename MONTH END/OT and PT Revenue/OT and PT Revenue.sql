SELECT        (SELECT        gl_acct_code_code
							  FROM            gl_acct_code_nl_view
							  WHERE        (gl_acct_code_id = AID.gl_acct_code_credit_id) AND (company_code = 'AHI')) AS gl_acct_code,
								 (SELECT        name_l
								   FROM            gl_acct_code_nl_view AS gl_acct_code_nl_view_2
								   WHERE        (gl_acct_code_id = AID.gl_acct_code_credit_id) AND (company_code = 'AHI')) AS gl_acct_name,
								 (SELECT        visible_patient_id
								   FROM            patient_hospital_usage_nl_view
								   WHERE        (patient_id = PV.patient_id)) AS hospital_nr,
								 (SELECT        display_name_l
								   FROM            person_formatted_name_iview_nl_view
								   WHERE        (person_id = PV.patient_id)) AS patient_name,
								 (SELECT        visit_type_group_rcd
								   FROM            visit_type_ref_nl_view
								   WHERE        (visit_type_rcd = AID.visit_type_rcd)) AS visit_type_group,
								 (SELECT        name_l
								   FROM            visit_type_ref_nl_view AS visit_type_ref_nl_view_1
								   WHERE        (visit_type_rcd = AID.visit_type_rcd)) AS visit_type, CASE WHEN
								 (SELECT        person_id
								   FROM            customer_nl_view
								   WHERE        customer_id = AI.customer_id) IS NULL THEN
								 (SELECT        name_l
								   FROM            organisation_nl_view
								   WHERE        organisation_id =
																 (SELECT        organisation_id
																   FROM            customer_nl_view
																   WHERE        customer_id = AI.customer_id)) ELSE
								 (SELECT        display_name_l
								   FROM            person_formatted_name_iview_nl_view
								   WHERE        person_id =
																 (SELECT        person_id
																   FROM            customer_nl_view
																   WHERE        customer_id = AI.customer_id)) END AS customer, AI.transaction_text AS transaction_nr,
								 (SELECT        name_l
								   FROM            policy_nl_view
								   WHERE        (policy_id = AI.policy_id)) AS policy,
								 (SELECT        name_l
								   FROM            discount_posting_rule_nl_view
								   WHERE        (discount_posting_rule_id = AID.discount_posting_rule_id)) AS discount_reason,
								 (SELECT        name_l
								   FROM            item_nl_view
								   WHERE        (item_id = AID.item_id)) AS item, AID.quantity, 
							 CASE WHEN AI.credit_factor = 1 THEN AID.gross_amount ELSE AID.gross_amount * - 1 END AS gross_amount, 
							 CASE WHEN AI.credit_factor = 1 THEN AID.discount_amount ELSE AID.discount_amount * - 1 END AS discount_amount, 
							 CASE WHEN AI.credit_factor = 1 THEN AID.discount_percentage ELSE AID.discount_percentage * - 1 END AS discount_percentage,
							 MONTH(AI.effective_date) as month_id
							 
	FROM            ar_invoice_nl_view AS AI INNER JOIN
							 ar_invoice_detail_nl_view AS AID ON AI.ar_invoice_id = AID.ar_invoice_id INNER JOIN
							 charge_detail_nl_view AS CD ON AID.charge_detail_id = CD.charge_detail_id INNER JOIN
							 patient_visit_nl_view AS PV ON CD.patient_visit_id = PV.patient_visit_id
	WHERE        
	(MONTH(AI.effective_date) = @Month and YEAR(AI.effective_date) = @Year)
	 AND (AID.gl_acct_code_credit_id IN
								 (SELECT        gl_acct_code_id
								   FROM            gl_acct_code_nl_view AS gl_acct_code_nl_view_1
								   WHERE        (gl_acct_code_code IN ('4234000', '4232000')) AND (company_code = 'AHI'))) AND (AI.transaction_status_rcd NOT IN ('VOI', 'UNK'))