
DECLARE @table table
(
	invoice_id uniqueidentifier,
	invoice_no varchar(20),
	transaction_date_time smalldatetime,
	policy_name varchar(250),
	swe_payment_status_rcd varchar(10),
	total_amt money,
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
	payor_name varchar(300)

)



insert into @table(invoice_id,
				   invoice_no,
				   transaction_date_time,
				   policy_name,
				   swe_payment_status_rcd,
				   total_amt,
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
				   payor_name)
	SELECT rip.invoice_id,
		   rip.invoice_no,
		   rip.transaction_date_time,
		   case when rip.policy_name = '--' then rip.patient_name else rip.policy_name end as policy_name,
		   rip.swe_payment_status_rcd,
		   rip.total_amt,
		   sai.instalment_id,
		   r.remittance_id,
		   sai.swe_payment_status_rcd as sai_payment_status,
		   sai.net_amount as sai_net_amount,
		   r.transaction_date_time as rem_transaction_datetime,
		   DATEDIFF(DAY,rip.transaction_date_time,r.transaction_date_time) as aging,
		
		   case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as organisation_type,
		   
		   p.policy_id,
		   case when c.person_id is not NULL then pfn.display_name_l else o.name_l end as payor_name
	from HISReport.dbo.rpt_invoice_pf rip LEFT OUTER JOIN AmalgaPROD.dbo.swe_ar_instalment sai on rip.invoice_id = sai.ar_invoice_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.remittance r on sai.remittance_id = r.remittance_id
										  inner JOIN AmalgaPROD.dbo.ar_invoice_nl_view ar on rip.invoice_id = ar.ar_invoice_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.policy p on ar.policy_id = p.policy_id
										  left OUTER JOIN AmalgaPROD.dbo.customer c on ar.customer_id = c.customer_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation o on c.organisation_id = o.organisation_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on c.person_id = pfn.person_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation_role oor on o.organisation_id = oor.organisation_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd
	where YEAR(rip.transaction_date_time) = 2015
	    and MONTH(rip.transaction_date_time) >= 1 and  MONTH(rip.transaction_date_time) <= 1
	   and ar.ar_invoice_id = sai.ar_invoice_id
	   and ar.user_transaction_type_id in ('F8EF2162-3311-11DA-BB34-000E0C7F3ED2','30957FA1-735D-11DA-BB34-000E0C7F3ED2')
	   and ar.transaction_status_rcd not in ('voi','unk')




SELECT temp.monthid,
	   temp.month_name,
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
	   temp.future_ap as future_ap,
	   temp.current_ap as current_ap,
	   temp.total_amt - temp.overdue_0_30 as overdue_0_30,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 as overdue_31_60,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 as overdue_61_90,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 as overdue_91_120,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 as overdue_121_365,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 as overdue_366_999,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 - temp.over_999 as over_999

	
	from
