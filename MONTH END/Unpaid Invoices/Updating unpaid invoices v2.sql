begin tran
DECLARE @date0 DATETIME 
DECLARE @date1 DATETIME
DECLARE @date2 DATETIME

SET @date0 = DATEADD(MONTH, -1, GETDATE())
SET @date1 = HISViews.dbo.GETFIRSTDATEOFMONTH(@date0)
SET @date2 = HISViews.dbo.GETLASTDATEOFMONTH(@date0)

update rpt_invoice_pf
set gross_df = temp.gross_df,
	discount_df = temp.discount_df,
	net_df = temp.gross_df - temp.discount_df,
	gross_hb = temp.gross_hb,
	discount_hb = temp.discount_hb,
	net_hb = temp.gross_hb - temp.discount_hb,
	philhealth = temp.philhealth,
	philhealth_pf = temp.philhealth_pf,
	gross_pf = temp.gross_pf,
	discount_pf = temp.discount_pf,
	net_pf = temp.gross_pf - temp.discount_pf
/*select temp.hn as HN,
		   temp.patient_name as [Patient Name],
		   ISNULL(temp.policy_name,'--') as [Payor],
		   temp.invoice_no as [Invoice No.],
		   temp.visit_type as [Visit Type],
		   temp.visit_type_rcd,
		   temp.transaction_date_time as [Transaction Date and Time],
		   temp.discharge_date_time as [Discharge Date and Time],
		   temp.swe_payment_status_rcd,
		   temp.total_amt,
		   temp.ar_net_amt,
		   temp.philhealth as [Philhealth],
		   temp.philhealth_pf as [Philhealth PF],
		   temp.gross_hb,
		   temp.discount_hb as [Discount HB],
		  case when temp.system_transaction_type_rcd = 'DBMR' or temp.system_transaction_type_rcd = 'CDMR' then temp.dmar_cmar
				 else temp.gross_hb - (temp.discount_hb) end as [Net HB],
		   temp.gross_df,
		   temp.discount_df as [Discount DF],
		   temp.gross_df - temp.discount_df as [Net DF],
		   temp.gross_pf,
		   temp.discount_pf as [Discount PF],
		   temp.gross_pf - temp.discount_pf as [Net PF],
		   temp.gross_er_pf,
		   temp.discount_er_pf as [Discount ER PF],
		   temp.gross_er_pf - temp.discount_er_pf as [Net ER],
		   temp.package_discount as [Package Discount],
		   temp.patient_id,
		   temp.invoice_id,
		   temp.gross_readersfee,
		   temp.discount_readersfee*/
	from
	(
		SELECT DISTINCT _main.patient_id,
					_main.transaction_date_time,
					pfn.display_name_l as patient_name,
					_main.owing_amount,
					_main.ar_net_amt * ar_main.credit_factor as ar_net_amt,
					_main.visit_type,
					_main.visit_type_rcd,
					phu.visible_patient_id as hn,
					_main.policy_name,
					_main.discharge_date_time,
					_main.invoice_no,
					_main.invoice_id,
					ar_main.credit_factor,
					ar_main.gross_amount * ar_main.credit_factor as total_amt,
					ISNULL((SELECT SUM(a.gross_amount) as gross_philhealth
								from rpt_invoice_pf_detailed a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
															   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
								where main_itemgroupcode <> 's23'
									--and ISNULL(policy_name,'') LIKE '%philhealth%'
									 and c.short_code in (91,92,93,94,95,96,685,642)
									and gl_acct_code_code NOT in ('2152100','4445000','4264000')
									and invoice_no = _main.invoice_no),0) as philhealth,
						ISNULL((SELECT SUM(a.gross_amount) as gross_philhealth
								from rpt_invoice_pf_detailed  a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
															   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
								where
								  -- main_itemgroupcode = 's23'
									--and ISNULL(policy_name,'') LIKE '%philhealth%'
										  c.short_code in (91,92,93,94,95,96,685,642)
									--and  gl_acct_code_code <> '4445000'
									--and  gl_acct_code_code in ('2152100','4264000') --remove 4264000 from 2017 onwards
									and  gl_acct_code_code = '2152100'
									and invoice_no = _main.invoice_no),0) as philhealth_pf,
					  ISNULL((SELECT SUM(a.gross_amount) as gross
								from rpt_invoice_pf_detailed  a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
															   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
								where -- ISNULL(policy_name,'') not LIKE 'philhealth%'
								     c.short_code not in (91,92,93,94,95,96,685,642)-- or a.policy_id is NULL
								--	and item_code not LIKE 's23%'
									and gl_acct_code_code not in  ('2152100','2152250','4445000','4264000')
									and invoice_no = _main.invoice_no),0) + 
						--gross hb self pay
						  ISNULL((SELECT SUM(a.gross_amount) as gross
								from rpt_invoice_pf_detailed  a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
															   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
								where -- ISNULL(policy_name,'') not LIKE 'philhealth%'
								     a.policy_id is NULL
								--	and item_code not LIKE 's23%'
									and gl_acct_code_code not in  ('2152100','2152250','4445000','4264000')
									and invoice_no = _main.invoice_no),0)
					  as gross_hb,
						ISNULL((SELECT SUM(a.discount_amount) as gross
								from rpt_invoice_pf_detailed  a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
															   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
								where --ISNULL(policy_name,'') not LIKE 'philhealth%'
									  c.short_code not in (91,92,93,94,95,96,685,642)
									--and item_code not LIKE 's23%'
									and gl_acct_code_code not in  ('2152100','2152250','4445000','4264000')
									and invoice_no = _main.invoice_no),0) + 
						--discount hb self pay
							ISNULL((SELECT SUM(a.discount_amount) as gross
								from rpt_invoice_pf_detailed  a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
															   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
								where --ISNULL(policy_name,'') not LIKE 'philhealth%'
									  a.policy_id is NULL
									--and item_code not LIKE 's23%'
									and gl_acct_code_code not in  ('2152100','2152250','4445000','4264000')
									and invoice_no = _main.invoice_no),0)			
						 as discount_hb,
					  ISNULL((SELECT SUM(a.gross_amount) as gross_pf
							from rpt_invoice_pf_detailed a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
														   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
							where   --ISNULL(policy_name,'') not LIKE '%philhealth%'
						            c.short_code not in (91,92,93,94,95,96,685,642) 
								-- and main_itemgroupcode = 's23'
								 and gl_acct_code_code = '2152100'
									and invoice_no = _main.invoice_no),0) +
					 --gross pf self pay
					   ISNULL((SELECT SUM(a.gross_amount) as gross_pf
							from rpt_invoice_pf_detailed a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
														   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
							where   --ISNULL(policy_name,'') not LIKE '%philhealth%'
						           a.policy_id is NULL
								-- and main_itemgroupcode = 's23'
								 and gl_acct_code_code = '2152100'
									and invoice_no = _main.invoice_no),0) 
					as gross_pf,
					  ISNULL((SELECT SUM(a.discount_amount) as discount_pf
							from rpt_invoice_pf_detailed  a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
														   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
							where  --ISNULL(policy_name,'') not LIKE '%philhealth%'
									 c.short_code not in (91,92,93,94,95,96,685,642)
								-- and main_itemgroupcode = 's23'
								 and gl_acct_code_code = '2152100'
									and invoice_no = _main.invoice_no),0) + 
					--discount pf self pay
					 ISNULL((SELECT SUM(a.discount_amount) as discount_pf
							from rpt_invoice_pf_detailed  a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
														   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
							where  --ISNULL(policy_name,'') not LIKE '%philhealth%'
									a.policy_id is NULL
								-- and main_itemgroupcode = 's23'
								 and gl_acct_code_code = '2152100'
									and invoice_no = _main.invoice_no),0) 
					 as discount_pf,
					  ISNULL((SELECT SUM(a.gross_amount) as gross_df
								from rpt_invoice_pf_detailed  a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
														   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
								where    gl_acct_code_code in ('4264000')
									-- and main_itemgroupcode <> 's23'
									-- and  c.short_code not in (91,92,93,94,95,96,685,642)
									-- and  ISNULL(policy_name,'') not LIKE '%philhealth%'
									and invoice_no = _main.invoice_no),0) as gross_df,
					   ISNULL((SELECT SUM(a.discount_amount) as discount_df
								from rpt_invoice_pf_detailed  a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
														   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
								where  gl_acct_code_code in ('4264000')
									 --and main_itemgroupcode <> 's23'
									 --and  ISNULL(policy_name,'') not LIKE '%philhealth%'
									-- and  c.short_code not in (91,92,93,94,95,96,685,642)
									and invoice_no = _main.invoice_no),0) as discount_df,

					 /* --original readers fee
					   ISNULL((SELECT SUM(a.gross_amount) as gross_df
								from rpt_invoice_pf_detailed a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
														   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
								where    gl_acct_code_code = '2152100' 
									 and main_itemgroupcode <> 's23'
									 and  c.short_code not in (91,92,93,94,95,96,685,642)
									 --and  ISNULL(policy_name,'') not LIKE '%philhealth%'
									and invoice_no = _main.invoice_no),0) as gross_df,
					   ISNULL((SELECT SUM(a.discount_amount) as discount_df
								from rpt_invoice_pf_detailed a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
														   left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
								where   gl_acct_code_code = '2152100'
									 and main_itemgroupcode <> 's23'
									  and  c.short_code not in (91,92,93,94,95,96,685,642)
									 --and  ISNULL(policy_name,'') not LIKE '%philhealth%'
									and invoice_no = _main.invoice_no),0) as discount_df,
					   */

						ISNULL((SELECT SUM(gross_amount) as gross_er_pf
								from rpt_invoice_pf_detailed 
								where    main_itemgroupcode = '600'
									 and gl_acct_code_code = '2152250'
									and invoice_no = _main.invoice_no),0) as gross_er_pf,
						ISNULL((SELECT SUM(discount_amount) as discount_er_pf
								from rpt_invoice_pf_detailed
								where    main_itemgroupcode = '600'
									 and gl_acct_code_code = '2152250'
									and invoice_no = _main.invoice_no),0) as discount_er_pf,
						ISNULL((SELECT SUM(gross_amount) as package_discount
								from rpt_invoice_pf_detailed
								where    gl_acct_code_code = '4445000'
									and invoice_no = _main.invoice_no),0) as package_discount,
						 ISNULL((SELECT SUM(a.net_amount * b.credit_factor) as met
									from rpt_invoice_pf_detailed a inner JOIN AmalgaPROD.dbo.ar_invoice b on a.invoice_id = b.ar_invoice_id
																	  left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
									where -- ISNULL(policy_name,'') not LIKE 'philhealth%'
										   c.short_code not in (91,92,93,94,95,96,685,642) 
										and b.system_transaction_type_rcd in ('DBMR','CDMR')
										and invoice_no = _main.invoice_no),0) +
						 --dmar cmar self pay
						  ISNULL((SELECT SUM(a.net_amount * b.credit_factor) as met
									from rpt_invoice_pf_detailed a inner JOIN AmalgaPROD.dbo.ar_invoice b on a.invoice_id = b.ar_invoice_id
																	  left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
									where -- ISNULL(policy_name,'') not LIKE 'philhealth%'
										   a.policy_id is NULL
										and b.system_transaction_type_rcd in ('DBMR','CDMR')
										and invoice_no = _main.invoice_no),0) 
						 as dmar_cmar,
							ar_main.system_transaction_type_rcd,
							ar_main.swe_payment_status_rcd
		from rpt_invoice_pf_detailed _main inner JOIN AmalgaPROD.dbo.ar_invoice_nl_view ar_main on RTRIM(_main.invoice_no) = rtrim(ar_main.transaction_text)
												LEFT OUTER JOIN  AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on _main.patient_id = pfn.person_id
												left OUTER JOIN  AmalgaPROD.dbo.patient_hospital_usage_nl_view phu on pfn.person_id = phu.patient_id
												LEFT OUTER JOIN AmalgaPROD.dbo.swe_payment_status_ref sps on _main.swe_payment_status_rcd = sps.swe_payment_status_rcd
			where	 
				 CAST(CONVERT(VARCHAR(10),_main.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2018',101) as SMALLDATETIME)
				  and CAST(CONVERT(VARCHAR(10),_main.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2018',101) as SMALLDATETIME)
				 and  ar_main.transaction_status_rcd not in  ('unk','voi')
			     and _main.deleted is NULL		
				 --and invoice_no = 'PINV-2015-220801'										
				 --and _main.invoice_id not in (SELECT invoice_id
					--						  from rpt_invoice_pf)
	) as temp
	where rpt_invoice_pf.invoice_id = temp.invoice_id

--rollback tran
--commit tran

/*
SELECT  *
from rpt_invoice_pf
 where CAST(CONVERT(VARCHAR(10),transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'07/01/2018',101) as SMALLDATETIME)
				  and CAST(CONVERT(VARCHAR(10),transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'07/31/2018',101) as SMALLDATETIME)
      and swe_payment_status_rcd <> 'COM'	
	 -- and  invoice_no = 'pinv-2018-188332'

	--  where invoice_no = 'pinv-2018-188332'
*/

--PINV-2018-188056
/*
SELECT invoice_no,
	   policy_name,
	   total_amt,	  
	    (ISNULL(philhealth,0) + ISNULL(philhealth_pf,0) + ISNULL(gross_hb,0) +  ISNULL(gross_df,0) + ISNULL(gross_pf,0) + ISNULL(gross_er_pf,0) + ISNULL(package_discount,0)) as total
		,
	    swe_payment_status_rcd,
		philhealth,
		philhealth_pf,
	   gross_hb,
	   gross_df,
	   gross_pf,
	   gross_er_pf,
       package_discount
from rpt_invoice_pf
where MONTH(transaction_date_time) = 5
   and YEAR(transaction_date_time) = 2016
   and invoice_no LIKE 'pinv%'
   and  (ISNULL(philhealth,0) + ISNULL(philhealth_pf,0) + ISNULL(gross_hb,0) +  ISNULL(gross_df,0) + ISNULL(gross_pf,0) + ISNULL(gross_er_pf,0) + ISNULL(package_discount,0))  <> total_amt



SELECT invoice_no,
	   policy_name,
	   total_amt,
	    swe_payment_status_rcd,
		philhealth,
		philhealth_pf,
	   gross_hb,
	   gross_df,
	   gross_pf,
	   gross_er_pf,
       package_discount,
	   (ISNULL(philhealth,0) + ISNULL(philhealth_pf,0) + ISNULL(gross_hb,0) +  ISNULL(gross_df,0) + ISNULL(gross_pf,0) + ISNULL(gross_er_pf,0) + ISNULL(package_discount,0)) as total
from rpt_invoice_pf
where invoice_no = 'PINV-2018-187505'


SELECT a.gross_amount,
	   a.policy_name,
	   a.gl_acct_name,
	   a.item_code,
	   a.itemname
from rpt_invoice_pf_detailed a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
								left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
where   --ISNULL(policy_name,'') not LIKE '%philhealth%'
		--c.short_code not in (91,92,93,94,95,96,685,642) 
		-- main_itemgroupcode = 's23'
		 gl_acct_code_code = '2152100'
		and invoice_no ='PINV-2018-187505'

SELECT  a.gross_amount,
	   a.policy_name,
	   a.gl_acct_name,
	   a.item_code,
	   a.itemname
from rpt_invoice_pf_detailed  a inner JOIN amalgaprod.dbo.ar_invoice_nl_view b on a.invoice_id = b.ar_invoice_id
							left outer JOIN amalgaprod.dbo.policy c on b.policy_id = c.policy_id
where    gl_acct_code_code in ('4264000','2152100')
									 and main_itemgroupcode <> 's23'
	-- and  c.short_code not in (91,92,93,94,95,96,685,642)
	-- and  ISNULL(policy_name,'') not LIKE '%philhealth%'
	and invoice_no ='PINV-2018-187505'
*/