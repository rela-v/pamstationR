#' Import Pamstation folder
#'
#' This function imports a data folder, containing image data in tiff format
#' (typically in an `ImageResults` subfolder) from
#' the Pamgene Pamstation kinome array device.
#' @param filepath A character vector indicating the filepath for the
#' Pamstation data folder containing the image data.
#' @param image_folder_name A character vector indicating the
#' name of the ImageData subfolder contained within the Pamstation
#' data folder specified in **filepath** - default is "ImageResults".
#' @return A SummarizedExperiment object representing the intensity
#' statistics for each probe, well, and chip.
#' @seealso \code{\link[stats]{setNames}}, \code{\link{get_bmi_category}}
#' (assuming another function exists)
#' @keywords data import image
#' @export
#' @examples
#' # Example 1: A data folder at `/Users/user/project/data/pamstation_output_folder/`
#' import_data_folder(filepath = "/Users/user/project/data/pamstation_output_folder/",
#' image_folder_name = "ImageResults")
#'
#' # Example 2: A data folder within a data folder inside of the current working directory, at `./data/pamstation_output_folder/` where the image_folder_name is "ImageResults" (default)
#' import_data_folder(filepath = "data/pamstation_output_folder/")
import_data_folder <- function(filepath, image_folder_name = "ImageResults") {
  # Error handling (good practice but not strictly Roxygen2)
  TRUE
}
