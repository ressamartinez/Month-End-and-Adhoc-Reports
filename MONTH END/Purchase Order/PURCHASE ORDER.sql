SELECT
      *
FROM
(
      SELECT 
            v.vendor_code
            ,vendor_name = (CASE WHEN v.person_id IS NOT NULL
                                          THEN (SELECT display_name_l FROM person_formatted_name_view WHERE person_id = v.person_id) 
                                          ELSE (SELECT name_l FROM organisation WHERE organisation_id = v.organisation_id)
                                          END)
            ,SPO.transaction_text
            ,costcentre_code = (SELECT costcentre_code FROM costcentre WHERE costcentre_id = SPRD.costcentre_id)
            ,costcentre = (SELECT name_l FROM costcentre WHERE costcentre_id = SPRD.costcentre_id)
            ,gl_account_code = (SELECT gl_acct_code_code FROM gl_acct_code WHERE gl_acct_code_id = SPRD.gl_acct_code_id)
            ,gl_account = (SELECT name_l FROM gl_acct_code WHERE gl_acct_code_id = SPRD.gl_acct_code_id)
            ,SVI.vendor_item_code
            ,SVI.vendor_item_name_l
            ,SPOD.uom_rcd
            ,SPOD.ordered_qty
            ,SPOD.pending_qty
            ,SPOD.unit_price
            ,SPOD.discount_amount
            ,gross_amount = SPOD.gross_amount
            ,SPOD.tax_amount
            ,net_amount = SPOD.gross_amount - SPOD.tax_amount 
            ,SPO.ordered_on_date
            ,SPOD.promised_on_date
            ,purchase_status = (SELECT name_l FROM swe_purchase_status_ref_nl_view WHERE swe_purchase_status_rcd = SPO.swe_purchase_status_rcd)     
            ,purchase_order_status = (SELECT name_l FROM swe_purchase_status_ref_nl_view WHERE swe_purchase_status_rcd = SPOD.swe_purchase_status_rcd) 
            ,created_by_employee = (SELECT display_name_l FROM person_formatted_name_iview_nl_view WHERE person_id = SPO.created_by_employee_id)
            ,SPO.created_on_date
            ,SPO.number_of_items    
            ,SPOD.purchase_order_detail_id
            

      FROM 
            swe_purchase_order SPO
      INNER JOIN 
            swe_purchase_order_detail SPOD ON SPO.purchase_order_id = SPOD.purchase_order_id
      LEFT JOIN
            swe_purchase_request_detail SPRD ON SPOD.purchase_order_detail_id = SPRD.purchase_order_detail_id
      LEFT JOIN
            swe_vendor_item SVI ON SVI.vendor_item_id = SPOD.vendor_item_id
      INNER JOIN 
            vendor v ON v.vendor_id = spo.vendor_id
      WHERE 
            created_on_date BETWEEN '2018-01-01' AND '2018-01-31 23:59:59.998' AND SPO.swe_purchase_site_id = '31488C46-FDB0-11D9-A79B-001143B8816C'
) AS purchase_order_request
GROUP by
      vendor_code
      ,vendor_name
      ,transaction_text
      ,costcentre_code
      ,costcentre
      ,gl_account_code
      ,gl_account
      ,vendor_item_code
      ,vendor_item_name_l
      ,uom_rcd
      ,ordered_qty
      ,pending_qty
      ,unit_price
      ,discount_amount
      ,net_amount
      ,tax_amount
      ,gross_amount
      ,ordered_on_date
      ,promised_on_date
      ,purchase_status
      ,purchase_order_status
      ,created_by_employee
      ,created_on_date
      ,number_of_items
      ,purchase_order_detail_id
      
      order by purchase_order_request.created_on_date, vendor_name asc

