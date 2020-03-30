
Select DISTINCT ard.item_id
			 ,gac.gl_acct_code_code
			 ,gac.name_l as gl_acct_name
	         ,i.item_code
			 ,i.name_l as item_name
			 ,c.costcentre_code
			 ,c.name_l as costcentre
from ar_invoice_detail ard left join charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
                           left join item i on ard.item_id = i.item_id
						   left join gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
						   left join costcentre c on cd.service_provider_costcentre_id = c.costcentre_id
where gac.gl_acct_code_code = '4219000'
      and gac.company_code = 'AHI'
	  and i.active_flag = 1
order by i.item_code

