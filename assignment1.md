Assignment1 - Eli Lauwers
================

# 1 Consider the relational schema of the `rollsbin` database

## 1.1 Is it possible to assign multiple (different) locations to the same branch? Why (not)?

This question is a bit dependent on what exactly is a branch and how it
is related to an enterprise(name). I see two options, and I will give an
explanation for both.

1.  If two different numbers of `branch.enterprisenumber` are considered
    two different branches, than the answer is ‘no, multiple locations
    cannot be assigned to the same location’. Reason being that
    `branch.enterprisenumber`is the primary key, and will always be
    unique in the `branch` table. That means that a given number can
    only appear once in the table, and every enterprise in that sense
    will be coupled with one -and only one- location.

2.  If two different names in `branch.name` are considered two different
    branches, then the answer is ‘yes, multiple locations can be
    assigned to one branch’. There is no constraint on the `branch.name`
    column, so two rows might exist with identical `branch.name`. Every
    enterprise -or row- in the `branch` table has a location given by
    `branch.postalcode` and `branch.municipality`. If there are two rows
    with the same name and different locations, then we have a situation
    where multiple locations are assigned to the same branch.

I consider (2) to be the most logical case for this exercise. My final
answer follows (2)

**Answer**: Yes, multiple locations can be assigned to the same branch.

## 1.2 Is it possible to store locations that are not linked to a branch? Why (not)?

Yes, the only constraint for the `location`-table is that the pair of
`location.postalcode` and `location.muncipality`, being the (combined)
primary key must be unique. There is however no constraint that every
‘location’ must be present somewhere in the `branch` table.

Next, we know from the relational schema that locations are stored for
the branches as well as for the employee working for those branches. If
every location should have to be linked to a branch, than branch
employees can only live in the location of a branch, which would be
quite stupid.

**Answer**: Yes, it is possible to store locations not linked to a
branch.

# 2 Suppose one wants to select all data

Suppose one wants to select all data (i.e. data stored in columns
license\_plate, enterprisenumber, brand and model) related to cars of
type ‘cabriolet’. What is a potential issue that one may have when
executing the following SELECT-query for this task and why? How would
you solve this? Explain in your own words.

``` sql
SELECT DISTINCT 
  c.license_plate, c.enterprisenumber, c.brand, c.model
FROM car c
  INNER JOIN carmodel cm ON c.brand = cm.brand
  INNER JOIN type t ON cm.type = t.name
WHERE t.name = 'cabriolet'
```

In the first `INNER JOIN`, we’re joining solely on a cars brand.
However, in the `carmodel`-table, one brand can be linked with multiple
distinct models. Imagine a car of the brand ‘FIAT’ in the `cars`-table .
Next, imagine two carmodels in the `carmodel`-table for the FIAT brand:
FIAT **Punto** and FIAT **500**. As the inner join solely joins on
brand, both fiat models will be joined to only one car.

If this assumption is true, than in the result of the query we will see
identical numberplates linked to multiple distinct carmodels, which
shouldn’t be possible. I looked around and quickly found proof for this
hypthesis:

``` sql
SELECT *
FROM car c
  INNER JOIN carmodel cm ON c.brand = cm.brand
  INNER JOIN type t ON cm.type = t.name
WHERE t.name = 'cabriolet' AND c.license_plate = '1-IZX-389'
```

<div class="knitsql-table">

| license\_plate | enterprisenumber | brand | model        | brand..5 | model..6     | type      | name      | price\_per\_day |
|:---------------|-----------------:|:------|:-------------|:---------|:-------------|:----------|:----------|----------------:|
| 1-IZX-389      |       1740806639 | Audi  | A3 Cabriolet | Audi     | TT Roadster  | cabriolet | cabriolet |           70.44 |
| 1-IZX-389      |       1740806639 | Audi  | A3 Cabriolet | Audi     | A3 Cabriolet | cabriolet | cabriolet |           70.44 |

2 records

</div>

You can see that one license plate is linked to multiple car types,
which should not be possible.

To improve the query, one small fix has to be done. In the first
`INNER JOIN`, we will join on a cars brand, but also on a cars model. We
will then preform the same testquery to see if this strategy works
better. I also use the `USING` keyword as a preferation for working with
join-statements.

