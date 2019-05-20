
SELECT 
		CUST1.customer_name [PAYERS NAME]
		,CD.actual_visit_date_time [VISIT START]
		,CD.closure_date_time [VISIT CLOSE]
		,CD.visit_type [VISIT TYPE]
		,(SELECT visible_patient_id FROM patient_info_view WHERE CD.patient_id = person_id)[HN]
		,(SELECT display_name_l FROM person_formatted_name_iview_nl_view WHERE person_id =CD.patient_id) [PATIENT NAME]
		,AI1.transaction_text  [INVOICE NR]
		,AI1.net_amount [INVOICE AMOUNT]
		,AI1.transaction_date_time [INVOICE DATE]
		,AI1.write_off_amount [WRITE OFF AMOUNT]
		,(AI1.net_amount - AI1.write_off_amount - AI1.owing_amount)[AMOUNT PAID]
		,((AI1.net_amount - AI1.write_off_amount)-(AI1.net_amount - AI1.write_off_amount - AI1.owing_amount)) [BALANCE AMOUNT]
		,STUFF((SELECT ','+ document_number AS[RECEIPTNR] FROM remittance WHERE remittance_id IN (SELECT SAI.remittance_id FROM swe_ar_instalment SAI WHERE SAI.ar_invoice_id = AI1.ar_invoice_id)FOR XML PATH(''),TYPE).value('.','NVARCHAR(MAX)'),1,1,'')[RECEIPT NR]
		,SPSR.name_l [PAYMENT STATUS]
		,diagnosis = (SELECT diagnosis2 FROM HISViews.dbo.GEN_vw_patient_diagnosis WHERE patient_visit_id = CD.patient_visit_id AND diagnosis_type_rcd = 'DIS' AND primary_flag = 1)
	
FROM
      ar_invoice AI1
      INNER JOIN ar_invoice_detail AID ON AI1.ar_invoice_id=AID.ar_invoice_id
      INNER JOIN swe_payment_status_ref SPSR ON AI1.swe_payment_status_rcd = SPSR.swe_payment_status_rcd
      LEFT JOIN (
            SELECT      CD.charge_detail_id
                        ,PV.patient_id
                        ,PV.actual_visit_date_time
                        ,PV.closure_date_time,VTR.name_l AS visit_type
                        ,PV.charge_type_rcd
                        ,PV.patient_visit_id
            FROM  charge_detail CD
                        LEFT JOIN patient_visit PV ON CD.patient_visit_id = PV.patient_visit_id
                INNER JOIN visit_type_ref VTR ON PV.visit_type_rcd = VTR.visit_type_rcd
            ) CD ON AID.charge_detail_id = CD.charge_detail_id
      INNER JOIN (            
        SELECT    C.customer_id
                        ,(CASE WHEN organisation_id IS NOT NULL 
                        THEN (SELECT name_l FROM organisation WHERE organisation_id = C.organisation_id) 
                ELSE (SELECT display_name_l FROM person_formatted_name_iview_nl_view  WHERE person_id = C.person_id)
                END) [customer_name]
            FROM  customer C
            ) CUST1 ON AI1.customer_id = CUST1.customer_id
      LEFT JOIN(
            SELECT      AI2.transaction_text, CUST2.customer_name, AI2.ar_invoice_id
            FROM  ar_invoice AI2
                        INNER JOIN (
                              SELECT      C.customer_id
                                          ,(CASE WHEN organisation_id IS NOT NULL 
                                            THEN (SELECT name_l FROM organisation WHERE organisation_id = C.organisation_id) 
                                            ELSE (SELECT display_name_l FROM person_formatted_name_iview_nl_view  WHERE person_id = C.person_id)
                                            END) [customer_name]
                              FROM customer C
                              ) CUST2 ON AI2.customer_id = CUST2.customer_id
        ) NR ON AI1.related_ar_invoice_id = NR.ar_invoice_id
        
		INNER JOIN policy POL ON AI1.policy_id = POL.policy_id
		
WHERE
	--	AI1.transaction_date_time BETWEEN '2013-02-01' AND '2013-02-02 23:59:59.998'
		--month(transaction_date_time) >= @From and month(transaction_date_time) <= @To
		----and YEAR(transaction_date_time) = @Year
		CAST(CONVERT(VARCHAR(10),transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
		and CAST(CONVERT(VARCHAR(10),transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)

		--CAST(CONVERT(VARCHAR(10),transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2011',101) as SMALLDATETIME)
		--and CAST(CONVERT(VARCHAR(10),transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2014',101) as SMALLDATETIME)
		
		AND POL.name_e LIKE '%PHILHEALTH%'
		--AND POL.name_e <> 'PHILHEALTH CARE, INC. (formerly Philamcare)'
		AND POL.short_code in ('91','92','93','94','95','96','642','685')
		AND AI1.transaction_status_rcd<>'VOI'
		AND SPSR.swe_payment_status_rcd in ('UNP', 'PART')

GROUP BY
		CUST1.customer_name
		,CD.actual_visit_date_time
		,CD.closure_date_time
		,CD.visit_type
		,CD.patient_id
		,CD.patient_visit_id
		,AI1.transaction_text 
		,AI1.transaction_date_time 
		,AI1.net_amount
		,AI1.write_off_amount
		,AI1.owing_amount
		,AI1.ar_invoice_id
		,SPSR.name_l
		,NR.transaction_text
		,NR.customer_name
ORDER BY 
		[INVOICE DATE], [PATIENT NAME]