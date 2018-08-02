SELECT temp.patient_id,
	   temp.patient_name,
	   temp.hn,
	   temp.previous_visit,
	   temp.latest_visit,
	   DATEDIFF(hh,temp.previous_visit,temp.latest_visit) / 24  as elapsetime_day,
	   DATEDIFF(mi,temp.previous_visit,temp.latest_visit) / 60 % 60 as elapsetime_hrs,
	   DATEDIFF(ss,temp.previous_visit,temp.latest_visit) / 60 % 60 as elapsetime_mins,
	   DATEDIFF(ss,temp.previous_visit,temp.latest_visit) % 60 % 60 as elapsetime_sec,
	   'Operating Room' as visit_type
from
(
	SELECT DISTINCT phu.patient_id,
		   phu.visible_patient_id as hn,
		   pfn.display_name_l as patient_name,
		   ISNULL((SELECT MAX(_pv.actual_visit_date_time) as latest_visit
				from patient_visit _pv inner join charge_detail _cd on _pv.patient_visit_id = _cd.patient_visit_id
				where 
					 _pv.patient_id = pv.patient_id
					and _cd.item_id in ('D77267ED-517B-11DE-AFBF-000E0C7F3ED2',
	 								    '1DFC7631-B898-4E36-827B-B96E0D674991',
									    '63D9816D-AF23-44E8-B391-5197325308EB',
									    'A1EC529B-6BA4-11DA-BB34-000E0C7F3ED2')),0) as latest_visit,
		   ISNULL((SELECT MIN(temp.actual_visit_date_time) as previous_visit
					from
					(
						SELECT DISTINCT top 2 _pv.patient_visit_id,
								_pv.actual_visit_date_time
						from patient_visit _pv inner join charge_detail _cd on _pv.patient_visit_id = _cd.patient_visit_id
						where  _pv.patient_id = pv.patient_id
								and _cd.item_id in ('D77267ED-517B-11DE-AFBF-000E0C7F3ED2',
	 											    '1DFC7631-B898-4E36-827B-B96E0D674991',
												    '63D9816D-AF23-44E8-B391-5197325308EB',
												    'A1EC529B-6BA4-11DA-BB34-000E0C7F3ED2')
						order by _pv.actual_visit_date_time DESC
					) as temp),0) as previous_visit
	from patient_visit pv inner join patient_hospital_usage_nl_view phu on pv.patient_id = phu.patient_id
						  inner join person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
	where CAST(CONVERT(VARCHAR(10),pv.actual_visit_date_time,101)  as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dFrom,101)  as SMALLDATETIME)
		 and CAST(CONVERT(VARCHAR(10),pv.actual_visit_date_time,101)  as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dTo,101)  as SMALLDATETIME)
		 and pv.cancelled_date_time is NULL
		 AND pv.patient_visit_id in (SELECT patient_visit_id
									from charge_detail
									where item_id in ('D77267ED-517B-11DE-AFBF-000E0C7F3ED2',
													  '1DFC7631-B898-4E36-827B-B96E0D674991',
													  '63D9816D-AF23-44E8-B391-5197325308EB',
												      'A1EC529B-6BA4-11DA-BB34-000E0C7F3ED2')
										and patient_visit_id = pv.patient_visit_id
										and deleted_date_time is NULL)
	group by pv.patient_id,
			 phu.visible_patient_id,
			 phu.patient_id,
			 pfn.display_name_l,
			 pv.actual_visit_date_time
) as temp
where (DATEDIFF(hh,temp.previous_visit,temp.latest_visit) / 24) <= 30
	 and (DATEDIFF(hh,temp.previous_visit,temp.latest_visit) / 24) > 0
order by elapsetime_day DESC,
	     elapsetime_hrs DESC,
		 elapsetime_mins DESC,
		 elapsetime_sec DESC