``` sql
SELECT *
FROM car c
  INNER JOIN carmodel cm USING(brand, model)
  INNER JOIN type t ON cm.type = t.name
WHERE t.name = 'cabriolet' AND c.license_plate = '1-IZX-389'
```

<div class="knitsql-table">

| brand | model        | license\_plate | enterprisenumber | type      | name      | price\_per\_day |
|:------|:-------------|:---------------|-----------------:|:----------|:----------|----------------:|
| Audi  | A3 Cabriolet | 1-IZX-389      |       1740806639 | cabriolet | cabriolet |           70.44 |

1 records

</div>

Looking at the test-query, we see that the problematic situation
encountered earlier was overcome!

## 2.1 Consider the following `SELECT`-query

``` sql
SELECT * FROM contract c1
  LEFT JOIN contract c2 ON c1.employeenumber = c2.employeenumber
    AND c1.enterprisenumber = c2.enterprisenumber
    AND c1.period_begin < c2.period_begin
WHERE c2.period_begin IS NULL;
```

Explain, in your own words, what this SELECT-query achieves. You should
not give the result table of this query or explain this query in
technical terms, but explain what the semantical outcome is of this
query when executed on data that is stored in the rollsrobin database.

The asterisk sign at the start of the query means that every column from
the resulting table will be selected and that no columns will be
removed.

Next, a `LEFT JOIN` is performed on the `contract`-table with itself
with three join-conditions, where every condition must be met to perform
a join:

-   `c1.employeenumber = c2.employeenumber`: every employee-contract is
    linked to every contract for that employee. If an employee has 5
    contracts, than the resulting table will have 25 rows (5 \* 5 = 25)
    for that employee.
-   `c1.enterprisenumber = c2.enterprisenumber`: An employees contracts
    will be linked, but only contracts within the same enterprise will
    be linked
-   `c1.period_begin < c2.period_begin`: The left contract can only be
    linked if the left starts earlier in time than the right one

Next, we filter the resulting table for rows where the `begin_period`
for the right contract is `null`.

The resulting table is thus an overview for every employee that shows
**the last** contract for a given enterprise. If an employee has worked
for multiple enterprises, than there will be a row for every enterprise
the employee has worked for.

## 2.2 Draw the table

Draw the entire table that will be returned upon completion of the given
query, starting from the example data of the contract table, given in
the appendix of this document.

| employeenumber | period\_begin | period\_end | enterprisenumber | employeenumber | period\_begin | period\_end | enterprisenumber |
|----------------|---------------|-------------|------------------|----------------|---------------|-------------|------------------|
| 1              | 01/07/2021    | 31/12/2021  | 102              | null           | null          | null        | null             |
| 1              | 01/08/2021    | 01/08/2023  | 101              | null           | null          | null        | null             |
| 2              | 24/02/2022    | 15/05/2022  | 101              | null           | null          | null        | null             |
| 2              | 31/05/2022    | 30/06/2022  | 104              | null           | null          | null        | null             |
| 3              | 01/10/2021    | 30/09/2022  | 103              | null           | null          | null        | null             |

## 2.3 Draw again

Suppose one removes the entire WHERE-clause from the SELECT-query. Draw,
again, the entire table that will be returned upon completion of the
given query (now without the WHERE-clause), starting from the example
data of the contract table, given in the appendix of this document.

| employeenumber | period\_begin | period\_end | enterprisenumber | employeenumber | period\_begin | period\_end | enterprisenumber |
|----------------|---------------|-------------|------------------|----------------|---------------|-------------|------------------|
| 1              | 12/01/2021    | 31/05/2021  | 101              | 1              | 01/02/2022    | 30/06/2022  | 101              |
| 1              | 12/01/2021    | 31/05/2021  | 101              | 1              | 01/08/2022    | 01/08/2023  | 101              |
| 1              | 01/02/2022    | 30/06/2022  | 101              | 1              | 01/08/2022    | 01/08/2023  | 101              |
| 1              | 01/07/2021    | 31/12/2021  | 102              | null           | null          | null        | null             |
| 1              | 01/08/2021    | 01/08/2023  | 101              | null           | null          | null        | null             |
| 2              | 24/02/2022    | 15/05/2022  | 101              | null           | null          | null        | null             |
| 2              | 31/05/2022    | 30/06/2022  | 104              | null           | null          | null        | null             |
| 3              | 01/10/2021    | 30/09/2022  | 103              | null           | null          | null        | null             |

