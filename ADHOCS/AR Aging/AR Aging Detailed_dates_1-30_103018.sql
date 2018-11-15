--aging = invoice_date
--filtration = aged_trial_balance_id
--for dates with 1-30 only

DECLARE @table table
(
	invoice_id uniqueidentifier,
	invoice_no varchar(20),
	transaction_date_time smalldatetime,
	policy_name varchar(250),
	swe_payment_status_rcd varchar(10),
	total_amt money,
	ar_net_amount money,
	discount_hb money,
	instalment_id uniqueidentifier,
	remittance_id uniqueidentifier,
	sai_payment_status varchar(10),
	sai_net_amount money,
	rem_transaction_datetime smalldatetime,
	aging int,
	--policy_group varchar(250),
	--orgtype_name varchar(250),
	organisation_type varchar(250),
	policy_id uniqueidentifier,
	payor_name varchar(300),
	hn varchar(10),
	patient_name varchar(300),
	due_date smalldatetime,
	system_transaction_type_rcd varchar(10),
	remit smalldatetime
    --transaction_no varchar(20)
)



insert into @table(invoice_id,
				   invoice_no,
				   transaction_date_time,
				   policy_name,
				   swe_payment_status_rcd,
				   total_amt,
				   ar_net_amount,
				   discount_hb,
				   instalment_id,
				   remittance_id,
				   sai_payment_status,
				   sai_net_amount,
				   rem_transaction_datetime,
				   aging,
				  -- policy_group,
				 --  orgtype_name,
				   organisation_type,
				   policy_id,
				   payor_name,
				   hn,
				   patient_name,
				   due_date,
				   system_transaction_type_rcd,
				   remit
				   --transaction_no
				   )

	SELECT rip.invoice_id,
		   rip.invoice_no,
		   rip.transaction_date_time,
		   case when rip.policy_name = '--' then rip.patient_name else rip.policy_name end as policy_name,
		   rip.swe_payment_status_rcd,
		   rip.total_amt,
		   rip.ar_net_amt,
		   rip.discount_hb,
		   sai.instalment_id,
		   r.remittance_id,
		   sai.swe_payment_status_rcd as sai_payment_status,
		   (sai.net_amount*ar.credit_factor) as sai_net_amount,
		   r.transaction_date_time as rem_transaction_datetime,
		   DATEDIFF(DAY,rip.transaction_date_time,r.transaction_date_time) as aging,
		   --DATEDIFF(DAY,rip.transaction_date_time,atb.due_date) as aging,
		   case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as organisation_type,
		   p.policy_id,
		   case when c.person_id is not NULL then pfn.display_name_l else o.name_l end as payor_name,
		   rip.hn,
		   rip.patient_name,
		   atb.due_date,
		   ar.system_transaction_type_rcd,
		   r.transaction_date_time as remit


	from HISReport.dbo.rpt_invoice_pf rip LEFT OUTER JOIN AmalgaPROD.dbo.swe_ar_instalment sai on rip.invoice_id = sai.ar_invoice_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.remittance r on sai.remittance_id = r.remittance_id
										  inner JOIN AmalgaPROD.dbo.ar_invoice_nl_view ar on rip.invoice_id = ar.ar_invoice_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.policy p on ar.policy_id = p.policy_id
										  left OUTER JOIN AmalgaPROD.dbo.customer c on ar.customer_id = c.customer_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation o on c.organisation_id = o.organisation_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on c.person_id = pfn.person_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation_role oor on o.organisation_id = oor.organisation_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd
										  LEFT OUTER JOIN AmalgaPROD.dbo.aged_trial_balance_ar_rollup_nl_view atb on atb.invoice_id = rip.invoice_id
	where --YEAR(rip.transaction_date_time) = 2015
	   --and MONTH(rip.transaction_date_time) >= 1 and  MONTH(rip.transaction_date_time) <= 1
	  -- --and ar.ar_invoice_id = sai.ar_invoice_id
	  -- ----and ar.user_transaction_type_id in ('F8EF2162-3311-11DA-BB34-000E0C7F3ED2','30957FA1-735D-11DA-BB34-000E0C7F3ED2')
	  -- --and ar.transaction_status_rcd not in ('voi','unk') --and
	     atb.gl_acct_code_code = '1130400'
	  --and atb.aged_trial_balance_id = 'BF4A3A1B-AAC7-11E4-9D8F-78E3B597EAF4'    --2015-01-31
	  and atb.aged_trial_balance_id = '45E2BFF9-C149-11E4-9B7D-78E3B58FDDFA'    --2015-02-28
	  --and atb.aged_trial_balance_id = '17FDE9BB-D80C-11E4-99C7-78E3B58FDDFA'    --2015-03-31
	  --and atb.aged_trial_balance_id = '3247038C-F071-11E4-A4CC-78E3B58FDDFA'    --2015-04-30
	  --and atb.aged_trial_balance_id = 'C25991D5-08DB-11E5-A8C6-78E3B58FDDFA'    --2015-05-31
	  --and atb.aged_trial_balance_id = 'BCA1968E-1FC5-11E5-A903-78E3B58FDDFA'    --2015-06-30
	  --and atb.aged_trial_balance_id = '92E71CF7-39A9-11E5-9EB6-78E3B58FDDFA'    --2015-07-31
	  --and atb.aged_trial_balance_id = '5A6FB1D4-508D-11E5-A2AF-78E3B58FDDFA'    --2015-08-31
	  --and atb.aged_trial_balance_id = '2E4DD26D-6811-11E5-AE06-78E3B58FDDFA'    --2015-09-30
	  --and atb.aged_trial_balance_id = 'CAC941B1-8140-11E5-9DC0-78E3B58FDDFA'    --2015-10-31
	  --and atb.aged_trial_balance_id = '2BF80A85-9807-11E5-A77A-78E3B58FDDFA'    --2015-11-30
	  --and atb.aged_trial_balance_id = 'EBA174BD-B2BA-11E5-A6AB-78E3B58FDDFA'    --2015-12-31
		 and CAST(CONVERT(VARCHAR(10),rip.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'02/01/2015',101) as SMALLDATETIME)
			and CAST(CONVERT(VARCHAR(10),rip.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'02/28/2015',101) as SMALLDATETIME)


