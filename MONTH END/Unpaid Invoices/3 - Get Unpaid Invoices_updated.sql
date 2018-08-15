--HISReport

--INVOICES UNPAID AND PARTIALLY PAID --24122, 24084, 24086
 DECLARE @dFrom datetime
DECLARE @dTo datetime
DECLARE @AsOFDate2 datetime

SET @dFrom = @From --'01/01/2006 00:00:00.000'		--Jan 2018 = 22667
SET @dTo = @To --'07/31/2018 23:59:59.998'
set @AsOFDate2 = @AsOf --'07/31/2018  23:59:59.998'	--27975


SELECT distinct tempb.[Invoice No.],
	   tempb.[HN],
	   tempb.[Patient Name],
	   tempb.[Payor],
		   tempb.[Visit Type],
		  tempb.[Transaction Date and Time],
		   tempb.[Discharge Date and Time],
		  tempb.[Philhealth],
		  tempb.[Philhealth PF],
		  tempb.[Net HB],
		  tempb.[Discount HB],
		  tempb.[Net DF],
		   tempb.[Discount DF],
		   tempb.[Net PF S23],
		   tempb.[Discount PF S23],
		   tempb.[Net ER PF],
		  tempb.[Discount ER PF],
		   tempb.[Package Discount],
		   tempb.[Payment Status],
		   tempb.[Owing Amount]
