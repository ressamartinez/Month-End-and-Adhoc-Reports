--Volume and Revenue per Policy with IPD/OPD discount (MAXICARE)

SELECT DISTINCT temp.[Invoice No.]
			,temp.[Policy Name]
			,temp.Year
			,temp.Month
			,temp.[Transaction Date and Time]
			,temp.[Transaction NR]
			,temp.[Patient Name]
			,temp.HN
			,temp.[Date of birth]
			,temp.Age
			,temp.[Visit Type]
			,temp.[GL Account Code]
			,temp.[GL Account Name]
			,temp.[Visit Type Group]
			,temp.[Item Type]
			,temp.[Item Code]
			,temp.[Item Name]
			--,temp.Qty --added field
			,temp.[Gross Amount]
			,temp.[Discount Amount]
			,temp.[Net Amount]
			,temp.[Discount Name]
			,temp.[Transaction Status]
			,temp.[Payment Status]

FROM
(

				SELECT DISTINCT ar.policy_id as [Policy ID]
							,ar.ar_invoice_id as [AR Invoice ID]
							,ard.charge_detail_id as [Charge Detail ID]
							,ard.ar_invoice_detail_id as [AR Invoice Detail ID]
							--,ar.policy_id as ar_policy_id
							--,p.policy_third_party_id
							--,dpr.gl_acct_code_id
							,YEAR(ar.transaction_date_time) as [Year]
							,month(ar.transaction_date_time) as [Month]
							,pfn.display_name_l as [Patient Name]
							,phu.visible_patient_id as [HN]
							,pfn.date_of_birth as [Date of birth]
							,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as [Age]
							,vtr.name_l as [Visit Type]

							,gac.gl_acct_code_id as [GL Account Code ID]
							,gac.gl_acct_code_code as [GL Account Code]
							,gac.name_l as [GL Account Name]

							--,gl.gl_acct_code_id as [GL Account Code ID]
							--,gl.gl_acct_code_code as [GL Account Code]
							--,gl.name_l as [GL Account Name]

							,vtr.visit_type_group_rcd as [Visit Type Group]
							,itr.name_l as [Item Type]
							,i.item_code as [Item Code]
							,i.name_l as [Item Name]
							--,ard.quantity as [Qty] --added field
							,ar.transaction_date_time as [Transaction Date and Time]
							,ar.transaction_nr as [Transaction NR]
							,ar.transaction_text as [Invoice No.]
							,ard.gross_amount as [Gross Amount]
							,ard.discount_amount as [Discount Amount]
							,(ard.gross_amount - ard.discount_amount) as [Net Amount]
							--,p.policy_id as [Policy ID]
							,p.name_l as [Policy Name]
							,p.description_l as [Policy Description]
							,p.policy_type_rcd as [Policy Type]						
							,p.billing_flag as [Policy Billing Flag]
							,p.policy_third_party_id as [Policy Third Party ID]
							,p.third_party_discount_flag as [Policy Third Party Discount Flag]
							,dpr.name_l as [Discount Name]
							,dpr.discount_posting_rule_code as [Discount Posting Rule]
							,dpr.company_code as [Company Code]
							--,gac.company_code
							,ar.visit_type_rcd
							--,ar.swe_payment_status_rcd as [Payment Status]
							--,ar.transaction_status_rcd as [Transaction Status]
							,spsr.name_l AS [Payment Status]
							,tsr.name_l AS [Transaction Status]
							,ar.system_transaction_type_rcd as [System Transaction Type]
							--,cd.payment_status_rcd as [Payment Status]
							--,ard.free_line_l
							,ar.user_transaction_type_id as [User Transaction Type ID]
							,ar.gl_acct_code_debit_id as [GL Account Code Debit ID]
							,ar.gl_transaction_id as [GL Transaction ID]
							,ar.related_ar_invoice_id as [Related AR Invoice ID]
							,ard.discount_posting_rule_id as [Discount Posting Rule ID]
							--,dpr.discount_posting_rule_id
							,ard.gl_acct_code_credit_id as [GL Account Code Credit ID]
							,ard.discount_gl_acct_code_id as [Discount GL Account Code ID]	
			
				FROM ar_invoice ar
								INNER JOIN policy p on ar.policy_id = p.policy_id
								LEFT OUTER JOIN ar_invoice_detail ard ON ar.ar_invoice_id = ard.ar_invoice_id
								LEFT OUTER JOIN charge_detail cd ON ard.charge_detail_id = cd.charge_detail_id
								LEFT OUTER JOIN discount_posting_rule dpr ON ard.discount_posting_rule_id = dpr.discount_posting_rule_id
								LEFT OUTER JOIN gl_acct_code gac ON cd.gl_acct_code_id = gac.gl_acct_code_id
								LEFT OUTER JOIN item i ON ard.item_id = i.item_id
								inner JOIN item_type_ref itr on i.item_type_rcd = itr.item_type_rcd
								LEFT OUTER JOIN patient_visit pv ON cd.patient_visit_id = pv.patient_visit_id
								LEFT OUTER JOIN patient_visit_policy pvp ON pv.patient_visit_id = pvp.patient_visit_id
								INNER JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
								LEFT OUTER JOIN patient_hospital_usage phu ON pv.patient_id = phu.patient_id
								--LEFT OUTER JOIN gl_transaction glt ON ar.gl_transaction_id = glt.gl_transaction_id
								INNER JOIN user_transaction_type ust ON ar.user_transaction_type_id = ust.user_transaction_type_id
								inner JOIN visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd
								INNER JOIN swe_payment_status_ref spsr ON ar.swe_payment_status_rcd = spsr.swe_payment_status_rcd
								INNER JOIN transaction_status_ref tsr ON ar.transaction_status_rcd = tsr.transaction_status_rcd

								--LEFT OUTER JOIN gl_acct_code gl ON ard.discount_gl_acct_code_id = gl.gl_acct_code_id

				where ar.policy_id IN  ('0D2C251E-6ED7-11E3-84F9-78E3B58FDD66', 'F359BE0B-63BA-11DA-BB34-000E0C7F3ED2') --2014 MAXICARE, MAXICARE

							AND ar.transaction_date_time  BETWEEN '05/01/2018 00:00:00:000' AND '05/31/2018 23:59:59:998'
							--and YEAR(ar.transaction_date_time) = 2018
							--AND MONTH(ar.transaction_date_time) = 3

							AND ard.discount_posting_rule_id IN ('05F8582D-6E0D-11E3-A6A2-78E3B597EAF4'  --Inpatient Discount
																								,'3D06C575-6E0D-11E3-A6A2-78E3B597EAF4') --Outpatient Discount

							AND ar.swe_payment_status_rcd IN ('COM', 'UNP')
							AND ar.transaction_status_rcd NOT IN ('VOI','UNK')
							AND cd.deleted_date_time IS NULL

							AND dpr.gl_acct_code_id IN ('D06BE6F5-6E0C-11E3-8117-0022195FB682' --Outpatient Discount
																				,'95437EF6-6E0C-11E3-8117-0022195FB682') --Inpatient Discount										

							AND ar.user_transaction_type_id IN ('F8EF2162-3311-11DA-BB34-000E0C7F3ED2'  --PINV
																								,'30957FA1-735D-11DA-BB34-000E0C7F3ED2') --CINV

) as temp

ORDER BY temp.[Patient Name], temp.[Transaction Date and Time] ASC