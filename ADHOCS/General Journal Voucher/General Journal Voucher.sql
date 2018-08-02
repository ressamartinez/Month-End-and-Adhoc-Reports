SELECT temp.[Transaction Text],
	   temp.[Transaction Date and Time],
	   CONVERT(VARCHAR(20), temp.[Transaction Date and Time],101) AS [Transaction Date],
		FORMAT(temp.[Transaction Date and Time],'hh:mm tt') AS [Transaction Time],
	   temp.[Effective Date] as edt,
	   	CONVERT(VARCHAR(20), temp.[Effective Date],101) AS [Effective Date],
		FORMAT(temp.[Effective Date],'hh:mm tt') AS [Effective Time],
	   temp.[Cost Centre Code],
	   temp.[Cost Centre],
	   temp.[GL Account Code],
	   temp.[GL Account Name],
	   SUM(temp.AUC) as AUC,
	   temp.lu_user as [Last Updated By]
from
(
	SELECT gl.transaction_text as [Transaction Text],
		   gl.transaction_date_time as [Transaction Date and Time],
		   gl.effective_date as [Effective Date],
			cc.costcentre_code as [Cost Centre Code],
			cc.name_l as [Cost Centre],
			gac.gl_acct_code_code as [GL Account Code],
			gac.name_l as [GL Account Name],
			case WHEN ISNULL(gld.debit_flag,0) = 1 then gld.amount else -gld.amount END as [AUC],
			gld.debit_flag,
			pfn.display_name_l as lu_user
	from gl_transaction gl inner JOIN user_transaction_type utt on gl.user_transaction_type_id = utt.user_transaction_type_id
							inner JOIN gl_transaction_detail gld on gl.gl_transaction_id = gld.gl_transaction_id
							inner join costcentre cc on gld.costcentre_id = cc.costcentre_id
							inner JOIN gl_acct_code gac on gld.gl_acct_code_id = gac.gl_acct_code_id
							inner JOIN user_account ua on gl.lu_user_id = ua.user_id
							inner JOIN person_formatted_name_iview_nl_view pfn on ua.person_id = pfn.person_id
	where utt.user_transaction_type_code IN ('GJV')
		and YEAR(gl.effective_date) = @Year
		and gl.transaction_text is not NULL
		and gl.transaction_status_rcd <> 'VOI'
	--order by gl.transaction_text
) as temp
group by temp.[Transaction Text],
	      temp.[Cost Centre Code],
		  temp.[Cost Centre],
		  temp.[GL Account Code],
		  temp.[GL Account Name],
		  temp.[Transaction Date and Time],
		  temp.lu_user,
		  temp.[Effective Date]