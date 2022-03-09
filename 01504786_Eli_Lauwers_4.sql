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
