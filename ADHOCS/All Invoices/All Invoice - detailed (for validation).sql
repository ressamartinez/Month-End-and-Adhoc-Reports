--for validation
--626053 -August only	
--Jan to Dec 2017 extracted asof 01/17/18	- 456328

SELECT distinct
			 inv.transaction_date_time,
				inv.invoice_no,
				invd.gross_amount * ar.credit_factor as gross_amount,
				invd.discount_amount * ar.credit_factor as discount_amount,
				invd.net_amount * ar.credit_factor as net_amount,
				invd.item_code,
				invd.itemname,
				vtr.visit_type_group_rcd,
				vtr.name_l as visit_type,
				inv.patient_name,
				inv.hn
				,invd.gl_acct_code_code
				,invd.gl_acct_name

				--,gl.gl_acct_code_code
				--,gl.name_l as gl_account_name

				--sum(invd.gross_amount * ar.credit_factor)

from HISReport.dbo.rpt_invoice_pf_detailed invd 
													inner JOIN ar_invoice ar on invd.invoice_id = ar.ar_invoice_id
													inner JOIN HISReport.dbo.rpt_invoice_pf inv on ar.ar_invoice_id = inv.invoice_id
													inner JOIN visit_type_ref vtr on inv.visit_type_rcd = vtr.visit_type_rcd

													--LEFT OUTER JOIN charge_detail cd ON invd.charge_detail_id = cd.charge_detail_id
													--LEFT OUTER JOIN gl_acct_code gl ON cd.gl_acct_code_id = gl.gl_acct_code_id

where CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'09/26/2018',101) as SMALLDATETIME)
and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'09/30/2018',101) as SMALLDATETIME)
--where month(ar.transaction_date_time) = @Month
--and year(ar.transaction_date_time) = @Year
and ar.transaction_status_rcd not in ('voi','unk')
--and vtr.visit_type_group_rcd = 'opd'
--And ar.visit_type_rcd IN ('v1', 'v2', 'v3')

--order by ar.transaction_date_time

