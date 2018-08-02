SELECT r.transaction_text as [Remittance Number],
		r.remittance_id,
		r.document_number as [Receipt Number],
		CAST((r.received_amount) AS DECIMAL(10,2)) as [Remittance Amount],
		tsr.name_l as [Transaction Status],
		r.transaction_date_time as [Transaction DateTime],
		CONVERT(VARCHAR(20), r.transaction_date_time,101) AS [Transaction Date],
		FORMAT(r.transaction_date_time,'hh:mm tt') AS [Transaction Time],
		r.effective_date as [Effective DateTime],
		CONVERT(VARCHAR(20), r.effective_date,101) AS [Effective Date],
		FORMAT(r.effective_date,'hh:mm tt') AS [Effective Time],
		r.created_on_date_time as [Created DateTime],
		CONVERT(VARCHAR(20), r.created_on_date_time,101) AS [Date Created],
		FORMAT(r.created_on_date_time,'hh:mm tt') AS [Time Created],
		utt.user_transaction_type_code + '- ' + utt.name_l as [Transaction Type],
		(SELECT case when person_id is not NULL then (SELECT display_name_l 
													from person_formatted_name_iview_nl_view
													where person_id = customer_id)
					else (SELECT name_l
						from organisation
						where organisation_id = customer_id) end as customer_name
		from customer
		where customer_id = r.customer_id) as [Customer Name],
		r.transaction_description as [Description],
		r.lu_updated as [Last Updated],
		CONVERT(VARCHAR(20), r.lu_updated,101) AS [Last Updated Date],
		FORMAT(r.lu_updated,'hh:mm tt') AS [Last Updated Time],
		pfn.display_name_l as [Last Updated By]
from remittance_nl_view r INNER JOIN user_transaction_type_nl_view utt on r.user_transaction_type_id = utt.user_transaction_type_id
							INNER  JOIN user_account ua on r.lu_user_id = ua.user_id
							INNER JOIN person_formatted_name_iview_nl_view pfn on ua.person_id = pfn.person_id
							INNER JOIN transaction_status_ref_nl_view tsr on r.transaction_status_rcd = tsr.transaction_status_rcd
where 	r.user_transaction_type_id = '30957FA5-735D-11DA-BB34-000E0C7F3ED2'
	--and MONTH(r.transaction_date_time) >= @iFromMonth and MONTH(r.transaction_date_time) <= @iToMonth
	--and YEAR(r.transaction_date_time) = @iYear
	and r.transaction_date_time BETWEEN @iFromMonth and @iToMonth
order by [Remittance Number]