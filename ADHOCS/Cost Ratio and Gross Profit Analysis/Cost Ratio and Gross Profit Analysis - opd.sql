
select DISTINCT
--count(distinct tempc.patient_visit_id)
    opd.[Visit No.]
	,opd.[Visit Start]
	,opd.[Closure Date]
	,opd.HN
	,opd.[Patient Name]
	,ar.gross_amount as [Gross Amount]
	,ar.discount_amount as [Discount Amount]
	,ar.gross_amount - ar.discount_amount as [Net Amount]
	,ar.transaction_text as [Invoice Number]
	,ar.transaction_date_time as [Invoice Date]
	,p.name_l as Policy
	,case when otr.organisation_type_rcd is NULL or otr.organisation_type_rcd = 'oth' then 'Self Pay' else otr.name_l end as 'Payor Type'
	,opd.Age
	--,ard.ar_invoice_detail_id


from AHMC_DataAnalyticsDB.dbo.opd_census_2  opd
inner join charge_detail cd on opd.patient_visit_id = cd.patient_visit_id
inner join ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
inner join ar_invoice ar on ard.ar_invoice_id = ar.ar_invoice_id
inner join policy p on ar.policy_id = p.policy_id
left OUTER JOIN customer c on ar.customer_id = c.customer_id
LEFT OUTER JOIN organisation o on c.organisation_id = o.organisation_id
LEFT OUTER JOIN person_formatted_name_iview_nl_view pfn on c.person_id = pfn.person_id
LEFT OUTER JOIN organisation_role oor on o.organisation_id = oor.organisation_id
LEFT OUTER JOIN organisation_type_ref otr on oor.organisation_type_rcd = otr.organisation_type_rcd
where CAST(CONVERT(VARCHAR(10),opd.[Visit Start],101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'07/01/2020',101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),opd.[Visit Start],101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'07/31/2020',101) as SMALLDATETIME)
	  --and opd.HN = '00420892'
	  and ar.transaction_status_rcd not in ('voi', 'unk')
      and ar.policy_id = 'B01C02EE-04CC-11DF-B726-00237DBC514A'



