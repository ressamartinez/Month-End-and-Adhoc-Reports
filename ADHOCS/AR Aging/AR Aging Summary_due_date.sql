
DECLARE @table table
	(organisation_type varchar(250),
	invoice_id uniqueidentifier,
	invoice_no varchar(20),
	hn varchar(20),
	patient_name varchar(255),
	due_date smalldatetime,
	invoice_date smalldatetime,
	total_amt money,
	installment_amount money,
	overdue_age int,
	gl_acct_code_code varchar(20),
	swe_payment_status_rcd varchar(10)
	)



insert into @table
	(organisation_type,
	invoice_id,
	invoice_no,
	hn,
	patient_name,
	due_date,
	invoice_date,
	total_amt,
	installment_amount,
	overdue_age,
	gl_acct_code_code,
	swe_payment_status_rcd
	)

select distinct case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as organisation_type,
				rip.invoice_id,
				rip.invoice_no,
				rip.hn,
				rip.patient_name,
				atb.due_date,
				atb.invoice_date,
				rip.total_amt,
				atb.instalment_amount,
				atb.overdue_age,
				atb.gl_acct_code_code,
				rip.swe_payment_status_rcd

from aged_trial_balance_ar_rollup_nl_view atb
	 left outer join HISReport.dbo.rpt_invoice_pf rip on rip.invoice_id = atb.invoice_id
	 left outer join aged_trial_balance a on a.aged_trial_balance_id = atb.aged_trial_balance_id
	  inner JOIN AmalgaPROD.dbo.ar_invoice_nl_view ar on rip.invoice_id = ar.ar_invoice_id
	 left OUTER JOIN AmalgaPROD.dbo.customer c on atb.customer_id = c.customer_id
	 LEFT OUTER JOIN AmalgaPROD.dbo.organisation o on c.organisation_id = o.organisation_id
	 LEFT OUTER JOIN AmalgaPROD.dbo.organisation_role oor on o.organisation_id = oor.organisation_id
	 LEFT OUTER JOIN AmalgaPROD.dbo.organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd
