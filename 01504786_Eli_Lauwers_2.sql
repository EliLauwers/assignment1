SELECT DISTINCT
e.email
FROM registration r
LEFT JOIN employee e USING(email)
LEFT JOIN contract con USING(employeenumber)
LEFT JOIN car c USING(license_plate)
WHERE
/* Select only if both enterpisenumbers are identical */
c.enterprisenumber = con.enterprisenumber AND
/* Select only if the rental period lays inside the contract interval */
con.period_begin <= r.period_begin AND
con.period_end >= r.period_end
ORDER BY
/* Order alphabetically */
e.email asc
