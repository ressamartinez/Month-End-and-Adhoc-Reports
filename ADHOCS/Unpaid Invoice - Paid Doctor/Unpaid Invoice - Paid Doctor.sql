SELECT
	   DISTINCT ppdh.ar_invoice_detail_id,
	    ppdh.charge_id,
	   ppdh.employee_nr as [Employee NR],
	   RTRIM(d.last_name_l) + ', ' + RTRIM(d.first_name_l) + '' + ISNULL(RTRIM(d.middle_name_l),'') as [Doctor Name],
	   ppdh.upi as [HN],
	   ppdh.pname as [Patient Name],
	    cd.item_code as [Item Code],
		ppdh.item_desc as [Item Desc],
		ppdh.charge_date as [Charge DateTime],
		CONVERT(VARCHAR(20), ppdh.charge_date,101) AS [Charge Date],
		substring(convert(varchar(20), ppdh.charge_date, 9), 13, 5) + ' ' + 
		substring(convert(varchar(30), ppdh.charge_date, 9), 25, 2) AS [Charge Time],
		arh.transaction_text as [Invoice Number],
		ppdh.processed_datetime as [Processed DateTime],
		CONVERT(VARCHAR(20), ppdh.processed_datetime,101) AS [Processed Date],
		substring(convert(varchar(20), ppdh.processed_datetime, 9), 13, 5) + ' ' + 
		substring(convert(varchar(30), ppdh.processed_datetime, 9), 25, 2) AS [Processed Time],
		ppdh.gross_amount as [Gross Amount],
		ppdh.net_amount as [Net Amount],
		ppdh.discount_amount as [Discount Amount],
		ppdh.vat_rate as [Vat Rate],
		ppdh.tax_rate as [Tax Rate],
		swe_payment_status_rcd
from itworksds01.dis.dbo.payment_period_detail_history ppdh  inner JOIN itworksds01.dis.dbo.ar_invoice_detail_head ardh on ppdh.ar_invoice_detail_id = ardh.ar_invoice_detail_id
										 inner JOIN itworksds01.dis.dbo.ar_invoice_head arh on ardh.ar_invoice_id = arh.ar_invoice_id	
										 inner JOIN itworksds01.dis.dbo.ar_invoice_body arhb on arh.ar_invoice_id = arhb.ar_invoice_id
										 inner JOIN itworksds01.dis.dbo.charge_detail cd on ppdh.charge_id = cd.charge_id
										 inner JOIN itworksds01.dis.dbo.doctor d on ppdh.employee_nr = d.employee_nr
	where    CAST(CONVERT(VARCHAR(10),ppdh.processed_datetime,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
		 and CAST(CONVERT(VARCHAR(10),ppdh.processed_datetime,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)
      and arhb.swe_payment_status_rcd <> 'com'
	 and cd.item_group_code <> 's23-00'
   and cd.charge_id = ardh.charge_detail_id
order by ppdh.charge_date
