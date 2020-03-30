
select be.ward_name_l as Ward
	   --,irc.ipd_room_class_rcd
	   ,irc.name_l as [IPD Room Name]
	   ,count(case when pv.charge_type_rcd = 'IPD' then 1 end) as 'In-patient'
	   ,count(case when pv.charge_type_rcd = 'OPD' then 1 end) as 'Out-patient'
	   ,count(case when pv.charge_type_rcd = 'IPD' then 1
				   when pv.charge_type_rcd = 'OPD' then 1 end) as 'Total'

from charge_detail cd inner join patient_visit pv on cd.patient_visit_id = pv.patient_visit_id
                      inner join bed_charge bc on bc.charge_detail_id = cd.charge_detail_id
					  inner join bed_entry_info_view be on cd.patient_visit_id = be.patient_visit_id
					  inner join ipd_room_class_ref irc on be.ipd_room_class_rcd = irc.ipd_room_class_rcd

where cd.deleted_date_time is NULL
      and pv.cancelled_date_time is NULL
	  and be.cancelled_date_time is NULL
      and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2020',101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'01/31/2020',101) as SMALLDATETIME)
	  --and cd.patient_visit_id = '0DB4EE85-2C96-11EA-8D85-001E0BACC260'

group by be.ward_name_l
		 --,irc.ipd_room_class_rcd
		 ,irc.name_l

order by be.ward_name_l, irc.name_l
