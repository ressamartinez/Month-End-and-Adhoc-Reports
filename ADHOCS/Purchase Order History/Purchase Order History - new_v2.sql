

SELECT       
            purchase_order_request.gl_account_code
            ,purchase_order_request.gl_account
			,purchase_order_request.vendor_item_code as [Item Code]
			,purchase_order_request.vendor_item_name_l as [Item Description]
			,purchase_order_request.vendor_name as [Vendor Name]
			,purchase_order_request.costcentre as [Costcentre]
			,purchase_order_request.item_group as [Item Group/Material Group]
			,purchase_order_request.item_type as [Item Type/Material Type]
			,purchase_order_request.uom_rcd as [Base Unit of Measure]
			,purchase_order_request.uom2 as [Order Unit of Measure]
			,purchase_order_request.pr_no as [Purchase Requisition (PR No.)]
			,purchase_order_request.po_no as [Purchase Order (PO No.)]
			,purchase_order_request.po_date as [PO Date]
			,purchase_order_request.received_no as [Received No. (GR No.)]
			,purchase_order_request.received_on_date as [GR Date (Received on Date)]
			,purchase_order_request.vendor_invoice_no as [Invoice Receipt (IR No.)]
			,purchase_order_request.vendor_invoice_date as [IR Date (Vendor Invoice Date)]
			,purchase_order_request.ordered_qty as [Ordered Qty]			
			,purchase_order_request.unit_price as [Unit Price]
			,purchase_order_request.unit_price as [VAT Ex]
			,purchase_order_request.unit_price * 1.12 as [VAT Inc]
			,purchase_order_request.unit_price * purchase_order_request.ordered_qty as [Total Amount (VAT Ex)]
            ,(purchase_order_request.unit_price * 1.12) * purchase_order_request.ordered_qty as [Total Amount (VAT Inc)]
			,purchase_order_request.ipd as [Selling Price per Piece - In Patient (Vat Ex)]
			,purchase_order_request.ipd * 1.12 as [Selling Price per Piece - In Patient (Vat Inc)]
            ,purchase_order_request.opd as [Selling Price per Piece - Out Patient (Vat Ex)]
            ,purchase_order_request.opd * 1.12 as [Selling Price per Piece - Out Patient (Vat Inc)]
			--,purchase_order_request.pending_qty as [Pending Qty]
			--,purchase_order_request.net_amount as [Net Amount]
			--,purchase_order_request.pr_date as [PR Date]
			--,purchase_order_request.item_group_code as [Item Group Code]

			FROM (SELECT
						v.vendor_code,
						vendor_name = (CASE WHEN v.person_id IS NOT NULL THEN 
																(SELECT display_name_l FROM person_formatted_name_view WHERE person_id = v.person_id)
													ELSE (SELECT name_l FROM organisation WHERE organisation_id = v.organisation_id)END),
						SPO.transaction_text as po_no,
						costcentre_code = (SELECT costcentre_code 
															FROM costcentre 
															WHERE costcentre_id = SPRD.costcentre_id),
						costcentre = (SELECT name_l 
													FROM costcentre 
													WHERE costcentre_id = SPRD.costcentre_id),
					    gl_account_code = (SELECT gl_acct_code_code 
																FROM gl_acct_code
																WHERE gl_acct_code_id = SPD.gl_acct_code_debit_id),
					   gl_account = (SELECT name_l 
												FROM gl_acct_code 
												WHERE gl_acct_code_id = SPD.gl_acct_code_debit_id),
					  SVI.vendor_item_code,
					  SVI.vendor_item_name_l,
					  SPOD.uom_rcd,
					  SPOD.ordered_qty,
					  SPOD.pending_qty,
					  SPOD.unit_price,
					  SPOD.discount_amount,
					  gross_amount = SPOD.gross_amount,
					  SPOD.tax_amount,
					  net_amount = SPOD.gross_amount - SPOD.tax_amount,
					  SPO.ordered_on_date,
					  SPOD.promised_on_date,
					  purchase_status = (SELECT name_l 
															FROM swe_purchase_status_ref_nl_view 
															WHERE swe_purchase_status_rcd = SPO.swe_purchase_status_rcd),
					  purchase_order_status = (SELECT name_l
																		FROM swe_purchase_status_ref_nl_view
																		WHERE swe_purchase_status_rcd = SPOD.swe_purchase_status_rcd),
					  created_by_employee = (SELECT display_name_l
																	FROM person_formatted_name_iview_nl_view
																	WHERE person_id = SPO.created_by_employee_id),
					  SPO.created_on_date as po_date,
					  SPO.number_of_items,
					  SPOD.purchase_order_detail_id,
					  SPO.purchase_order_id,
					  SPR.transaction_text as received_no,
					  SPR.received_on_date,
					  SPR.vendor_invoice_no,
					  SPR.vendor_invoice_date,
					  SPQ.transaction_text as pr_no,
					  SPRD.purchase_request_id,
					  SPRD.created_on_date_time as pr_date,
					  MONTH(created_on_date) as monthid
					  ,i.item_group_id
					  ,ig.name_l as item_group
					  ,ig.item_group_code
					  ,ig.item_type_rcd
					  ,itr.name_l as item_type
					  ,sviu.uom_rcd as uom2
					  ,ipd = (Select price from item_price where item_id = i.item_id 
					                                             and charge_type_rcd = 'IPD'
																 and effective_to_date_time is null)
					  ,opd = (Select price from item_price where item_id = i.item_id 
					                                             and charge_type_rcd = 'OPD'
																 and effective_to_date_time is null)
					  ,SPD.purchase_receive_detail_id
					  ,SPD.ap_invoice_detail_id
					  ,SPRD.purchase_request_detail_id

	FROM swe_purchase_order SPO 
								INNER JOIN swe_purchase_order_detail SPOD ON SPO.purchase_order_id = SPOD.purchase_order_id
								LEFT JOIN swe_purchase_request_detail SPRD ON SPOD.purchase_order_detail_id = SPRD.purchase_order_detail_id
								LEFT JOIN swe_vendor_item SVI ON SVI.vendor_item_id = SPOD.vendor_item_id
								LEFT JOIN swe_vendor_item_uom SVIU on SVI.vendor_item_id = SVIU.vendor_item_id
								INNER JOIN vendor v	ON v.vendor_id = spo.vendor_id
								LEFT OUTER JOIN swe_purchase_receive_detail SPD on SPOD.purchase_order_detail_id = SPD.purchase_order_detail_id
								LEFT OUTER JOIN swe_purchase_receive SPR on SPD.purchase_receive_id = SPR.purchase_receive_id
								LEFT OUTER JOIN swe_purchase_request SPQ on SPRD.purchase_request_id = SPQ.purchase_request_id
								LEFT OUTER JOIN item i ON SVI.item_id = i.item_id
								LEFT OUTER JOIN item_group ig ON i.item_group_id = ig.item_group_id
								LEFT OUTER JOIN item_type_ref itr ON ig.item_type_rcd = itr.item_type_rcd

	WHERE ((MONTH(created_on_date) BETWEEN 1 AND 5) AND YEAR(created_on_date) = 2020)		
	--AND SPO.swe_purchase_site_id = '2198E881-0E1D-11DA-A79E-001143B8816C' )AS purchase_order_request --For Pharmacy Purchasing
	--AND SPO.swe_purchase_site_id = '31488C46-FDB0-11D9-A79B-001143B8816C'  --For Central Purchasing
	--and i.item_code = 'OPP-0700001'
	)AS purchase_order_request 

