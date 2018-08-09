
SELECT 
			(SELECT name_l from item_group where item_group_id = parent_ig.parent_item_group_id) as [Parent Item Group]
			,tempB.item_group as [Item Group]
			,tempB.item_code as [Item Code]
			,tempB.item as [Item]
			,tempB.uom_rcd as [UOM]
			,tempB.lot_number as [Lot Number]
			,tempB.expiry_date_time as [Expiry Date and Time]
			,tempB.costcentre as [Costcentre]
			,tempB.store as [Store]
			,tempB.item_movement_type as [Item Movement Type]
			,tempB.last_vendor_receipt_of_central_purchasing as [Last Vendor Receipt (Central Purchasing AHI)]
			,tempB.last_qty_in as [Last Qty In]
			,tempB.total_qty_on_hand as [Total Qty on Hand]
			,tempB.on_hand_cost as [On Hand Cost]
			,tempB.issue_to_store_received_date_time as [Issue to store Received Date and Time]
			,tempB.movement_qty as [Movement Qty]
			,tempB.movement_cost as [Movement Cost]
			,tempB.qty_on_hand as [Qty on Hand]
			,tempB.last_movement_date_time_asof_JUL312018 as [Last Movement Date (as of 07-31-2018)]
			,tempB.qty_on_hand_per_June30_cutoff as [Qty on Hand (06-30-2018 cut-off)]
			,tempB.movement_date_June30_cutoff as [Movement Date (06-30-2018 cut-off)]