from
(
	SELECT temp.hn as [HN],
		   temp.patient_name AS [Patient Name],
		   temp.invoice_no as [Invoice No.],
		   temp.payor as [Payor],
		   temp.visit_type as [Visit Type],
		   temp.transaction_date_time as [Transaction Date and Time],
		   temp.discharge_date_time as [Discharge Date and Time],
		   temp.philhealth as [Philhealth],
		   temp.philhealth_pf as [Philhealth PF],
		   temp.net_hb as [Net HB],
		   temp.discount_hb as [Discount HB],
		   temp.net_df as [Net DF],
		   temp.discount_df as [Discount DF],
		   temp.net_pf as [Net PF S23],
		   temp.discount_pf as [Discount PF S23],
		   temp.net_er_pf as [Net ER PF],
		   temp.discount_er_pf as [Discount ER PF],
		   temp.package_discount as [Package Discount],
		   'Partial' as [Payment Status],
		   temp.ar_net_amt - temp.paid_amt as [Owing Amount]
	from
	(
		SELECT DISTINCT inv.invoice_no,
			   inv.hn,
			   inv.patient_name,
			   inv.policy_name as payor,
			   inv.visit_type,
			   ar_main.transaction_date_time,
			   inv.discharge_date_time,
			   total_amt,
			   inv.ar_net_amt,
			   inv.philhealth,
			   inv.philhealth_pf,
			   inv.net_hb,
			   inv.discount_hb,
			   inv.net_df,
			   inv.discount_df,
			   inv.net_pf,
			   inv.discount_pf,
			   inv.net_er_pf,
			   inv.discount_er_pf,
			   inv.package_discount,
		  
				isnull((SELECT ISNULL(SUM(temp.net_amount),0)
										from
										(
											SELECT ISNULL(SUM(b2.net_amount * b2.credit_factor),0) as net_amount
											from AmalgaPROD.dbo.swe_ar_instalment a left OUTER JOIN AmalgaPROD.dbo.ar_invoice c on a.ar_invoice_id = c.ar_invoice_id
																		inner JOIN  (SELECT DISTINCT _c.ar_invoice_id,
																							_a.remittance_id,
																							_b.net_amount as net_amount,
																							_a.transaction_date_time,
																							_a.transaction_status_rcd,
																							_c.related_ar_invoice_id,
																							_c.credit_factor
																					from AmalgaPROD.dbo.remittance _a inner JOIN AmalgaPROD.dbo.swe_ar_instalment _b on _a.remittance_id = _b.remittance_id
																																INNER JOIN AmalgaPROD.dbo.ar_invoice _c on _b.ar_invoice_id = _c.ar_invoice_id
																					where _c.related_ar_invoice_id  is NOT NULL
																						  and _c.system_transaction_type_rcd <> 'cdmr'
																					) as b2 on a.remittance_id = b2.remittance_id
																							and a.ar_invoice_id = b2.ar_invoice_id
											where a.ar_invoice_id =   ar_main.ar_invoice_id
												and CAST(CONVERT(VARCHAR(10),b2.transaction_date_time,101) as SMALLDATETIME) <= @AsOFDate2
												and b2.transaction_status_rcd <> 'voi'
											UNION all
											SELECT ISNULL(SUM(b2.net_amount * b2.credit_factor),0)
											from AmalgaPROD.dbo.swe_ar_instalment a left OUTER JOIN AmalgaPROD.dbo.ar_invoice c on a.ar_invoice_id = c.ar_invoice_id
																		inner JOIN  (SELECT DISTINCT _c.ar_invoice_id,
																							_a.remittance_id,
																							_b.net_amount as net_amount,
																							_a.transaction_date_time,
																							_a.transaction_status_rcd,
																							_a.transaction_text,
																							_c.transaction_text as ar,
																							_c.related_ar_invoice_id,
																							_b.instalment_id,
																							_c.credit_factor
																					from AmalgaPROD.dbo.remittance _a inner JOIN AmalgaPROD.dbo.swe_ar_instalment _b on _a.remittance_id = _b.remittance_id
																																INNER JOIN AmalgaPROD.dbo.ar_invoice _c on _b.ar_invoice_id = _c.ar_invoice_id
																					where _c.related_ar_invoice_id  is NOT NULL
																						  and _c.system_transaction_type_rcd not in ('cdmr','dbmr')
																					) as b2 on a.remittance_id = b2.remittance_id
																						and b2.related_ar_invoice_id = c.ar_invoice_id
											where a.ar_invoice_id =  ar_main.ar_invoice_id
												and CAST(CONVERT(VARCHAR(10),b2.transaction_date_time,101) as SMALLDATETIME) <= @AsOFDate2
												and b2.transaction_status_rcd <> 'voi'
												and a.remittance_id not in (SELECT b2.remittance_id
																			from AmalgaPROD.dbo.swe_ar_instalment a2 left OUTER JOIN AmalgaPROD.dbo.ar_invoice c2 on a2.ar_invoice_id = c2.ar_invoice_id
																										inner JOIN  (SELECT DISTINCT _c.ar_invoice_id,
																															_a.remittance_id,
																															_b.net_amount as net_amount,
																															_a.transaction_date_time,
																															_a.transaction_status_rcd,
																															_a.transaction_text
																													from AmalgaPROD.dbo.remittance _a inner JOIN AmalgaPROD.dbo.swe_ar_instalment _b on _a.remittance_id = _b.remittance_id
																																								INNER JOIN AmalgaPROD.dbo.ar_invoice _c on _b.ar_invoice_id = _c.ar_invoice_id
																													where _c.related_ar_invoice_id  is NOT NULL
																													and _c.system_transaction_type_rcd <> 'cdmr'
																													) as b2 on a2.remittance_id = b2.remittance_id
																														and a2.ar_invoice_id = b2.ar_invoice_id
																			where a2.ar_invoice_id =  ar_main.ar_invoice_id
																				and CAST(CONVERT(VARCHAR(10),b2.transaction_date_time,101) as SMALLDATETIME) <= @AsOFDate2
																				and b2.transaction_status_rcd <> 'voi')
											UNION ALL
										SELECT ISNULL(SUM(temp.net_amount * temp.credit_factor),0) as net_amount
											from
											(
												SELECT DISTINCT b2.rem,
													   b2.net_amount,
													   b2.credit_factor
													   --,a.instalment_id --added
												from AmalgaPROD.dbo.swe_ar_instalment a left OUTER JOIN AmalgaPROD.dbo.ar_invoice c on a.ar_invoice_id = c.ar_invoice_id
																			inner JOIN  (SELECT DISTINCT _c.ar_invoice_id,
																								_a.remittance_id,
																								_b.net_amount as net_amount,
																								_a.transaction_date_time,
																								_a.transaction_status_rcd,
																								_c.related_ar_invoice_id,
																								_c.credit_factor,
																								_a.transaction_text as rem
																							--	_a.transaction_description
																						from AmalgaPROD.dbo.remittance _a inner JOIN AmalgaPROD.dbo.swe_ar_instalment _b on _a.remittance_id = _b.remittance_id
																																	INNER JOIN AmalgaPROD.dbo.ar_invoice _c on _b.ar_invoice_id = _c.ar_invoice_id
																						where _c.related_ar_invoice_id  is NULL
																								and _c.system_transaction_type_rcd <> 'cdmr'
																						) as b2 on a.remittance_id = b2.remittance_id

												where a.ar_invoice_id =    ar_main.ar_invoice_id
													and CAST(CONVERT(VARCHAR(10),b2.transaction_date_time,101) as SMALLDATETIME) <= @AsOFDate2
													and b2.transaction_status_rcd <> 'voi'
													and b2.ar_invoice_id = a.ar_invoice_id
											) as temp
										) as temp),0) as paid_amt
		from rpt_invoice_pf inv inner JOIN AmalgaPROD.dbo.ar_invoice_nl_view ar_main on RTRIM(inv.invoice_no) = rtrim(ar_main.transaction_text)
								inner JOIN AmalgaPROD.dbo.swe_ar_instalment ar_instl_main on ar_main.ar_invoice_id = ar_instl_main.ar_invoice_id
								INNER  JOIN AmalgaPROD.dbo.remittance r_main on ar_instl_main.remittance_id = r_main.remittance_id
		where    CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
			and CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)
			and ar_main.transaction_status_rcd not in  ('unk','voi')
			and inv.invoice_id not in (SELECT _inv.invoice_id
										from rpt_invoice_pf _inv inner JOIN AmalgaPROD.dbo.ar_invoice _ar_main on _inv.invoice_id = _ar_main.ar_invoice_id
										where CAST(CONVERT(VARCHAR(10),_inv.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
											 and CAST(CONVERT(VARCHAR(10),_inv.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)	
											 and _ar_main.net_amount > 0 
											 and _ar_main.transaction_status_rcd not in ('unk','voi')
											  and _inv.invoice_id not in (SELECT c.ar_invoice_id
																	from AmalgaPROD.dbo.swe_ar_instalment a INNER JOIN AmalgaPROD.dbo.remittance b on a.remittance_id  = b.remittance_id
																													inner JOIN AmalgaPROD.dbo.ar_invoice c on a.ar_invoice_id = c.ar_invoice_id
																	where  YEAR(b.transaction_date_time) <= @AsOfDate2
																		and b.transaction_status_rcd <> 'voi'))
	) as temp
	where (temp.paid_amt <> temp.ar_net_amt and temp.paid_amt !> temp.ar_net_amt)
			 and temp.paid_amt > 0
	UNION all
	SELECT temp.hn as [HN],
		   temp.patient_name AS [Patient Name],
		   temp.invoice_no as [Invoice No.],
		   temp.payor as [Payor],
		   temp.visit_type as [Visit Type],
		   temp.transaction_date_time as [Transaction Date and Time],
		   temp.discharge_date_time as [Discharge Date and Time],
		   temp.philhealth as [Philhealth],
		   temp.philhealth_pf as [Philhealth PF],
		   temp.net_hb as [Net HB],
		   temp.discount_hb as [Discount HB],
		   temp.net_df as [Net DF],
		   temp.discount_df as [Discount DF],
		   temp.net_pf as [Net PF S23],
		   temp.discount_pf as [Discount PF S23],
		   temp.net_er_pf as [Net ER PF],
		   temp.discount_er_pf as [Discount ER PF],
		   temp.package_discount as [Package Discount],
		   'Partial' as [Payment Status],
		   temp.ar_net_amt as [Owing Amount]
	from
	(
		SELECT DISTINCT inv.invoice_no,
			   inv.hn,
			   inv.patient_name,
			   inv.policy_name as payor,
			   inv.visit_type,
			   ar_main.transaction_date_time,
			   inv.discharge_date_time,
			   total_amt,
			   inv.ar_net_amt,
			   inv.philhealth,
			   inv.philhealth_pf,
			   inv.net_hb,
			   inv.discount_hb,
			   inv.net_df,
			   inv.discount_df,
			   inv.net_pf,
			   inv.discount_pf,
			   inv.net_er_pf,
			   inv.discount_er_pf,
			   inv.package_discount
		from rpt_invoice_pf inv inner JOIN AmalgaPROD.dbo.ar_invoice_nl_view ar_main on RTRIM(inv.invoice_no) = rtrim(ar_main.transaction_text)
		where    CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
			and CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)
			and ar_main.transaction_status_rcd not in  ('unk','voi')
			and inv.invoice_no = 'CMAR-2009-002659'
		
	) as temp
	UNION ALL
	-----
	SELECT inv.hn as [HN],
			inv.patient_name as [Patient Name],
			inv.invoice_no as [Invoice No.],
			inv.policy_name as [Payor],
			inv.visit_type as [Visit Type],
			ar_main.transaction_date_time as [Transaction Date and Time],
			inv.discharge_date_time as [Discharge Date and Time],
			inv.philhealth as [Philhealth],
			inv.philhealth_pf as [Philhealth PF],
			inv.net_hb as [Net HB],
			inv.discount_hb as [Discount HB],
			inv.net_df as [Net DF],
			inv.discount_df as [Discount DF],
			inv.net_pf as [Net PF S23],
			inv.discount_pf as [Discount PF S23],
			inv.net_er_pf as [Net ER PF],
			inv.discount_er_pf as [Discount ER PF],
			inv.package_discount as [Package Discount],
			'No Payment' as [Payment Status],
			inv.ar_net_amt as [Owing Amount]
	from rpt_invoice_pf inv inner JOIN AmalgaPROD.dbo.ar_invoice ar_main on inv.invoice_id = ar_main.ar_invoice_id
	where CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
		 and CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)	
		 and ar_main.net_amount > 0 
		 and ar_main.transaction_status_rcd not in ('unk','voi')
		  and inv.invoice_id not in (SELECT a.ar_invoice_id
													from AmalgaPROD.dbo.swe_ar_instalment a INNER JOIN AmalgaPROD.dbo.remittance b on a.remittance_id  = b.remittance_id
																									inner JOIN AmalgaPROD.dbo.ar_invoice c on a.ar_invoice_id = c.ar_invoice_id
													where CAST(CONVERT(VARCHAR(10),b.transaction_date_time,101) as SMALLDATETIME) <= @AsOFDate2
														and b.transaction_status_rcd <> 'voi')
		and inv.patient_name is not NULL
	UNION ALL
	SELECT temp.hn as [HN],
		   temp.patient_name as [Patient Name],
		   temp.invoice_no as [Invoice No.],
		   temp.payor as [Payor],
		   temp.visit_type as [Visit Type],
		   temp.transaction_date_time as [Transaction Date and Time],
		   temp.discharge_date_time as [Discharge Date and Time],
		   temp.philhealth as [Philhealth],
		   temp.philhealth_pf as [Philhealth PF],
		   temp.net_hb as [Net HB],
		   temp.discount_hb as [Discount HB],
		   temp.net_df as [Net DF],
		   temp.discount_df as [Discount DF],
		   temp.net_pf as [Net PF S23],
		   temp.discount_pf as [Discount PF S23],
		   temp.net_er_pf  as [Net ER PF],
		   temp.discount_er_pf as [Discount ER PF],
		   temp.package_discount as [Package Discount],
		   'No Payment' as [Payment Status],
		   temp.owing_amt as [Owing Amount]
	from
	(
		SELECT DISTINCT inv.invoice_no,
			   vtr.name_l as visit_type,
			   ISNULL(p.name_l,'--') as payor,
			   phu.visible_patient_id as hn,
			   pfn.display_name_l as patient_name,
			   inv.transaction_date_time,
			   inv.discharge_date_time,
			   inv.philhealth,
			   inv.philhealth_pf,
			   inv.net_hb,
			   inv.discount_hb,
			   inv.net_df,
			   inv.discount_df,
			   inv.net_pf,
			   inv.discount_pf,
			   inv.net_er_pf,
			   inv.discount_er_pf,
			   inv.package_discount,
			   inv.ar_net_amt as owing_amt

		from rpt_invoice_pf inv inner JOIN AmalgaPROD.dbo.ar_invoice ar_main on inv.invoice_id = ar_main.ar_invoice_id
								inner JOIN (SELECT ar_invoice_id,
																transaction_text as ar_invoice,
																related_ar_invoice_id,
																system_transaction_type_rcd,
																visit_type_rcd,
																swe_payment_status_rcd,
																net_amount
														from AmalgaPROD.dbo.ar_invoice_nl_view) ar2 on ar_main.related_ar_invoice_id = ar2.ar_invoice_id
												inner JOIN (SELECT ar_invoice_id,
																transaction_text as ar_invoice,
																related_ar_invoice_id,
																system_transaction_type_rcd,
																visit_type_rcd,
																swe_payment_status_rcd,
																net_amount,
																policy_id
														from AmalgaPROD.dbo.ar_invoice_nl_view) ar3 on ar2.related_ar_invoice_id = ar3.ar_invoice_id
												inner JOIN (SELECT ar_invoice_id,
																				   ar_invoice_detail_id,
																				   gross_amount,
																				   discount_amount,
																				   charge_detail_id
																			from AmalgaPROD.dbo.ar_invoice_detail_nl_view) ard on ar3.ar_invoice_id = ard.ar_invoice_id
											   INNER JOIN AmalgaPROD.dbo.charge_detail_nl_view cd on ard.charge_detail_id = cd.charge_detail_id
											   inner JOIN AmalgaPROD.dbo.patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
											   INNER JOIN AmalgaPROD.dbo.visit_type_ref vtr on RTRIM(pv.visit_type_rcd) = RTRIM(vtr.visit_type_rcd)
											   INNER JOIN  AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
											   INNER JOIN  AmalgaPROD.dbo.patient_hospital_usage_nl_view phu on pfn.person_id = phu.patient_id
											   LEFT OUTER JOIN AmalgaPROD.dbo.policy_nl_view p on ar3.policy_id = p.policy_id
		where  CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
			and CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)
			and ar_main.net_amount > 0 
			and ar_main.transaction_status_rcd not in ('unk','voi')
			and inv.invoice_id not in (SELECT a.ar_invoice_id
									from AmalgaPROD.dbo.swe_ar_instalment a INNER JOIN AmalgaPROD.dbo.remittance b on a.remittance_id  = b.remittance_id
																					inner JOIN AmalgaPROD.dbo.ar_invoice c on a.ar_invoice_id = c.ar_invoice_id
									where CAST(CONVERT(VARCHAR(10),b.transaction_date_time,101) as SMALLDATETIME) <= @AsOFDate2
										and b.transaction_status_rcd <> 'voi')
			and inv.patient_visit_id is NULL
			
	) as temp
) as tempb

