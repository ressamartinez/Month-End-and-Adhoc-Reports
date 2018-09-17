


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
	payor_name varchar(300),
	hn varchar(10),
	patient_name varchar(300),
	receive_due_date smalldatetime,
	gl_acct_code varchar(20)
	--effective_date smalldatetime
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
				   payor_name,
				   hn,
				   patient_name,
				   receive_due_date,
				   gl_acct_code
				   --effective_date
				   )
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
		   DATEDIFF(DAY,rip.transaction_date_time,sai.receive_due_date) as aging,
		   case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as organisation_type,
		   p.policy_id,
		   case when c.person_id is not NULL then pfn.display_name_l else o.name_l end as payor_name,
		   rip.hn,
		   rip.patient_name,
		   sai.receive_due_date,
		   gac.gl_acct_code_code
		   --r.effective_date
	from HISReport.dbo.rpt_invoice_pf rip LEFT OUTER JOIN AmalgaPROD.dbo.swe_ar_instalment sai on rip.invoice_id = sai.ar_invoice_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.remittance r on sai.remittance_id = r.remittance_id
										  inner JOIN AmalgaPROD.dbo.ar_invoice_nl_view ar on rip.invoice_id = ar.ar_invoice_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.policy p on ar.policy_id = p.policy_id
										  left OUTER JOIN AmalgaPROD.dbo.customer c on ar.customer_id = c.customer_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation o on c.organisation_id = o.organisation_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on c.person_id = pfn.person_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation_role oor on o.organisation_id = oor.organisation_id
										  LEFT OUTER JOIN AmalgaPROD.dbo.organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd
										  left outer join gl_acct_code gac on gac.gl_acct_code_id = ar.gl_acct_code_debit_id
	where YEAR(sai.receive_due_date) = 2015
	    and MONTH(sai.receive_due_date) >= 1 and  MONTH(sai.receive_due_date) <= 1
	   and ar.ar_invoice_id = sai.ar_invoice_id
	   and ar.user_transaction_type_id in ('F8EF2162-3311-11DA-BB34-000E0C7F3ED2','30957FA1-735D-11DA-BB34-000E0C7F3ED2')
	   and ar.transaction_status_rcd not in ('voi','unk')


SELECT tempb.*,
	  case when tempb.paid_amount > 0 THEN tempb.total_amt - tempb.paid_amount else tempb.total_amt end as balance
	 -- case when (tempb.paid_amount + tempb.paid_2) > 0 then tempb.total_amt - (tempb.paid_amount + tempb.paid_2) else tempb.total_amt end  as bal_2,
	 -- case when (tempb.paid_amount + tempb.paid_2 + tempb.paid_3) > 0 then tempb.total_amt - (tempb.paid_amount + tempb.paid_2 + tempb.paid_3) else tempb.total_amt end  as bal_3,
	 -- case when (tempb.paid_amount + tempb.paid_2 + tempb.paid_3 + tempb.paid_4) > 0 then tempb.total_amt - (tempb.paid_amount + tempb.paid_2 + tempb.paid_3 + tempb.paid_4) 
		--	    else tempb.total_amt end  as bal_4,
	 -- case when (tempb.paid_amount + tempb.paid_2 + tempb.paid_3 + tempb.paid_4 + tempb.paid_5) > 0 then tempb.total_amt - (tempb.paid_amount + tempb.paid_2 + tempb.paid_3 + tempb.paid_4 + tempb.paid_5) 
	 --           else tempb.total_amt end  as bal_5,
	 -- case when (tempb.paid_amount + tempb.paid_2 + tempb.paid_3 + tempb.paid_4 + tempb.paid_5 + tempb.paid_6) > 0 
	 --           then tempb.total_amt - (tempb.paid_amount + tempb.paid_2 + tempb.paid_3 + tempb.paid_4 + tempb.paid_5 + tempb.paid_6) else tempb.total_amt end  as bal_6,
	 --case when (tempb.paid_amount + tempb.paid_2 + tempb.paid_3 + tempb.paid_4 + tempb.paid_5 + tempb.paid_6 + tempb.paid_7) > 0 
	 --           then tempb.total_amt - (tempb.paid_amount + tempb.paid_2 + tempb.paid_3 + tempb.paid_4 + tempb.paid_5 + tempb.paid_6 + tempb.paid_7) else tempb.total_amt end  as bal_7

