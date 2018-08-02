	SELECT  tempb.hn as HN, 
			tempb.patient_name as [Patient Name], 
			tempb.visit_type as [Visit Type],
			tempb.invoice_number as [Invoice Number], 
			tempb.invoice_date as [Invoice Date],
			tempb.invoice_amount as [Invoice Amount], 
			tempb.gross_amount as [Gross Amount], 
			case when tempb.visit_type_rcd = 'V34' THEN	tempb.vat
				 when tempb.visit_type_rcd = 'V35' then CAST(tempb.orig_gross_amount * .12 as NUMERIC(12,2))
			end as [Vat], 
			tempb.coveredby_co_payor as [Covered by Co-Payor], 
			tempb.deposit as [Deposit], 
			case when tempb.policy_discount = 'SCD' or tempb.policy_discount = 'PWD' then 0 else tempb.vatable_sales end as [Vatable Sales], 
			tempb.total_invoice as [Total Invoice], 
			case when tempb.visit_type_rcd = 'V34' then 0
				 when tempb.visit_type_rcd = 'V35' then tempb.orig_gross_amount
			end as [Vat-Exempt], 
			case when tempb.visit_type_rcd = 'V34' then 0
				 when tempb.visit_type_rcd = 'V35' THEN tempb.policy_discount_amt
			end as [Discount Amount], 
			case WHEN tempb.visit_type_rcd = 'V34' then tempb.orig_gross_amount
				 when tempb.visit_type_rcd = 'V35' THEN tempb.orig_gross_amount - tempb.policy_discount_amt
			end as [Net Amount],
			tempb.policy_name as [Policy Name]
					
	from 
	( 
	SELECT temp.hn, 
		   temp.patient_name, 
		   temp.visit_type_rcd, 
		   temp.invoice_number, 
		   temp.invoice_date,
		   temp.invoice_amount, 
		   cast(case when temp.visit_type_rcd = 'V35' then  (temp.gross_amount + temp.coveredby_co_payor) * 1.12   
					 else temp.gross_amount + temp.coveredby_co_payor  
				end as NUMERIC(12,2)) as gross_amount, 
		   temp.gross_amount + temp.coveredby_co_payor as orig_gross_amount, 
		   case when (temp.gross_amount + temp.coveredby_co_payor) > 0 THEN CAST((temp.gross_amount + temp.coveredby_co_payor) - CAST((temp.gross_amount + temp.coveredby_co_payor) / 1.12 as NUMERIC(12,2)) as NUMERIC(12,2)) else 0 end as vat,  
		   temp.coveredby_co_payor, 
	   		case when (ISNULL(temp.deposit,0) < 1  and temp.deposit > 0) then 0   
				 when ISNULL(temp.deposit,0) <= 0 then 0   
				 when ISNULL(temp.deposit,0) > 1 THEN temp.deposit end as deposit,  
			temp.deposit as orig_deposit,   
		   sum(temp.discount_amount) as discount, 
		   case WHEN (temp.gross_amount + temp.coveredby_co_payor) > 0 then CAST((temp.gross_amount + temp.coveredby_co_payor) / 1.12 as NUMERIC(12,2)) else 0 end as vatable_sales,  
		  case when ISNULL(temp.deposit,0) > 0 then temp.invoice_amount - (case when (temp.deposit < 1  and temp.deposit > 0) then 0   
																					when temp.deposit < 0 then 0 
																					when temp.deposit > 1 THEN temp.deposit end) else temp.invoice_amount end as total_invoice,  
  
			 temp.policy_discount,  
			 CAST((temp.gross_amount + temp.coveredby_co_payor) - case when (temp.gross_amount + temp.coveredby_co_payor) > 0 THEN CAST((temp.gross_amount + temp.coveredby_co_payor) - CAST((temp.gross_amount + temp.coveredby_co_payor) / 1.12 as NUMERIC(12,2)) as NUMERIC(12,2)) else 0 end as NUMERIC(12,2)) as vat_exempt, 
		   CAST((temp.gross_amount + temp.coveredby_co_payor) * (20.00 / 100.00) as NUMERIC(12,2)) as policy_discount_amt,
		   temp.policy_name,
		   temp.visit_type
	from 
	( 
		SELECT phu.visible_patient_id as hn, 
			   pfn.display_name_l as patient_name, 
			   invoice_number, 
			   ar.invoice_date,
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
					where c.patient_visit_id = ar.patient_visit_id 
						and e.policy_type_rcd = 'INS' 
						and a.transaction_status_rcd <> 'VOI' 
				) as temp),0) as coveredby_co_payor, 
				cid.discount_amount, 
				ar.tax_amount  as vat, 
				ar.patient_visit_id, 
				ar.gross_amount, 
				ar.visit_type_rcd, 
					case when ar.policy_id = 'AE27B927-5FF7-11DA-BB34-000E0C7F3ED2' then 'SCD' 
								 when ar.policy_id = 'B01C02EE-04CC-11DF-B726-00237DBC514A' then 'PWD' 
					end as policy_discount,
				ISNULL(p.name_l,'Self Pay') as policy_name,
				vtr.name_l as visit_type
		from cashier_invoice_view ci INNER JOIN patient_hospital_usage phu on ci.invoice_customer_id = phu.patient_id 
									 inner JOIN person_formatted_name_iview_nl_view pfn on ci.invoice_customer_id = pfn.person_id 
									 inner JOIN (SELECT distinct a.transaction_text, 
													   c.patient_visit_id, 
														   a.tax_amount, 
													   a.gross_amount, 
													  rtrim(a.visit_type_rcd) as visit_type_rcd, 
                               					 a.ar_invoice_id,  
													  a.policy_id,
													  a.transaction_date_time as invoice_date,
													  a.transaction_status_rcd
												from ar_invoice a inner JOIN ar_invoice_detail b on a.ar_invoice_id = b.ar_invoice_id 
																	  inner JOIN charge_detail c on b.charge_detail_id = c.charge_detail_id 
																  inner join patient_visit d on c.patient_visit_id = d.patient_visit_id) ar on ci.invoice_number = ar.transaction_text 
									 INNER JOIN cashier_invoice_detail_view cid on ci.invoice_id = cid.invoice_id 
									 LEFT outer JOIN policy_nl_view p on ar.policy_id = p.policy_id
									 inner JOIN visit_type_ref_nl_view vtr on ar.visit_type_rcd = vtr.visit_type_rcd
		where MONTH(ar.invoice_date) = @Month
			and YEAR(ar.invoice_date) = @Year
			and ar.visit_type_rcd in ('v34','v35')
			and ar.transaction_status_rcd not in ('voi','unk')
	) as temp 
	group by temp.hn, 
			 temp.patient_name, 
			 temp.visit_type_rcd, 
			 temp.invoice_number, 
			 temp.gross_amount, 
			 temp.invoice_amount, 
			 temp.coveredby_co_payor, 
			 temp.vat, 
			 temp.deposit,  
			  temp.policy_discount,
			  temp.policy_name,
			  temp.visit_type,
			  temp.invoice_date
	  ) as tempb     
	  ORDER BY tempb.visit_type_rcd                