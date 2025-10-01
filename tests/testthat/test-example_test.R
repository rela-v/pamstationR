test_that("import_data_folder function exists", {
  source('../../R/import_data_folder.R')
  expect_true(exists("import_data_folder"))
})
