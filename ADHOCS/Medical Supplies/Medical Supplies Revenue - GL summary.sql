declare @company_code varchar(3)
DECLARE @From datetime
DECLARE @To datetime

set @company_code = 'AHI'
SET @From = '01/01/2018 00:00:00.000'		
SET @To = '12/31/2018 23:59:59.998'

select 
       tempb.[GL Account Code],
       tempb.[GL Account Name],
	   tempb.[Costcentre Code],
	   tempb.Costcentre,
	   tempb.[Itemgroup Code],
	   tempb.[Itemgroup Name],
       tempb.[Item Code],
       tempb.[Item Description],
	   tempb.period_code,
	   [Gross Amount] = sum(tempb.[Gross Amount]),
	   [Discount Amount] = sum(tempb.[Discount Amount])

from (

	select distinct 
		temp.[GL Account Code],
		temp.[GL Account Name],
		temp.PAR,
		temp.[Effective Date],
		temp.[Invoice Date],
		temp.[Invoice Number],
		temp.[Related Invoice],
		temp.[Related Invoice Date],
		temp.[Costcentre Code],
		temp.Costcentre,
		temp.[Gross Amount],
		temp.[Discount Amount],
		temp.[Itemgroup Code],
		temp.[Itemgroup Name],
		temp.[Item Code],
		temp.[Item Description],
		temp.ar_invoice_detail_id,
		temp.period_id,
		temp.period_code

	from (

		SELECT gac.gl_acct_code_code as [GL Account Code]
				,gac.name_l as [GL Account Name]
				,ar.transaction_date_time as [Invoice Date]
				,glt.transaction_text as [PAR]
				,ar.transaction_text as [Invoice Number]
				,isnull((select transaction_text from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice]
				,isnull((select transaction_date_time from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice Date]
				,c.costcentre_code as [Costcentre Code]
				,c.name_l as [Costcentre]
				,ard.gross_amount * ar.credit_factor as [Gross Amount]
				,ard.discount_amount * ar.credit_factor as [Discount Amount]
				,ig.item_group_code as [Itemgroup Code]
				,ig.name_l as [Itemgroup Name]
				,i.item_code as [Item Code]
				,i.name_l as [Item Description]
				,cd.charged_date_time as [Charged Date]
				,ard.ar_invoice_detail_id
				,ar.related_ar_invoice_id
				,glt.effective_date as [Effective Date]
				,p.period_id
				,p.period_code

		from gl_transaction glt inner JOIN ar_invoice_nl_view ar on glt.gl_transaction_id = ar.gl_transaction_id
								inner JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
								inner JOIN costcentre c on ard.costcentre_credit_id = c.costcentre_id
								inner JOIN gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
								inner join period p on glt.period_id = p.period_id
								LEFT JOIN charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
								LEFT join item i on ard.item_id = i.item_id
								left join item_group ig on i.item_group_id = ig.item_group_id

		where CAST(CONVERT(VARCHAR(10),glt.effective_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
				and CAST(CONVERT(VARCHAR(10),glt.effective_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
				and ar.transaction_status_rcd not in ('unk','voi')
				and glt.transaction_status_rcd not in ('unk','voi')
				and cd.deleted_date_time is null
				and glt.company_code = @company_code
				and glt.transaction_status_rcd = 'POS'
				--and gac.gl_acct_code_code = '4217000'
	)as temp

	UNION 

		select distinct 
		temp.[GL Account Code],
		temp.[GL Account Name],
		temp.PAR,
		temp.[Effective Date],
		temp.[Invoice Date],
		temp.[Invoice Number],
		temp.[Related Invoice],
		temp.[Related Invoice Date],
		temp.[Costcentre Code],
		temp.Costcentre,
		temp.[Gross Amount] * -1 as [Gross Amount],
		temp.[Discount Amount],
		temp.[Itemgroup Code],
		temp.[Itemgroup Name],
		temp.[Item Code],
		temp.[Item Description],
		temp.ap_invoice_detail_id,
		temp.period_id,
		temp.period_code

	from (
			select gac.gl_acct_code_code as [GL Account Code]
				,gac.name_l as [GL Account Name]
				,sat.vendor_invoice_date_time as [Invoice Date]
				,gt.transaction_text as [PAR]
				,sat.transaction_text as [Invoice Number]
				,null as [Related Invoice]
				,null as [Related Invoice Date]
				,c.costcentre_code as [Costcentre Code]
				,c.name_l as [Costcentre]
				,satd.gross_amount  as [Gross Amount]
				,satd.discount_amount as [Discount Amount]
				,ig.item_group_code as [Itemgroup Code]
				,ig.name_l as [Itemgroup Name]
				,i.item_code as [Item Code]
				,i.name_l as [Item Description]
				,satd.ap_invoice_detail_id
				,gt.effective_date as [Effective Date]
				,p.period_id
				,p.period_code

		from gl_transaction gt inner join swe_ap_transaction sat on gt.gl_transaction_id = sat.gl_transaction_id
		                        inner JOIN swe_ap_transaction_detail satd on sat.ap_invoice_id = satd.ap_invoice_id
								inner JOIN costcentre c on satd.costcentre_debit_id = c.costcentre_id
								inner JOIN gl_acct_code gac on satd.gl_acct_code_debit_id = gac.gl_acct_code_id
								inner join period p on gt.period_id = p.period_id
								LEFT outer JOIN item i on satd.item_id = i.item_id
								left join item_group ig on i.item_group_id = ig.item_group_id

		where CAST(CONVERT(VARCHAR(10),gt.effective_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
					and CAST(CONVERT(VARCHAR(10),gt.effective_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
					and	gt.company_code = @company_code
					and gt.transaction_status_rcd not in ('unk','voi')
					and	gt.transaction_status_rcd = 'POS'
					--and gt.transaction_text = 'PAP-2014-000141'
					--and gac.gl_acct_code_code = '4217000'
	)as temp

	UNION ALL

	select 
			temp.[GL Account Code],
			temp.[GL Account Name],
			temp.PAR,
			temp.[Effective Date],
			temp.[Invoice Date],
			temp.[Invoice Number],
			temp.[Related Invoice],
			temp.[Related Invoice Date],
			temp.[Costcentre Code],
			temp.Costcentre,
			[Gross Amount] = temp.[Credit Amount] - temp.[Debit Amount],
			'0.00' as [Discount Amount],
			temp.[Itemgroup Code],
			temp.[Itemgroup Name],
			temp.[Item Code],
			temp.[Item Description],
			temp.ar_invoice_detail_id,
			temp.period_id,
			temp.period_code

	from  (

		select 		
					gac.gl_acct_code_code as [GL Account Code]
					,gac.name_l as [GL Account Name]
					,ar.transaction_date_time as [Invoice Date]
					,gt.transaction_text as [PAR]
					,ar.transaction_text as [Invoice Number]
					,isnull((select transaction_text from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice]
					,isnull((select transaction_date_time from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice Date]
					,c.costcentre_code as [Costcentre Code]
					,c.name_l as [Costcentre]
					,[Debit Amount] = case when debit_flag = 1 then gtd.amount else '-' end
					,[Credit Amount] = case when debit_flag = 0 then gtd.amount else '-' end
					,ig.item_group_code as [Itemgroup Code]
					,ig.name_l as [Itemgroup Name]
					,i.item_code as [Item Code]
					,i.name_l as [Item Description]
					,ard.ar_invoice_detail_id
					,ar.related_ar_invoice_id
					,gt.effective_date as [Effective Date]
					,p.period_id
					,p.period_code

		from		gl_transaction_nl_view gt
		inner join gl_transaction_detail_nl_view gtd on gtd.gl_transaction_id = gt.gl_transaction_id 
		inner JOIN costcentre c on gtd.costcentre_id = c.costcentre_id
		inner join gl_acct_code_nl_view gac on gac.gl_acct_code_id = gtd.gl_acct_code_id
		inner join period p on gt.period_id = p.period_id
		left JOIN ar_invoice_nl_view ar on gt.gl_transaction_id = ar.gl_transaction_id
		left JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
		LEFT join item i on ard.item_id = i.item_id
		left join item_group ig on i.item_group_id = ig.item_group_id

		where CAST(CONVERT(VARCHAR(10),gt.effective_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
			and CAST(CONVERT(VARCHAR(10),gt.effective_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
			and	gt.company_code = @company_code
			and gt.transaction_status_rcd not in ('unk','voi')
			and	gt.transaction_status_rcd = 'POS'
			and gt.user_transaction_type_id = '8566FA00-63FE-11DA-BB34-000E0C7F3ED2'    --GJV
			--and gac.gl_acct_code_code = '4217000'

	) as temp

	UNION ALL

		select 
			temp.[GL Account Code],
			temp.[GL Account Name],
			temp.PAR,
			temp.[Effective Date],
			temp.[Invoice Date],
			temp.[Invoice Number],
			temp.[Related Invoice],
			temp.[Related Invoice Date],
			temp.[Costcentre Code],
			temp.Costcentre,
			[Gross Amount] = temp.[Credit Amount] - temp.[Debit Amount],
			'0.00' as [Discount Amount],
			temp.[Itemgroup Code],
			temp.[Itemgroup Name],
			temp.[Item Code],
			temp.[Item Description],
			temp.ar_invoice_detail_id,
			temp.period_id,
			temp.period_code

	from  (

		select 		
					gac.gl_acct_code_code as [GL Account Code]
					,gac.name_l as [GL Account Name]
					,ar.transaction_date_time as [Invoice Date]
					,gt.transaction_text as [PAR]
					,ar.transaction_text as [Invoice Number]
					,isnull((select transaction_text from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice]
					,isnull((select transaction_date_time from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice Date]
					,c.costcentre_code as [Costcentre Code]
					,c.name_l as [Costcentre]
					,[Debit Amount] = case when debit_flag = 1 then gtd.amount else '-' end
					,[Credit Amount] = case when debit_flag = 0 then gtd.amount else '-' end
					,ig.item_group_code as [Itemgroup Code]
					,ig.name_l as [Itemgroup Name]
					,i.item_code as [Item Code]
					,i.name_l as [Item Description]
					,ard.ar_invoice_detail_id
					,ar.related_ar_invoice_id
					,gt.effective_date as [Effective Date]
					,p.period_id
					,p.period_code

		from		gl_transaction_nl_view gt
		inner join gl_transaction_detail_nl_view gtd on gtd.gl_transaction_id = gt.gl_transaction_id 
		inner JOIN costcentre c on gtd.costcentre_id = c.costcentre_id
		inner join gl_acct_code_nl_view gac on gac.gl_acct_code_id = gtd.gl_acct_code_id
		inner join period p on gt.period_id = p.period_id
		left JOIN ar_invoice_nl_view ar on gt.gl_transaction_id = ar.gl_transaction_id
		left JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
		LEFT join item i on ard.item_id = i.item_id
		left join item_group ig on i.item_group_id = ig.item_group_id

		where CAST(CONVERT(VARCHAR(10),gt.effective_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
			and CAST(CONVERT(VARCHAR(10),gt.effective_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
			and	gt.company_code = @company_code
			and gt.transaction_status_rcd not in ('unk','voi')
			and	gt.transaction_status_rcd = 'POS'
			and gt.user_transaction_type_id = '30957FA8-735D-11DA-BB34-000E0C7F3ED2'    --GRV
			--and gac.gl_acct_code_code = '4217000'

	) as temp

)as tempb 

where tempb.[GL Account Code] = '4217000'
	  --and tempb.[Costcentre Code] = '7052'
	  --and tempb.period_code = '2015PRD2'

group by tempb.[GL Account Code],
         tempb.[GL Account Name],
		 tempb.[Costcentre Code],
		 tempb.Costcentre,
		 tempb.[Itemgroup Code],
		 tempb.[Itemgroup Name],
         tempb.[Item Code],
         tempb.[Item Description],
         tempb.period_code
		 ,tempb.period_id

order by tempb.period_id