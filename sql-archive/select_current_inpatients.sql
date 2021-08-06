-- 2021-05-13
-- Steve Harris

-- finds necessary ids (identifiers) from hospital visit and demographics
-- then identifies which of those are inpatients
-- deals with current MRN issue

WITH ids AS (
SELECT DISTINCT
	
	 p.core_demographic_id
  ,mrn.mrn_id
  ,mrn_to_live.mrn_id AS mrn_id_alt
	,mrn.mrn
	,mrn.nhs_number
	,vo.hospital_visit_id 
	,vo.encounter

FROM star.hospital_visit vo 
-- get core_demographic id
LEFT JOIN star.core_demographic p ON vo.mrn_id = p.mrn_id
-- get current MRN
LEFT JOIN star.mrn_to_live ON p.mrn_id = mrn_to_live.mrn_id
LEFT JOIN star.mrn ON mrn_to_live.live_mrn_id = mrn.mrn_id

-- where inpatient
WHERE 
  vo.patient_class = 'INPATIENT'
  and
  vo.discharge_time IS NULL

), res AS (
SELECT
   vd.location_visit_id
  ,vd.admission_time
  ,vd.location_id
  ,loc.location_string
  ,ids.*
FROM 
  star.location_visit vd
RIGHT JOIN 
  ids
  ON vd.hospital_visit_id = ids.hospital_visit_id
LEFT JOIN
  star.location loc
  ON vd.location_id = loc.location_id
WHERE vd.discharge_time IS NULL
)

SELECT * FROM res


;
