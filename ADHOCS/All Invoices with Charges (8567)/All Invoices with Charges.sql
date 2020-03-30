

select distinct case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as 'Organisation Type',
		temp.HN,
		temp.[Patient Name],
		temp.[Invoice No.], 
		temp.Payor,
		temp.[Visit Type],
		temp.[Invoice Date],
		temp.[Discharge Date],
		[Gross Amount] = sum(temp.gross_amount),
		[Discount Amount] = sum(temp.discount_amount),
		[Net Amount] = sum(temp.gross_amount) - sum(temp.discount_amount),
		temp.[Payment Status]

	from(

		select 
			   phu.visible_patient_id as HN
			   ,pfn.display_name_l as [Patient Name]
			   ,ar.transaction_text as [Invoice No.]
			   ,p.name_l as [Payor]
			   ,vtr.name_l as [Visit Type]
			   ,ar.transaction_date_time as [Invoice Date]
			   ,cd.closed_date_time as [Discharge Date]
			   ,gross_amount = (select ard1.gross_amount from ar_invoice ar1 
											 left join ar_invoice_detail ard1 on ar1.ar_invoice_id = ard1.ar_invoice_id
											 left join gl_acct_code gac on ard1.gl_acct_code_credit_id = gac.gl_acct_code_id
										 where ard1.ar_invoice_detail_id = ard.ar_invoice_detail_id
									 		   and gac.gl_acct_code_code not in (/*'4264000',*/ '2152100', '2152250')
											   and gac.company_code = 'AHI')
			   ,discount_amount = (select ard1.discount_amount from ar_invoice ar1 
											 left join ar_invoice_detail ard1 on ar1.ar_invoice_id = ard1.ar_invoice_id
											 left join gl_acct_code gac on ard1.gl_acct_code_credit_id = gac.gl_acct_code_id
										 where ard1.ar_invoice_detail_id = ard.ar_invoice_detail_id
									 		   and gac.gl_acct_code_code not in (/*'4264000',*/ '2152100', '2152250')
											   and gac.company_code = 'AHI')
			   ,sp.name_l as [Payment Status]
			   ,ar.customer_id


		from ar_invoice ar left join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
						   left join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
						   left join patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
						   left join person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
						   left join patient_hospital_usage_nl_view phu on pfn.person_id = phu.patient_id
						   left join policy p on ar.policy_id = p.policy_id
						   left join visit_type_ref vtr on ar.visit_type_rcd = vtr.visit_type_rcd
						   left join swe_payment_status_ref sp on ar.swe_payment_status_rcd = sp.swe_payment_status_rcd


		where ar.transaction_status_rcd not in ('voi','unk')
				--and ar.system_transaction_type_rcd not in ('cdmr','dbmr')
				and cd.deleted_date_time is null
				and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/31/2018',101) as SMALLDATETIME)
				and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2018',101) as SMALLDATETIME)


)as temp
		left OUTER JOIN customer c on temp.customer_id = c.customer_id
		LEFT OUTER JOIN organisation o on c.organisation_id = o.organisation_id
		LEFT OUTER JOIN person_formatted_name_iview_nl_view pfn1 on c.person_id = pfn1.person_id
		LEFT OUTER JOIN organisation_role oor on o.organisation_id = oor.organisation_id
		LEFT OUTER JOIN organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd

--where temp.[Invoice No.] in ('PINV-2018-353032', 'PINV-2018-353033')
group by temp.HN,
		 temp.[Patient Name],
		 temp.[Invoice No.],
		 temp.Payor,
		 temp.[Visit Type],
		 temp.[Invoice Date],
		 temp.[Discharge Date],
		 temp.[Payment Status],
		 otr.organisation_type_rcd,
		 otr.name_l

order by temp.[Invoice No.]