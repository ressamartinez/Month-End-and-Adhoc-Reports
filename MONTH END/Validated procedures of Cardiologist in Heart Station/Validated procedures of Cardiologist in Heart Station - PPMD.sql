
SELECT cd.costcentre_group_description as [Costcentre Group],
       cd.employee_number as [Employee NR],
	   RTRIM(cd.d_lname) as [Caregiver Lastname],
	   RTRIM(cd.d_fname) as [Caregiver Firstname],
	   --cd.caregiver_job_type,
	   vc.hn as HN,
	   vc.patient_name as [Patient Name],
	   cd.admission_date as [Admission Date],
	   cd.admission_type as [Admission Type],
	   cd.visit_type as [Visit Type],
	   cd.item_code as [Item Code],
	   cd.item_desc as [Item Description],
	   cd.quantity as Qty,
	   cd.unit_price as [Unit Price],
	   cd.total_amt as [Total Amount],
	   cd.charge_date as [Charge Date],
	   cd.validated_name as Validated,
	   cd.paid as [Paid Invoice],
	   case when vc.processed_flag = 1 then 'Yes' else 'No' end as Processed,
	   cd.service_requestor as [Service Requestor],
	   cd.service_provider as [Service Provider],
	   cd.package_flag as [Package Flag]

from dbo.validated_charges vc left join dbo.charge_details_vw cd on vc.charge_id = cd.charge_id
where month(vc.charge_date) = @Month
	  and year(vc.charge_date) = @Year
      and cd.costcentre_group_id = '8A6503A8-39EE-49B7-8455-8343F0A4F290'   --Heart Station
      and cd.validated = 1
	  and vc.blocked_flag = 0
	  and cd.deleted_date_time is NULL
	  and cd.employee_number IN
		(
		'2663',
		'3170',
		'3037',
		'6354',
		'4301',
		'3449',
		'3046',
		'2820',
		'2686',
		'3611',
		'3479',
		'6380',
		'3056',
		'8497',
		'6288',
		'3455',
		'4346',
		'5841',
		'4103',
		'2738',
		'2855',
		'2654',
		'6353',
		'6352',
		'3342',
		'8569',
		'3620',
		'8324',
		'8350',
		'3584',
		'3599',
		'3411',
		'3013',
		'6335',
		'3568',
		'3474',
		'3021',
		'9108',
		'4563',
		'5059'
		)

order by vc.validation_id