SELECT tempb.*,

      case when tempb.system_transaction_type_rcd = 'cdmr' then
	  (case when tempb.future_ap < 0 THEN tempb.future_ap 
				else tempb.future_ap end)
	  else 
	  (case when tempb.future_ap > 0 THEN tempb.future_ap 
				else tempb.future_ap end) end as bal_future,

      case when tempb.system_transaction_type_rcd = 'cdmr' then
	  (case when (tempb.future_ap + tempb.current_ap) < 0 then (tempb.future_ap + tempb.current_ap) 
				else tempb.current_ap end) 
	  else
	  (case when (tempb.future_ap + tempb.current_ap) > 0 then (tempb.future_ap + tempb.current_ap) 
				else tempb.current_ap end) end as bal_current,

	  case when tempb.system_transaction_type_rcd = 'cdmr' then
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30) < 0 then (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30) 
				else tempb.ar_net_amount end) 
	  else
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30) > 0 then (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30) 
				else tempb.ar_net_amount end) end as bal_overdue_1_30,

	  case when tempb.system_transaction_type_rcd = 'cdmr' then
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60) < 0 
				then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60) 
			    else tempb.ar_net_amount end) 
	  else 
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60) > 0 
				then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60) 
			    else tempb.ar_net_amount end) end as bal_overdue_31_60,

	  case when tempb.system_transaction_type_rcd = 'cdmr' then
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90) < 0 
				then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90) 
	            else tempb.ar_net_amount end) 
	  else
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90) > 0 
				then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90) 
	            else tempb.ar_net_amount end) end as bal_overdue_61_90,

	  case when tempb.system_transaction_type_rcd = 'cdmr' then
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120) 
				else tempb.ar_net_amount end) 
	  ELSE
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120) 
				else tempb.ar_net_amount end) end as bal_overdue_91_120,

      case when tempb.system_transaction_type_rcd = 'cdmr' then
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151) 
				else tempb.ar_net_amount end) 
	  ELSE
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151) 
				else tempb.ar_net_amount end) end as bal_overdue_121_151,

	  case when tempb.system_transaction_type_rcd = 'cdmr' then
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182) 
				else tempb.ar_net_amount end) 
	  ELSE
	  (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182) 
				else tempb.ar_net_amount end) end as bal_overdue_152_182,

	  case when tempb.system_transaction_type_rcd = 'cdmr' then
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213) 
				else tempb.ar_net_amount end) 
	  else
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213) 
				else tempb.ar_net_amount end) end as bal_overdue_183_213,

      case when tempb.system_transaction_type_rcd = 'cdmr' then
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244) 
				else tempb.ar_net_amount end)
	  ELSE 
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244) 
				else tempb.ar_net_amount end) end as bal_overdue_214_244,

      case when tempb.system_transaction_type_rcd = 'cdmr' then
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275) 
				else tempb.ar_net_amount end) 
	  else
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275) 
				else tempb.ar_net_amount end) end as bal_overdue_245_275,

      case when tempb.system_transaction_type_rcd = 'cdmr' then
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306) 
				else tempb.ar_net_amount end) 
	  else
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306) 
				else tempb.ar_net_amount end) end as bal_overdue_276_306,

      case when tempb.system_transaction_type_rcd = 'cdmr' then
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337) 
				else tempb.ar_net_amount end) 
	  else
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337) 
				else tempb.ar_net_amount end) end as bal_overdue_307_337,

      case when tempb.system_transaction_type_rcd = 'cdmr' then
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365) 
				else tempb.ar_net_amount end) 
	  else
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365) 
				else tempb.ar_net_amount end) end as bal_overdue_338_365,

      case when tempb.system_transaction_type_rcd = 'cdmr' then
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365 + tempb.overdue_366_999) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365 + tempb.overdue_366_999) 
				else tempb.ar_net_amount end) 
	  else 
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365 + tempb.overdue_366_999) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365 + tempb.overdue_366_999) 
				else tempb.ar_net_amount end) end as bal_overdue_366_999,

      case when tempb.system_transaction_type_rcd = 'cdmr' then
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365 + tempb.overdue_366_999 + tempb.over_999) < 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365 + tempb.overdue_366_999 + tempb.over_999) 
				else tempb.ar_net_amount end) 
	  else
      (case when (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365 + tempb.overdue_366_999 + tempb.over_999) > 0 
	            then tempb.ar_net_amount - (tempb.future_ap + tempb.current_ap + tempb.overdue_1_30 + tempb.overdue_31_60 + tempb.overdue_61_90 + tempb.overdue_91_120 + tempb.overdue_121_151 + tempb.overdue_152_182 + tempb.overdue_183_213 + tempb.overdue_214_244 + tempb.overdue_245_275 + tempb.overdue_276_306 + tempb.overdue_307_337 + tempb.overdue_338_365 + tempb.overdue_366_999 + tempb.over_999) 
				else tempb.ar_net_amount end) end as bal_over_999