FROM
(
					SELECT 
								cc.name_l as costcentre
								,s.name_l as store
								,vendor_name = (CASE WHEN v.person_id IS NOT NULL THEN 
																										(SELECT display_name_l
																										FROM person_formatted_name_view
																										WHERE person_id = v.person_id) 
																								   ELSE (SELECT name_l
																											FROM organisation
																											WHERE organisation_id = v.organisation_id)
																											END)
								,ig.name_l as item_group
								,ig.parent_item_group_id
								,i.item_code as item_code
								,i.name_l as item
								,i.uom_rcd
								,sil.lot_number
								,sil.expiry_date_time
								,CASE WHEN temp.item_movement_type_rcd = 'VREC' THEN imtr.name_l
											ELSE imtr.name_l END as item_movement_type

							,CASE WHEN temp.item_movement_type_rcd = 'VREC' --AND temp.store_id = 'CEECA2AE-A630-4D65-8342-F7F7AED08073' 
									THEN temp.date_time
									ELSE NULL END as last_vendor_receipt_of_central_purchasing

								,CASE WHEN temp.item_movement_type_rcd = 'ISREC' THEN temp.last_qty_in
											ELSE NULL END as last_qty_in

								,CASE WHEN temp.item_movement_type_rcd = 'ISREC' THEN temp.total_qty_on_hand
											ELSE NULL END as total_qty_on_hand

								,CASE WHEN temp.item_movement_type_rcd = 'ISREC' THEN temp.actual_cost 
											ELSE null END as on_hand_cost

								,CASE WHEN temp.item_movement_type_rcd = 'ISREC' THEN temp.date_time
											ELSE NULL END as issue_to_store_received_date_time

								,CASE WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale' THEN temp.last_qty_in
											WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale (June 30 cut-off)' THEN NULL
											ELSE NULL END as movement_qty

								,CASE WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale' THEN temp.actual_cost
											WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale (June 30 cut-off)' THEN NULL
											ELSE NULL END as movement_cost

								,CASE WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale' THEN temp.total_qty_on_hand
											WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale (June 30 cut-off)' THEN NULL
											ELSE NULL END as qty_on_hand

								,CASE WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale' THEN temp.date_time
											WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale (June 30 cut-off)' THEN NULL
											ELSE NULL END as last_movement_date_time_asof_JUL312018

								,CASE WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale (June 30 cut-off)' THEN temp.total_qty_on_hand
											WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale' THEN NULL
											ELSE NULL END as qty_on_hand_per_June30_cutoff

								,CASE WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale (June 30 cut-off)' THEN temp.date_time
											WHEN temp.item_movement_type_rcd = 'S' AND temp.indicator = 'Sale' THEN NULL
											ELSE NULL END as movement_date_June30_cutoff

								--,(SELECT qty_on_hand
								--			FROM item_movement im
								--			where im.date_time IN (SELECT MAX(date_time) from item_movement
								--											where item_id = im.item_id -- 'BD4E7EFF-8F5E-40DE-9DE6-2CE89A24E8DC'
								--											AND CAST(CONVERT(VARCHAR(10),date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'06/01/2018',101) as SMALLDATETIME)
								--											and CAST(CONVERT(VARCHAR(10),date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'06/30/2018',101) as SMALLDATETIME)
								--											AND item_movement_type_rcd = 's'
								--											--group BY date_time
								--											--ORDER BY date_time DESC
								--											)) as qty_on_hand_per_June30_cutoff

								--,(SELECT date_time
								--			FROM item_movement im
								--			where im.date_time IN (SELECT MAX(date_time) from item_movement
								--											where item_id = im.item_id -- 'BD4E7EFF-8F5E-40DE-9DE6-2CE89A24E8DC'
								--											AND CAST(CONVERT(VARCHAR(10),date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'06/01/2018',101) as SMALLDATETIME)
								--											and CAST(CONVERT(VARCHAR(10),date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'06/30/2018',101) as SMALLDATETIME)
								--											AND item_movement_type_rcd = 's'
								--											--group BY date_time
								--											--ORDER BY date_time DESC
								--											)) as movement_date_June30_cutoff
				

					FROM
					(
									/*****************************Issue to store received*************************************/
									SELECT 
												im.item_movement_type_rcd
												,im.movement_qty as last_qty_in
												,im.qty_on_hand as total_qty_on_hand
												,im.actual_cost
												,im.item_id
												,im.store_id
												,im.date_time
												,isd.issue_detail_id
												,'Issue to store received' as indicator
												--,*
									FROM item_movement im
													LEFT OUTER JOIN (SELECT issue_detail_id
																			FROM issue_detail
																			GROUP by issue_detail_id) isd ON im.source_id = isd.issue_detail_id
									WHERE
											im.date_time IN (SELECT MAX(date_time) from item_movement
																					where item_id = im.item_id -- 'BD4E7EFF-8F5E-40DE-9DE6-2CE89A24E8DC'		
																					AND item_movement_type_rcd IN ('isrec')
																					)
									--ORDER BY im.date_time DESC

									union all

									/*****************************Vendor receipt*************************************/
									SELECT 
												im.item_movement_type_rcd
												,im.movement_qty
												,im.qty_on_hand
												,im.actual_cost
												,im.item_id
												,im.store_id
												,im.date_time as last_vendor_receipt_of_CentralPurchasing
												,sprd.purchase_receive_detail_id
												,'Vendor Receipt' as indicator
									FROM item_movement im
													LEFT OUTER JOIN (SELECT purchase_receive_detail_id
																			FROM swe_purchase_receive_detail
																			GROUP by purchase_receive_detail_id) sprd ON im.source_id = sprd.purchase_receive_detail_id
									WHERE
												im.date_time IN (SELECT MAX(date_time) from item_movement
																					where item_id = im.item_id -- 'BD4E7EFF-8F5E-40DE-9DE6-2CE89A24E8DC'		
																					AND item_movement_type_rcd IN ('vrec'))
									--ORDER BY im.date_time DESC

									union all

									/*****************************Sale*************************************/
									SELECT 
												temp.item_movement_type_rcd
												,SUM(temp.movement_qty) as movement_qty
												,MIN(temp.qty_on_hand) as qty_on_hand
												,SUM(temp.actual_cost) as movement_cost
												,temp.item_id
												,temp.store_id
												,MAX(temp.date_time) as last_movement_date
												,temp.item_id
												,'Sale' as indicator
									FROM
									(
											SELECT *
											FROM item_movement im
											where im.date_time IN (SELECT date_time from item_movement
																			where item_id = im.item_id -- 'BD4E7EFF-8F5E-40DE-9DE6-2CE89A24E8DC'
																			AND CAST(CONVERT(VARCHAR(10),date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'07/01/2018',101) as SMALLDATETIME)
																			and CAST(CONVERT(VARCHAR(10),date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'07/31/2018',101) as SMALLDATETIME)
																			AND item_movement_type_rcd = 's'
																			)
									)as temp
									GROUP BY temp.item_id
														,temp.store_id
														,temp.item_movement_type_rcd
				
									union all

									/*****************************SALE (For June 30 Cut-off)*************************************/

									--SALE (For June 30 Cut-off)
									SELECT 
												temp.item_movement_type_rcd
												,temp.movement_qty
												,temp.qty_on_hand
												,temp.actual_cost as movement_cost
												,temp.item_id
												,temp.store_id
												,temp.date_time as last_movement_date
												,temp.item_id
												,'Sale (June 30 cut-off)' as indicator
									FROM
									(
											SELECT *
											FROM item_movement im
											where im.date_time IN (SELECT MAX(date_time) from item_movement
																			where item_id = 'BD4E7EFF-8F5E-40DE-9DE6-2CE89A24E8DC'
																			AND CAST(CONVERT(VARCHAR(10),date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'06/01/2018',101) as SMALLDATETIME)
																			and CAST(CONVERT(VARCHAR(10),date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'06/30/2018',101) as SMALLDATETIME)
																			AND item_movement_type_rcd = 's'
																			)
									)as temp
									GROUP BY temp.item_id
														,temp.store_id
														,temp.item_movement_type_rcd
														,temp.movement_qty
														,temp.actual_cost
														,temp.qty_on_hand
														,temp.date_time

					

					)as temp

					INNER JOIN item i ON temp.item_id = i.item_id
					INNER JOIN store s ON temp.store_id = s.store_id
					INNER JOIN item_group ig ON i.item_group_id = ig.item_group_id
					INNER JOIN costcentre cc ON s.costcentre_id = cc.costcentre_id
					INNER JOIN swe_vendor_item svi ON temp.item_id = svi.item_id
					INNER JOIN vendor v ON svi.vendor_id = v.vendor_id
					INNER JOIN item_movement_type_ref imtr ON temp.item_movement_type_rcd = imtr.item_movement_type_rcd
					INNER JOIN store_item_lot sil ON temp.item_id = sil.item_id

					WHERE 
--s.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'					--Central Warehouse
								i.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'																										--OR Supplies - Exclusive
								AND temp.store_id IN ('08CD273F-19CE-11DA-A79E-001143B8816C', 'CEECA2AE-A630-4D65-8342-F7F7AED08073')			--Central Purchasing (AHI) , Peri Operative Services	--2741

								--AND i.item_code = '212024152'

--ORDER BY item
)as tempB

LEFT OUTER JOIN item_group parent_ig ON tempB.parent_item_group_id = parent_ig.item_group_id

order by Item