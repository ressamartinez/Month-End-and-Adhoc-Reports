
select 
	   ar.transaction_text as [Invoice Number],
	   ar.transaction_date_time as [Invoice Date],
	   ar.gross_amount as [Invoice Amount],
	   r.transaction_text as [Remittance Invoice No.],
	   sai.net_amount as [Remittance Amount],
	   ar.owing_amount as [Owing Amount],
	   r.transaction_date_time as [Remittance Invoice Date],
	   ISNULL(p.name_l, 'Self Pay') as Payor
	   --tsr.name_l as transaction_status,
	   --pfn.display_name_l as posted_by,
	   --gt.lu_updated

from gl_transaction gt left join ar_invoice ar on gt.gl_transaction_id = ar.gl_transaction_id
                       left join swe_ar_instalment sai on ar.ar_invoice_id = sai.ar_invoice_id
					   left join remittance r on sai.remittance_id = r.remittance_id
					   left join policy p on ar.policy_id = p.policy_id
					   inner JOIN transaction_status_ref tsr on ar.transaction_status_rcd = tsr.transaction_status_rcd
					   inner join user_account ua on gt.lu_user_id = ua.user_id
					   inner join person_formatted_name_iview pfn on ua.person_id = pfn.person_id

where CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'06/01/2019',101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'06/07/2019',101) as SMALLDATETIME)
	  and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'
      --and ar.transaction_text = 'PINV-2019-166927'
	  and ar.gross_amount <> 0

order by [Invoice Number]