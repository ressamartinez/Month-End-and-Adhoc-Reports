
SELECT DISTINCT
        api.actual_visit_date_time
		,apv.visible_patient_id as hn
		,apv.display_name_l as patient_name
		,p.name_l as policy
		,ar.transaction_date_time
		,ar.transaction_text
		,ar.gross_amount
		,ar.discount_amount
		,net_amount = ar.gross_amount - ar.discount_amount


from ar_invoice ar left join ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
	                left join item i on ard.item_id = i.item_id
	                left join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
	                left join api_patient_visit_view api on cd.patient_visit_id = api.patient_visit_id 
					left join api_patient_view apv on api.patient_id = apv.patient_id
					left join policy p on ar.policy_id = p.policy_id

where ar.transaction_status_rcd not in ('voi', 'unk') 
        and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'   --PINV
		and p.short_code = '309'   --PWD
        and month(cd.charged_date_time) BETWEEN 11 and 12
		--and month(cd.charged_date_time) = 11
		and year(cd.charged_date_time) = 2019
		--and i.item_code = '010-10-0410'
		--and apv.visible_patient_id = '00488621'

order by apv.display_name_l
