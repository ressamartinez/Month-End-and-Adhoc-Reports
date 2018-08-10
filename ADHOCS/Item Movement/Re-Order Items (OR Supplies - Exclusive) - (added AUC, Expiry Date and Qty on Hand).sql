--FOR VALIDATION
--15924

SELECT DISTINCT
			temp.item_group as [Item Group]
			,temp.item_code as [Item Code]
			,temp.item as [Item]
			,temp.uom_rcd as [UOM]
			,temp.ordered_qty as [Ordered Qty]
			,temp.received_qty as [Received Qty]
			----,temp.created_on_date_time as [Created On Date and Time]
			,temp.ordered_on_date as [Last Purchased Date and Time]
			,temp.gross_amount as [Gross Amount]
			--,temp.discount_amount as [Discount Amount]
			--,temp.tax_amount as [Tax Amount]
			--,temp.vendor_code as [Vendor Code]
			,temp.vendor_name as [Vendor Name]
			--,temp.user_transaction_type as [User Transaction Type]
			----,temp.purchase_request_no as [PR No]
			----,temp.purchase_request_comment as [PR Comment]
			--,temp.purchase_status as [Purchase Status]
			--,temp.purchase_order_status as [Purchase Order Status]
			--,temp.po_no as [PO No]
			--,temp.internal_comment as [PO Internal Comment]
			--,temp.external_comment as [PO External Comment]
			--,temp.costcentre_code as [Costcentre Code]
			,temp.costcentre as [Costcentre]
			--,temp.gl_account_code as [GL Account Code]
			--,temp.gl_account as [GL Account Name]
			--,temp.created_by_employee as [Created By Employee]

			--,temp.purchase_receive_detail_id
			--,temp.item_movement_id
			--,temp.item_movement_type_rcd
			--,temp.date_time
			--,temp.item_type_rcd
			--,temp.sub_item_type_rcd

		--	,temp.actual_unit_price
			
			,temp.unit_price as [Actual Unit Price]
		--	,temp.unit_price_2
		--	,temp.vendor_item_unit_price
			,temp.expiry_date_time as [Expiry Date and Time]
			,temp.qty_on_hand as [Qty on Hand]

			,temp.swe_purchase_site_id
		