## 2.4 Add a row

Is it possible to add the row {employeenumber: 1, period\_begin:
12/01/2021, period\_end: 31/01/2021, enterprisenumber: 103} to the
contract table given in the appendix of this document, considering the
relational schema of the rollsrobin database and the example data? Why
(not)?

Yes, this is possible. For the `contracts`-table, the primary key is a
combined key for the `contract.employeenumber`, `contract_begin` and
`contract.period_end`, which means that the combination of those
elements must be unique. There is a row where the employeenumber and
begin date are equal to this row of interest, but the period ends
differ.

Next, there is a constraint on the `contract`-table that a new row must
always have a begin date that is prior to the end date. That condition
is met in this test row

**Answer**: Yes, we can safely add the new row

# 3 Imagine

Imagine that the designers of the rollsrobin database would have left
out the employee table from the relational schema. Instead, all data
related to employees would then be stored in the person table (which
would include an extra column employeenumber). The foreign key in the
table contract, originally pointing to the employee table, would then
point to the column employeenumber in the person table. What are
possible (dis)advantages of this approach? Explain in your own words.

disadvantage: the `employeenumber` in the `person`-table must become
optional, as basic customers will not have an employeenumber. In that
sense, it is crucial that an employee can only be made with an
employeenumber, which is a check that has to be done by the form which
creates new employees.

**Answer**: I would advise against the integration of the `employee` and
`person` tables

# 4 Basic SQL

## 4.1 Postal codes and month letters

Construct a list of unique email addresses of all persons who did a
registration for which (1) the rented car is owned by a branch for which
the sum of the numbers in the branches postal code (branch.postalcode)
equals the sum of the numbers in the postal code of the person, who
rented the car (person.postalcode), and (2) the first date of the rental
period (registration.period\_begin) is in a month which name ends with
letter ‘r’ (in English). You may assume that all postal codes consist of
4 digits between 0 and 9. In the result table, we expect one column with
name email of datatype varchar.

``` sql
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
```

| email                             |
|:----------------------------------|
| <abdoultenny@outlook.com>         |
| <ajuni@dedomenicis.com>           |
| <aneel.vasser@gmail.com>          |
| <areen-waberer@hotmail.com>       |
| <dorian@claisse.com>              |
| <elouise@jon.nl>                  |
| <emmy-rae@haker.be>               |
| <fatima_shory@mail.be>            |
| <finnegan-macavaddy@yahoo.com>    |
| <ghitalamport@hotmail.com>        |
| <gregory_winspear@yahoo.com>      |
| <halima-frudd@gmail.com>          |
| <hannah-maymycroft@msn.be>        |
| <hidayah_atwill@yahoo.com>        |
| <jasmeet.rudinger@outlook.com>    |
| <kray-goldsmith@telenet.be>       |
| <kris.kneller@telenet.be>         |
| <laci-mai.corpes@yahoo.com>       |
| <leyah.brobyn@mail.be>            |
| <lilly-mai_leadbitter@gmail.com>  |
| <marguerite_burleigh@msn.be>      |
| <maybel_quaife@mail.be>           |
| <roberts_oattes@yahoo.com>        |
| <rosie-leigh-hassall@hotmail.com> |
| <shanique@stansall.nl>            |

## 4.2 Rentals during contract time

Construct a list of unique email addresses of all employees who rented a
car at a company at which they have worked. Moreover, the first date of
the rental period should fall within the period they were working at the
company (i.e. registration.period\_begin should be between
contract.period\_begin and contract.period\_end, boundaries inclusive).
In the result table, we expect one column with name email of datatype
varchar. Order the results in this table alphabetically according to the
values in the column email.

``` sql
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
```

