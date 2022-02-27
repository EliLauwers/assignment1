SELECT 
  r1.email,
  r1.license_plate license_plate1,
  r1.period_begin period_begin1,
  r2.license_plate license_plate2,
  r2.period_begin period_begin2
FROM registration r1
LEFT JOIN registration r2 ON r1.email = r2.email AND
  (r1.period_begin < r2.period_begin OR
  (r1.period_begin = r2.period_begin AND r1.license_plate < r2.license_plate))
WHERE r2.license_plate IS NOT null
