--paid invoices, unpaid doctors fee
SELECT DISTINCT 
		--ard.charge_detail_id,
	   ar.ar_invoice_id,
	   ar.transaction_date_time as [Invoice DateTime],
	   CONVERT(VARCHAR(20), ar.transaction_date_time,101) AS [Invoice Date],
	   FORMAT(ar.transaction_date_time,'hh:mm tt') AS [Invoice Time],
	   ar.transaction_text as [Invoice No.],
	   eii.employee_nr as [Employee NR],
	   pfn.display_name_l as [Caregiver],
	   cd2.item_code as [Item Code],
	   cd2.item_desc as [Item Desc],
	    ppdh.gross_amount,
	    ppdh.discount_amount_oth,
		ppdh.discount_amount_scd,
		ppdh.adjustment_amount,
		ppdh.net_amount,
		ppdh.commission_rate,
		ppdh.prev_paid_amount,
		ppdh.upi,
		ppdh.pname,
		ppdh.policy_group,
	   cd.charged_date_time as [Charge Date Time],
	   CONVERT(VARCHAR(20), cd.charged_date_time,101) AS [Charge Date],
	   FORMAT(cd.charged_date_time,'hh:mm tt') AS [Charge Time],
	   processed_datetime,
	   CONVERT(VARCHAR(20), processed_datetime,101) AS [Processed Date],
	   FORMAT(processed_datetime,'hh:mm tt') AS [Processed Time],
	   period_id
	   --cch.upi,
	  -- ISNULL(cch.lname,'') + ', ' + isnull(cch.fname,'') as [Patient Name]
from dbprod03.hisviews.dbo.ar_invoice_vw ar  inner join dbprod03.amalgaprod.dbo.ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id		
                   inner JOIN dbprod03.amalgaprod.dbo.charge_detail	cd on ard.charge_detail_id = cd.charge_detail_id
				   inner JOIN itworksds01.dis.dbo.charge_detail cd2 on cd.charge_detail_id = cd2.charge_id
				   inner JOIN dbprod03.amalgaprod.dbo.person_formatted_name_iview_nl_view pfn on cd.caregiver_employee_id = pfn.person_id
				   inner JOIN dbprod03.amalgaprod.dbo.employee_info_view eii on cd.caregiver_employee_id = eii.person_id
				   --inner JOIN itworksds01.dis.dbo.df_browse_all cd on ard.charge_detail_id = cd.charge_id
				 --  inner JOIN itworksds01.dis.dbo.charge_caregiver_history cch on cd2.charge_id = cd2.charge_id
				   inner JOIN itworksds01.dis.dbo.payment_period_detail_history ppdh on cd2.charge_id = ppdh.charge_id
				   
where swe_payment_status_rcd IN ('COM','PART') 
    and ar.transaction_status_rcd not in ('unk','voi')
	--and cch.charge_id = ard.charge_detail_id
	--and CAST(CONVERT(VARCHAR(10),transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'9/01/2017',101) as SMALLDATETIME)
	and CAST(CONVERT(VARCHAR(10),transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@FROM,101) as SMALLDATETIME)
	and CAST(CONVERT(VARCHAR(10),processed_datetime,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@TO,101) as SMALLDATETIME)
	and cd2.paid = 'N'
	--and ar.transaction_text in ('PINV-2016-248703')
	and ppdh.charge_id = cd.charge_detail_id
	and ppdh.charge_id = ard.charge_detail_id
	--and stc_flag_rcd = 'N'
order by ar.transaction_date_time