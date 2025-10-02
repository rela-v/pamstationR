test_that("read_tiff function exists", {
  expect_true(exists("read_tiff"))
})

test_that("read_tiff handles missing arguments", {
  expect_error(read_tiff(dirpath='', image_filename=''))
  expect_error(read_tiff(dirpath='folder_that_doesnt_exist'))
  test_dir <- system.file('extdata', 'test_dir', package="pamstationR")
  inner_name <- "ImageResults"
  expect_true(dir.exists(test_dir))
  expect_true(dir.exists(file.path(test_dir, inner_name)))
  expect_error(read_tiff(dirpath = test_dir, image_filename='nonexistent_image.tiff'))
  expect_no_error(read_tiff(dirpath = test_dir, image_filename='test_image_PTK.tif'))
})

test_that("read_tiff has all required arguments", {
  required_arguments <- c("dirpath", "image_filename")
  current_arguments <- names(formals("read_tiff"))
  logical_difference <- required_arguments %in% current_arguments
  expect_true(all(logical_difference))
})

test_that("read_tiff does not use an ellipsis", {
  expect_false(uses_ellipsis("read_tiff"))
})

test_that("read_tiff uses only the base R pipe ('|>')", {
    expect_false(uses_forbidden_pipe(body("read_tiff")))
})

test_that("read_tiff does not use unprefixed calls to external functions", {
  unprefixed_calls <- find_unprefixed_calls(body("read_tiff"), exported_function_list)
  length_unprefixed <- length(unprefixed_calls)
  expect_true(length_unprefixed==0)
})

test_that("read_tiff returns a named list", {
  test_dir <- system.file('extdata', 'test_dir', package="pamstationR")
  inner_name <- "ImageResults"
  expect_true(dir.exists(test_dir))
  expect_true(dir.exists(file.path(test_dir, inner_name)))
  expect_error(read_tiff(dirpath = test_dir, image_filename='nonexistent_image.tiff'))
  result <- read_tiff(dirpath = test_dir, image_filename='test_image_PTK.tif')
  expect_true(is_named_list(result))
})

test_that("read_tiff returns a named list containing an Image object in 'enhanced_array' list item", {
  test_dir <- system.file('extdata', 'test_dir', package="pamstationR")
  inner_name <- "ImageResults"
  expect_true(dir.exists(test_dir))
  expect_true(dir.exists(file.path(test_dir, inner_name)))
  expect_error(read_tiff(dirpath = test_dir, image_filename='nonexistent_image.tiff'))
  result <- read_tiff(dirpath = test_dir, image_filename='test_image_PTK.tif')
  expect_true(class(result$raw_array)=="DFrame")
})


