--164014
--49994	(2006 - Jan 2017)
--ALL DF and Reader's Fee

DECLARE @dFrom datetime
DECLARE @dTo datetime
DECLARE @AsOFDate2 datetime

SET @dFrom = /*@From*/ '01/01/2006 00:00:00.000'
SET @dTo = /*@To*/ '01/30/2017 23:59:59.998'
set @AsOFDate2 = /*@AsOf*/ '01/30/2017  23:59:59.998'

SELECT DISTINCT temp.invoiced_date as [Invoice Date]
				,temp.charge_date as [Charge Date]
				,temp.admission_date as [Admission Date]
				,temp.admission_type as [Admission Type]
				,temp.visit_type as [Visit Type]
				,temp.employee_nr as [Employee NR]
				,temp.caregiver_lname as [Caregiver Last Name]
				,temp.caregiver_fname as [Caregiver First Name]
				,temp.caregiver_job_type as [Caregiver Job Type]
				,temp.upi as [HN]
				,temp.lname as [Patient Last Name]
				,temp.fname as [Patient First Name]
				,temp.mname as [Patient Middle Name]
				,temp.item_code as [Item Code]
				,temp.item_desc as [Item Description]
				,temp.quantity as [Quantity]
				,temp.uom as [UOM]
				,temp.unit_price as [Unit Price]
				,temp.total_amt as [Gross Amount]
				,temp.discount_amt_other as [Discount Amount Other]
				,temp.discount_amt_scd as [SCD Discount]
				,temp.scd_flag as [SCD Flag]
				,temp.net_amt as [Net Amount]
				,temp.validated as [Validated]
				,temp.processed as [Processed]
				,temp.paid as [Paid]
				,temp.bank_name as [Bank Name]
				,temp.bank_acct_no as [Bank Account No.]
				,temp.service_requestor as [Service Requestor]
				,temp.service_provider as [Service Provider]

				,temp.policy
				,temp.policy_discount
				,temp.discount_name
				,temp.policy_group
				,temp.item_group_code
				,temp.item_group_name

