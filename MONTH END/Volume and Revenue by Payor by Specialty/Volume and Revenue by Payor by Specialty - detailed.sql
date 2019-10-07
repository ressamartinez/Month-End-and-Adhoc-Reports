
select case when temp.org_type is NULL then 'Self Pay' else temp.org_type end as org_type
       ,'Conventional'
	   --,temp.rpt_type
	   ,temp.year_id
	   ,temp.month_id
	   ,temp.charge_type_rcd
	   ,temp.policy_id
	   ,temp.policy
	   ,temp.specialty
	   ,temp.count
	   ,temp.gross_amount
	   ,temp.discount_amount

from (

	select 
		  (select top 1 case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end
				from HISReport.dbo.rpt_cpr_charge_summary_2 _ccs left join ar_invoice _ar on _ccs.ar_invoice_id = _ar.ar_invoice_id 
							   left OUTER JOIN customer c on _ar.customer_id = c.customer_id
							   LEFT OUTER JOIN organisation o on c.organisation_id = o.organisation_id
							   LEFT OUTER JOIN person_formatted_name_iview_nl_view pfn1 on c.person_id = pfn1.person_id
							   LEFT OUTER JOIN organisation_role oor on o.organisation_id = oor.organisation_id
							   LEFT OUTER JOIN organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd
				where _ccs.policy_id = ccs.policy_id) as org_type,
		   ccs.rpt_type
		   ,year_id
		   ,month_id
		   ,charge_type_rcd
		   ,ccs.policy_id
		   ,policy
		   ,specialty
		   ,COUNT(ccs.ar_invoice_id) AS [count]
		   ,SUM(ccs.gross_amount) AS [gross_amount]
		   ,SUM(ccs.discount_amount) AS [discount_amount]

	FROM HISReport.dbo.rpt_cpr_charge_summary_2 ccs 
    
                                                
	where ccs.year_id = 2016
		  --and ccs.month_id = 1
		  and ccs.rpt_type = 'C'
	group by ccs.rpt_type
			 ,ccs.year_id
			 ,ccs.month_id
			 ,ccs.charge_type_rcd
			 ,ccs.policy_id
			 ,ccs.policy
             ,ccs.specialty
)as temp
order by temp.year_id
         ,temp.month_id
		 ,temp.charge_type_rcd
         ,temp.policy
		 ,temp.specialty