(
select  DISTINCT MONTH(tbl1.transaction_date_time) as monthid,
		    case when MONTH(tbl1.transaction_date_time) = 1 then 'January'
				 when MONTH(tbl1.transaction_date_time) = 2 then 'February'
				 when MONTH(tbl1.transaction_date_time) = 3 then 'March'
			     when MONTH(tbl1.transaction_date_time) = 4 then 'April'
			     when MONTH(tbl1.transaction_date_time) = 5 then 'May'
				 when MONTH(tbl1.transaction_date_time) = 6 then 'June'
				 when MONTH(tbl1.transaction_date_time) = 7 then 'July'
				 when MONTH(tbl1.transaction_date_time) = 8 then 'August'
				 when MONTH(tbl1.transaction_date_time) = 9 then 'September'
				 when MONTH(tbl1.transaction_date_time) = 10 then 'October'
				 when MONTH(tbl1.transaction_date_time) = 11 then 'November'
				 when MONTH(tbl1.transaction_date_time) = 12 then 'December' 
		   END as month_name,
		   tbl1.organisation_type,
		  -- sum(tbl1.total_amt) as total_amt,
		  (SELECT sum(temp.total_amt)
			from
			(
				SELECT DISTINCT invoice_id,
						total_amt
				from @table
				where organisation_type = tbl1.organisation_type
					and MONTH(transaction_date_time) = MONTH(tbl1.transaction_date_time)
			) as temp) as total_amt,
			isnull((SELECT sum(sai_net_amount)
					from @table
					where sai_payment_status = 'COM'
						and aging <= -31
						and organisation_type = tbl1.organisation_type
						and MONTH(transaction_date_time) =  MONTH(tbl1.transaction_date_time)
						--and MONTH(transaction_date_time) = @month
						),0) as future_ap,
			isnull((SELECT sum(sai_net_amount)
					from @table
					where sai_payment_status = 'COM'
						and aging >= -30 and aging <= -1
						and organisation_type = tbl1.organisation_type
						and MONTH(transaction_date_time) =  MONTH(tbl1.transaction_date_time)
						--and MONTH(transaction_date_time) = @month
						),0) as current_ap,
			isnull((SELECT sum(sai_net_amount)
					from @table
					where sai_payment_status = 'COM'
						and aging >= 0 and aging <= 60
						and organisation_type = tbl1.organisation_type
						and MONTH(transaction_date_time) =  MONTH(tbl1.transaction_date_time)
						--and MONTH(transaction_date_time) = @month
						),0) as philhealth_overdue_0_60,
		    isnull((SELECT sum(sai_net_amount)
					from @table
					where sai_payment_status = 'COM'
						and aging >= 0 and aging <= 30
						and organisation_type = tbl1.organisation_type
						and MONTH(transaction_date_time) =  MONTH(tbl1.transaction_date_time)
						--and MONTH(transaction_date_time) = @month
						),0) as overdue_0_30,
		   	isnull((SELECT sum(sai_net_amount)
					from @table
					where sai_payment_status = 'COM'
						and aging >= 31 and aging <= 60
						and organisation_type = tbl1.organisation_type
						and MONTH(transaction_date_time) =  MONTH(tbl1.transaction_date_time)),0) as overdue_31_60,
			isnull((SELECT sum(sai_net_amount)
					from @table
					where sai_payment_status = 'COM'
						and aging >= 61 and aging <= 90
						and organisation_type = tbl1.organisation_type
						and MONTH(transaction_date_time) =  MONTH(tbl1.transaction_date_time)),0) as overdue_61_90,
			isnull((SELECT sum(sai_net_amount)
					from @table
					where sai_payment_status = 'COM'
						and aging >= 91 and aging <= 120
						and organisation_type = tbl1.organisation_type
						and MONTH(transaction_date_time) =  MONTH(tbl1.transaction_date_time)),0) as overdue_91_120,
			isnull((SELECT sum(sai_net_amount)
					from @table
					where sai_payment_status = 'COM'
						and aging >= 121 and aging <= 365
						and organisation_type = tbl1.organisation_type
						and MONTH(transaction_date_time) =  MONTH(tbl1.transaction_date_time)),0) as overdue_121_365,
			isnull((SELECT sum(sai_net_amount)
					from @table
					where sai_payment_status = 'COM'
						and aging >= 366 and aging <= 999
						and organisation_type = tbl1.organisation_type
						and MONTH(transaction_date_time) =  MONTH(tbl1.transaction_date_time)),0) as overdue_366_999,
		 isnull((SELECT sum(sai_net_amount)
					from @table
					where sai_payment_status = 'COM'
						and aging >  999
						and organisation_type = tbl1.organisation_type
						and MONTH(transaction_date_time) =  MONTH(tbl1.transaction_date_time)),0) as over_999
from @table tbl1
--where tbl1.organisation_type = 'Self Pay'
--  and MONTH(tbl1.transaction_date_time) = 1
group by  MONTH(tbl1.transaction_date_time), tbl1.organisation_type
) as temp
ORDER BY temp.monthid, temp.organisation_type
