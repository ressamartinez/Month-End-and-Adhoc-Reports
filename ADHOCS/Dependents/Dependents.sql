

SELECT distinct phu.visible_patient_id as [HN],
		pfn.display_name_l as [Patient Name],
		case when pfn.sex_rcd = 'M' then 'Male' else 'Female' end as [Gender],
		pir.name_l as [Indicator],
		pin.person_indicator_rcd as [Inidicator Code]
		--isnull(pin.comment, '') as [Comment]
from patient p inner JOIN person_indicator pin on p.patient_id = pin.person_id
			   inner join person_indicator_ref pir on pin.person_indicator_rcd = pir.person_indicator_rcd
			   inner JOIN person_formatted_name_iview_nl_view pfn on p.patient_id = pfn.person_id
			   inner JOIN patient_hospital_usage_nl_view phu on p.patient_id = phu.patient_id
			  
where pin.person_indicator_rcd = 'DEP'
    and pin.active_flag = 1
order by pfn.display_name_l

