SELECT 
  l.postalcode,
  l.municipality,
  length(l.municipality) - length(replace(replace(l.municipality, '-', ''), ' ','')) + 1 as numberlocation
FROM location l
