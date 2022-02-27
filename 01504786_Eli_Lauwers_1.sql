SELECT DISTINCT
p.email
FROM registration r
LEFT JOIN car c USING(license_plate)
LEFT JOIN branch b USING(enterprisenumber)
LEFT JOIN person p USING(email)
WHERE 
/* Reverse the lowercase month name and take the first letter */
/* Then, check if that letter is 'r' */
substr(reverse(to_char(r.period_begin,'month')),1,1) = 'r' AND 
/* for every branch and person, calculate the sum of elements in the year field */
/* Next, compare both and retain those where elements are equal */
(cast(substr(p.postalcode, 1, 1) as integer) + 
cast(substr(p.postalcode, 2, 1) as integer) + 
cast(substr(p.postalcode, 3, 1) as integer) + 
cast(substr(p.postalcode, 4, 1) as integer)) = 
(cast(substr(b.postalcode, 1, 1) as integer) + 
cast(substr(b.postalcode, 2, 1) as integer) + 
cast(substr(b.postalcode, 3, 1) as integer) + 
cast(substr(b.postalcode, 4, 1) as integer))
