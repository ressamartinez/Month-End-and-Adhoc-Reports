DECLARE @table table
(
	ar_invoice_id uniqueidentifier,
	ar_invoice_detail_id uniqueidentifier,
	invoice_date smalldatetime,
	invoice_no varchar(20),
	effective_date smalldatetime,
	invoice_gross_amount money,
	invoice_discount_amount money,
	gross_amount money,
	discount_amount money,
	net_amount money,
	gl_acct_code_code varchar(20),
	gl_acct_name varchar(250),
	charge_id uniqueidentifier,
	employee_nr int,
	doctor_name varchar(250),
	item_code varchar(20),
	item_name varchar(250),
	payment_status varchar(25)
)


insert into @table(
				   ar_invoice_id,
				   ar_invoice_detail_id,
				   invoice_no,
				   invoice_date,
				   effective_date,
				   invoice_gross_amount,
				   invoice_discount_amount,
				   gross_amount,
				   discount_amount,
				   net_amount,
				   gl_acct_code_code,
				   gl_acct_name,
				   charge_id,
				   employee_nr,
				   doctor_name,
				   item_code,
				   item_name,
				   payment_status)
SELECT ar.ar_invoice_id,
	ard.ar_invoice_detail_id,
	   ar.transaction_text as invoice_no,
	   ar.transaction_date_time as invoice_date,
	   ar.effective_date as effective_date,
	   ar.gross_amount as invoice_gross_amount,
	   ar.discount_amount as invoice_discount_amount,
	   ard.gross_amount,
	   ard.discount_amount,
	   ard.gross_amount - ard.discount_amount as net_amount,
	   gac.gl_acct_code_code,
	   gac.name_l as gl_acct_name,
	   cd.charge_detail_id,
	   dba.employee_nr,
	   rtrim(dba.caregiver_lname) + ', ' + RTRIM(caregiver_fname) as doctor_name,
	   i.item_code,
	   i.name_l as item_name,
	   sps.name_l as payment_status

from dbprod03.hisviews.dbo.ar_invoice_vw ar inner join dbprod03.amalgaprod.dbo.ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
						   inner JOIN dbprod03.amalgaprod.dbo.charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
						   inner JOIN dbprod03.amalgaprod.dbo.gl_acct_code gac on cd.gl_acct_code_id = gac.gl_acct_code_id
						   LEFT OUTER JOIN DIS_TEST_2017.dbo.df_browse_all dba on cd.charge_detail_id = dba.charge_id
						   inner JOIN dbprod03.amalgaprod.dbo.item i on cd.item_id = i.item_id
						   inner JOIN dbprod03.hisviews.dbo.patient_visit_vw pv on cd.patient_visit_id = pv.patient_visit_id
						   inner JOIN dbprod03.amalgaprod.dbo.visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd
						   inner JOIN dbprod03.amalgaprod.dbo.swe_payment_status_ref sps on ar.swe_payment_status_rcd = sps.swe_payment_status_rcd
where ar.transaction_status_rcd not in ('voi','unk')
   and CAST(CONVERT(varchar(10),ar.transaction_date_time,101) as SMALLDATETIME) = CAST(CONVERT(varchar(10),'09/01/2018',101) as SMALLDATETIME)
   --and CAST(CONVERT(varchar(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(varchar(10),'08/18/2018',101) as SMALLDATETIME)
   and cd.deleted_date_time is NULL
   AND vtr.visit_type_group_rcd = 'ipd'
   and ar.user_transaction_type_id in ('30957FA1-735D-11DA-BB34-000E0C7F3ED2','F8EF2162-3311-11DA-BB34-000E0C7F3ED2')
   and ard.gross_amount > 0
   and gac.gl_acct_code_code <> '4445000'
   --and dba.charge_id = ard.charge_detail_id
   


--IPD ONLY --ADD PAYMENT STATUS 20452


   /*
SELECT invoice_no,
	   effective_date,
	   dba.employee_nr,
	   rtrim(dba.caregiver_lname) + ', ' + RTRIM(dba.caregiver_fname) as doctor_name,
	   main.gross_amount,
	   hb_portion = (SELECT sum(gross_amount)
					from @table
					where gl_acct_code_code not in ('2152100','2152250','4445000')
					   and ar_invoice_id = main.ar_invoice_id
					   and ar_invoice_detail_id = main.ar_invoice_detail_id),
      
	   pf_portion = (SELECT sum(gross_amount)
					from @table
					where gl_acct_code_code  in ('2152100','2152250','4445000')
					   and ar_invoice_id = main.ar_invoice_id
					   and ar_invoice_detail_id = main.ar_invoice_detail_id),
     total_invoice = main.invoice_gross_amount,
	 main.ar_invoice_detail_id,
	 dba.charge_id
from @table main inner JOIN DIS_TEST_2017.dbo.df_browse_all dba on main.charge_id = dba.charge_id
where main.invoice_no = 'PINV-2018-327030'
*/



SELECT invoice_no,
	   effective_date,
	   main.gl_acct_code_code,
	   main.gl_acct_name,
	   isnull(cast(main.employee_nr as varchar(25)),'...') as employee_nr,
	   isnull(main.doctor_name,'No Assigned Physician') as doctor_name,
	   main.gross_amount,
	   hb_portion = isnull((SELECT sum(gross_amount)
					from @table
					where gl_acct_code_code not in ('2152100','2152250','4264000')
					   and ar_invoice_id = main.ar_invoice_id
					   and ar_invoice_detail_id = main.ar_invoice_detail_id),0),
      
	   pf_portion = isnull((SELECT sum(gross_amount)
					from @table
					where gl_acct_code_code  in ('2152100','2152250','4264000')
					   and ar_invoice_id = main.ar_invoice_id
					   and ar_invoice_detail_id = main.ar_invoice_detail_id),0),
     total_invoice = main.invoice_gross_amount,
	 main.item_code,
	 main.item_name,
	 main.payment_status
from @table main
where main.invoice_no = 'pinv-2018-235216'
order by main.invoice_no, isnull(main.doctor_name,'No Assigned Physician')
