
Select temp.costcentre_code,
       temp.costcentre,
	   case when temp.y2019pd > 0 then temp.y2019pd * -1 else abs(temp.y2019pd) end as y2019pd,
	   case when temp.y2020pd > 0 then temp.y2020pd * -1 else abs(temp.y2020pd) end as y2020pd,
	   temp.y2019v,
	   temp.y2020v,
	   temp.Month

from (

	select distinct c.costcentre_code,
		   c.name_l as costcentre,
		   isnull((Select sum(pd.[Package Discount]) from AHMC_DataAnalyticsDB.dbo.package_discount pd
					 where pd.[Costcentre Code] = c.costcentre_code collate sql_latin1_general_cp1_cs_as
					 and pd.Year = '2020'
					 and pd.Month = pd_main.Month),0) as y2020pd,
		   isnull((Select sum(pd.[Package Discount]) from AHMC_DataAnalyticsDB.dbo.package_discount pd 
					 where pd.[Costcentre Code] = c.costcentre_code collate sql_latin1_general_cp1_cs_as
					 and pd.Year = '2019'
					 and pd.Month = pd_main.Month),0) as y2019pd,
		   isnull((Select count(distinct pd.patient_visit_id) from AHMC_DataAnalyticsDB.dbo.package_discount pd
					 where pd.[Costcentre Code] = c.costcentre_code collate sql_latin1_general_cp1_cs_as
					 and pd.Year = '2020'
					 and pd.Month = pd_main.Month),0)  as y2020v,
		   isnull((Select count(distinct pd.patient_visit_id) from AHMC_DataAnalyticsDB.dbo.package_discount pd
					 where pd.[Costcentre Code] = c.costcentre_code collate sql_latin1_general_cp1_cs_as
					 and pd.Year = '2019'
					 and pd.Month = pd_main.Month),0)  as y2019v,
		   pd_main.Month

	from AmalgaPROD.dbo.costcentre c inner join AHMC_DataAnalyticsDB.dbo.package_discount pd_main on c.costcentre_code = pd_main.[Costcentre Code] collate sql_latin1_general_cp1_cs_as
	where pd_main.Month = 'February'
		  --and c.costcentre_code in ('7245', '7300')

)as temp
order by costcentre

/*
select count(distinct patient_visit_id), sum([Package Discount]), Month
from package_discount
where [Costcentre Code] = '7110'
and Year = 2020
group by Month
*/