SELECT DISTINCT p.email
FROM registration r
LEFT JOIN car c USING(license_plate)
LEFT JOIN branch b USING(enterprisenumber)
LEFT JOIN person p USING(email)
WHERE 
  /* Reverse the lowercase month name and take the first letter */
  /* Use FM (Fillmode) to not get a space character as the last character*/
  /* Then, check if that letter is 'r' */
    substr(reverse(to_char(r.period_begin,'FMmonth')),1,1) = 'r' 
  AND 
  /* for every branch and person, calculate the sum of elements in the year field */
  /* Next, compare both and retain those where elements are equal */
  ((substr(p.postalcode, 1, 1)::integer) + 
  (substr(p.postalcode, 2, 1)::integer) + 
  (substr(p.postalcode, 3, 1)::integer) + 
  (substr(p.postalcode, 4, 1)::integer)) = 
  ((substr(b.postalcode, 1, 1)::integer) + 
  (substr(b.postalcode, 2, 1)::integer) + 
  (substr(b.postalcode, 3, 1)::integer) + 
  (substr(b.postalcode, 4, 1)::integer)) 
