SELECT l.postalcode, l.municipality
FROM location l
LEFT JOIN person p USING(postalcode, municipality)
WHERE 
  /* If p.email is null, then the location is not */
  /* used for any person in the person table */
  p.email is null AND
  /* Check if first letter is B (case insensitive) */
  /* This can also be done with the substring command */
  l.municipality not ilike 'B%' AND
  /* Select only even postal codes */
  cast(l.postalcode as integer) % 2 = 0
