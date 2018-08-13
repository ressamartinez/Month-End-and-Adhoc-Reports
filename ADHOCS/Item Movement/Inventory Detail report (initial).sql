--319705

SELECT DISTINCT itm.item_movement_id
			,itm.store_id
			,itm.date_time
			,(SELECT name_l from store where store_id = itm.store_id) as store_name
			,(SELECT name_l from item_group where item_group_id = 
					(SELECT top 1 item_group_id from item where item_id = itm.item_id)) as item_group
			,(SELECT name_l from item where item_id = itm.item_id) as item_name
			,(SELECT item_code from item where item_id = itm.item_id) as item_code
			,(SELECT uom_rcd from item where item_id = itm.item_id) as uom
			--,(SELECT average_unit_cost from inventory_summary_day where item_id = itm.item_id) carried_forward_ave_unit_cost
			--,inv.average_unit_cost


FROM item_movement itm
			--LEFT OUTER JOIN inventory_summary_day inv ON itm.item_id = inv.item_id

where CAST(CONVERT(VARCHAR(10),itm.date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'09/01/2017',101) as SMALLDATETIME)
			and CAST(CONVERT(VARCHAR(10),itm.date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'09/30/2017',101) as SMALLDATETIME)


order by item_group, itm.date_time
------------------------------------------------------------------------

select * FROM inventory_summary_day
where item_id = '5A03DDE4-5DE4-4409-A7D1-8751CF1B2EE1'
order by date_time

select * from item_movement
where item_id = '5A03DDE4-5DE4-4409-A7D1-8751CF1B2EE1'
			AND MONTH(date_time) = 9
			AND YEAR(date_time) = 2017
order by date_time

select * FROM store_item
where item_id = '0DCA0B24-1DFF-4212-AC33-032DFFD2A080'
			AND store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'
			AND MONTH(lu_updated) = 9
			AND YEAR(lu_updated) = 2017
order by lu_updated

select top 2 * FROM store


select * from item_movement_type_ref
select top 2 * FROM item

select top 5 * FROM stock_adjustment
select top 5  * FROM issue_detail
select top 5 * FROM stock_check_detail
select top 5  * FROM charge_detail
select top 5 * FROM swe_purchase_receive_detail
select top 5  * FROM swe_purchase_return_detail

select * FROM data_change_log
select * FROM data_change_type_ref
select * FROM store_item
select * FROM store_item_cost
select * FROM store_item_group
select * FROM store_item_lot
select * FROM store_type_ref
select * FROM store

select * FROM inventory_summary_month_nl_view