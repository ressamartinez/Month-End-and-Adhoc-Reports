declare @company_code varchar(3)
DECLARE @From datetime
DECLARE @To datetime
declare @table table
(
	ar_invoice_id uniqueidentifier,
	hospital_number varchar(20),
	patient_name varchar(500)
)

INSERT into @table(ar_invoice_id,hospital_number,patient_name)
SELECT DISTINCT _ar.ar_invoice_id,
	   _phu.visible_patient_id as hn,
	   _pfn.display_name_l
	   
from ar_invoice_nl_view _ar inner JOIN ar_invoice_detail _ard on _ar.ar_invoice_id = _ard.ar_invoice_id
							inner JOIN charge_detail _cd on _ard.charge_detail_id = _cd.charge_detail_id
							inner JOIN patient_visit_nl_view _pv on _cd.patient_visit_id = _pv.patient_visit_id
							inner JOIn patient_hospital_usage_nl_view _phu on _pv.patient_id = _phu.patient_id
							inner JOIN person_formatted_name_iview_nl_view _pfn on _phu.patient_id = _pfn.person_id
							inner JOIN gl_acct_code _gac on _ard.gl_acct_code_credit_id = _gac.gl_acct_code_id
where _gac.gl_acct_code_code in  ('2152100')
    and _ar.related_ar_invoice_id is NULL

set @company_code = 'AHI'
SET @From = '01/01/2019 00:00:00.000'		
SET @To = '12/31/2019 23:59:59.998'

select  distinct 
	temp.[GL Account Code],
	temp.[GL Account Name],
	temp.PAR,
	temp.[Effective Date],
	temp.[Invoice Date],
	temp.[Invoice Number],
	temp.[Related Invoice],
	temp.[Related Invoice Date],
	--temp.[Costcentre Code],
	--temp.Costcentre,
	temp.[Gross Amount],
	temp.[Item Code],
	temp.[Item Description],
	temp.[Charged Date],
	temp.Caregiver,
	temp.HN,
	temp.ar_invoice_detail_id,
	temp.related_ar_invoice_id

from (

	SELECT gac.gl_acct_code_code as [GL Account Code]
			,gac.name_l as [GL Account Name]
			,ar.transaction_date_time as [Invoice Date]
			,glt.transaction_text as [PAR]
			,ar.transaction_text as [Invoice Number]
			,isnull((select transaction_text from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice]
			,isnull((select transaction_date_time from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice Date]
			,c.costcentre_code as [Costcentre Code]
			,c.name_l as [Costcentre]
			,ard.gross_amount * ar.credit_factor as [Gross Amount]
			,i.item_code as [Item Code]
			,i.name_l as [Item Description]
			,cd.charged_date_time as [Charged Date]
			,ard.ar_invoice_detail_id
			,ar.related_ar_invoice_id
			,glt.effective_date as [Effective Date]
			,isnull((select display_name_l from person_formatted_name_iview_nl_view where person_id = cd.caregiver_employee_id),'') as [Caregiver]
			,case when phu.visible_patient_id is not NULL then phu.visible_patient_id ELSE		
				(select DISTINCT _t.hospital_number from @table _t where _t.ar_invoice_id = ar.related_ar_invoice_id) end as HN
	        ,case when phu.visible_patient_id is not NULL then pfn.display_name_l ELSE		
				(select DISTINCT _t.patient_name from @table _t where _t.ar_invoice_id = ar.related_ar_invoice_id) end as [Patient Name]

	from gl_transaction glt inner JOIN ar_invoice_nl_view ar on glt.gl_transaction_id = ar.gl_transaction_id
							inner JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
							inner JOIN costcentre c on ard.costcentre_credit_id = c.costcentre_id
							inner JOIN gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
							LEFT JOIN charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
							LEFT JOIN patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
							LEFT JOIN patient_hospital_usage_nl_view phu on pv.patient_id = phu.patient_id
							LEFT JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
							LEFT join item i on ard.item_id = i.item_id

	where CAST(CONVERT(VARCHAR(10),glt.effective_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
	        and CAST(CONVERT(VARCHAR(10),glt.effective_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
			and ar.transaction_status_rcd not in ('unk','voi')
			and cd.deleted_date_time is null
			and glt.company_code = @company_code
			and glt.transaction_status_rcd = 'POS'
			and gac.gl_acct_code_code = '2152100'
)as temp

UNION ALL

select 
		temp.[GL Account Code],
		temp.[GL Account Name],
		temp.PAR,
		temp.[Effective Date],
		temp.[Invoice Date],
		temp.[Invoice Number],
		temp.[Related Invoice],
		temp.[Related Invoice Date],
		--temp.[Costcentre Code],
		--temp.Costcentre,
		[Gross Amount] = temp.[Credit Amount] - temp.[Debit Amount],
		temp.[Item Code],
		temp.[Item Description],
		temp.[Charged Date],
		temp.Caregiver,
		temp.HN,
		temp.ar_invoice_detail_id,
		temp.related_ar_invoice_id

from  (

	select 		
				gac.gl_acct_code_code as [GL Account Code]
				,gac.name_l as [GL Account Name]
				,ar.transaction_date_time as [Invoice Date]
				,gt.transaction_text as [PAR]
				,ar.transaction_text as [Invoice Number]
				,isnull((select transaction_text from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice]
				,isnull((select transaction_date_time from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice Date]
				,c.costcentre_code as [Costcentre Code]
				,c.name_l as [Costcentre]
				,[Debit Amount] = case when debit_flag = 1 then gtd.amount else '-' end
				,[Credit Amount] = case when debit_flag = 0 then gtd.amount else '-' end
				,i.item_code as [Item Code]
			    ,i.name_l as [Item Description]
				,ard.ar_invoice_detail_id
				,ar.related_ar_invoice_id
				,gt.effective_date as [Effective Date]
				,cd.charged_date_time as [Charged Date]
			    ,isnull((select display_name_l from person_formatted_name_iview_nl_view where person_id = cd.caregiver_employee_id),'') as [Caregiver]
			   ,case when phu.visible_patient_id is not NULL then phu.visible_patient_id ELSE		
				(select DISTINCT _t.hospital_number from @table _t where _t.ar_invoice_id = ar.related_ar_invoice_id) end as HN
	           ,case when phu.visible_patient_id is not NULL then pfn.display_name_l ELSE		
				(select DISTINCT _t.patient_name from @table _t where _t.ar_invoice_id = ar.related_ar_invoice_id) end as [Patient Name]


	from		gl_transaction_nl_view gt
	inner join gl_transaction_detail_nl_view gtd on gtd.gl_transaction_id = gt.gl_transaction_id 
	inner JOIN costcentre c on gtd.costcentre_id = c.costcentre_id
	inner join gl_acct_code_nl_view gac on gac.gl_acct_code_id = gtd.gl_acct_code_id
	left JOIN ar_invoice_nl_view ar on gt.gl_transaction_id = ar.gl_transaction_id
	left JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
	LEFT JOIN charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
	LEFT JOIN patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
	LEFT JOIN patient_hospital_usage_nl_view phu on pv.patient_id = phu.patient_id
	LEFT JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
	LEFT join item i on ard.item_id = i.item_id

	where CAST(CONVERT(VARCHAR(10),gt.effective_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
	    and CAST(CONVERT(VARCHAR(10),gt.effective_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
		and	gt.company_code = @company_code
		and	gt.transaction_status_rcd = 'POS'
		and gt.user_transaction_type_id = '8566FA00-63FE-11DA-BB34-000E0C7F3ED2'    --GJV
		and gac.gl_acct_code_code = '2152100'

) as temp
