select charge_detail.charged_date_time as 'Day',
       item_group.item_group_code as 'Main Group Code', 
       item_group.name_l  as 'Group Name', 
       item.item_code as 'Item Code', 
       item.name_l as 'Item Name', 
       charge_detail.quantity as 'Quantity', 
       charge_detail.amount as 'Amount'
from dbo.charge_detail
inner join item on charge_detail.item_id = item.item_id
inner join item_group on item.item_group_id = item_group.item_group_id
where item.item_type_rcd = 'pck' and year(charged_date_time) >= 2013 and deleted_date_time is null 
order by charged_date_time


/*
select top 100 * 
from item_group
where name_l like '%package%'

select top 100 * from item

select top 100 * from item_type_ref
*/