| email                        |
|:-----------------------------|
| <ammaarwhotton@hotmail.com>  |
| <fiachrafrankema@msn.be>     |
| <krissie-stopps@outlook.com> |
| <layahscroxton@hotmail.com>  |
| <manal.peckitt@hotmail.com>  |
| <matthewroydon@yahoo.com>    |
| <milou_oakden@msn.be>        |

## 4.3 Unregistered locations

Construct a list of locations (postal code and municipality) in which
each location (1) is not registered as a residence of a person in the
database, (2) has an even postal code and (3) does not start with letter
‘B’ (case insensitive). In the result table, we expect two columns with
corresponding datatype: postalcode (varchar) and municipality (varchar).

``` sql
SELECT l.postalcode, l.municipality
FROM location l
LEFT JOIN person p USING(postalcode, municipality)
WHERE 
  /* If p.email is null, then the location is not 
  used for any person in the person table */
  p.email is null AND
  /* Check if first letter is B (case insensitive) */
  /* This can also be done with the substring command */
  l.municipality not ilike 'B%' AND
  /* Select only even postal codes */
  l.postalcode::integer % 2 = 0
```

| postalcode | municipality   |
|:-----------|:---------------|
| 8430       | Middelkerke    |
| 4780       | Sankt Vith     |
| 1820       | Steenokkerzeel |

## 4.4 Number of parts in municipality

Give for each location in the database (uniquely defined by postalcode
and municipality), the number of parts that make up the name of the
municipality. Here, a part is defined as a substring of the municipality
that is separated from other substrings by either a hyphen (“-”) or a
space (“ ”).

``` sql
SELECT 
  l.postalcode,
  l.municipality,
  /*
  calculate the difference in the length of the original string
  whith the length of the string where every hyphen and space are removed.
  The result is the number of spaces and hyphens in the original string. 
  Add 1 to this result to get the number of  parts in the string.
  Remember that removing a character is the same as replacing it with nothing.
  */
  length(l.municipality) - 
  length(replace(replace(l.municipality, '-', ''), ' ','')) + 1 as number
FROM location l
```

| postalcode | municipality               | number |
|:-----------|:---------------------------|-------:|
| 2870       | Puurs                      |      1 |
| 4170       | Comblain-au-Pont           |      3 |
| 4031       | Lüttich                    |      1 |
| 6230       | Pont-à-Celles              |      3 |
| 6832       | Bouillon                   |      1 |
| 2800       | Mechelen                   |      1 |
| 1670       | Pepingen                   |      1 |
| 2840       | Rumst                      |      1 |
| 8957       | Mesen                      |      1 |
| 8434       | Middelkerke                |      1 |
| 8510       | Kortrijk                   |      1 |
| 8930       | Menin                      |      1 |
| 1341       | Ottignies-Louvain-la-Neuve |      4 |
| 6593       | Momignies                  |      1 |
| 1476       | Genepiën                   |      1 |
| 7548       | Doornik                    |      1 |
| 9700       | Audenarde                  |      1 |
| 8755       | Ruiselede                  |      1 |
| 8904       | Ypres                      |      1 |
| 1410       | Waterloo                   |      1 |
| 8572       | Anzegem                    |      1 |
| 3840       | Borgloon                   |      1 |
| 4432       | Ans                        |      1 |
| 4000       | Liège                      |      1 |
| 1400       | Nijvel                     |      1 |

## 4.5 Customer pairs

Give all possible couples of registrations that were done by the same
person (i.e. the table that is returned by your query should contain
rows consisting of two registrations that were conducted by the same
person). Be aware of the fact that no rows may be present in your result
that contain two identical registrations (i.e. same person, car, begin
date and end date)! In order to prevent this, the value in column
period\_begin of the first registration should be chronologically strict
before the value in column period\_begin of the second registration.
However, if this value is the same for the two registrations, the value
in column license\_plate of the first registration should come
alphabetically strict before the value in column license\_plate of the
second registration.

