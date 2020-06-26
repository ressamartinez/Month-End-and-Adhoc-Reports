
select purchase_order.gl_account_code,
       purchase_order.gl_account,
	   purchase_order.item_code as [Item Code],
	   purchase_order.item_name as [Item Description],
	   purchase_order.vendor_name as [Vendor Name],
	   --purchase_order.costcentre_code,
	   purchase_order.costcentre as [Costcentre],
	   purchase_order.item_group_name as [Item Group/Material Group],
	   purchase_order.item_type as [Item Type/Material Type],
	   purchase_order.uom_rcd as [Base Unit of Measure],
	   purchase_order.uom2 as [Order Unit of Measure],
	   purchase_order.pr_no as [Purchase Requisition (PR No.)],
	   purchase_order.po_no as [Purchase Order (PO No.)],
	   purchase_order.created_on_date as [PO Date],
	   purchase_order.received_no as [Received No. (GR No.)],
	   purchase_order.received_on_date as [Received on Date (GR Date)],
	   purchase_order.vendor_invoice_no as [Invoice Receipt (IR No.)],
	   purchase_order.vendor_invoice_date as [Vendor Invoice Date (IR Date)],
	   purchase_order.ordered_qty as [Ordered Qty],
	   purchase_order.unit_price as [Unit Price],
	   purchase_order.unit_price as [VAT Ex],
	   purchase_order.unit_price * 1.12 as [VAT Inc],
	   purchase_order.unit_price * purchase_order.ordered_qty as [Total Amount (VAT Ex)],
	   (purchase_order.unit_price * 1.12) * purchase_order.ordered_qty as [Total Amount (VAT Inc)],
	   purchase_order.ipd as [Selling Price per Piece - In Patient (VAT Ex)],
	   purchase_order.ipd * 1.12 as [Selling Price per Piece - In Patient (VAT Inc)],
	   purchase_order.opd as [Selling Price per Piece - Out Patient (VAT Ex)],
	   purchase_order.opd * 1.12 as [Selling Price per Piece - Out Patient (VAT Inc)],
	   purchase_order.distributed_no as [Distributed No.],
	   purchase_order.distributed_on_date as [Date Distributed]

from (
	select 
		   v.vendor_code,
		   vendor_name = (CASE WHEN v.person_id IS NOT NULL THEN 
							   (SELECT display_name_l FROM person_formatted_name_view WHERE person_id = v.person_id)
						  ELSE (SELECT name_l FROM organisation WHERE organisation_id = v.organisation_id)END),
		   costcentre_code = (SELECT costcentre_code 
							  FROM costcentre 
							  WHERE costcentre_id = spdd.costcentre_id),
		   costcentre = (SELECT name_l 
						 FROM costcentre 
						 WHERE costcentre_id = spdd.costcentre_id),
		   gl_account_code = (SELECT gl_acct_code_code 
							  FROM gl_acct_code
							  WHERE gl_acct_code_id = sprd.gl_acct_code_debit_id
							        and company_code = 'AHI'),
		   gl_account = (SELECT name_l 
						 FROM gl_acct_code 
						 WHERE gl_acct_code_id = sprd.gl_acct_code_debit_id
						       and company_code = 'AHI'),
		   svi.vendor_item_code,
		   svi.vendor_item_name_l,
		   i.item_code,
		   i.name_l as item_name,
		   spod.uom_rcd,
		   spod.ordered_qty,
		   spod.pending_qty,
		   spod.unit_price,
		   spod.discount_amount,
		   spod.gross_amount,
		   spod.tax_amount,
		   net_amount = spod.gross_amount - spod.tax_amount,
		   spd.transaction_text as distributed_no,
		   spd.distributed_on_date,
		   spr.transaction_text as received_no,
		   spr.received_on_date,
		   spo.transaction_text as po_no,
		   spo.ordered_on_date,
		   spo.created_on_date,
		   spod.promised_on_date,
		   spq.transaction_text as pr_no,
		   spq.lu_updated,
		   purchase_status = (SELECT name_l 
							  FROM swe_purchase_status_ref_nl_view 
							  WHERE swe_purchase_status_rcd = spo.swe_purchase_status_rcd),
		   purchase_order_status = (SELECT name_l
									FROM swe_purchase_status_ref_nl_view
									WHERE swe_purchase_status_rcd = spod.swe_purchase_status_rcd),
		   created_by_employee = (SELECT display_name_l
								  FROM person_formatted_name_iview_nl_view
								  WHERE person_id = spo.created_by_employee_id),
		   spo.number_of_items,
		   spod.purchase_order_detail_id,
		   spo.purchase_order_id,
		   spr.vendor_invoice_no,
		   spr.vendor_invoice_date,
		   spqd.purchase_request_id,
		   spqd.created_on_date_time,
		   i.item_group_id,
		   ig.item_group_code,
		   ig.name_l as item_group_name,
		   itr.name_l as item_type,
		   sviu.uom_rcd as uom2,
		   ipd = (Select price from item_price where item_id = i.item_id 
												and charge_type_rcd = 'IPD'
												and effective_to_date_time is null),
		   opd = (Select price from item_price where item_id = i.item_id 
												and charge_type_rcd = 'OPD'
												and effective_to_date_time is null),
		   spdd.purchase_receive_detail_id,
		   sprd.ap_invoice_detail_id,
		   spqd.purchase_request_detail_id

	from swe_purchase_distribute spd
		inner join swe_purchase_distribute_detail spdd on spd.purchase_distribute_id = spdd.purchase_distribute_id
		inner join swe_purchase_receive_detail sprd on spdd.purchase_receive_detail_id = sprd.purchase_receive_detail_id
		inner join swe_purchase_receive spr on sprd.purchase_receive_id = spr.purchase_receive_id
		inner join swe_purchase_request_detail spqd on spdd.purchase_request_detail_id = spqd.purchase_request_detail_id
		inner join swe_purchase_request spq on spqd.purchase_request_id = spq.purchase_request_id
		inner join swe_purchase_order_detail spod on spqd.purchase_order_detail_id = spod.purchase_order_detail_id
		inner join swe_purchase_order spo on spod.purchase_order_id = spo.purchase_order_id
		inner join swe_vendor_item svi on spod.vendor_item_id = svi.vendor_item_id
		inner join swe_vendor_item_uom sviu on svi.vendor_item_id = sviu.vendor_item_id
		inner join vendor v on spo.vendor_id = v.vendor_id
		inner join item i on svi.item_id = i.item_id
		inner JOIN item_group ig ON i.item_group_id = ig.item_group_id
		inner JOIN item_type_ref itr ON ig.item_type_rcd = itr.item_type_rcd

	--where svi.vendor_item_code = '11-01-800'
		  --and spd.transaction_text = 'PDC-2020-003882'

)as purchase_order
where purchase_order.gl_account_code = '1160200' --Medical Supplies -MSU Store
      and purchase_order.costcentre_code = '8560' --Warehousing

order by [Item Description], [Date Distributed]
