DECLARE @Year varchar(10)

SET @Year = '%-2016-%'

SELECT temp.[Table],
	   temp.[Type Code],
	   temp.[Transaction Type],
	   temp.[Voided Transaction]
from
(
	SELECT 'AR Invoice' as [Table],
		   utt.user_transaction_type_code as [Type Code],
		   utt.name_l as [Transaction Type],
		   ar.transaction_text as [Voided Transaction]
	from ar_invoice ar inner JOIN user_transaction_type utt on ar.user_transaction_type_id = utt.user_transaction_type_id
	where transaction_status_rcd = 'voi'
		and transaction_text  LIKE @Year
	UNION ALL
	SELECT 'SWE AP Transaction' as [Table],
			utt.user_transaction_type_code as [Type Code],
			utt.name_l as [Transaction Type],
			ap.transaction_text as [Voided Transaction]
	from swe_ap_transaction ap inner JOIN  user_transaction_type utt on ap.user_transaction_type_id = utt.user_transaction_type_id
	where transaction_status_rcd = 'voi'
		and transaction_text  LIKE @Year
	UNION ALL
	SELECT 'SWE Purchase Receive' as [Table],
			 utt.user_transaction_type_code as [Type Code],
			utt.name_l as [Transaction Type],
			spr.transaction_text as [Voided Transaction]	
	from swe_purchase_receive spr inner JOIN  user_transaction_type utt on spr.user_transaction_type_id = utt.user_transaction_type_id
	where transaction_status_rcd = 'voi'
		and transaction_text  LIKE @Year
	UNION ALL
	SELECT 'SWE Purchase Distribute' as [Table],
			 utt.user_transaction_type_code as [Type Code],
			utt.name_l as [Transaction Type],
			spd.transaction_text as [Voided Transaction]	
	from swe_purchase_distribute spd  inner JOIN  user_transaction_type utt on spd.user_transaction_type_id = utt.user_transaction_type_id
	where spd.void_transaction_id is not NULL
		and transaction_text  LIKE @Year
	UNION ALL
	SELECT 'AP Payment' as [Table],
			 utt.user_transaction_type_code as [Type Code],
			utt.name_l as [Transaction Type],
			app.transaction_text as [Voided Transaction]	
	from ap_payment app inner JOIN  user_transaction_type utt on app.user_transaction_type_id = utt.user_transaction_type_id
	where  app.transaction_status_rcd = 'voi'
		and transaction_text  LIKE @Year
	UNION all
	SELECT 'GL Transaction' as [Table],
			 utt.user_transaction_type_code as [Type Code],
			utt.name_l as [Transaction Type],
			gl.transaction_text as [Voided Transaction]	
	from gl_transaction_nl_view gl inner JOIN  user_transaction_type utt on gl.user_transaction_type_id = utt.user_transaction_type_id
	where  gl.transaction_status_rcd = 'voi'
		and transaction_text  LIKE @Year
	UNION ALL
	SELECT 'SWE Purchase Order' as [Table],
			 utt.user_transaction_type_code as [Type Code],
			utt.name_l as [Transaction Type],
			po.transaction_text as [Voided Transaction]	
	from swe_purchase_order po inner JOIN  user_transaction_type utt on po.user_transaction_type_id = utt.user_transaction_type_id
	where void_transaction_id is not NULL
		  and transaction_text  LIKE @Year
	UNION ALL
	SELECT  'SWE Purchase Order' as [Table],
			 utt.user_transaction_type_code as [Type Code],
			utt.name_l as [Transaction Type],
			r.transaction_text as [Voided Transaction]	
	from remittance r inner JOIN  user_transaction_type utt on r.user_transaction_type_id = utt.user_transaction_type_id
	where r.transaction_status_rcd = 'voi'
		and transaction_text  LIKE @Year
) as temp
order by temp.[Table],temp.[Voided Transaction]