``` sql
SELECT r1.email,
  r1.license_plate license_plate1,
  r1.period_begin period_begin1,
  r2.license_plate license_plate2,
  r2.period_begin period_begin2
FROM registration r1
  /* Join on email. however, in that case couples might be duplicated.
  To only get unique couples, use the period_begin and make sure the first is lower
  than the second. If both are equal, make sure that the license_plate of the
  first comes alphabetically before the second  */
INNER JOIN registration r2 ON r1.email = r2.email AND
  (r1.period_begin < r2.period_begin OR
  (r1.period_begin = r2.period_begin AND r1.license_plate < r2.license_plate))
```

| email                          | license\_plate1 | period\_begin1 | license\_plate2 | period\_begin2 |
|:-------------------------------|:----------------|:---------------|:----------------|:---------------|
| <aluna@bulleyn.com>            | 1-PZR-102       | 2018-08-08     | 1-YCA-352       | 2018-08-08     |
| <aariz_drewell@yahoo.com>      | 1-PZR-102       | 2017-07-03     | 1-BQE-096       | 2018-08-22     |
| <winifred.gellert@outlook.com> | 1-PZR-102       | 2017-01-15     | 1-BUL-570       | 2018-06-30     |
| <winifred.gellert@outlook.com> | 1-PZR-102       | 2017-01-15     | 1-POI-917       | 2017-06-08     |
| <winifred.gellert@outlook.com> | 1-PZR-102       | 2017-01-15     | 1-TRL-351       | 2017-01-15     |
| <winifred.gellert@outlook.com> | 1-PZR-102       | 2017-01-15     | 1-BCG-366       | 2018-06-30     |
| <winifred.gellert@outlook.com> | 1-PZR-102       | 2017-01-15     | 1-SVZ-211       | 2018-06-30     |
| <winifred.gellert@outlook.com> | 1-PZR-102       | 2017-01-15     | 1-GXK-887       | 2017-08-28     |
| <winifred.gellert@outlook.com> | 1-PZR-102       | 2017-01-15     | 1-FZS-779       | 2018-06-30     |
| <alexis_ahearne@yahoo.com>     | 1-IZX-389       | 2018-09-03     | 1-XFT-243       | 2018-09-03     |
| <heela-harses@gmail.com>       | 1-IZX-389       | 2018-01-13     | 1-ZFO-950       | 2018-01-13     |
| <heela-harses@gmail.com>       | 1-IZX-389       | 2018-01-13     | 1-OBQ-352       | 2018-01-13     |
| <heela-harses@gmail.com>       | 1-IZX-389       | 2018-01-13     | 1-WZC-412       | 2018-08-26     |
| <heela-harses@gmail.com>       | 1-IZX-389       | 2018-01-13     | 1-HEW-250       | 2018-10-24     |
| <heela-harses@gmail.com>       | 1-IZX-389       | 2018-01-13     | 1-BUP-153       | 2018-11-27     |
| <mitchel.pengelly@outlook.com> | 1-IZX-389       | 2018-08-16     | 1-VLZ-903       | 2018-09-23     |
| <iyla-mae.burgisi@outlook.com> | 1-IZX-389       | 2018-08-10     | 1-ZAI-317       | 2018-11-09     |
| <iyla-mae.burgisi@outlook.com> | 1-IZX-389       | 2018-08-10     | 1-QMT-716       | 2018-08-10     |
| <iyla-mae.burgisi@outlook.com> | 1-IZX-389       | 2018-08-10     | 1-TZS-216       | 2018-08-10     |
| <fausta-sparrow@msn.be>        | 1-IZX-389       | 2017-12-18     | 1-CRI-027       | 2018-04-21     |
| <fausta-sparrow@msn.be>        | 1-IZX-389       | 2017-12-18     | 1-VRM-549       | 2018-04-09     |
| <fausta-sparrow@msn.be>        | 1-IZX-389       | 2017-12-18     | 1-THX-072       | 2018-04-09     |
| <jawahir@daelman.be>           | 1-PPA-110       | 2017-05-17     | 1-LWY-156       | 2018-06-05     |
| <jawahir@daelman.be>           | 1-PPA-110       | 2017-05-17     | 1-OQQ-410       | 2018-06-02     |
| <jawahir@daelman.be>           | 1-PPA-110       | 2017-05-17     | 1-DCC-344       | 2018-07-24     |