where 
		--year(atb.due_date) = 2016
	 --and month(atb.due_date) = 1
  --    and atb.overdue_age >= 31 and atb.overdue_age <= 60
	    atb.gl_acct_code_code = '1130400'
	  --and atb.aged_trial_balance_id = 'BF4A3A1B-AAC7-11E4-9D8F-78E3B597EAF4'    --2015-01-31
	  --and atb.aged_trial_balance_id = '45E2BFF9-C149-11E4-9B7D-78E3B58FDDFA'    --2015-02-28
	  --and atb.aged_trial_balance_id = '17FDE9BB-D80C-11E4-99C7-78E3B58FDDFA'    --2015-03-31
	  --and atb.aged_trial_balance_id = '18D9CFF1-D815-11E4-99C7-78E3B58FDDFA'    --2015-03-31 (2) same as above id
	  --and atb.aged_trial_balance_id = '3247038C-F071-11E4-A4CC-78E3B58FDDFA'    --2015-04-30
	  --and atb.aged_trial_balance_id = 'C25991D5-08DB-11E5-A8C6-78E3B58FDDFA'    --2015-05-31
	  --and atb.aged_trial_balance_id = 'BCA1968E-1FC5-11E5-A903-78E3B58FDDFA'    --2015-06-30
	  --and atb.aged_trial_balance_id = '92E71CF7-39A9-11E5-9EB6-78E3B58FDDFA'    --2015-07-31
	  --and atb.aged_trial_balance_id = '5A6FB1D4-508D-11E5-A2AF-78E3B58FDDFA'    --2015-08-31
	  --and atb.aged_trial_balance_id = '2E4DD26D-6811-11E5-AE06-78E3B58FDDFA'    --2015-09-30
	  --and atb.aged_trial_balance_id = 'CAC941B1-8140-11E5-9DC0-78E3B58FDDFA'    --2015-10-31
	  --and atb.aged_trial_balance_id = '2BF80A85-9807-11E5-A77A-78E3B58FDDFA'    --2015-11-30
	  --and atb.aged_trial_balance_id = 'EBA174BD-B2BA-11E5-A6AB-78E3B58FDDFA'    --2015-12-31
	  and atb.aged_trial_balance_id = '81F6970B-C8CB-11E5-9F48-78E3B58FDDFA'    --2016-01-31
	  --and atb.aged_trial_balance_id = 'B9ED3F47-E01D-11E5-9981-78E3B58FDDFA'    --2016-02-29
	  --and atb.aged_trial_balance_id = '5C297F96-F7E1-11E5-A358-78E3B58FDDFA'    --2016-03-31
	  --and atb.aged_trial_balance_id = '5FC49A03-1033-11E6-98A8-78E3B58FDDFA'    --2016-04-30
	  --and atb.aged_trial_balance_id = '90876F40-27A5-11E6-9E87-78E3B58FDDFA'    --2016-05-31
	  --and atb.aged_trial_balance_id = '7FF75B05-3F8F-11E6-ADB7-78E3B58FDEEC'    --2016-06-30
	  --and atb.aged_trial_balance_id = '4BCB071C-57BC-11E6-8B7C-78E3B58FDDFA'    --2016-07-31
	  --and atb.aged_trial_balance_id = '3CFBEF2A-6FEC-11E6-A779-78E3B58FDDFA'    --2016-08-31
	  --and atb.aged_trial_balance_id = '8134DDAE-8911-11E6-8FE3-78E3B58FDDFA'    --2016-09-30
	  --and atb.aged_trial_balance_id = '8185E916-8946-11E6-8FE3-78E3B58FDDFA'    --2016-09-30 (2) same as above id
	  --and atb.aged_trial_balance_id = 'A0599284-A0B0-11E6-A54F-78E3B58FDDFA'    --2016-10-31
	  --and atb.aged_trial_balance_id = 'A13BE7D9-B78D-11E6-A1F5-78E3B58FDDFA'    --2016-11-30
	  --and atb.aged_trial_balance_id = '7C6C8D61-D189-11E6-A3F3-78E3B58FDDFA'    --2016-12-31
	  --and atb.aged_trial_balance_id = 'DB943969-E834-11E6-897B-78E3B58FDDFA'    --2017-01-31
	  --and atb.aged_trial_balance_id = 'B2D2D36E-FE25-11E6-9ED3-78E3B58FDDFA'    --2017-02-28
	  --and atb.aged_trial_balance_id = '3681E740-FEF4-11E6-B413-78E3B58FDDFA'    --2017-02-28 (2) not equal, use above id
	  --and atb.aged_trial_balance_id = '9CBD52D0-1681-11E7-BB8C-78E3B58FDDFA'    --2017-03-31
	  --and atb.aged_trial_balance_id = 'C14E613E-2EF7-11E7-8234-78E3B58FDDFA'    --2017-04-30
	  --and atb.aged_trial_balance_id = 'A14A0BE0-4687-11E7-ADA3-78E3B58FDDFA'    --2017-05-31
	  --and atb.aged_trial_balance_id = 'FD33FFBC-5E0D-11E7-B8F3-78E3B58FDDFA'    --2017-06-30
	  --and atb.aged_trial_balance_id = '37141D69-766E-11E7-B605-78E3B58FDDFA'    --2017-07-31
	  --and atb.aged_trial_balance_id = 'CF493DAF-8EB9-11E7-A3BE-78E3B58FDDFA'    --2017-08-31
	  --and atb.aged_trial_balance_id = 'D999CBA3-A718-11E7-8CEC-78E3B58FDDFA'    --2017-09-30
	  --and atb.aged_trial_balance_id = '04F0F35B-BFAB-11E7-A743-78E3B58FDDFA'    --2017-10-31
	  --and atb.aged_trial_balance_id = '73EAC4B1-D645-11E7-9256-78E3B58FDDFA'    --2017-11-30
	  --and atb.aged_trial_balance_id = '8366C25A-EF6B-11E7-A2B8-78E3B58FDDFA'    --2017-12-31






SELECT 
	   --temp.monthid,
	   --temp.month_name,
	   temp.organisation_type,
	   --temp.total_amt,
	 --case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 
		--  else  temp.total_amt - temp.overdue_0_30 end as overdue_0_30,
	 --case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 
		--	else  temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 end as overdue_31_60,
	 -- case when temp.organisation_type = 'Philhealth'  then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 - overdue_91_120 
		--   else temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 end as overdue_61_90,
	 --  case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 - overdue_91_120 - overdue_121_365  
		--	else temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 end as overdue_91_120,
	 -- case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 - overdue_91_120 - overdue_121_365 - overdue_366_999 
		--	else temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 end as overdue_121_365,
	 -- case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 - overdue_91_120 - overdue_121_365 - overdue_366_999 - over_999
		--   else temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 end as  overdue_366_999,
	 -- case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 - overdue_91_120 - overdue_121_365 - overdue_366_999 - over_999
		--   else temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 - temp.over_999 end as over_999
	   --temp.future_ap asue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 - temp.over_999 as over_999

	   --temp.future_ap as future_ap_a,
	   --temp.current_ap as current_ap_a,
	   --temp.total_amt - temp.future_ap - temp.current_ap - temp.overdue_0_30 as overdue_0_30_a,
	   --temp.total_amt - temp.future_ap - temp.current_ap - temp.overdue_0_30 - temp.overdue_31_60 as overdue_31_60_a,
	   --temp.total_amt - temp.future_ap - temp.current_ap - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 as overdue_61_90_a,
	   --temp.total_amt - temp.future_ap - temp.current_ap - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 as overdue_91_120_a,
	   --temp.total_amt - temp.future_ap - temp.current_ap - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 as overdue_121_365_a,
	   --temp.total_amt - temp.future_ap - temp.current_ap - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 as overdue_366_999_a,
	   --temp.total_amt - temp.future_ap - temp.current_ap - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 - temp.over_999 as over_999_a


	   temp.future_ap as future_ap,
	   temp.current_ap as current_ap,
	   temp.overdue_0_30 as overdue_0_30,
	   temp.overdue_31_60 as overdue_31_60,
	   temp.overdue_61_90 as overdue_61_90,
	   temp.overdue_91_120 as overdue_91_120,
	   temp.overdue_121_365 as overdue_121_365,
	   temp.overdue_366_999 as overdue_366_999,
	   temp.over_999 as over_999

	
	from
