--for validation
--29796 -August 2017 only
--322947 -JAN to DEC 2017	extracted asof 01/17/18
--IPD = 38825

SELECT 
			inv.transaction_date_time,
				inv.invoice_no,
				ar.gross_amount * ar.credit_factor as gross_amount,
				ar.discount_amount * ar.credit_factor as discount_amount,
				ar.net_amount * ar.credit_factor as net_amount,
				inv.hn,
				inv.patient_name
				,vtr.visit_type_group_rcd

			--	--,gl.gl_acct_code_code
			--	--,gl.name_l
				
			--sum(ar.gross_amount * ar.credit_factor)

from ar_invoice ar inner JOIN HISReport.dbo.rpt_invoice_pf inv on ar.ar_invoice_id = inv.invoice_id
									inner JOIN visit_type_ref vtr on inv.visit_type_rcd = vtr.visit_type_rcd

									--LEFT OUTER JOIN HISReport.dbo.rpt_invoice_pf_detailed invd ON ar.ar_invoice_id = invd.invoice_id

									--LEFT OUTER JOIN charge_detail cd ON invd.charge_detail_id = cd.charge_detail_id
									--LEFT OUTER JOIN gl_acct_code gl ON cd.gl_acct_code_id = gl.gl_acct_code_id

--where MONTH(ar.transaction_date_time) = 8
--and YEAR(ar.transaction_date_time) = 2017
where CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2018',101) as SMALLDATETIME)
and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'09/30/2018',101) as SMALLDATETIME)
and ar.transaction_status_rcd not in ('voi','unk')
--and vtr.visit_type_group_rcd = 'opd'
--And ar.visit_type_rcd IN ('v1', 'v2', 'v3')

--AND gl.gl_acct_code_code IS NOT NULL

order by ar.transaction_date_time
