
select DISTINCT
--count(distinct tempc.patient_visit_id)
    tempc.visit_code as [Visit Code]
	,tempc.[Visit Start]
	,tempc.[Closure Date]
	,tempc.HN
	,tempc.[Patient Name]
	,ar.gross_amount as [Gross Amount]
	,ar.discount_amount as [Discount Amount]
	,ar.gross_amount - ar.discount_amount as [Net Amount]
	,ar.transaction_text as [Invoice Number]
	,ar.transaction_date_time as [Invoice Date]
	,p.name_l as Policy
	,case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as 'Payor Type'
	,tempc.[Room Code] as [Bed Assignment]
	,tempc.Age
	--,ard.ar_invoice_detail_id

from (

select tempb.patient_id
	   ,tempb.patient_visit_id
	   ,tempb.visit_code
	   ,tempb.[Visit Start]
	   ,tempb.[Closure Date]
	   ,tempb.[Visit Policies]
	   ,tempb.policy_id
	   ,tempb.HN
	   ,tempb.Age
	   ,tempb.[Patient Name]
	   ,tempb.[Room Code]

from (

select temp.patient_id
	   ,temp.patient_visit_id
	   ,temp.visit_code
	   ,temp.[Visit Start]
	   ,temp.[Expected Discharge Date]
	   ,temp.[Closure Date]
	   ,temp.cancelled_date_time
	   ,temp.[Visit Type Name]
	   ,temp.[Visit Policies]
	   ,temp.policy_id
	   ,temp.HN
	   ,temp.Age
	   ,temp.[Patient Name]
	   ,temp.[Address Type]
	   ,temp.[Room Code]

from (

select distinct apv.patient_id
	   ,api.patient_visit_id
	   ,api.actual_visit_date_time as [Visit Start]
	   ,api.expected_discharge_date_time as [Expected Discharge Date]
	   ,api.closure_date_time as [Closure Date]
	   ,api.visit_code
	   ,api.cancelled_date_time
	   ,api.visit_type_name_l as [Visit Type Name]
	   --,stuff((select '; ' + name_l from patient_visit_reason a1 left join visit_reason_ref a2 on a1.visit_reason_rcd = a2.visit_reason_rcd
				--														where a1.patient_visit_id = api.patient_visit_id
				--														for XML PATH('')),1,1,'') as [Visit Reason]
	   ,vrr.name_l as [Visit Reason]
	   --,stuff((select '; ' + b1.policy_name_l from api_patient_visit_policy_view b1 where b1.patient_visit_id = api.patient_visit_id
				--														for XML PATH('')),1,1,'') as [Visit Policies]
	   ,ISNULL(apvp.policy_name_l, 'Self Pay') as [Visit Policies]
	   ,apvp.policy_id
	   ,apv.visible_patient_id as HN
	   ,apv.display_name_l as [Patient Name]
		,case when panv.person_address_type_rcd is NULL then 'N/A' ELSE panv.person_address_type_rcd end as [Address Type]
		--,datediff(dd,apv.date_of_birth, getdate()) / 365 as Age
		,cast(cast((DATEDIFF(dd,apv.date_of_birth,api.closure_date_time) / 365.25) as int) as varchar) as Age
		--,apv.date_of_birth as [Date of Birth]
	    ,api.admission_bed_code as [Room Code]

FROM api_patient_visit_view api 
			left join api_patient_view apv on api.patient_id = apv.patient_id
			left join user_account ua on api.created_by = ua.user_id
			left join person_formatted_name_iview emp1 on ua.person_id = emp1.person_id
			left join api_patient_visit_policy_view apvp on api.patient_visit_id = apvp.patient_visit_id
			left join address_label_view al on apv.home_address_id = al.address_id
			left join person_address_nl_view panv ON apv.patient_id = panv.person_id
			left join address_nl_view adnv ON al.address_id = adnv.address_id
			left join city_nl_view city on ADNV.city_id = city.city_id
			left join caregiver_role cr on cr.patient_visit_id = api.patient_visit_id
			left join person_formatted_name_iview emp2 on emp2.person_id = cr.employee_id
			left join patient_visit_reason pvr on api.patient_visit_id = pvr.patient_visit_id
			left join visit_reason_ref vrr on pvr.visit_reason_rcd = vrr.visit_reason_rcd
			--left join country_ref cref on apv.home_address_country_rcd = cref.country_rcd


where 
	  cancelled_date_time is null
      and api.visit_type_rcd in ('V1', 'V2')
      --and discharge_status_rcd = 'COM'
	  --and panv.effective_until_date is null 
	  and cr.caregiver_role_type_rcd = 'PRIDR'
	  and cr.caregiver_role_status_rcd = 'ACTIV'
	  --and api.visible_patient_id in ('00006719', '00509908', '00032498')  
      --and last_status_rcd is NULL

) as temp
			left join patient_visit_diagnosis_view pvdv on pvdv.patient_visit_id = temp.patient_visit_id
			left join coding_system_element_description csed on csed.code = pvdv.code

where temp.[Address Type] in ('H1','N/A')
	  and (csed.coding_system_rcd is null or csed.coding_system_rcd in ('ICD10', 'ICD9CM'))
	  --and (pvdv.coding_type_rcd is null or pvdv.coding_type_rcd = 'PRI')
	  and isnull(pvdv.current_visit_diagnosis_flag,0) = 1
      and (select count(*) from patient_visit_diagnosis_view
				where patient_visit_id = pvdv.patient_visit_id
				and current_visit_diagnosis_flag = 1) > 0

UNION ALL

select temp.patient_id
	   ,temp.patient_visit_id
	   ,temp.visit_code
	   ,temp.[Visit Start]
	   ,temp.[Expected Discharge Date]
	   ,temp.[Closure Date]
	   ,temp.cancelled_date_time
	   ,temp.[Visit Type Name]
	   ,temp.[Visit Policies]
	   ,temp.policy_id
	   ,temp.HN
	   ,temp.Age
	   ,temp.[Patient Name]
	   ,temp.[Address Type]
	   ,temp.[Room Code]

from (

select distinct apv.patient_id
	   ,api.patient_visit_id
	   ,api.actual_visit_date_time as [Visit Start]
	   ,api.expected_discharge_date_time as [Expected Discharge Date]
	   ,api.closure_date_time as [Closure Date]
	   ,api.cancelled_date_time
	   ,api.visit_code
	   ,api.visit_type_name_l as [Visit Type Name]
	   --,stuff((select '; ' + name_l from patient_visit_reason a1 left join visit_reason_ref a2 on a1.visit_reason_rcd = a2.visit_reason_rcd
				--														where a1.patient_visit_id = api.patient_visit_id
				--														for XML PATH('')),1,1,'') as [Visit Reason]
	   ,datediff(dd,api.actual_visit_date_time,api.closure_date_time) as [Length of Stay]
	   --,stuff((select '; ' + b1.policy_name_l from api_patient_visit_policy_view b1 where b1.patient_visit_id = api.patient_visit_id
				--														for XML PATH('')),1,1,'') as [Visit Policies]
	   ,ISNULL(apvp.policy_name_l, 'Self Pay') as [Visit Policies]
	   ,apvp.policy_id
	   ,apv.visible_patient_id as HN
	   ,apv.display_name_l as [Patient Name]
		,case when panv.person_address_type_rcd is NULL then 'N/A' ELSE panv.person_address_type_rcd end as [Address Type]
		--,datediff(dd,apv.date_of_birth, getdate()) / 365 as Age
		,cast(cast((DATEDIFF(dd,apv.date_of_birth,api.closure_date_time) / 365.25) as int) as varchar) as Age
		--,apv.date_of_birth as [Date of Birth]
	    ,api.admission_bed_code as [Room Code]

FROM api_patient_visit_view api 
			left join api_patient_view apv on api.patient_id = apv.patient_id
			left join user_account ua on api.created_by = ua.user_id
			left join person_formatted_name_iview emp1 on ua.person_id = emp1.person_id
			left join api_patient_visit_policy_view apvp on api.patient_visit_id = apvp.patient_visit_id
			left join address_label_view al on apv.home_address_id = al.address_id
			left join person_address_nl_view panv ON apv.patient_id = panv.person_id
			left join address_nl_view adnv ON al.address_id = adnv.address_id
			left join city_nl_view city on ADNV.city_id = city.city_id
			left join caregiver_role cr on cr.patient_visit_id = api.patient_visit_id
			left join person_formatted_name_iview emp2 on emp2.person_id = cr.employee_id
			left join patient_visit_reason pvr on api.patient_visit_id = pvr.patient_visit_id
			left join visit_reason_ref vrr on pvr.visit_reason_rcd = vrr.visit_reason_rcd
			--left join country_ref cref on apv.home_address_country_rcd = cref.country_rcd

where 
	  cancelled_date_time is null
      and api.visit_type_rcd in ('V1', 'V2')
      --and discharge_status_rcd = 'COM'
	  --and panv.effective_until_date is null 
	  and cr.caregiver_role_type_rcd = 'PRIDR'
	  and cr.caregiver_role_status_rcd = 'ACTIV'
	  --and api.visible_patient_id in ('00006719', '00509908', '00032498')  
      --and last_status_rcd is NULL

) as temp
			left join patient_visit_diagnosis_view pvdv on temp.patient_visit_id = pvdv.patient_visit_id
			left join coding_system_element_description csed on pvdv.code = csed.code

where temp.[Address Type] in ('H1','N/A')
	  and (csed.coding_system_rcd is null or csed.coding_system_rcd in ('ICD10', 'ICD9CM'))
	  and (pvdv.coding_type_rcd is null or pvdv.coding_type_rcd = 'PRI')
      and (select count(*) from patient_visit_diagnosis_view
				where patient_visit_id = pvdv.patient_visit_id
				and current_visit_diagnosis_flag = 1) = 0

) as tempb
where 
      --year(tempb.[Visit Start]) = 2018
      --and month(tempb.[Visit Start]) = 11
	   CAST(CONVERT(VARCHAR(10),tempb.[Visit Start],101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'07/01/2020',101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),tempb.[Visit Start],101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'07/31/2020',101) as SMALLDATETIME)
	  --and tempb.HN in ('00609412')
	  and tempb.[Room Code] not like '%-%'
	  --and tempb.Age >=60
--and tempb.patient_visit_id = '09EF6AC9-2239-11EA-A0D4-484D7EF1A97B'
	  
) as tempc
inner join charge_detail cd on tempc.patient_visit_id = cd.patient_visit_id
inner join ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
inner join ar_invoice ar on ard.ar_invoice_id = ar.ar_invoice_id
inner join policy p on ar.policy_id = p.policy_id
left OUTER JOIN customer c on ar.customer_id = c.customer_id
LEFT OUTER JOIN organisation o on c.organisation_id = o.organisation_id
LEFT OUTER JOIN person_formatted_name_iview_nl_view pfn on c.person_id = pfn.person_id
LEFT OUTER JOIN organisation_role oor on o.organisation_id = oor.organisation_id
LEFT OUTER JOIN organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd
where ar.transaction_status_rcd not in ('voi', 'unk')
      and ar.policy_id = 'B01C02EE-04CC-11DF-B726-00237DBC514A'
order by tempc.HN, [Invoice Number]


