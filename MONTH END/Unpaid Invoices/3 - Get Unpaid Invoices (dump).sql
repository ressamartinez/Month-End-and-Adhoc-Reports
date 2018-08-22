 --AHMC_DataAnalyticsDB


select * from unpaid_invoices
where CAST(CONVERT(VARCHAR(10), [Transaction Date and Time],101) as SMALLDATETIME) >=  CAST(CONVERT(VARCHAR(10),@dFrom,101) as SMALLDATETIME)
and CAST(CONVERT(VARCHAR(10), [Transaction Date and Time],101) as SMALLDATETIME) <=  CAST(CONVERT(VARCHAR(10),@dTo,101) as SMALLDATETIME)
and CAST(CONVERT(VARCHAR(10), [Transaction Date and Time],101) as SMALLDATETIME) <=  CAST(CONVERT(VARCHAR(10),@AsOFDate2,101) as SMALLDATETIME)

--where CAST(CONVERT(VARCHAR(10), [Transaction Date and Time],101) as SMALLDATETIME) >=  CAST(CONVERT(VARCHAR(10),'01/01/2006',101) as SMALLDATETIME)
--and CAST(CONVERT(VARCHAR(10), [Transaction Date and Time],101) as SMALLDATETIME) <=  CAST(CONVERT(VARCHAR(10),'07/31/2018',101) as SMALLDATETIME)
--and CAST(CONVERT(VARCHAR(10), [Transaction Date and Time],101) as SMALLDATETIME) <=  CAST(CONVERT(VARCHAR(10),'07/31/2018',101) as SMALLDATETIME)

order by [Transaction Date and Time],
		 [Invoice No.],
		 [Patient Name]




