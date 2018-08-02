declare @company_code varchar(3)

set @company_code = 'AHI'

select 		gt.transaction_text as [Transaction Number],
			gt.transaction_date_time as [Transaction DateTime],
			CONVERT(VARCHAR(20), gt.transaction_date_time,101) AS [Transaction Date],
			FORMAT(gt.transaction_date_time,'hh:mm tt') AS [Transaction Time],
			gt.effective_date as [Effective DateTime],
			CONVERT(VARCHAR(20), gt.effective_date,101) AS [Effective Date],
			FORMAT(gt.effective_date,'hh:mm tt') AS [Effective Time],
			ISNULL(gt.gl_manual_journal_no,'-') as [Journal Number],
			REPLACE(REPLACE(gt.transaction_description,'''','*'),'"','*') as [Journal Description],
			REPLACE(REPLACE(ISNULL(gt.transaction_comment,'-'),'''','*'),'"','*') as Comment,
			gac.gl_acct_code_code as [Account Code],
			gac.name_l as [Account Name],
			cc.costcentre_code as [Cost Centre Code],
			cc.name_l as [Cost Center],
			[Debit Amount] = case when debit_flag = 1 then amount else '-' end,
			[Credit Amount] = case when debit_flag = 0 then amount else '-' end,
			[Detail Description] = case when isnull(gtd.description, '') <> gt.transaction_description then case when isnull(gtd.description, '') <> '' then REPLACE(REPLACE(gtd.description,'''','*'),'"','*') else '-' end end,
			case when gt.created_by_user_id IS NULL THEN (SELECT top 1 c.display_name_l as username
															FROM transaction_history a inner JOIN user_account b on a.lu_user_id = b.user_id
																					   inner JOIN person_formatted_name_iview_nl_view c on b.person_id = c.person_id
															where gl_transaction_id = gt.gl_transaction_id
															order by a.lu_updated) ELSE (SELECT b.display_name_l
																								from  user_account a inner JOIN person_formatted_name_iview_nl_view b on a.person_id = b.person_id
																								where user_id = GT.created_by_user_id) END as [Created By],
			coalesce(gpt.name_l, 'General Ledger') as [Source]
from		gl_transaction_nl_view gt
inner join	gl_transaction_detail_nl_view gtd on gtd.gl_transaction_id = gt.gl_transaction_id 
inner join	gl_acct_code_nl_view gac on gac.gl_acct_code_id = gtd.gl_acct_code_id
inner join	costcentre_nl_view cc on cc.costcentre_id = gtd.costcentre_id
left join	user_account_nl_view ua on ua.user_id = gt.created_by_user_id
left  join	person_formatted_name_iview_nl_view pfn on pfn.person_id = ua.person_id
left join	gl_posting_type_ref_nl_view gpt on gpt.gl_posting_type_rid = gt.gl_posting_type_rid
where   MONTH(gt.effective_date) >= @iFromMonth and MONTH(gt.effective_date) <= @iToMonth
	and	Year(gt.effective_date) = @Year
	and	gt.company_code = @company_code
	and	gt.transaction_status_rcd = 'POS'
order by	gt.effective_date 
			,gt.transaction_text
			,debit_flag