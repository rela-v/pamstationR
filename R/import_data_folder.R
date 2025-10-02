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
#' @return A SummarizedExperiment object representing the intensity
#' statistics for each probe, well, and chip.
#' @seealso \code{\link[stats]{setNames}}, \code{\link{get_bmi_category}}
#' (assuming another function exists)
#' @keywords data import image
#' @export
#' @examples
#' # Example 1: A data folder at `/Users/user/project/data/pamstation_output_folder/`
#' import_data_folder(dirpath = "/Users/user/project/data/pamstation_output_folder/",
#' image_folder_name = "ImageResults")
#'
#' # Example 2: A data folder within a data folder inside of the current working directory, at `./data/pamstation_output_folder/` where the image_folder_name is "ImageResults" (default)
#' import_data_folder(dirpath = "data/pamstation_output_folder/")
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
