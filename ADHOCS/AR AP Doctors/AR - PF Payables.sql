--455380 ALL

SELECT 
			glt.transaction_text as [Transaction Number]
			,glt.transaction_date_time as [Transaction Date and Time]
			,glt.effective_date as [Effective Date and Time]
			,CASE WHEN gltd.debit_flag = 1 THEN gltd.amount END as [Debit Amount]
			,CASE WHEN gltd.debit_flag = 0 THEN gltd.amount END as [Credit Amount]
			,glc.gl_acct_code_code as [GL Account Code]
			,glc.name_l as [GL Account Name]
			,cc.costcentre_code as [Costcentre Code]
			,cc.name_l as [Costcentre]
			,gltd.description as [Description]

			--,*

FROM gl_transaction glt
				INNER JOIN gl_transaction_detail gltd ON glt.gl_transaction_id = gltd.gl_transaction_id
				INNER JOIN gl_acct_code glc ON gltd.gl_acct_code_id = glc.gl_acct_code_id
				INNER JOIN costcentre cc ON gltd.costcentre_id = cc.costcentre_id


where 
			glt.user_transaction_type_id = '8566FA00-63FE-11DA-BB34-000E0C7F3ED2'		--GJV
			AND glt.transaction_status_rcd NOT IN ('VOI', 'UNK')
			AND YEAR(glt.effective_date) = 2018
			AND glc.gl_acct_code_code IN ('1130491')		

ORDER BY glt.transaction_date_time