FROM
(
			SELECT DISTINCT	--17263
						sprd.purchase_order_detail_id
						,sprd.purchase_request_detail_id
						,sprd.purchase_request_id
						,i.item_id

						,spo.ordered_on_date
						,spo.locked_on_date
						,spo.unlocked_on_date
						,spod.promised_on_date
						,sprd.required_on_date
						,sprd.created_on_date_time
						,ig.name_l as item_group
						,i.item_code
						,i.name_l as item

						--,sprd.requested_qty
						--,sprd.distributed_qty
						--,sprd.pending_qty
						--,sprd.department_receipt_qty

						,spod.ordered_qty
						,spod.received_qty
						,spod.pending_qty

						,sprd.approved_unit_cost
						,sprd.vendor_item_unit_cost
						,sprd.user_defined_unit_cost
			
						,spod.gross_amount
						,spod.discount_amount
						,spod.tax_amount

						--,spo.gross_amount
						--,spo.discount_amount
						--,spo.tax_amount
						--,spo.book_total_cost_amount

						,i.uom_rcd
						,sprd.vendor_id
						,v.vendor_code
						,vendor_name = (CASE WHEN v.person_id IS NOT NULL THEN 
																			(SELECT
																				display_name_l
																			FROM person_formatted_name_view
																			WHERE person_id = v.person_id) 
														ELSE (SELECT
																	name_l
																	FROM organisation
																	WHERE organisation_id = v.organisation_id)
														END)
						,ut.name_l as user_transaction_type
						,spr.transaction_text as purchase_request_no
						,spr.transaction_nr as purchase_request_tran_no
						,sprd.comment as purchase_request_comment
						,sprd.swe_purchase_status_rcd
						,purchase_status = (SELECT name_l 
															FROM swe_purchase_status_ref_nl_view 
															WHERE swe_purchase_status_rcd = spo.swe_purchase_status_rcd)
						,purchase_order_status = (SELECT name_l
																		FROM swe_purchase_status_ref_nl_view
																		WHERE swe_purchase_status_rcd = spod.swe_purchase_status_rcd)
						,spo.transaction_text as po_no
						,spo.internal_comment
						,spo.external_comment

						,costcentre_code = (SELECT costcentre_code 
															FROM costcentre 
															WHERE costcentre_id = sprd.costcentre_id)
						,costcentre = (SELECT name_l 
													FROM costcentre 
													WHERE costcentre_id = sprd.costcentre_id)
					    ,gl_account_code = (SELECT gl_acct_code_code 
																FROM gl_acct_code
																WHERE gl_acct_code_id = sprd.gl_acct_code_id)
					   ,gl_account = (SELECT name_l 
												FROM gl_acct_code 
												WHERE gl_acct_code_id = sprd.gl_acct_code_id)
						,created_by_employee = (SELECT display_name_l
																	FROM person_formatted_name_iview_nl_view
																	WHERE person_id = SPO.created_by_employee_id)

						--,(SELECT item_movement_type_rcd from item_movement where source_id = 
						--		(SELECT top 1 purchase_receive_detail_id from swe_purchase_receive_detail where  purchase_order_detail_id = sprd.purchase_order_detail_id))as test

						--,(SELECT date_time from item_movement where source_id = 
						--		(select top 1 purchase_receive_detail_id from swe_purchase_receive_detail where purchase_order_detail_id = spod.purchase_order_detail_id AND item_id = i.item_id))

						--,sprd2.*

						--,sprd2.purchase_receive_detail_id
						--,im.item_movement_id
						--,im.item_movement_type_rcd
						--,im.date_time.

						,i.item_type_rcd
						,i.sub_item_type_rcd
						,spod.ap_invoice_detail_id
						,sprd2.purchase_receive_detail_id
						--,spdd.actual_unit_price

						,spod.unit_price 
						--,sprd2.unit_price as unit_price_2
						--,spod.vendor_item_unit_price
						,sprd.store_id

						,sil.expiry_date_time
						,sil.qty_on_hand

						,spo.swe_purchase_site_id


			FROM swe_purchase_request spr
						INNER JOIN swe_purchase_request_detail sprd ON spr.purchase_request_id = sprd.purchase_request_id
						INNER JOIN item i ON sprd.item_id = i.item_id
						INNER JOIN item_group ig ON i.item_group_id = ig.item_group_id
						INNER JOIN swe_purchase_order_detail spod ON sprd.purchase_order_detail_id = spod.purchase_order_detail_id
						INNER JOIN swe_purchase_order spo ON spod.purchase_order_id = spo.purchase_order_id
						INNER JOIN vendor v ON sprd.vendor_id = v.vendor_id
						INNER JOIN user_transaction_type ut ON spr.user_transaction_type_id = ut.user_transaction_type_id

						INNER JOIN swe_purchase_receive_detail sprd2 ON sprd.purchase_order_detail_id = sprd2.purchase_order_detail_id
						--LEFT OUTER JOIN item_movement im ON sprd2.purchase_receive_detail_id = im.source_id
						--INNER JOIN swe_purchase_distribute_detail spdd ON sprd.purchase_request_detail_id = spdd.purchase_request_detail_id

						LEFT OUTER JOIN store_item_lot sil ON i.item_id = sil.item_id AND sprd.store_id = sil.store_id


			where spr.user_transaction_type_id = '27054B9E-55A6-11DA-BB34-000E0C7F3ED2'		--Re-order Point Request
						--AND year(spo.ordered_on_date) = 2017
						AND sprd.swe_purchase_status_rcd NOT IN ('VOI', 'UNK')
						AND sprd.swe_purchase_request_type_rcd = 'reo'										--Re-order Point
						AND ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'	--OR Supplies - Exclusive

						AND spo.ordered_on_date BETWEEN '2000-01-01 00:00:00.000' AND '2018-06-30 23:59:59.998'

						--AND spdd.swe_purchase_status_rcd NOT IN ('VOI', 'UNK')
						
						--AND im.item_movement_type_rcd = 'ISREC'
						--AND i.item_code = '212018016'
						--AND im.item_movement_type_rcd <> 'VRECV'
						--AND year(im.date_time) = 2017
						--AND sprd2.swe_purchase_status_rcd NOT IN ('VOI', 'UNK')

			--order by spo.ordered_on_date
			
)as temp

ORDER BY temp.ordered_on_date 