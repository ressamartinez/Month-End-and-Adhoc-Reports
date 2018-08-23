--last processed date (07/2018)
DECLARE @iMonth int
DECLARE @iYear int

SET @iMonth = 7
SET @iYear = 2018

SELECT DISTINCT charge_id, 
	   temp.[Payment Status],
	    temp.[Charge Date],
		temp.[Invoice Date],
		temp.[Patient Name],
		temp.[GL Account Code],
		temp.[GL Account Name],
		temp.[Item Code],
		temp.[Item Description],
		temp.Quantity,
		temp.UoM,
		temp.[Unit Price],
		temp.[Total Amount],
		temp.[Discount Amount],
		temp.[Adjustment Amount],
		temp.[Net Amount],
		temp.[Discount Percentage],
		temp.[Commission Rate],
		temp.[Discount Amount SCD],
		temp.[Discount Amount Other],
		temp.[Remaining Balance],
		temp.[Accumulated Amount],
		temp.[Service Requestor],
		temp.[Service Provider],
		temp.[Visit Type],
		temp.costcentre_code as [Cost Centre Code],
	    temp.costcentre as [Cost Centre]
from
(
	SELECT 'Paid' as [Payment Status],
		   dfb.charge_date as [Charge Date],
		   dfb.invoiced_date as [Invoice Date],
		   dfb.lname + ', ' + dfb.fname + ' ' + dfb.mname as [Patient Name],
		   cl.gl_acct_code as [GL Account Code],
		   cl.gl_acct_name as [GL Account Name],
		   dfb.item_code as [Item Code],
		   dfb.item_desc as [Item Description],
		   dfb.quantity as Quantity,
		   dfb.uom as UoM,
		   ISNULL(cd.unit_price,0) as [Unit Price],
		   ISNULL(cd.total_amt,0) as [Total Amount],
		   ISNULL(cd.discount_amt,0) as [Discount Amount],
		   ISNULL(cd.adjustment_amt,0) as [Adjustment Amount],
		   ISNULL(cd.net_amt,0) as [Net Amount],
		   ISNULL(cd.discount_percentage,0) as [Discount Percentage],
		   ISNULL(cd.commission_rate,0) as [Commission Rate],
		   ISNULL(cd.discount_amt_scd,0) as [Discount Amount SCD],
		   ISNULL(cd.discount_amt_other,0) as [Discount Amount Other],
		   ISNULL(cd.remaining_balance,0) as [Remaining Balance],
		   ISNULL(cd.accumulated_amount,0) as [Accumulated Amount],
		   dfb.service_requestor as [Service Requestor],
		   dfb.service_provider as [Service Provider],
		   dfb.visit_type as [Visit Type],
		   cc.costcentre_code,
	        cc.name_l as costcentre,
			cd.charge_id

	from df_browse_all dfb inner JOIN charge_location cl on dfb.charge_id = cl.charge_id
						   inner JOIN charge_detail cd on dfb.charge_id = cd.charge_id
						   inner JOIN DBPROD03.AmalgaProd.dbo.item i on RTRIM(cd.item_code) collate database_default = RTRIM(i.item_code) collate database_default
							inner JOIN DBPROD03.AmalgaProd.dbo.visit_type_ref vtr on dfb.visit_type  collate database_default = vtr.name_l  collate database_default
							inner JOIN DBPROD03.AmalgaProd.dbo.item_group_costcentre igc on i.item_group_id = igc.item_group_id 
							inner JOIN DBPROD03.AmalgaProd.dbo.costcentre cc on igc.costcentre_id = cc.costcentre_id

	where cd.charge_id = cl.charge_id
		 and MONTH(dfb.charge_date)= @iMonth
		 and YEAR(dfb.charge_date) = @iYear
		 and dfb.charge_id in (select charge_id from payment_period_detail_history)
		 AND cl.gl_acct_code = '4264000' --Reader's Fee Revenue
	UNION ALL
	SELECT 'Unpaid' as [Payment Status],
		   dfb.charge_date as [Charge Date],
		   dfb.invoiced_date as [Invoice Date],
		   dfb.lname + ', ' + dfb.fname + ' ' + dfb.mname as [Patient Name],
		   cl.gl_acct_code as [GL Account Code],
		   cl.gl_acct_name as [GL Account Name],
		    dfb.item_code as [Item Code],
		   dfb.item_desc as [Item Description],
		   dfb.quantity as Quantity,
		   dfb.uom as UoM,
		   ISNULL(cd.unit_price,0) as [Unit Price],
		   ISNULL(cd.total_amt,0) as [Total Amount],
		   ISNULL(cd.discount_amt,0) as [Discount Amount],
		   ISNULL(cd.adjustment_amt,0) as [Adjustment Amount],
		   ISNULL(cd.net_amt,0) as [Net Amount],
		   ISNULL(cd.discount_percentage,0) as [Discount Percentage],
		   ISNULL(cd.commission_rate,0) as [Commission Rate],
		   ISNULL(cd.discount_amt_scd,0) as [Discount Amount SCD],
		   ISNULL(cd.discount_amt_other,0) as [Discount Amount Other],
		   ISNULL(cd.remaining_balance,0) as [Remaining Balance],
		   ISNULL(cd.accumulated_amount,0) as [Accumulated Amount],
		   dfb.service_requestor as [Service Requestor],
		   dfb.service_provider as [Service Provider],
		   dfb.visit_type as [Visit Type], 
		   cc.costcentre_code,
	        cc.name_l as costcentre,
			cd.charge_id

	from df_browse_all dfb inner JOIN charge_location cl on dfb.charge_id = cl.charge_id
						   inner JOIN charge_detail cd on dfb.charge_id = cd.charge_id
						   inner JOIN DBPROD03.AmalgaProd.dbo.item i on RTRIM(cd.item_code) collate database_default = RTRIM(i.item_code) collate database_default
							inner JOIN DBPROD03.AmalgaProd.dbo.visit_type_ref vtr on dfb.visit_type  collate database_default = vtr.name_l  collate database_default
							inner JOIN DBPROD03.AmalgaProd.dbo.item_group_costcentre igc on i.item_group_id = igc.item_group_id 
							inner JOIN DBPROD03.AmalgaProd.dbo.costcentre cc on igc.costcentre_id = cc.costcentre_id

	where cd.charge_id = cl.charge_id
		  and MONTH(dfb.charge_date)= @iMonth
		 and YEAR(dfb.charge_date) = @iYear
		 and dfb.charge_id not in (select charge_id from payment_period_detail_history)
		AND cl.gl_acct_code = '4264000' --Reader's Fee Revenue
) as temp
--WHERE temp.[GL Account Code] = '4264000'
order by temp.[Charge Date]

