
select DISTINCT
	   svi.vendor_item_code as 'Vendor Item Code'
	   ,svi.vendor_item_name_l as 'Vendor Item Name'
	   ,i.item_code as 'Item Code'
	   ,i.name_l as 'Item Name'
	   ,ig.item_group_code as 'Item Group Code'
	   ,ig.name_l as 'Item Group Name'

from swe_vendor_item svi 
left outer join item i on i.item_id = svi.item_id
left outer join item_group ig on ig.item_group_id = i.item_group_id

where i.active_flag = 1
	  --and sil.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'          --Central Warehouse
	  --and i.item_id ='BD4E7EFF-8F5E-40DE-9DE6-2CE89A24E8DC'
	  --and ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'    --OR Supplies - Exclusive
	  --and ig.item_group_code in ('0803-1', '0807-1', '0808-1', '0809-1', '0825-1', '0826-1', '0830-1', '0832-1', '0832-2', '0853-1', '0856-1', '0880-1')
	  and ig.item_group_code = '24000'
	  --and ig.item_group_code between '08711' and '08723'
order by ig.item_group_code ASC