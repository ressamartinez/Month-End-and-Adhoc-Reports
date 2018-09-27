
select distinct rip.hn,
	   rip.patient_name,
	   rip.policy_name as payor,
	   rip.visit_type,
	   rip.transaction_date_time,
	   rip.discharge_date_time,
	   rip.invoice_no,
	   rip.gross_pf,
	   rip.net_pf,
	   ar.write_off_amount as pf_adjustment_from_par,
	   r.transaction_text,
	   gac.gl_acct_code_code 

from HISReport.dbo.rpt_invoice_pf rip left outer join ar_invoice ar on ar.ar_invoice_id = rip.invoice_id
									  left outer join ar_invoice_detail ard on ard.ar_invoice_id = ar.ar_invoice_id
									  left outer join charge_detail cd on cd.charge_detail_id = ard.charge_detail_id
									  left outer join gl_acct_code gac on gac.gl_acct_code_id = cd.gl_acct_code_id
									  left outer join swe_ar_instalment sai on sai.ar_invoice_id = ar.ar_invoice_id
									  left outer join remittance r on r.remittance_id = sai.remittance_id
									  
where month(rip.transaction_date_time) = 8
	  and year(rip.transaction_date_time) = 2018
	  --and rip.hn = '00546170'
	  and ar.transaction_status_rcd not in ('unk','voi')
	  and gac.gl_acct_code_code = '2152100'
	  
order by rip.transaction_date_time asc		