
select temp.[Invoice Number],
       temp.[Invoice Date],
	   temp.[Charge Date],
	   temp.HN, 
	   temp.[Patient Name],
	   temp.[Item Code],
	   temp.[Item Name],
	   temp.[Costcentre Code],
	   temp.Costcentre,
	   temp.Quantity,
	   temp.[Unit Price],
	   temp.[Discount Amount],
	   temp.[Blocked Amount],
	   temp.[Invoice Gross Amount],
	   temp.[Invoice Discount Amount],
	   temp.[Invoice Net Amount],
	   temp.[Employee NR],
	   temp.[Caregiver Name],
	   temp.[Service Requestor],
	   temp.[GL Account Code],
	   temp.[Gl Account Name],
	   temp.[Date Blocked],
	   u.display_name as [Blocked by],
	   d.name_l as Department

from ( 
	select vc.charge_id,
		   ar.transaction_text as [Invoice Number],
		   ar.transaction_date_time as [Invoice Date],
		   cd.charge_date as [Charge Date],
		   cd.hospital_number as HN,
		   cd.patient_name as [Patient Name],
		   cd.item_id,
		   cd.item_code as [Item Code],
		   cd.item_desc as [Item Name],
		   c.costcentre_code as [Costcentre Code],
		   cd.service_provider as [Costcentre],
		   cd.quantity as [Quantity],
		   cd.unit_price as [Unit Price],
		   cd.discount_amount as [Discount Amount],
		   cd.net_amount as [Blocked Amount],
		   ar.gross_amount * ar.credit_factor as [Invoice Gross Amount],
		   ar.discount_amount as [Invoice Discount Amount],
		   (ar.gross_amount * ar.credit_factor) - ar.discount_amount as [Invoice Net Amount],
		   cd.employee_number as [Employee NR],
		   cd.display_name as [Caregiver Name],
		   cd.service_requestor as [Service Requestor],
		   cd.gl_acct_code_code as [GL Account Code],
		   cd.gl_acct_name as [Gl Account Name],
		   blocked_by_user_id = (Select top 1 user_id from dbo.charge_audit_trail 
												where charge_id = vc.charge_id
													  and action = 'Block'
													  order by updated_datetime desc),
		   [Date Blocked] = (Select top 1 updated_datetime from dbo.charge_audit_trail 
												where charge_id = vc.charge_id
													  and action = 'Block'
													  order by updated_datetime desc)

	from dbo.validated_charges vc inner join dbo.charge_details_vw cd on vc.charge_id = cd.charge_id
								  inner join dbo.ar_invoice_details ard on cd.charge_id = ard.charge_detail_id
								  inner join dbo.ar_invoices ar on ard.ar_invoice_id = ar.ar_invoice_id
								  inner join dbo.costcentre c on cd.service_provider_id = c.costcentre_id
	where vc.blocked_flag = 1
	      and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'09/01/2019',101) as SMALLDATETIME)
	      and CAST(CONVERT(VARCHAR(10),ar.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'04/23/2020',101) as SMALLDATETIME)
) as temp inner join dbo.users u on temp.blocked_by_user_id = u.user_id
          left outer join dbo.departments d on u.department = d.department_id
--where temp.[Invoice Number] = 'PINV-2019-303013'
order by temp.charge_id, temp.[Invoice Date]