(
select  DISTINCT 
--MONTH(tbl1.due_date) as monthid,
--		    case when MONTH(tbl1.due_date) = 1 then 'January'
--				 when MONTH(tbl1.due_date) = 2 then 'February'
--				 when MONTH(tbl1.due_date) = 3 then 'March'
--			     when MONTH(tbl1.due_date) = 4 then 'April'
--			     when MONTH(tbl1.due_date) = 5 then 'May'
--				 when MONTH(tbl1.due_date) = 6 then 'June'
--				 when MONTH(tbl1.due_date) = 7 then 'July'
--				 when MONTH(tbl1.due_date) = 8 then 'August'
--				 when MONTH(tbl1.due_date) = 9 then 'September'
--				 when MONTH(tbl1.due_date) = 10 then 'October'
--				 when MONTH(tbl1.due_date) = 11 then 'November'
--				 when MONTH(tbl1.due_date) = 12 then 'December' 
--		   END as month_name,
		   tbl1.organisation_type,
		  -- sum(tbl1.total_amt) as total_amt,
		  (SELECT sum(temp.total_amt)
			from
			(
				SELECT DISTINCT invoice_id,
						total_amt
				from @table
				where organisation_type = tbl1.organisation_type
					--and MONTH(due_date) = MONTH(tbl1.due_date)
			) as temp) as total_amt,
			isnull((SELECT sum(installment_amount)
					from @table
					where overdue_age <= -31
						and organisation_type = tbl1.organisation_type
						--and MONTH(due_date) =  MONTH(tbl1.due_date)
						),0) as future_ap,
			isnull((SELECT sum(installment_amount)
					from @table
					where overdue_age >= -30 and overdue_age <= -1
						and organisation_type = tbl1.organisation_type
						--and MONTH(due_date) =  MONTH(tbl1.due_date)
						),0) as current_ap,
			isnull((SELECT sum(installment_amount)
					from @table
					where overdue_age >= 0 and overdue_age <= 60
						and organisation_type = tbl1.organisation_type
						--and MONTH(due_date) =  MONTH(tbl1.due_date)
						),0) as philhealth_overdue_0_60,
		    isnull((SELECT sum(installment_amount)
					from @table
					where overdue_age >= 0 and overdue_age <= 30
						and organisation_type = tbl1.organisation_type
						--and MONTH(due_date) =  MONTH(tbl1.due_date)
						),0) as overdue_0_30,
		   	isnull((SELECT sum(installment_amount)
					from @table
					where overdue_age >= 31 and overdue_age <= 60
						and organisation_type = tbl1.organisation_type
						--and MONTH(due_date) =  MONTH(tbl1.due_date)
						),0) as overdue_31_60,
			isnull((SELECT sum(installment_amount)
					from @table
					where overdue_age >= 61 and overdue_age <= 90
						and organisation_type = tbl1.organisation_type
						--and MONTH(due_date) =  MONTH(tbl1.due_date)
						),0) as overdue_61_90,
			isnull((SELECT sum(installment_amount)
					from @table
					where overdue_age >= 91 and overdue_age <= 120
						and organisation_type = tbl1.organisation_type
						--and MONTH(due_date) =  MONTH(tbl1.due_date)
						),0) as overdue_91_120,
			isnull((SELECT sum(installment_amount)
					from @table
					where overdue_age >= 121 and overdue_age <= 365
						and organisation_type = tbl1.organisation_type
						--and MONTH(due_date) =  MONTH(tbl1.due_date)
						),0) as overdue_121_365,
			isnull((SELECT sum(installment_amount)
					from @table
					where overdue_age >= 366 and overdue_age <= 999
						and organisation_type = tbl1.organisation_type
						--and MONTH(due_date) =  MONTH(tbl1.due_date)
						),0) as overdue_366_999,
		 isnull((SELECT sum(installment_amount)
					from @table
					where overdue_age > 999
						and organisation_type = tbl1.organisation_type
						--and MONTH(due_date) =  MONTH(tbl1.due_date)
						),0) as over_999
from @table tbl1
--where tbl1.organisation_type = 'Self Pay'
--  and MONTH(tbl1.transaction_date_time) = 1
group by  tbl1.organisation_type
) as temp
ORDER BY temp.organisation_type

