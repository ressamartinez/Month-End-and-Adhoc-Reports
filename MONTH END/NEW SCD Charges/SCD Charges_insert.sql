
INSERT INTO [HISReport].[dbo].[rpt_scd_chargesDUMP]
                        ([item_desc]
                        ,[charge_date]
                        ,[PriceVATEx]
                        ,[quantity]
                        ,[charge_amount]
                        ,[osca_id]
                        ,[hospital_nr]
                        ,[patient_name]
                        ,[vendor]
                        ,[month_rcd]
                        ,[year_rcd]
                        ,[principal]
                        ,[source]
                        ,[item_type_rcd]
                        ,[vendor_code]
                        ,[main_item_group_code])

select distinct(item_desc),
          charge_date,
          unit_cost as PriceVATEx,
          quantity,
          charge_amount,
          CASE WHEN senior_id IS NULL THEN '' ELSE senior_id END AS osca_id,
          hospital_nr, 
          patient_name, 
          vendor, 
          month_rcd,
          year_rcd,
          principal,
          'Lab',
          item_type_rcd,
          vendor_code,
          main_item_group_code                     
FROM dbo.rpt_vw_scd_charges2 as scd_charges2
where     month_rcd = 9
         and year_rcd = 2019
