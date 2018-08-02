SELECT 
	   (SELECT employee_nr
		from employee_employment_info_view
		where person_id = cd.caregiver_employee_id) as [Employee NR],
       (SELECT last_name_l  from person_name_iview where person_id = cd.caregiver_employee_id) as [Caregiver Last Name],
       (SELECT first_name_l  from person_name_iview where person_id = cd.caregiver_employee_id) as  [Caregiver First Name],
	   phu.visible_patient_id as HN,
       (SELECT last_name_l  from person_name_iview where person_id = pv.patient_id) as [Patient Last Name],
	   (SELECT first_name_l  from person_name_iview where person_id = pv.patient_id) as [Patient First Name],
	   i.item_code as [Item Code],
	   i.name_l as [Item Desc],
	   cd.unit_price as [Unit Price],
	   cd.amount as [Total Amount],
	   (SELECT sum(discount_amount)
		from ar_invoice_detail
		where charge_detail_id = cd.charge_detail_id) as discount_amount,
	   cd.charged_date_time as [Charge DateTime],
	   CONVERT(VARCHAR(20), cd.charged_date_time,101) AS [Charge Date],
		FORMAT(cd.charged_date_time,'hh:mm tt') AS [Charge Time],
	   (SELECT name_l from costcentre where costcentre_id = cd.service_requester_costcentre_id) as [Service Requestor],
		(SELECT name_l from costcentre where costcentre_id = cd.service_provider_costcentre_id) as [Service Provider]
		
	  
from charge_detail cd inner JOIN item i on cd.item_id = i.item_id
					 inner JOIN item_group ig on i.item_group_id = ig.item_group_id
					 inner JOIN patient_visit pv on cd.patient_visit_id = pv.patient_visit_id
				     inner JOIN patient_hospital_usage phu on pv.patient_id = phu.patient_id
where service_provider_costcentre_id = 'AAEAA764-F4FF-11D9-A79A-001143B8816C'
    and YEAR(charged_date_time) = @Year
	--and MONTH(charged_date_time) = 1
	and i.item_group_id = '9BD94116-66E9-11DA-BB34-000E0C7F3ED2'
	and cd.deleted_date_time is NULL
order by [Charge Date]


