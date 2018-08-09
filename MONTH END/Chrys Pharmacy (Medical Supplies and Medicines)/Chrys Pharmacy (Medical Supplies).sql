SELECT hn,
	   temp.patient_name,
	   temp.invoice_number,
	   temp.invoice_amount,
	   case when (ISNULL(temp.deposit,0) < 1  and temp.deposit > 0) then 0   
			when ISNULL(temp.deposit,0) <= 0 then 0   
			when ISNULL(temp.deposit,0) > 1 THEN temp.deposit end as deposit,  
	   case WHEN (temp.gross_amount + temp.coveredby_co_payor) > 0 then CAST((temp.gross_amount + temp.coveredby_co_payor) / 1.12 as NUMERIC(12,2)) else 0 end as vatable_sales, 
       case when (temp.gross_amount + temp.coveredby_co_payor) > 0 THEN CAST((temp.gross_amount + temp.coveredby_co_payor) - CAST((temp.gross_amount + temp.coveredby_co_payor) / 1.12 as NUMERIC(12,2)) as NUMERIC(12,2)) else 0 end as vat,  
	   temp.coveredby_co_payor, 
	   temp.discount_amount,
	   temp.gross_amount,
	   temp.visit_type_rcd,
	   temp.transaction_date_time as [Transaction DateTime],
	   CONVERT(VARCHAR(20), temp.transaction_date_time,101) AS [Invoice Date],
		FORMAT(temp.transaction_date_time,'hh:mm tt') AS [Invoice Time],
	   temp.visit_type,
	   temp.item_code,
	   temp.item_name,
	   temp.amount,
	   temp.gl_acct_code_code,
	   temp.gl_acct_name
from
(
	SELECT DISTINCT ard.ar_invoice_detail_id,
			phu.visible_patient_id as hn, 
			   pfn.display_name_l as patient_name, 
			   invoice_number, 
			   ci.invoice_customer_id, 
			   invoice_amount, 
			   pfn.display_name_l as patientname, 
			   ISNULL((SELECT SUM(deposit_amount) - 
							   SUM(ABS(used_amount)) as deposit 
						from patient_deposit_balance pdb  
						where  customer_id = ci.invoice_customer_id),0) as deposit,
			 isnull( (SELECT SUM(temp.co_payor_amt) 
				from 
				( 
					SELECT DISTINCT a.transaction_text, 
						   a.gross_amount - a.discount_amount as co_payor_amt 
					from ar_invoice a inner JOIN ar_invoice_detail b on a.ar_invoice_id = b.ar_invoice_id 
								inner JOIN charge_detail c on b.charge_detail_id = c.charge_detail_id 
								inner join patient_visit d on c.patient_visit_id = d.patient_visit_id 
								inner JOIN policy e on a.policy_id = e.policy_id 
					where c.patient_visit_id = pv.patient_visit_id
						and e.policy_type_rcd = 'INS' 
						and a.transaction_status_rcd <> 'VOI' 
				) as temp),0) as coveredby_co_payor,
				cid.discount_amount, 
				ar.tax_amount  as vat, 
				pv.patient_visit_id, 
				ar.gross_amount, 
				ar.visit_type_rcd,
				ar.transaction_date_time,
				vtr.name_l as visit_type,
				cid.item_id,
				i.item_code,
				i.name_l as item_name,
				cd.amount,
				gac.gl_acct_code_code,
				gac.name_l as gl_acct_name
		from cashier_invoice_view ci INNER JOIN patient_hospital_usage phu on ci.invoice_customer_id = phu.patient_id 
									 inner JOIN person_formatted_name_iview_nl_view pfn on ci.invoice_customer_id = pfn.person_id 
									 inner JOIN ar_invoice ar on ar.transaction_text = ci.invoice_number
									 inner JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
									 inner JOIN charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
									 inner JOIN patient_visit pv on cd.patient_visit_id = pv.patient_visit_id
									 INNER JOIN cashier_invoice_detail_view cid on ci.invoice_id = cid.invoice_id 
									 inner JOIN visit_type_ref_nl_view vtr on ar.visit_type_rcd = vtr.visit_type_rcd
									  inner JOIN item i on cid.item_id = i.item_id
									   inner JOIN item_group_gl igg on i.item_group_id =igg.item_group_id
									 inner JOIN gl_acct_code gac on igg.gl_acct_code_id = gac.gl_acct_code_id
		where MONTH(ar.transaction_date_time) = @Month
			and YEAR(ar.transaction_date_time) = @Year
			and ar.transaction_status_rcd <> 'VOI'
			and ar.visit_type_rcd = 'V32' --chrys pharmacy 
			and ard.gross_amount > 0   
			and i.item_id = cd.item_id
			and i.item_id = cid.item_id
			and gac.gl_acct_code_code = '1160201'
) as temp
order by temp.transaction_date_time
