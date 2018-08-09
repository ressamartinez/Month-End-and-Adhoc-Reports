--Purchase Receive (OrionSnapshot2minutes)

SELECT temp.transaction_no as [Transaction No.]
			,temp.received_on_date as [Received On DateTime]
			,CONVERT(VARCHAR(20), temp.received_on_date,101) as [Received On Date]
			,FORMAT(temp.received_on_date,'hh:mm tt') AS [Received On Time]
			,temp.po_no as [PO Number]
			,temp.po_date as [PO Date]
			,temp.purchase_status as [Purchase Status]
			,temp.purchase_order_status as [Purchase Order Status]
			,temp.vendor_code as [Vendor Code]
			,temp.vendor_name as [Vendor Name]
			,temp.vendor_invoice_no as [Vendor Invoice No.]
			,temp.vendor_invoice_date as [Vendor Invoice Date]
			,temp.vendor_delivery_note_no as [Vendor Delivery Note No.]
			,temp.uom_rcd as [UOM]
			,temp.ordered_qty as [Ordered Qty]
		    ,temp.unit_price as [Unit Price]
		    ,temp.discount_amount as [Discount Amount]
		    ,temp.gross_amount as [Gross Amount]
			,temp.tax_amount as [Tax Amount]
			,temp.net_amount as [Net Amount]
			,temp.created_by_employee as [Created By Employee]
			,temp.ordered_on_date as [Ordered On Date]
		    ,temp.promised_on_date as [Promised On Date]
			,temp.costcentre_code as [Costcentre Code]
			,temp.costcentre as [Costcentre]
			,temp.gl_account_code as [GL Account Code]
			,temp.gl_account as [GL Account]

FROM
(

					select DISTINCT spr.transaction_text as transaction_no
								,spr.received_on_date
								,spo.transaction_text as po_no
								,spo.created_on_date as po_date
								,purchase_status = (SELECT
														name_l
												FROM swe_purchase_status_ref_nl_view
												WHERE swe_purchase_status_rcd = SPO.swe_purchase_status_rcd)
							  ,purchase_order_status = (SELECT
															name_l
														FROM swe_purchase_status_ref_nl_view
														WHERE swe_purchase_status_rcd = SPOD.swe_purchase_status_rcd)
								,v.vendor_code
								,vendor_name = (CASE
													WHEN v.person_id IS NOT NULL THEN (SELECT
																							display_name_l
																						FROM person_formatted_name_view
																						WHERE person_id = v.person_id) 
												ELSE (SELECT
															name_l
													  FROM organisation
													  WHERE organisation_id = v.organisation_id)
												END)
								,spr.vendor_invoice_no
								,spr.vendor_invoice_date
								,spr.vendor_delivery_note_no
								,spod.uom_rcd
								,spod.ordered_qty
								,spod.unit_price
								,spod.discount_amount
								,spod.gross_amount
								,spod.tax_amount
								,net_amount = spod.gross_amount - spod.tax_amount
								,created_by_employee = (SELECT
														display_name_l
													FROM person_formatted_name_iview_nl_view
													WHERE person_id = SPO.created_by_employee_id)
		   
								,spo.ordered_on_date
								,spod.promised_on_date
								,costcentre_code = (SELECT
														costcentre_code
												   FROM costcentre
												  WHERE costcentre_id = sprd2.costcentre_id)
							   ,costcentre = (SELECT
													name_l
											 FROM costcentre
											 WHERE costcentre_id = sprd2.costcentre_id)
							  ,gl_account_code = (SELECT
														 gl_acct_code_code
												  FROM gl_acct_code
												  WHERE gl_acct_code_id = sprd2.gl_acct_code_id)
							  ,gl_account = (SELECT
												   name_l
											FROM gl_acct_code
											WHERE gl_acct_code_id = sprd2.gl_acct_code_id)

					 FROM swe_purchase_receive spr
								LEFT OUTER JOIN swe_purchase_receive_detail sprd ON spr.purchase_receive_id = sprd.purchase_receive_id
								LEFT OUTER JOIN swe_purchase_order_detail spod ON sprd.purchase_order_detail_id = spod.purchase_order_detail_id
								LEFT OUTER JOIN swe_purchase_order spo ON spod.purchase_order_id = spo.purchase_order_id
								LEFT OUTER JOIN swe_purchase_request_detail sprd2 ON spod.purchase_order_detail_id = sprd2.purchase_order_detail_id
								LEFT OUTER JOIN swe_purchase_request spur ON sprd2.purchase_request_id =  spur.purchase_request_id
								LEFT OUTER JOIN swe_vendor_item svi ON svi.vendor_item_id = spod.vendor_item_id
								LEFT OUTER JOIN vendor v	ON v.vendor_id = spo.vendor_id
					where --MONTH(spr.received_on_date) = 7
							--and YEAR(spr.received_on_date) = 2017
							--((MONTH(spr.received_on_date) BETWEEN 07 AND 07) AND YEAR(spr.received_on_date) = 2017)
							spr.received_on_date BETWEEN '01/01/2013 00:00:00.000' and '07/31/2018 23:59:59.998'
							--spr.received_on_date BETWEEN @From and @To
							and spo.swe_purchase_site_id = '31488C46-FDB0-11D9-A79B-001143B8816C' ---Central Purchasing
							--and spr.transaction_text = 'RRC-2015-010052' 

) as temp

where temp.purchase_status <> 'void'
			AND temp.purchase_order_status <>  'void'
			-- and temp.transaction_no = 'RRC-2017-012565'
			--AND temp.vendor_invoice_no IS NULL

ORDER by temp.received_on_date


