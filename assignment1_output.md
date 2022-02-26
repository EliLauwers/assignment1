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
    column, so two rows might exist with identical `branch.name`.

Every enterprise -or row- in the `branch` table has a location given by
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
every location must be linked to a branch, than branch employees can
only live in the location of a branch, which would be quite stupid.

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
shouldn’t be possible. I looked around and qquickly found proof for this
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