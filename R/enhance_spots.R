#' Enhance Spots
#'
#' This function ingests an image file in tiff format
#' (typically in an `ImageResults` subfolder) from
#' the Pamgene Pamstation kinome array device
#' and enhances the image so that spots are more easily discerned.
#' @param dirpath A character vector indicating the dirpath for the
#' Pamstation data folder containing the image data.
#' @param image_folder_name A character vector indicating the
#' name of the ImageData subfolder contained within the Pamstation
#' data folder specified in **dirpath** - default is "ImageResults".
#' @param image_filename A character vector indicating the
#' filename of the *.tiff array image file to be processed,
#' contained within the Pamstation data folder specified in
#' the **dirpath** argument, within the **image_folder_name**
#' subdirectory.
#' @return A named list, with one list item being named "enhanced_array",
#' which contains an S4Vectors Dataframe of single-channel greyscale intensities
#' enhanced for visibility
#' @keywords data import image image-analysis preprocessing
#' @export
#' @examples
#' temp_dir <- withr::local_tempdir('folder_that_exists')
#' inner_name <- "ImageResults"
#' dir.create(file.path(temp_dir, inner_name))
#' file.create(file.path(temp_dir, inner_name, 'existing_image.tiff'))
#' enhance_spots(dirpath = temp_dir, image_filename='existing_image.tiff')

import_data_folder <- function(dirpath, array_annotation, sample_annotation, image_folder_name = "ImageResults") {
  if(dirpath %in% c('', NULL, NA)) {
    stop("Please input a non-empty dirpath to a pamstation-generated data folder containing a populated image data folder.")
  }
  if(!file.exists(dirpath)) {
    stop("Please input a dirpath to an existing pamstation-generated directory containing a populated image data folder.")
  }
  if(array_annotation %in% c('', NULL, NA)) {
    stop("Please input a non-empty filepath to a pamstation-generated array annotation file.")
  }
  if(!file.exists(array_annotation)) {
    stop("Please input a filepath to an existing array annotation file.")
  }
  if(sample_annotation %in% c('', NULL, NA)) {
    stop("Please input a non-empty filepath to a pamstation-generated sample annotation file.")
  }
  if(!file.exists(sample_annotation)) {
    stop("Please input a filepath to an existing sample annotation file.")
  }
  if(!image_folder_name %in% basename(list.dirs(dirpath))) {
    stop("Could not find image data folder (set by image_folder_name, default='ImageResults') in user set dirpath.")
  }
  result <- 1
  return(list(image_data=result))
}

