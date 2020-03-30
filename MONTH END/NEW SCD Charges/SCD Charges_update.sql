
UPDATE rpt_scd_chargesDUMP 
SET rpt_scd_chargesDUMP.item_code = rpt_vw_scd_charges2.item_code,
    rpt_scd_chargesDUMP.transaction_no = rpt_vw_scd_charges2.transaction_no,
    rpt_scd_chargesDUMP.discount_amount = rpt_vw_scd_charges2.discount_amount 
FROM rpt_scd_chargesDUMP  INNER JOIN rpt_vw_scd_charges2  ON rpt_scd_chargesDUMP.patient_name = rpt_vw_scd_charges2.patient_name
WHERE     rpt_scd_chargesDUMP.item_desc = rpt_vw_scd_charges2.item_desc
      and rpt_scd_chargesDUMP.charge_date = rpt_vw_scd_charges2.charge_date     
      and rpt_scd_chargesDUMP.month_rcd = 9
      and rpt_scd_chargesDUMP.year_rcd = 2019