from
(
	SELECT distinct 
	       temp.organisation_type,
		   temp.invoice_no,
		   temp.hn,
		   temp.patient_name,
		   temp.receive_due_date,
		   temp.transaction_date_time,
		   --temp.effective_date,
		   --temp.invoice_id,
		   temp.total_amt,
		   --temp.rem_transaction_datetime,
		   isnull((SELECT SUM(sai_net_amount)
			from @table
			where aging >= 0 and aging <= 30
			   and invoice_no = temp.invoice_no),0) as paid_amount
			--isnull((SELECT SUM(sai_net_amount)
			--from @table
			--where aging >= 31 and aging <= 60
			--   and invoice_no = temp.invoice_no),0) as paid_2,
			--isnull((SELECT SUM(sai_net_amount)
			--from @table
			--where aging >= 61 and aging <= 90
			--   and invoice_no = temp.invoice_no),0) as paid_3,
			--isnull((SELECT SUM(sai_net_amount)
			--from @table
			--where aging >= 91 and aging <= 120
			--   and invoice_no = temp.invoice_no),0) as paid_4,
			--isnull((SELECT SUM(sai_net_amount)
			--from @table
			--where aging >= 121 and aging <= 365
			--   and invoice_no = temp.invoice_no),0) as paid_5,
			--isnull((SELECT SUM(sai_net_amount)
			--from @table
			--where aging >= 366 and aging <= 999
			--   and invoice_no = temp.invoice_no),0) as paid_6,
			--isnull((SELECT SUM(sai_net_amount)
			--from @table
			--where aging >= 999
			--   and invoice_no = temp.invoice_no),0) as paid_7
			,temp.aging
			,temp.gl_acct_code
	from
	(
	SELECT *,
		   CASE when aging >= 1 and aging <= 30 then 1
				when aging >= 31 and aging <= 60 then 2
				when aging >= 61 and aging <= 90 then 3
				when aging >= 91 and aging <= 120 then 4
				when aging >= 121 and aging <= 365 then 5
				when aging >= 366 and aging <= 999 then 6
				when aging >= 999 then 7
		   end as aging_group
	from @table maintbl
	) as temp
	where temp.aging_group = 1
	--and temp.gl_acct_code = '1130400'
	--and temp.invoice_no in ('PINV-2014-210199', 'PINV-2014-210008', 'PINV-2014-210325', 'PINV-2014-210370', 'PINV-2014-210387', 'PINV-2014-209750')
) as tempb
order by aging desc




/*
SELECT temp.monthid,
	   temp.month_name,
	   temp.organisation_type,
	 --  temp.total_amt,
	 case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 
		  else  temp.total_amt - temp.overdue_0_30 end as overdue_0_30,
	 case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 
			else  temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 end as overdue_31_60,
	  case when temp.organisation_type = 'Philhealth'  then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 - overdue_91_120 
		   else temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 end as overdue_61_90,
	   case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 - overdue_91_120 - overdue_121_365  
			else temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 end as overdue_91_120,
	  case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 - overdue_91_120 - overdue_121_365 - overdue_366_999 
			else temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 end as overdue_121_365,
	  case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 - overdue_91_120 - overdue_121_365 - overdue_366_999 - over_999
		   else temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 end as  overdue_366_999,
	  case when temp.organisation_type = 'Philhealth' then temp.total_amt - philhealth_overdue_0_60 - overdue_61_90 - overdue_91_120 - overdue_121_365 - overdue_366_999 - over_999
		   else temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 - temp.over_999 end as over_999,


	   temp.total_amt - temp.overdue_0_30 as overdue_0_30_a,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 as overdue_31_60_a,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 as overdue_61_90_a,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 as overdue_91_120_a,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 as overdue_121_365_a,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 as overdue_366_999_a,
	   temp.total_amt - temp.overdue_0_30 - temp.overdue_31_60 - temp.overdue_61_90 - temp.overdue_91_120 - temp.overdue_121_365 - overdue_366_999 - temp.over_999 as over_999_a
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

*/