SELECT DISTINCT e.email
FROM registration r
/* INNER JOIN ensures that the resulting table 
is a combination of all registrations by employees */
INNER JOIN employee e USING(email)
/* LEFT JOIN ensures that every employee-rental is 
matched with all contracts for that employee */
LEFT JOIN contract con USING(employeenumber)
LEFT JOIN car c USING(license_plate)
WHERE
/* Select only if enterprisenumbers for contract and rental car are identical */
/* Ensures that a car was rented from a branch where a contract was present */
c.enterprisenumber = con.enterprisenumber AND
/* Select only if the rental period lays inside the contract interval */
con.period_begin <= r.period_begin AND
con.period_end >= r.period_end
ORDER BY
/* Order alphabetically */
e.email asc