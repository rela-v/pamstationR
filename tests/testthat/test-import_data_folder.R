test_that("import_data_folder function exists", {
  expect_true(exists("import_data_folder"))
})

test_that("import_data_folder handles missing arguments", {
  expect_error(import_data_folder(dirpath=''))
  expect_error(import_data_folder(dirpath='folder_that_doesnt_exist'))
  temp_dir <- withr::local_tempdir('folder_that_exists')
  # 2. Create the Inner Directory using the outer path
  # We use tempfile() to generate a unique name, and then dir.create() 
  # to make the actual directory structure.
  inner_name <- "ImageResults"
  dir.create(file.path(temp_dir, inner_name))
  # Check if the structure exists
  expect_true(dir.exists(temp_dir))
  expect_true(dir.exists(file.path(temp_dir, inner_name)))
  array_annotation_file <- 'array_annotation.txt'
  expect_error(import_data_folder(dirpath = temp_dir, array_annotation = array_annotation_file, sample_annotation = sample_annotation_file))
  file.create(file.path(temp_dir, array_annotation_file))
  sample_annotation_file <- 'sample_annotation.txt'
  expect_error(import_data_folder(dirpath = temp_dir, array_annotation = file.path(temp_dir, array_annotation_file), sample_annotation = file.path(temp_dir, sample_annotation_file)))
  file.create(file.path(temp_dir, sample_annotation_file))
  expect_no_error(import_data_folder(dirpath = temp_dir, array_annotation = file.path(temp_dir, array_annotation_file), sample_annotation = file.path(temp_dir, sample_annotation_file)))
})

test_that("import_data_folder has all required arguments", {
  required_arguments <- c("dirpath", "array_annotation", "sample_annotation", "image_folder_name")
  current_arguments <- names(formals("import_data_folder"))
  logical_difference <- required_arguments %in% current_arguments
  expect_true(all(logical_difference))
})

test_that("import_data_folder does not use an ellipsis", {
  expect_false(uses_ellipsis("import_data_folder"))
})

test_that("import_data_folder uses only the base R pipe ('|>')", {
    expect_false(uses_forbidden_pipe(body("import_data_folder")))
})

test_that("import_data_folder does not use unprefixed calls to external functions", {
  unprefixed_calls <- find_unprefixed_calls(body("import_data_folder"), exported_function_list)
  length_unprefixed <- length(unprefixed_calls)
  expect_true(length_unprefixed==0)
})

test_that("import_data_folder returns a named list", {
  temp_dir <- withr::local_tempdir('folder_that_exists')
  inner_name <- "ImageResults"
  dir.create(file.path(temp_dir, inner_name))
  array_annotation_file <- 'array_annotation.txt'
  file.create(file.path(temp_dir, array_annotation_file))
  sample_annotation_file <- 'sample_annotation.txt'
  file.create(file.path(temp_dir, sample_annotation_file))
  result <- import_data_folder(dirpath = temp_dir, array_annotation = file.path(temp_dir, array_annotation_file), sample_annotation = file.path(temp_dir, sample_annotation_file))
  expect_true(is_named_list(result))
})
