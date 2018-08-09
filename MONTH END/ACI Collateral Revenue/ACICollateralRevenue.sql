DECLARE @iMonth int
DECLARE @iMonth2 int
DECLARE @iYear int

SET @iMonth = @MonthFrom
SET @iMonth2 = @MonthTo
SET @iYear = @Year

SELECT temp.patient_visit_id,
	   temp.hn as HN,
	   temp.patient_name as [Patient Name],
	   temp.invoice_no as [Invoice No.],
	   temp.invoice_date as [Invoice Date],
	   temp.visit_type as [Visit Type],
	   temp.visit_code as [Visit Code],
	   temp.policy_name as [Policy Name],
	   temp.diagnosis,
	   temp.brachytheraphy as Brachytheraphy,
	   temp.breast_clinic as [Breast Clinic],
		temp.center_for_women as [Center for Women's Health],
		temp.ct_scan as [CT Scan],
		temp.radiation_therapy as [Radiation Therapy],
		temp.radiology_diagnostic as [Radiology Diagnostic],
		temp.emg as EMG,
		temp.heart_station as [Heart Station],
		temp.laboratory as Laboratory,
		temp.med_equip_charges as [Medical Equipment Charges],
		temp.msu as MSU,
		temp.nuclear_medicine as [Nuclear Medicine],
		temp.pharmacy as Pharmacy,
		temp.simply_women as [Simply Women],
		temp.support_and_hcu as [Support and Home Care Unit],
		temp.ultrasound as Ultrasound,
		temp.audiology as Audiology,
		temp.bed_charges as [Bed Charges],
		temp.chemo_infusion as [Chemo Infusion],
		temp.emergency_room as [Emergency Room],
		temp.eye_center as [Eye Center],
		temp.food as [Food],
		temp.genesis_dr as [Genesis (DR)],
		temp.intensive_monitoring_fee as [Intensive Monitoring Fee],
		temp.lab_blood_bank as [Lab-blood Bank],
		temp.mri as MRI,
		temp.nursing_service as [Nursing Service],
		temp.nutrition_counselling as [Nutrition Counselling],
		temp.or_gi_endoscopy as [OR/GI Endoscopy],
		temp.other_revenue as [Other Revenue],
		temp.pain_management as [Pain Management],
		temp.perioperative_services as [Perioperative Service],
		temp.pysiotheraphy as Pysiotheraphy,
		temp.pulmonary_respiratory_theraphy as [Pulmonary Respiratory Theraphy],
		temp.recovery as [Recovery],
		temp.acupuncture as Acupuncture,
		temp.physicians_payable as [Physician's Fee],
		temp.readers_fee as [Reader's Fee],
		temp.category
FROM
(
	SELECT avs.invoice_no,
		   avs.invoice_date,
		   avs.visit_type,
		   avs.visit_code,
		   hn,
		   avs.patient_name,
		   ISNULL(avs.policy_name,'SELF PAY') as policy_name,
		   case when avs.visit_type_rcd = 'V28' then avs.brachytheraphy + avs.radiation_therapy else avs.brachytheraphy end as brachytheraphy,
		   avs.breast_clinic,
		   avs.center_for_women,
		   avs.ct_scan,
		   case when avs.visit_type_rcd = 'V28' then 0 ELSE avs.radiation_therapy end as radiation_therapy,
		   avs.radiology_diagnostic,
		   avs.emg,
		   avs.heart_station,
		   avs.lab_clinical + avs.lab_pathology as laboratory,
		   avs.med_equip_charges,
		   avs.msu,
		   avs.nuclear_medicine,
		   avs.pharmacy,
		   avs.simply_women,
		   avs.support_and_hcu,
		   avs.ultrasound,
		   avs.audiology,
		   avs.bed_charges,
		   avs.chemo_infusion,
		   avs.emergency_room,
		   avs.eye_center,
		   avs.food_others + avs.food_service as food,
		   avs.genesis_dr,
		   avs.intensive_monitoring_fee,
		   avs.lab_blood_bank,
		   avs.mri,
		   avs.nursing_service,
		   avs.nutrition_counselling,
		   avs.or_gi_endoscopy,
		   avs.other_revenue,
		   avs.pain_management,
		   avs.perioperative_services,
		   avs.pysiotheraphy,
		   avs.pulmonary_respiratory_theraphy,
		   avs.recovery,
		   avs.acupuncture,
		   avs.physicians_payable,
		   avs.readers_fee,
		  isnull((SELECT description
					from AmalgaPROD.dbo.patient_visit_diagnosis_view a INNER JOIN AmalgaPROD.dbo.patient_visit_nl_view b on a.patient_visit_id = b.patient_visit_id
														inner JOIN AmalgaPROD.dbo.coding_system_element_description_nl_view c on a.coding_system_rcd = c.coding_system_rcd
					where c.code = a.code
						and a.patient_visit_id = avs.patient_visit_id
						and a.current_visit_diagnosis_flag = 1),'') as diagnosis,
		  'From ACI' as category,
		  avs.patient_visit_id
	from HISReport.dbo.rpt_aci_visit_summary avs
	where MONTH(avs.invoice_date) >= @iMonth and MONTH(avs.invoice_date) <= @iMonth2
		and YEAR(avs.invoice_date) = @iYear
	UNION ALL
	SELECT avs.invoice_no,
		   avs.invoice_date,
		   avs.visit_type,
		   avs.visit_code,
		   hn,
		   avs.patient_name,
		   ISNULL(avs.policy_name,'SELF PAY') as policy_name,
		   case when avs.visit_type_rcd = 'V28' then avs.brachytheraphy + avs.radiation_therapy else avs.brachytheraphy end as brachytheraphy,
		   avs.breast_clinic,
		   avs.center_for_women,
		   avs.ct_scan,
		   case when avs.visit_type_rcd = 'V28' then 0 ELSE avs.radiation_therapy end as radiation_therapy,
		   avs.radiology_diagnostic,
		   avs.emg,
		   avs.heart_station,
		   avs.lab_clinical + avs.lab_pathology as laboratory,
		   avs.med_equip_charges,
		   avs.msu,
		   avs.nuclear_medicine,
		   avs.pharmacy,
		   avs.simply_women,
		   avs.support_and_hcu,
		   avs.ultrasound,
		   avs.audiology,
		   avs.bed_charges,
		   avs.chemo_infusion,
		   avs.emergency_room,
		   avs.eye_center,
		   avs.food_others + avs.food_service as food,
		   avs.genesis_dr,
		   avs.intensive_monitoring_fee,
		   avs.lab_blood_bank,
		   avs.mri,
		   avs.nursing_service,
		   avs.nutrition_counselling,
		   avs.or_gi_endoscopy,
		   avs.other_revenue,
		   avs.pain_management,
		   avs.perioperative_services,
		   avs.pysiotheraphy,
		   avs.pulmonary_respiratory_theraphy,
		   avs.recovery,
		   avs.acupuncture,
		   avs.physicians_payable,
		   avs.readers_fee,
		  isnull((SELECT description
					from AmalgaPROD.dbo.patient_visit_diagnosis_view a INNER JOIN AmalgaPROD.dbo.patient_visit_nl_view b on a.patient_visit_id = b.patient_visit_id
														inner JOIN AmalgaPROD.dbo.coding_system_element_description_nl_view c on a.coding_system_rcd = c.coding_system_rcd
					where c.code = a.code
						and a.patient_visit_id = avs.patient_visit_id
						and a.current_visit_diagnosis_flag = 1),'') as diagnosis,
		  'After ACI' as category,
		  avs.patient_visit_id
	from HISReport.dbo.rpt_after_aci_visit_summary avs
	where MONTH(avs.invoice_date) >= @iMonth and MONTH(avs.invoice_date) <= @iMonth2
		and YEAR(avs.invoice_date) = @iYear
		 and hn in (select hn
				   from HISReport.dbo.rpt_aci_visit_summary
				   where HISReport.dbo.rpt_aci_visit_summary.invoice_date <= avs.invoice_date)
) as temp
order by temp.patient_name,
	     temp.invoice_date
