#' Import Pamstation folder
#'
#' This function imports a data folder, containing image data in tiff format
#' (typically in an `ImageResults` subfolder) from
#' the Pamgene Pamstation kinome array device.
#' @param dirpath A character vector indicating the dirpath for the
#' Pamstation data folder containing the image data.
#' @param image_folder_name A character vector indicating the
#' name of the ImageData subfolder contained within the Pamstation
#' data folder specified in **dirpath** - default is "ImageResults".
#' @param array_annotation A character vector indicating the
#' name of the array annotation file contained within the Pamstation
#' data folder specified in **dirpath**.
#' This should contain annotations for every spot on the array and
#' their corresponding peptide/sequence/etc. annotations.
#' @param sample_annotation A character vector indicating the
#' name of the sample annotation file contained within the Pamstation
#' data folder specified in **dirpath**.
#' This should contain annotations for every sample on the array and
#' (one per well) with any relevant information included.
#' @return A named list, among which is one `image_data` object
#' accessible via return_object$image_data, which is a
#' SummarizedExperiment object representing the intensity
#' statistics for each probe, well, and chip.
#' @keywords data import image
#' @export
#' @examples
#' temp_dir <- withr::local_tempdir('folder_that_exists')
#' inner_name <- "ImageResults"
#' dir.create(file.path(temp_dir, inner_name))
#' array_annotation_file <- 'array_annotation.txt'
#' file.create(file.path(temp_dir, array_annotation_file))
#' sample_annotation_file <- 'sample_annotation.txt'
#' file.create(file.path(temp_dir, sample_annotation_file))
#' import_data_folder(dirpath = temp_dir,
#' array_annotation = file.path(temp_dir, array_annotation_file),
#' sample_annotation = file.path(temp_dir, sample_annotation_file))

import_data_folder <- function(dirpath,
                               array_annotation,
                               sample_annotation,
                               image_folder_name = "ImageResults") {
  if (dirpath %in% c("", NULL, NA)) {
    stop("Please input a non-empty dirpath to a pamstation-generated \
         data folder containing a populated image data folder.")
  }
  if (!file.exists(dirpath)) {
    stop("Please input a dirpath to an existing\
         pamstation-generated directory containing\
         a populated image data folder.")
  }
  if (array_annotation %in% c("", NULL, NA)) {
    stop("Please input a non-empty filepath\ 
         to a pamstation-generated array annotation file.")
  }
  if (!file.exists(array_annotation)) {
    stop("Please input a filepath to an existing array annotation file.")
  }
  if (sample_annotation %in% c("", NULL, NA)) {
    stop("Please input a non-empty filepath\
         to a pamstation-generated sample annotation file.")
  }
  if (!file.exists(sample_annotation)) {
    stop("Please input a filepath to an existing sample annotation file.")
  }
  if (!image_folder_name %in% basename(list.dirs(dirpath))) {
    stop("Could not find image\
         data folder (set by image_folder_name,\ 
         default='ImageResults') in user set dirpath.")
  }
  result <- 1
  return(list(image_data = result))
}