where purchase_order_request.gl_account_code = '1160200'

GROUP BY	vendor_code,
			vendor_name,
			purchase_order_request.po_no,
			costcentre_code,
			costcentre,
			gl_account_code,
			gl_account,
			vendor_item_code,
			vendor_item_name_l,
			uom_rcd,
			ordered_qty,
			pending_qty,
			unit_price,
			discount_amount,
			net_amount,
			tax_amount,
			gross_amount,
			ordered_on_date,
			promised_on_date,
			purchase_status,
			purchase_order_status,
			created_by_employee,
			purchase_order_request.po_date,
			number_of_items,
			purchase_order_detail_id,
			purchase_order_request.purchase_order_id,
			purchase_order_request.received_no,
			purchase_order_request.received_on_date,
			purchase_order_request.vendor_invoice_no,
			purchase_order_request.vendor_invoice_date,
			purchase_order_request.pr_no,
			purchase_order_request.purchase_request_id,
			purchase_order_request.pr_date,
			purchase_order_request.monthid
			,purchase_order_request.item_group_id
			,purchase_order_request.item_group 
			,purchase_order_request.item_group_code
			,purchase_order_request.item_type_rcd
			,purchase_order_request.item_type
			,purchase_order_request.uom2
			,purchase_order_request.ipd
			,purchase_order_request.opd
			,purchase_order_request.purchase_receive_detail_id
			,purchase_order_request.purchase_request_detail_id
			,purchase_order_request.ap_invoice_detail_id


ORDER BY [Item Code], [PO Date]