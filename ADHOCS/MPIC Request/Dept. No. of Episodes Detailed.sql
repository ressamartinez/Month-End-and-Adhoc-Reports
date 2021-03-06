
DECLARE @table table
(
	charge_detail_id uniqueidentifier,
	costcentre_code varchar(10),
	costcentre varchar(300),
	charge_type varchar(10),
	charged_date_time smalldatetime,
	visit_code varchar(10),
	visit_start smalldatetime,
	closure_date smalldatetime,
	hn varchar(20),
	patient_name varchar(300), 
	item_code varchar(20),
	item_name varchar(300),
	employee_nr varchar(20),
	caregiver_name varchar(300)
)

insert into @table(charge_detail_id,
					costcentre_code,
					costcentre,
					charge_type,
					charged_date_time,
					visit_code,
					visit_start,
					closure_date,
					hn,
					patient_name,
					item_code,
					item_name,
					employee_nr,
					caregiver_name)

select cd.charge_detail_id,
	   case when c.costcentre_code in ('7060', '7070', '7080') then '0' 
					else c.costcentre_code end as costcentre_code,
	   case when c.costcentre_code in ('7060', '7070', '7080') then 'Laboratory' 
					else c.name_l end as costcentre,
       pv.charge_type_rcd as charge_type,
	   cd.charged_date_time,
	   pv.visit_code,
	   pv.actual_visit_date_time as visit_start,
	   pv.closure_date_time as closure_date,
	   phu.visible_patient_id as hn,
	   pfn.display_name_l as patient_name,
	   i.item_code,
	   i.name_l as item_name,
	   (select employee_nr from employee_employment_info_view where person_id = cd.caregiver_employee_id) as employee_nr,
	   (select RTRIM(last_name_l) + ', ' + RTRIM(first_name_l) from employee_employment_info_view where person_id = cd.caregiver_employee_id) as caregiver_name

from charge_detail cd inner join patient_visit pv on cd.patient_visit_id = pv.patient_visit_id
                      inner join costcentre c on cd.service_provider_costcentre_id = c.costcentre_id
					  inner join item i on cd.item_id = i.item_id
					  inner join patient_hospital_usage phu on pv.patient_id = phu.patient_id
					  inner join person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id

where cd.deleted_date_time is NULL
      and pv.cancelled_date_time is NULL
      and c.parent_costcentre_id = 'AAEAA734-F4FF-11D9-A79A-001143B8816C'    --ANCILLARY SERVICES
	  and c.active_flag = 1
	  and i.active_flag = 1
	  and i.item_type_rcd = 'SRV'
      and i.sub_item_type_rcd = 'SRV'
      and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2020',101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),cd.charged_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'01/31/2020',101) as SMALLDATETIME)


SELECT t.costcentre as Costcentre,
	   t.charge_type as 'Charge Type',
	   t.charged_date_time as 'Charged Date',
	   t.visit_code as 'Visit Code',
	   t.visit_start as 'Visit Start',
	   t.closure_date as 'Closure Date',
	   t.hn as 'HN',
	   t.patient_name as 'Patient Name',
	   t.item_code as 'Item Code',
	   t.item_name as 'Item Name',
	   t.employee_nr as 'Employee NR',
	   t.caregiver_name as 'Caregiver Name'
	   --t.costcentre_code
from @table t
where t.charge_type = 'OPD'