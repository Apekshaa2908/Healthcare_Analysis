DROP VIEW IF EXISTS vw_inpatient_analytics;
CREATE VIEW vw_inpatient_analytics AS
SELECT
    ip.facility_id,
    ip.rndrng_prvdr_org_name      AS provider_name,
    ip.rndrng_prvdr_state_abrvtn  AS state,
    ip.drg_cd,
    ip.drg_desc,
    ip.tot_dschrgs,
    ip.avg_submtd_cvrd_chrg,
    ip.avg_mdcr_pymt_amt,
    ip.billing_gap,
    ip.charge_ratio,
    p.hospital_type,
    p.hospital_ownership,
    d.mdc,
    d.mdc_name,
    d.drg_type,
    d.relative_weights,
    d.geometric_mean_los
FROM inpatient_payments ip
LEFT JOIN provider_info p
    ON ip.facility_id = p.facility_id
LEFT JOIN drg_details d
    ON ip.drg_cd = d.drgv22;
