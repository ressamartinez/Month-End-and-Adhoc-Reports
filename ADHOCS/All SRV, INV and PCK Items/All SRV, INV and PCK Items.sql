

SELECT *
	   ,[Transaction Text] = rtrim(temp.[Transaction Date Month Name]) + '-' + rtrim(temp.[Transaction Type])

FROM
(
	select rdsa.upi as HN
		   ,rdsa.patient_name as [Patient Name]
		   ,rdsa.admission_type as [Admission Type]
		   ,rdsa.admission_type_after_move as [Admission Type After Move]
		   ,rdsa.admitting_doctor as [Admitting Doctor]
		   ,rdsa.bed as Bed
		   ,rdsa.order_owner as [Order Owner]
		   ,rdsa.order_owner_specialty as [Order Owner Specialty]
		   ,rdsa.order_owner_sub_specialty as [Order Owner Subspecialty]
		   ,rdsa.item_group_code as [Itemgroup Code]
		   ,rdsa.item_group_name as [Itemgroup Name]
		   ,rdsa.item_code as [Item Code]
		   ,rdsa.item_desc as [Item Description]
		   ,rdsa.item_type_rcd as [Item Type Code]
		   ,rdsa.item_type_name as [Item Type Name]
		   ,rdsa.visit_type_rcd as [Visit Type Code]
		   ,rdsa.visit_type_rcd_after_move as [Visit Type Code After Move]
		   ,[Visit Type Category] = (case when rdsa.visit_type_rcd = 'V4' then 'ER' else 'NON-ER' end)
		   ,[Visit Type Code Category After Move] = (case when rdsa.visit_type_rcd = 'V4' AND rdsa.visit_type_rcd_after_move = 'V1' then 'TO IPD' else 'NOT TO IPD' end)
		   ,rdsa.qty as Qty
		   ,rdsa.total_amount as [Total Amount]
		   ,rdsa.service_requestor as [Service Requestor]
		   ,rdsa.service_provider as [Service Provider]
		   ,rdsa.service_category as [Service Category]
		   ,rdsa.gl_acct_code_code as [GL Account Code]
		   ,rdsa.gl_acct_name as [GL Account Name]
		   ,rdsa.transaction_date_time as [Transaction Date]
		   --,CONVERT(VARCHAR(20),rdsa.transaction_date_time,101) as transaction_date
		   --,FORMAT(rdsa.transaction_date_time,'hh:mm tt') as transaction_time
		   ,day(rdsa.transaction_date_time) as [Transaction Date Day]
		   ,month(rdsa.transaction_date_time) as [Transaction Date Month]
		   ,DATENAME(month,rdsa.transaction_date_time) as [Transaction Date Month Name]
		   ,year(rdsa.transaction_date_time) as [Transaction Year]
		   ,rdsa.transaction_type as [Transaction Type]
		   ,rdsa.transaction_by as [Transaction By]
		   ,[Current Diagnosis] = (SELECT top 1 csed.description 
										FROM AMALGAPROD.dbo.patient_visit_diagnosis_view pv left outer join AMALGAPROD.dbo.coding_system_element_description csed on pv.code = csed.code 
										WHERE patient_visit_id = rdsa.patient_visit_id AND current_visit_diagnosis_flag = 1 
										ORDER BY recorded_at_date_time DESC)
		   ,[Admitting Diagnosis] = (SELECT top 1 csed.description 
										FROM AMALGAPROD.dbo.patient_visit_diagnosis_view pv left outer join AMALGAPROD.dbo.coding_system_element_description csed on pv.code = csed.code
										WHERE patient_visit_id = rdsa.patient_visit_id AND diagnosis_type_rcd = 'ADM' 
										ORDER BY recorded_at_date_time DESC)
		   ,[Discharge Diagnosis] = (SELECT top 1 csed.description 
										FROM AMALGAPROD.dbo.patient_visit_diagnosis_view pv left outer join AMALGAPROD.dbo.coding_system_element_description csed on pv.code = csed.code
										WHERE patient_visit_id = rdsa.patient_visit_id AND diagnosis_type_rcd = 'DIS' 
										ORDER BY recorded_at_date_time DESC)


	from rpt_daily_statistics_all rdsa

) as temp
where --temp.transaction_date_month = 1
      temp.[Transaction Date] between '07/01/2019 00:00:00.000'  and '07/15/2019 23:59:59.998'
      --and temp.transaction_year = 2018
	  and temp.[Item Type Code] = 'SRV'

order by temp.[Transaction Date], temp.[Itemgroup Name], temp.[Item Description], temp.[Transaction Type]


