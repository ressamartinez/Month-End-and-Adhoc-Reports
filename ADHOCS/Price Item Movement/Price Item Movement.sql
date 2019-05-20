
select temp.* 
from (

		select distinct
			   i.item_id,
			   i.item_code,
			   i.name_l as item_name,
			   ig.name_l as item_group,
			   --ip.price
			   rate = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id order by imp.lu_updated desc),
			   rate_y2010 = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2010' order by imp.lu_updated desc),
			   change_date_y2010 = (Select top 1 imp.lu_updated from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2010' order by imp.lu_updated desc),
			   effective_date_y2010 = (Select top 1 imp.effective_from_date_time from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2010' order by imp.lu_updated desc),

			   rate_y2011 = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2011' order by imp.lu_updated desc),
			   change_date_y2011 = (Select top 1 imp.lu_updated from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2011' order by imp.lu_updated desc),
			   effective_date_y2011 = (Select top 1 imp.effective_from_date_time from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2011' order by imp.lu_updated desc),

			   rate_y2012 = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2012' order by imp.lu_updated desc),
			   change_date_y2012 = (Select top 1 imp.lu_updated from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2012' order by imp.lu_updated desc),
			   effective_date_y2012 = (Select top 1 imp.effective_from_date_time from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2012' order by imp.lu_updated desc),

			   change_y2013 = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2013' order by imp.lu_updated desc),
			   change_date_y2013 = (Select top 1 imp.lu_updated from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2013' order by imp.lu_updated desc),
			   effective_date_y2013 = (Select top 1 imp.effective_from_date_time from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2013' order by imp.lu_updated desc),

			   rate_y2014 = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2014' order by imp.lu_updated desc),
			   change_date_y2014 = (Select top 1 imp.lu_updated from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2014' order by imp.lu_updated desc),
			   effective_date_y2014 = (Select top 1 imp.effective_from_date_time from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2014' order by imp.lu_updated desc),

			   rate_y2015 = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2015' order by imp.lu_updated desc),
			   change_date_y2015 = (Select top 1 imp.lu_updated from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2015' order by imp.lu_updated desc),
			   effective_date_y2015 = (Select top 1 imp.effective_from_date_time from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2015' order by imp.lu_updated desc),

			   rate_y2016 = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2016' order by imp.lu_updated desc),
			   change_date_y2016 = (Select top 1 imp.lu_updated from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2016' order by imp.lu_updated desc),
			   effective_date_y2016 = (Select top 1 imp.effective_from_date_time from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2016' order by imp.lu_updated desc),

			   rate_y2017 = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2017' order by imp.lu_updated desc),
			   change_date_y2017 = (Select top 1 imp.lu_updated from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2017' order by imp.lu_updated desc),
			   effective_date_y2017 = (Select top 1 imp.effective_from_date_time from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2017' order by imp.lu_updated desc),

			   rate_y2018 = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2018' order by imp.lu_updated desc),
			   change_date_y2018 = (Select top 1 imp.lu_updated from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2018' order by imp.lu_updated desc),
			   effective_date_y2018 = (Select top 1 imp.effective_from_date_time from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2018' order by imp.lu_updated desc),

			   rate_y2019 = (Select top 1 imp.price from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2019' order by imp.lu_updated desc),
			   change_date_y2019 = (Select top 1 imp.lu_updated from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2019' order by imp.lu_updated desc),
			   effective_date_y2019 = (Select top 1 imp.effective_from_date_time from item_price imp 
							where imp.item_id = ip.item_id
								  and year(imp.lu_updated) = '2019' order by imp.lu_updated desc)
				 --,ip.lu_updated

		from item i inner join item_price ip on i.item_id = ip.item_id
					inner join item_group ig on i.item_group_id = ig.item_group_id
		where i.item_type_rcd = 'SRV'
			  and i.active_flag = 1
			  --and i.item_code = '010-00-0100'
) as temp
where temp.rate <> 0
order by temp.item_code asc

--HRU-19-004, ORT-19-077
