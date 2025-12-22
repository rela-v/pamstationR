test_that("get_candidate_centroids function exists", {
  expect_true(exists("get_candidate_centroids"))
})

test_that("get_candidate_centroids handles missing arguments", {
  expect_error(get_candidate_centroids(normalized_img_obj=nonexistent_image))
  expect_error(get_candidate_centroids())
  test_dir <- system.file('extdata', 'test_dir', package="pamstationR")
  inner_name <- "ImageResults"
  enhanced_img_obj <- enhance_spots(dirpath = test_dir, image_filename='test_image_PTK.tif')$enhanced_img_obj
  expect_no_error(get_candidate_centroids(normalized_img_obj=enhanced_img_obj))
})

test_that("get_candidate_centroids has all required arguments", {
  required_arguments <- c("normalized_img_obj")
  current_arguments <- names(formals("get_candidate_centroids"))
  logical_difference <- required_arguments %in% current_arguments
  expect_true(all(logical_difference))
})

test_that("get_candidate_centroids does not use an ellipsis", {
  expect_false(uses_ellipsis("get_candidate_centroids"))
})

test_that("get_candidate_centroids uses only the base R pipe ('|>')", {
    expect_false(uses_forbidden_pipe(body("get_candidate_centroids")))
})

test_that("get_candidate_centroids does not use unprefixed calls to external functions", {
  unprefixed_calls <- find_unprefixed_calls(body("get_candidate_centroids"), exported_function_list)
  length_unprefixed <- length(unprefixed_calls)
  expect_true(length_unprefixed==0)
})

test_that("get_candidate_centroids returns a named list", {
  test_dir <- system.file('extdata', 'test_dir', package="pamstationR")
  inner_name <- "ImageResults"
  enhanced_img <- enhance_spots(dirpath = test_dir, image_filename='test_image_PTK.tif')
  enhanced_img_obj <- enhanced_img$enhanced_img_obj
  result <- get_candidate_centroids(normalized_img_obj=enhanced_img_obj)
  expect_true(is_named_list(result))
})

test_that("get_candidate_centroids returns a named list containing an DFrame object in 'candcentroid_array' list item", {
  test_dir <- system.file('extdata', 'test_dir', package="pamstationR")
  inner_name <- "ImageResults"
  enhanced_img <- enhance_spots(dirpath = test_dir, image_filename='test_image_PTK.tif')
  enhanced_img_obj <- enhanced_img$enhanced_img_obj
  result <- get_candidate_centroids(normalized_img_obj=enhanced_img_obj)
  expect_true(class(result$candcentroid_array) == "DFrame")
})
