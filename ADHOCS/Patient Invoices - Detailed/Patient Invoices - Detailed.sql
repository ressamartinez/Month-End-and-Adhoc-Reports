SELECT temp.invoice_no as [Invoice No.],
       temp.transaction_date_time as [Transaction Date and Time],
	   	CONVERT(VARCHAR(20), temp.transaction_date_time,101) AS [Transaction Date],
		FORMAT(temp.transaction_date_time,'hh:mm tt') AS [Transaction Time],
	   temp.item_code as [Item Code],
	   temp.itemname as [Item Name],
	   temp.costcentre_code as [Cost Centre Code],
	   temp.costcentre_name as [Cost Centre],
	   temp.gl_acct_code_code as [GL Account Code],
	   temp.gl_acct_name as [GL Account Name],
	   temp.uom as [UoM],
	   CAST((temp.quantity) AS DECIMAL(10,2)) as Quantity,
	   CAST((temp.unit_price) AS DECIMAL(10,2)) as [Unit Price],
	   CAST((temp.gross_amount) AS DECIMAL(10,2)) as [Gross Amount],
	   CAST((temp.net_amount) AS DECIMAL(10,2)) as [Net Amount],
	   temp.doctor_name as [Caregiver Name]
from
(

	SELECT DISTINCT  cd.charge_detail_id,
		  inv.invoice_no,
		  inv.transaction_date_time,
		  item_code,
		   itemname,
			cc.costcentre_code as costcentre_code,
			cc.name_l as costcentre_name,
		   gl_acct_code_code,
		   gl_acct_name,
		   ISNULL(uom.name_l,'') as uom,
		   cd.quantity,
		   cd.unit_price,
		   inv.gross_amount,
		   inv.net_amount,
		   ISNULL(inv.doctor_name,'') as doctor_name,
		   'A' as a
	from HISReport.dbo.rpt_invoice_pf_detailed inv inner JOIN charge_detail_nl_view cd on inv.charge_detail_id = cd.charge_detail_id
												   INNER JOIN cashier_invoice_detail_view cid on cd.charge_detail_id = cid.charge_detail_id
												   LEFT outer JOIN uom_ref uom on cid.uom_rcd = uom.uom_rcd
												   inner JOIN costcentre cc on cd.service_provider_costcentre_id = cc.costcentre_id
	where    CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
		 and CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)
		 and cid.line_amount > 0
		 and inv.system_transaction_type_rcd not in ('cdmr','dbmr')
		 and inv.invoice_no is not NULL
		 
	UNION ALL
	SELECT  DISTINCT  cd.charge_detail_id,
		  inv.invoice_no,
		  inv.transaction_date_time,
		  item_code,
		   itemname,
			cc.costcentre_code as costcentre_code,
			cc.name_l as costcentre_name,
		   gl_acct_code_code,
		   gl_acct_name,
		   ISNULL(uom.name_l,'') as uom,
		   cd.quantity,
		   cd.unit_price,
		   inv.gross_amount,
		   inv.net_amount,
		   ISNULL(inv.doctor_name,'') as doctor_name,
		   'B' as a
	from HISReport.dbo.rpt_invoice_pf_detailed inv inner JOIN charge_detail_nl_view cd on inv.charge_detail_id = cd.charge_detail_id
												   INNER JOIN cashier_invoice_detail_view cid on cd.charge_detail_id = cid.charge_detail_id
												   LEFT outer JOIN uom_ref uom on cid.uom_rcd = uom.uom_rcd
												   inner JOIN costcentre cc on cd.service_provider_costcentre_id = cc.costcentre_id
	where    CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
		 and CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)
		 and cid.line_amount = 0
		 and inv.invoice_no is not NULL
		 and inv.system_transaction_type_rcd not in ('cdmr','dbmr')
		 and cd.charge_detail_id not in (SELECT  _cd.charge_detail_id
										from HISReport.dbo.rpt_invoice_pf_detailed _inv inner JOIN charge_detail_nl_view _cd on _inv.charge_detail_id = _cd.charge_detail_id
																					   INNER JOIN cashier_invoice_detail_view _cid on _cd.charge_detail_id = _cid.charge_detail_id
										where    CAST(CONVERT(VARCHAR(10),_inv.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
											  and CAST(CONVERT(VARCHAR(10),_inv.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME) 
											  and _cid.line_amount > 0 
		                                      and inv.system_transaction_type_rcd not in ('cdmr','dbmr'))
) as temp
order by [Invoice No.],
		 [Transaction Date and Time],
		 [Item Code]