compare_assignment = function(nms, df1, df2){
  if(!all(nms %in% names(df1))) stop(glue::glue("df1 does not contain all names in, {nms}"))
  if(!all(nms %in% names(df2))) stop(glue::glue("df2 does not contain all names in, {nms}"))
  if(nrow(df1) != nrow(df2)) stop(glue::glue("dfs do not contain same amount of rows"))
  
  df1_col = apply(df1[nms],MARGIN = 1, paste, collapse = ";")
  df2_col = apply(df2[nms],MARGIN = 1, paste, collapse = ";")
  
  if(!all(df1_col %in% df2_col)){
    print("Some rows in df1 but not in df2")
    print(df1_col[!df1_col%in%df2_col])
    stop("Some rows in df1 but not in df2")
  }
  
  if(!all(df2_col %in% df1_col)){
    print("Some rows in df2 but not in df1")
    print(df2_col[!df2_col%in%df1_col])
    stop("Some rows in df2 but not in df1")
  }
  print("All oke")  
}

nms = c("email")
df1 = read.csv("csv_tables/df1.csv")
df2 = read.csv("test_output/Q1.csv")
compare_assignment(nms, df1, df2)

nms = c("email")
df1 = read.csv("csv_tables/df2.csv")
df2 = read.csv("test_output/Q2.csv")
compare_assignment(nms, df1, df2)

nms = c("postalcode","municipality")
df1 = read.csv("csv_tables/df3.csv")
df2 = read.csv("test_output/Q3.csv")
compare_assignment(nms, df1, df2)

nms = c("postalcode","municipality","number")
df1 = read.csv("csv_tables/df4.csv")
df2 = read.csv("test_output/Q4.csv")
compare_assignment(nms, df1, df2)

nms = c("email","license_plate1","period_begin1","license_plate2","period_begin2")
df1 = read.csv("csv_tables/df5.csv")
df2 = read.csv("test_output/Q5.csv")
compare_assignment(nms, df1, df2)

