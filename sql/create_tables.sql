-- SQLite schema for the CMS Medicare inpatient payments case study

CREATE TABLE IF NOT EXISTS provider_info (
    facility_id         TEXT PRIMARY KEY,
    facility_name       TEXT,
    address             TEXT,
    city_town           TEXT,
    state               TEXT,
    zip_code            TEXT,
    hospital_type       TEXT,
    hospital_ownership  TEXT,
    emergency_services  TEXT
);

CREATE TABLE IF NOT EXISTS drg_details (
    drgv22              INTEGER PRIMARY KEY,
    drg_title           TEXT,
    mdc                 TEXT,
    mdc_name            TEXT,
    drg_type            TEXT,
    relative_weights    REAL,
    geometric_mean_los  REAL
);

CREATE TABLE IF NOT EXISTS inpatient_payments (
    rndrng_prvdr_ccn           INTEGER,
    facility_id                TEXT NOT NULL,
    rndrng_prvdr_org_name      TEXT,
    rndrng_prvdr_city          TEXT,
    rndrng_prvdr_state_abrvtn  TEXT,
    drg_cd                     INTEGER NOT NULL,
    drg_desc                   TEXT,
    tot_dschrgs                INTEGER,
    avg_submtd_cvrd_chrg       REAL,
    avg_tot_pymt_amt           REAL,
    avg_mdcr_pymt_amt          REAL,
    billing_gap                REAL,
    charge_ratio               REAL
);

CREATE INDEX IF NOT EXISTS idx_inpatient_facility_id ON inpatient_payments (facility_id);
CREATE INDEX IF NOT EXISTS idx_inpatient_drg_cd ON inpatient_payments (drg_cd);
