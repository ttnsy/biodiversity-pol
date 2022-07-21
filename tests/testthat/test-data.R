test_that("Loaded data has expected columns", {
  col_occurence_clean_ref <- c("id","eventDate","eventTime",
   "NAME_1","NAME_2","latitude",
   "longitude","coordinateUncertaintyInMeters","taxonRank",
   "kingdom","family","scientificName",
   "vernacularName","individualCount")
  
  col_multimeida_clean_ref <- c("id","Identifier","type","rightsHolder","creator","accessURI","format","variantLiteral","license") 
  
  col_occurence_clean <- colnames(occurence_clean)
  col_multimedia_clean <- colnames(multimedia_clean)
  
  expect_equal(sort(col_occurence_clean_ref), sort(col_occurence_clean))
  expect_equal(sort(col_multimeida_clean_ref), sort(col_multimedia_clean))
})

test_that("Shapefile exist in directory", {
  cond <- length(list.files(path = "../../data/", pattern = "\\.sf.rds$")) > 0
  expect_true(cond)
})

test_that("Shapefile contains expected information", {
  expect_true("Poland" %in% shapefile$NAME_0)
  expect_true("NAME_2" %in% colnames(shapefile))
})