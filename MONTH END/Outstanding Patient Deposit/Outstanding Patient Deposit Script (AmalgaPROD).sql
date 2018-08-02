	--AmalgaProd

	DECLARE @startdate DATETIME
	DECLARE @enddate DATETIME

	SET @startdate = (SELECT start_date FROM AmalgaPROD.dbo.period_nl_view WHERE period_code = '2005PRD12')
	SET @enddate = (SELECT end_date FROM AmalgaPROD.dbo.period_nl_view WHERE period_code = '2018PRD5')


	----Drops temporary tables
	--DROP TABLE temp_outstanding_deposit_pd
	--DROP TABLE temp_outstanding_deposit_rpdr
	--DROP TABLE temp_outstanding_deposit_total 

	--Table Variables
	DECLARE @temp_outstanding_deposit_pd TABLE
	(
		transaction_nr	NVARCHAR(150)
		,amount			MONEY
	)

	DECLARE @temp_outstanding_deposit_rpdr TABLE
	(
		transaction_nr	NVARCHAR(150)
		,user_transaction_type_id NVARCHAR (150)
		,amount			MONEY
		,used_deposit_transaction_nr NVARCHAR(150)
		,effective_date DATE
	)

	DECLARE @temp_outstanding_deposit_total TABLE
	(
		transaction_nr		NVARCHAR(150)
		,amount				MONEY
		,total_rem_refund	MONEY
		,total				MONEY
	)



	--Inserts patient deposits to temporary table(NEW)
	INSERT INTO @temp_outstanding_deposit_pd(transaction_nr,amount)
			SELECT
				REM.transaction_text
				,REM.received_amount
			FROM
				remittance_nl_view REM
				INNER JOIN customer_nl_view CUST ON REM.customer_id = CUST.customer_id
			WHERE
				system_transaction_type_rcd IN ('PDEP')
				AND effective_date BETWEEN @startdate AND @enddate


		
	INSERT INTO @temp_outstanding_deposit_rpdr
			SELECT
				REM.transaction_text
				,REM.user_transaction_type_id
				,PDEPPAY.used_amount * -1
				,used_deposit_transaction_nr =
				(
				SELECT 
						transaction_text
				FROM
						remittance_nl_view
				WHERE 
						remittance_id = ( SELECT remittance_id  FROM ar_payment_nl_view  WHERE ar_payment_id = PDEPPAY.deposit_ar_payment_id)	  
				)
				,REM.effective_date
				 
			FROM
				patient_deposit_payment_usage_nl_view PDEPPAY
				INNER JOIN ar_payment_nl_view AR ON PDEPPAY.used_ar_payment_id = AR.ar_payment_id
				INNER JOIN remittance_nl_view REM ON AR.remittance_id = REM.remittance_id
			
	WHERE
			--REM.effective_date BETWEEN '2014-02-01 00:00:00.000' AND '2014-02-28 23:59:59.998'
			REM.effective_date BETWEEN @startdate AND @enddate
			AND REM.user_transaction_type_id IN 
			(
			SELECT
				user_transaction_type_id 
			FROM 
				user_transaction_type_nl_view 
			WHERE 
				user_transaction_type_code IN ('PRMT','PDEP','PDRF','RCBC')
			)
	



	INSERT INTO @temp_outstanding_deposit_total
		SELECT
			TODPD.transaction_nr
			,TODPD.amount
			,total_rem_refund = (SELECT CASE WHEN SUM(amount) IS NULL THEN 0 ELSE sum(amount) END FROM @temp_outstanding_deposit_rpdr WHERE used_deposit_transaction_nr = TODPD.transaction_nr GROUP BY used_deposit_transaction_nr)							
			,total = TODPD.amount +	(SELECT CASE WHEN SUM(amount) IS NULL THEN 0 ELSE sum(amount) END FROM @temp_outstanding_deposit_rpdr WHERE used_deposit_transaction_nr = TODPD.transaction_nr GROUP BY used_deposit_transaction_nr)
		FROM
			@temp_outstanding_deposit_pd TODPD
		
		UNION ALL
		
		SELECT
			used_deposit_transaction_nr
			,amount
			,total_rem_fund = NULL
			,total = NULL
		FROM
			@temp_outstanding_deposit_rpdr TODR	
		WHERE
			transaction_nr IN (SELECT 
									transaction_nr 
								FROM 
									@temp_outstanding_deposit_rpdr 
								WHERE 
									user_transaction_type_id = (SELECT user_transaction_type_id FROM user_transaction_type_nl_view WHERE user_transaction_type_code = 'RCBC')
								)
		AND effective_date BETWEEN @startdate AND @enddate

	--Patient Deposit
	SELECT
		hn = (SELECT visible_patient_id FROM patient_hospital_usage_nl_view WHERE patient_id = CUST.person_id)
		,patient_name = (SELECT display_name_l FROM person_formatted_name_iview WHERE person_id = CUST.person_id)
		,transaction_nr = REM.transaction_text
		,effective_date = REM.effective_date
		,visit_type = NULL
		,amount = (REM.received_amount)
		,deposit_type = (SELECT name_l FROM system_transaction_type_ref_nl_view WHERE system_transaction_type_rcd = REM.system_transaction_type_rcd)
		,used_deposit_transaction_nr = NULL
		,discharge_date = NULL
	FROM
		remittance_nl_view REM
		INNER JOIN
		customer_nl_view CUST ON REM.customer_id = CUST.customer_id
	WHERE
		system_transaction_type_rcd IN ('PDEP')
		AND effective_date BETWEEN @startdate AND @enddate
		AND REM.transaction_text IN (SELECT transaction_nr FROM @temp_outstanding_deposit_total WHERE total > 0 OR total IS NULL)


	UNION ALL

	--Remittance and Patient Deposit Refund and rcbc
	SELECT
					hn=	CASE	WHEN REM.system_transaction_type_rcd IN ('PDEPR') OR REM.user_transaction_type_id = (SELECT user_transaction_type_id FROM user_transaction_type_nl_view WHERE user_transaction_type_code = 'RCBC')
								THEN(SELECT visible_patient_id FROM patient_hospital_usage_nl_view WHERE patient_id =(SELECT person_id FROM customer_nl_view WHERE customer_id = REM.customer_id))
								ELSE(SELECT visible_patient_id FROM patient_hospital_usage_nl_view WHERE patient_id =(SELECT patient_id  FROM patient_visit_nl_view WHERE patient_visit_id = (SELECT DISTINCT patient_visit_id FROM swe_cashier_transaction_nl_view WHERE receipt_id = AR.remittance_id AND cashier_shift_id = AR.cashier_shift_id)))
								END
		,patient_name = CASE	WHEN REM.system_transaction_type_rcd IN ('PDEPR') OR REM.user_transaction_type_id = (SELECT user_transaction_type_id FROM user_transaction_type_nl_view WHERE user_transaction_type_code = 'RCBC')
								THEN(SELECT display_name_l FROM person_formatted_name_iview_nl_view WHERE person_id =(SELECT person_id FROM customer_nl_view WHERE customer_id = REM.customer_id)) 	
								ELSE(SELECT display_name_l FROM person_formatted_name_iview_nl_view WHERE person_id =(SELECT patient_id FROM patient_visit_nl_view WHERE patient_visit_id = (SELECT DISTINCT patient_visit_id FROM swe_cashier_transaction_nl_view WHERE receipt_id = AR.remittance_id AND cashier_shift_id = AR.cashier_shift_id)))
								END
		,transaction_nr = CASE	WHEN REM.transaction_status_rcd = 'VOI' 
								THEN REM.transaction_text + ' (Voided)' 
								ELSE REM.transaction_text 	
								END	 
		,effective_date =		REM.effective_date
		,visit_type =	CASE	WHEN REM.system_transaction_type_rcd =  'PDEPR' 
								THEN NULL 
								ELSE (SELECT visit_type_rcd FROM patient_visit_nl_view WHERE patient_visit_id = (SELECT DISTINCT patient_visit_id FROM swe_cashier_transaction_nl_view WHERE receipt_id = AR.remittance_id AND cashier_shift_id = AR.cashier_shift_id))
								END
		,amount = (PDEPPAY.used_amount * -1)
		,deposit_type = CASE	WHEN REM.system_transaction_type_rcd =  'PDEPR' 	
								THEN (SELECT name_l FROM system_transaction_type_ref_nl_view WHERE system_transaction_type_rcd = REM.system_transaction_type_rcd) ELSE 'Patient Deposit'
								END
		,used_deposit_transaction_nr = (SELECT transaction_text FROM remittance_nl_view WHERE remittance_id = (SELECT remittance_id FROM ar_payment_nl_view WHERE ar_payment_id = PDEPPAY.deposit_ar_payment_id))
		,discharge_date = CASE  WHEN REM.system_transaction_type_rcd =  'PDEPR' 
									THEN NULL 
								ELSE(SELECT closure_date_time FROM patient_visit_nl_view WHERE patient_visit_id = (SELECT DISTINCT patient_visit_id FROM swe_cashier_transaction_nl_view WHERE receipt_id = AR.remittance_id AND cashier_shift_id = AR.cashier_shift_id))
								END
						  
						  
	FROM
		patient_deposit_payment_usage_nl_view PDEPPAY
		INNER JOIN ar_payment_nl_view AR ON PDEPPAY.used_ar_payment_id = AR.ar_payment_id
		INNER JOIN remittance_nl_view REM ON AR.remittance_id = REM.remittance_id
	WHERE
		REM.effective_date BETWEEN @startdate AND @enddate
		AND REM.user_transaction_type_id IN (SELECT user_transaction_type_id FROM user_transaction_type_nl_view WHERE user_transaction_type_code IN ('PRMT','PDEP','PDRF','RCBC'))
		AND REM.transaction_text IN (SELECT	transaction_nr FROM	@temp_outstanding_deposit_rpdr WHERE	used_deposit_transaction_nr IN (SELECT transaction_nr FROM @temp_outstanding_deposit_total WHERE	total > 0 OR total IS NULL))
		AND(SELECT transaction_text FROM remittance_nl_view WHERE remittance_id = (SELECT	remittance_id FROM	ar_payment_nl_view WHERE	ar_payment_id = PDEPPAY.deposit_ar_payment_id)) IN(SELECT transaction_nr FROM	@temp_outstanding_deposit_total WHERE	total > 0 OR total IS NULL)																																														 																																													 
	ORDER BY
		hn

