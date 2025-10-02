test_that("code is documented", {
  filepaths <- list.files("R", full.names=TRUE)
  filepaths <- setdiff(filepaths, 'R/custom_expectations.R')
  expect_true(all(sapply(filepaths, function(filepath) {
                           has_roxygen_doc(filepath)
  })))
})

test_that("code exports all relevant functions", {
  logical_vector <- sapply(exported_function_list, function(fun, pkg="pamstationR") {
                             is_exported(fun, pkg_name=pkg)
})
  expect_true(all(logical_vector))
})

test_that("code only uses prefixed external function calls (none should be unprefixed)", {
  logical_vector <- sapply(exported_function_list, function(X) {
    unprefixed_calls <- find_unprefixed_calls(body(X), exported_function_list)
    length_unprefixed <- length(unprefixed_calls)
    length_unprefixed == 0
  })
  expect_true(all(logical_vector))
})

