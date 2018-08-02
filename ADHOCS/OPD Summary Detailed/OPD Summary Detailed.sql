DECLARE @From datetime
DECLARE @To datetime

SET @From = @From
SET @To = @To

SELECT DISTINCT pv.patient_visit_id,
	   pv.creation_date_time as visit_date,
	   CONVERT(VARCHAR(20), pv.creation_date_time,101) AS [Visit Date],
	   FORMAT(pv.creation_date_time,'hh:mm tt') AS [Visit Time],
	   pvd.recorded_at_date_time,
	   CONVERT(VARCHAR(20), pvd.recorded_at_date_time,101) AS [Recorded Date],
	   FORMAT(pvd.recorded_at_date_time,'hh:mm tt') AS [Recorded Time],
	   phu.visible_patient_id as hn,
	   pfn.display_name_l as patient_name,
	   vtr.name_l as visit_type,
	   pvd.code,
	   pvd.coding_system_rcd,
	   pvd.lu_updated
from patient_visit pv inner JOIN visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd
					  inner JOIN patient_visit_diagnosis_view pvd on pv.patient_visit_id = pvd.patient_visit_id
					  inner JOIN patient_hospital_usage phu on pv.patient_id = phu.patient_id
					  inner JOIN person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
where CAST(CONVERT(VARCHAR(10), pv.creation_date_time,101) as SMALLDATETIME) >=  CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
    and CAST(CONVERT(VARCHAR(10), pv.creation_date_time,101) as SMALLDATETIME) <=  CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
	and pv.cancelled_date_time is NULL
	and vtr.visit_type_group_rcd = 'OPD'
	--AND pv.patient_id = '297D6BFF-9C75-11DA-BB34-000E0C7F3ED2'
	and pvd.diagnosis_type_rcd = 'GEN'
	and pvd.coding_type_rcd = 'PRI'
	--and pvd.recorded_at_date_time BETWEEN pv.creation_date_time and pv.closure_date_time
order by pv.creation_date_time