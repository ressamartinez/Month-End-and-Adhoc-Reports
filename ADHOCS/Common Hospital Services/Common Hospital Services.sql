	
select distinct top 1000
       temp.item_code,
       temp.item_name,
	   temp.item_group,
	   temp.main_item_group,
	   temp.department,
	   count(temp.ar_invoice_detail_id) as count,
	   temp.policy

from	
(
	select 
		   ard.item_id,
		   i.item_code,
		   i.name_l as item_name,
		   i.item_type_rcd,
		   i.sub_item_type_rcd,
		   item_group_code = (SELECT item_group_code
								FROM item_group_nl_view
								WHERE item_group_id = i.item_group_id),
		   item_group = (SELECT name_l
								FROM item_group_nl_view
								WHERE item_group_id = i.item_group_id),
		   main_item_group_code = (SELECT item_group_code
									 FROM item_group_nl_view
									 WHERE item_group_id = (SELECT parent_item_group_id
																   FROM item_group_nl_view
																   WHERE item_group_id = i.item_group_id)),
		   main_item_group = (SELECT name_l
									 FROM item_group_nl_view
									 WHERE item_group_id = (SELECT parent_item_group_id
																   FROM item_group_nl_view
																   WHERE item_group_id = i.item_group_id)),
		   dept_code = (SELECT DISTINCT costcentre_code 
		                        from costcentre 
								where costcentre_id = cd.service_provider_costcentre_id),
		   department = (SELECT DISTINCT name_l 
		                        from costcentre 
								where costcentre_id = cd.service_provider_costcentre_id),
		   p.policy_id,
		   p.name_l as policy,
		   ard.ar_invoice_detail_id,
		   ar.transaction_date_time

	from ar_invoice_nl_view ar left join ar_invoice_detail_nl_view ard on ar.ar_invoice_id = ard.ar_invoice_id
							   left join charge_detail_nl_view cd on ard.charge_detail_id = cd.charge_detail_id 
							   left join item_nl_view i on ard.item_id = i.item_id
							   left join policy_nl_view p on ar.policy_id = p.policy_id

	where cd.deleted_date_time is null
		  and ar.transaction_status_rcd not in ('voi', 'unk')
		  --and i.item_code = '090-10-0010'
		  and i.item_type_rcd = 'SRV'
		  and ard.item_id not in (Select item_id from item_nl_view where item_code like 'S23%')
		  and ard.item_id not in (Select item_id from item_nl_view where sub_item_type_rcd = 'DRFEE')
		  --and p.policy_id in ('70D41EC4-63D5-11DA-BB34-000E0C7F3ED2', '9C85614E-6ED7-11E3-84F9-78E3B58FDD66')       --MEDICARD, 2014 MEDICARD
		  --and p.policy_id in ('F359BE0B-63BA-11DA-BB34-000E0C7F3ED2', '0D2C251E-6ED7-11E3-84F9-78E3B58FDD66')       --MAXICARE, 2014 MAXICARE
		  --and p.policy_id in ('1A9C80A9-5E33-11DA-BB34-000E0C7F3ED2', '7D59250E-6ED6-11E3-84F9-78E3B58FDD66')       --INTELLICARE, 2014 INTELLICARE
		  --and p.policy_id in ('BDBF932F-4451-11DA-BB34-000E0C7F3ED2', '0562129E-6ED2-11E3-84F9-78E3B58FDD66')       --COCOLIFE, 2014 COCOLIFE
		  and p.policy_id in ('30459596-63DB-11DA-BB34-000E0C7F3ED2', 'B0CAEF7E-6ED8-11E3-84F9-78E3B58FDD66')       --PHILHEALTH CARE, INC. (formerly Philamcare), 2014 PHILHEALTH CARE, INC. (formerly Philamcare)

)as temp
where temp.dept_code in ('7300', '7283', '7145', '7234', '7025',     --Breast Clinic, Center for Women's Health, CT Scan, EEG-Neuroscience, Eye Center
					     '7233', '7110', '7080', '7060', '7070',     --Hearing Unit, Heart Station, Lab-Blood Bank, Lab-Clinical, Lab-Pathology
						 '7165', '7160', '7140', '7200', '7146')     --Magnetic Resonance Imaging, Nuclear Medicine, Radiology Services - General Radiology, Rehabilitation Medicine, Ultrasound
      --and month(temp.transaction_date_time) between 1 and 10
      and year(temp.transaction_date_time) = 2018

group by temp.item_code,
         temp.item_name,
		 temp.item_group_code,
		 temp.item_group,
		 temp.main_item_group_code,
		 temp.main_item_group,
		 temp.policy,
		 temp.department

order by count desc,
         temp.item_code,
		 temp.policy

         