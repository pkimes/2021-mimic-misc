WITH
## list of unique admissions
ADMISSIONS as (
  SELECT * EXCEPT (ROW_ID)
  FROM `physionet-data.mimiciii_clinical.admissions`
  WHERE HAS_CHARTEVENTS_DATA = 1
),

## list of unique admissions and ED admission date times 
ADM_DATES as (
  SELECT DISTINCT SUBJECT_ID, HADM_ID, EDREGTIME
  FROM `physionet-data.mimiciii_clinical.admissions`
  WHERE HAS_CHARTEVENTS_DATA = 1
),

## subset to notes from ED admission date
FIRSTDAY_NOTES as (
  SELECT * EXCEPT (EDREGTIME)
  FROM `physionet-data.mimiciii_notes.noteevents`
  LEFT JOIN ADM_DATES
  USING (SUBJECT_ID, HADM_ID)
  WHERE DATE_DIFF(EDREGTIME, CHARTDATE, DAY) = 0
),

## average oasis score per admission
OASIS AS (
  SELECT DISTINCT SUBJECT_ID, HADM_ID,
    AVG(AGE) AS AVG_OASIS_AGE,
    AVG(oasis_PROB) AS AVG_OASIS_PROB,
    AVG(oasis) as AVG_OASIS,
    MAX(mechvent) as MECHVENT
  FROM `physionet-data.mimiciii_derived.oasis`
  GROUP BY SUBJECT_ID, HADM_ID
),

## add oasis score, first day notes to list of unique admissions
PATIENT_NOTES as (
  SELECT *
  FROM ADMISSIONS
  LEFT JOIN OASIS
  USING (SUBJECT_ID, HADM_ID)
  LEFT JOIN FIRSTDAY_NOTES 
  USING (SUBJECT_ID, HADM_ID)
)

SELECT DISTINCT *
FROM PATIENT_NOTES
