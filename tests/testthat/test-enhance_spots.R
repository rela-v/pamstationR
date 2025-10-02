test_that("enhance_spots function exists", {
  expect_true(exists("enhance_spots"))
})

test_that("enhance_spots handles missing arguments", {
  expect_error(enhance_spots(dirpath='', image_filename=''))
  expect_error(enhance_spots(dirpath='folder_that_doesnt_exist'))
  test_dir <- system.file('extdata', 'test_dir', package="pamstationR")
  inner_name <- "ImageResults"
  expect_true(dir.exists(test_dir))
  expect_true(dir.exists(file.path(test_dir, inner_name)))
  expect_error(enhance_spots(dirpath = test_dir, image_filename='nonexistent_image.tiff'))
  expect_no_error(enhance_spots(dirpath = test_dir, image_filename='test_image_PTK.tif'))
})

test_that("enhance_spots has all required arguments", {
  required_arguments <- c("dirpath", "image_filename")
  current_arguments <- names(formals("enhance_spots"))
  logical_difference <- required_arguments %in% current_arguments
  expect_true(all(logical_difference))
})

test_that("enhance_spots does not use an ellipsis", {
  expect_false(uses_ellipsis("enhance_spots"))
})

test_that("enhance_spots uses only the base R pipe ('|>')", {
    expect_false(uses_forbidden_pipe(body("enhance_spots")))
})

test_that("enhance_spots does not use unprefixed calls to external functions", {
  unprefixed_calls <- find_unprefixed_calls(body("enhance_spots"), exported_function_list)
  length_unprefixed <- length(unprefixed_calls)
  expect_true(length_unprefixed==0)
})

test_that("enhance_spots returns a named list", {
  test_dir <- system.file('extdata', 'test_dir', package="pamstationR")
  inner_name <- "ImageResults"
  expect_true(dir.exists(test_dir))
  expect_true(dir.exists(file.path(test_dir, inner_name)))
  expect_error(enhance_spots(dirpath = test_dir, image_filename='nonexistent_image.tiff'))
  result <- enhance_spots(dirpath = test_dir, image_filename='test_image_PTK.tif')
  expect_true(is_named_list(result))
})