where tempb.[Invoice No.] not in ('PINV-2006-003407',
								'PINV-2006-160470',
								'PINV-2007-024279',
								'PINV-2009-054849',
								'PINV-2014-114595',
								--transaction year is 2022
								'PINV-2016-244742',
								'PINV-2016-251824',
								'PINV-2016-245652',
								'PINV-2016-245723',
								'PINV-2016-245846',
								'PINV-2016-244976',
								'PINV-2016-245089',
								'PINV-2016-244741',
								'PINV-2016-251466',
								'PINV-2016-245956',
								'PINV-2016-252079',
								'DMAR-2017-000281',
								--transaction date is 08-08-2017
								'PINV-2017-078057',
								--not in aged trial balance for May 2017
								'PINV-2017-101559',
								'PINV-2017-057248'	--with amount of 452.40 partial paid but when checked, already paid so must not be included in extraction (asof Mar-Apr 2018)
								)

							--'PINV-2017-078019' --status is COMPLETED but included in AGED TRAIL BALANCE for JUNE 2017 (Manual OR)




	--where tempb.[Invoice No.] =  --'PINV-2017-057248'			--'CMAR-2017-012677'	--not included in Sept extraction
	--IN ('PINV-2017-172544'
	--									,'PINV-2017-172532'
	--									,'PINV-2017-172527'
	--									,'PINV-2017-172506'
	--									,'PINV-2017-172496'
	--									,'PINV-2017-171650'
	--									,'PINV-2017-171643'
	--									,'PINV-2017-165246'
	--									,'PINV-2017-165247'
	--									,'DMAR-2017-001742'
	--									,'PINV-2017-078019'
	--									)											--July 2017 extraction 


order by tempb.[Transaction Date and Time],
		 tempb.[Invoice No.],
		 tempb.[Patient Name]