SELECT employee_nr as [Employee No.],
	   ISNULL(caregiver_lname,'') + ', ' + ISNULL(caregiver_fname,'') as [Caregiver Name],
	   admission_type as [Admission Type],
	   visit_type as [Visit Type],
	   upi as UPI,
	   ISNULL(lname,'') + ', ' + ISNULL(fname,'') + ' ' + ISNULL(mname,'') as [Patient Name],
	   item_code as [Item Code],
	   item_desc as [Item Description],
	   total_amt as [Total Amount],
	   discount_amt as [Discount Amount],
	   adjustment_amt as [Adjustment Amount],
	   ISNULL(net_amt,0) as [Net Amount],
	   validated as Validated,
	   case when processed = 'Y' then 'Processed'
		    when processed = 'N' then 'Rejected'
			when processed = 'P' then 'New'
	   end as Processed,
	   lu_updated_datetime as [Last Updated Date and Time]
from df_browse_manual_entry
order by [Last Updated Date and Time] 
