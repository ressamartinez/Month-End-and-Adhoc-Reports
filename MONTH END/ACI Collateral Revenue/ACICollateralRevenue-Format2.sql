DECLARE @iMonth int
DECLARE @iMonth2 int
DECLARE @iYear int

SET @iMonth =  10
SET @iMonth2 = 10
SET @iYear = 2017

SELECT invoice_no as [Invoice No.],
	   invoice_date as [Invoice Date],
	   visit_code as [Visit Code],
	   ISNULL(policy_name,'Self Pay') as [Policy Name],
	   hn as HN,
	   patient_name as [Patient Name],
	   gl_acct_code_code as [GL Acount Code],
	   gl_acct_name as [GL Account Name],
	   conquer_c as [Conquer C],
	   breast_center as [Breast Center],
	   simply_women as [Simply Women],
	   emmanuel as [Emmanuel],
	   chrys_pharmacy as [Chrys Pharmacy],
	   palliative_care as [Palliative Care],
	   home_care as [Home Care],
	   pain_management as [Pain Management Clinic]
from rpt_aci_visit_summary2
where  MONTH(invoice_date) >= @iMonth and MONTH(invoice_date) <= @iMonth2
    and YEAR(invoice_date) = @iYear
    and gl_acct_code_code not in ('2154940','4445000')