FROM
(
				SELECT        a.charge_id
									, a.employee_nr
									, a.caregiver_lname
									, a.caregiver_fname
									, a.caregiver_job_type
									, a.upi, a.lname
									, a.fname
									, a.mname
									, a.admission_date
									, a.admission_type
									, a.visit_type
									, b.item_code
									, b.item_desc
									, b.quantity
									, b.uom
									, b.unit_price
									, b.total_amt
									, b.discount_amt
									, b.net_amt				--added
									, b.charge_date
									, b.invoiced_date
									, b.validated
									, b.paid
									, b.processed
									, b.commission_rate
									, (SELECT account_id FROM doctor_account
											   WHERE employee_nr = a.employee_nr AND bank_default = 1 AND active = 1) AS account_id
									 , (SELECT bank_id FROM doctor_account
											   WHERE employee_nr = a.employee_nr AND bank_default = 1 AND active = 1) AS bank_id
									 , (SELECT bank_name FROM bank
											   WHERE bank_id =
															  (SELECT bank_id FROM doctor_account
																			   WHERE employee_nr = a.employee_nr AND bank_default = 1 AND active = 1)) AS bank_name
									, (SELECT bank_acct_no FROM doctor_account
											   WHERE  employee_nr = a.employee_nr AND bank_default = 1 AND active = 1) AS bank_acct_no
									 ,  c.service_requestor_id
									 ,  c.service_requestor
									 ,  c.service_provider_id
									 ,  c.service_provider
									 ,  c.costcentre_group_id

									 , b.scd_flag							--added
									 , b.discount_percentage	--added
									 , b.discount_amt_scd			--added
									 , b.discount_amt_other		--added

									,ar.policy_id
									,ar.policy_discount_id
									,p.name_l as policy
									,p2.name_l as policy_discount
									,dpr.name_l as discount_name
									,cir.policy_group
									,b.item_group_code
									,b.item_group_name

				FROM            
					--charge_caregiver a, 
					--charge_detail b,
					--charge_location c	

						charge_caregiver a 
							LEFT OUTER JOIN charge_detail b ON a.charge_id = b.charge_id
							LEFT OUTER JOIN charge_location c ON a.charge_id = c.charge_id

							LEFT OUTER JOIN ar_invoice_detail_head ard ON a.charge_id = ard.charge_detail_id
							LEFT OUTER JOIN ar_invoice_head ar ON ard.ar_invoice_id = ar.ar_invoice_id
							LEFT OUTER JOIN policy p ON ar.policy_id = p.policy_id
							LEFT OUTER JOIN policy p2 ON ar.policy_discount_id = p.policy_id
							LEFT OUTER JOIN discount_posting_rule dpr ON ar.gl_acct_code_debit_id = dpr.gl_acct_code_id
							
							LEFT OUTER JOIN charge_invoice_remittance cir ON a.charge_id = cir.charge_id
							--INNER JOIN dbo.df_view_charge_invoice_remittance_sum rs with (nolock) ON b.charge_id = rs.charge_detail_id	--added
				WHERE
					--a.charge_id = b.charge_id 
					--and b.charge_id = c.charge_id and
					 b.delete_date is null
					and b.total_amt <> 0 
					AND b.quantity > 0		--added

					and CAST(CONVERT(VARCHAR(10),b.charge_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
					and CAST(CONVERT(VARCHAR(10),b.charge_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)

					UNION

						SELECT        a.charge_id
											, a.employee_nr
											, a.caregiver_lname
											, a.caregiver_fname
											, a.caregiver_job_type
											, a.upi, a.lname
											, a.fname
											, a.mname
											, a.admission_date
											, a.admission_type
											, a.visit_type
											, b.item_code
											, b.item_desc
											, b.quantity
											, b.uom
											, b.unit_price
											, b.total_amt
											, b.discount_amt
											, b.net_amt				--added
											, b.charge_date
											, b.invoiced_date
											, b.validated
											, b.paid
											, b.processed
											, b.commission_rate
											, (SELECT  account_id FROM  doctor_account
													   WHERE employee_nr = a.employee_nr AND bank_default = 1 AND active = 1) AS account_id
											 , (SELECT bank_id FROM doctor_account
													   WHERE employee_nr = a.employee_nr AND bank_default = 1 AND active = 1) AS bank_id
											 , (SELECT bank_name FROM bank
													   WHERE bank_id =
																	(SELECT bank_id FROM doctor_account
																					   WHERE employee_nr = a.employee_nr AND bank_default = 1 AND active = 1)) AS bank_name
											, (SELECT bank_acct_no FROM doctor_account
													   WHERE employee_nr = a.employee_nr AND bank_default = 1 AND active = 1) AS bank_acct_no
											 , c.service_requestor_id
											 , c.service_requestor
											 , c.service_provider_id
											 , c.service_provider
											 , c.costcentre_group_id
						
											 , b.scd_flag							--added
											 , b.discount_percentage	--added
											 , b.discount_amt_scd			--added
											 , b.discount_amt_oth			--added

											,ar.policy_id
											,ar.policy_discount_id
											,p.name_l as policy
											,p2.name_l as policy_discount
											,dpr.name_l as discount_name
											,cir.policy_group
											,b.item_group_code
											,b.item_group_name

						FROM            
							--charge_caregiver_history a, 
							--charge_detail_history b, 
							--charge_location_history c	
							
							charge_caregiver_history a 
							LEFT OUTER JOIN charge_detail_history b ON a.charge_id = b.charge_id
							LEFT OUTER JOIN charge_location_history c ON a.charge_id = c.charge_id

							LEFT OUTER JOIN ar_invoice_detail_head ard ON a.charge_id = ard.charge_detail_id
							LEFT OUTER JOIN ar_invoice_head ar ON ard.ar_invoice_id = ar.ar_invoice_id
							LEFT OUTER JOIN policy p ON ar.policy_id = p.policy_id
							LEFT OUTER JOIN policy p2 ON ar.policy_discount_id = p.policy_id
							LEFT OUTER JOIN discount_posting_rule dpr ON ar.gl_acct_code_debit_id = dpr.gl_acct_code_id

							LEFT OUTER JOIN charge_invoice_remittance cir ON a.charge_id = cir.charge_id
									--INNER JOIN	dbo.df_view_charge_invoice_remittance_sum rs with (nolock) ON b.charge_id = rs.charge_detail_id	--added
						WHERE
							--a.charge_id = b.charge_id 
							--and b.charge_id = c.charge_id and
							 b.total_amt <> 0 
							AND b.quantity > 0		--added
							AND b.delete_date = NULL

							and CAST(CONVERT(VARCHAR(10),b.charge_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
							and CAST(CONVERT(VARCHAR(10),b.charge_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)

)as temp

order BY temp.invoiced_date