from
(
	SELECT distinct temp.organisation_type,
		   temp.invoice_no,
		   temp.system_transaction_type_rcd,
		   --temp.transaction_no,
		   temp.hn,
		   --temp.patient_name,
		   temp.due_date,
		   temp.transaction_date_time,
		   --temp.remit,
		   --temp.aging,
		   --temp.invoice_id,
		   temp.total_amt,
		   temp.ar_net_amount,
		   	isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging <= -31
			   and invoice_no = temp.invoice_no),0) as future_ap,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= -30 and aging <= 0
			   and invoice_no = temp.invoice_no),0) as current_ap,
		   isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 1 and aging <= 30
			   and invoice_no = temp.invoice_no),0) as overdue_1_30,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 31 and aging <= 60
			   and invoice_no = temp.invoice_no),0) as overdue_31_60,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 61 and aging <= 90
			   and invoice_no = temp.invoice_no),0) as overdue_61_90,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 91 and aging <= 120
			   and invoice_no = temp.invoice_no),0) as overdue_91_120,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 121 and aging <= 151
			   and invoice_no = temp.invoice_no),0) as overdue_121_151,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 152 and aging <= 182
			   and invoice_no = temp.invoice_no),0) as overdue_152_182,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 183 and aging <= 213
			   and invoice_no = temp.invoice_no),0) as overdue_183_213,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 214 and aging <= 244
			   and invoice_no = temp.invoice_no),0) as overdue_214_244,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 245 and aging <= 275
			   and invoice_no = temp.invoice_no),0) as overdue_245_275,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 276 and aging <= 306
			   and invoice_no = temp.invoice_no),0) as overdue_276_306,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 307 and aging <= 337
			   and invoice_no = temp.invoice_no),0) as overdue_307_337,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 338 and aging <= 365
			   and invoice_no = temp.invoice_no),0) as overdue_338_365,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 366 and aging <= 999
			   and invoice_no = temp.invoice_no),0) as overdue_366_999,
			isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging > 999
			   and invoice_no = temp.invoice_no),0) as over_999
	from
	(
	SELECT * from @table maintbl
	) as temp
	--where temp.aging_group <> 1
	--where temp.invoice_no in ('PINV-2015-033295')
	--  temp.hn = '00262026'
) as tempb
order by tempb.hn


