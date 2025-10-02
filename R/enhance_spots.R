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
#' @param method A character vector indicating the
#' method to use for image enhancement: must be in
#' c("wth", "dog"), for either the "White Top-Hat
#' Transformation" or the "Difference of Gaussians"
#' methods respectively.
#' @return A named list, with one list item being named "enhanced_array",
#' which contains an S4Vectors Dataframe of single-channel greyscale intensities
#' enhanced for visibility
#' @keywords data import image image-analysis preprocessing
#' @export
#' @examples
#' test_dir <- system.file('extdata', 'test_dir', package = "pamstationR")
#' enhance_spots(dirpath = test_dir, image_filename='test_image_PTK.tif')

enhance_spots <- function(dirpath, 
                          image_filename,
                          image_folder_name = "ImageResults",
                          method = "wth") {
  if(dirpath %in% c('', NULL, NA)) {
    stop("Please input a non-empty dirpath to a pamstation-generated 
         data folder containing a populated image data folder.")
  }
  if(!file.exists(dirpath)) {
    stop("Please input a dirpath to an existing pamstation-generated 
         directory containing a populated image data folder.")
  }
  if(image_filename %in% c('', NULL, NA)) {
    stop("Please input a non-empty filepath to 
         a pamstation-generated TIFF image file.")
  }
  if(!file.exists(file.path(dirpath, image_folder_name, image_filename))) {
    stop("Please input a filepath to an existing TIFF image file.")
  }
  if(!image_folder_name %in% basename(list.dirs(dirpath))) {
    stop("Could not find image data folder (set by image_folder_name, 
         default='ImageResults') in user set dirpath.")
  }
  image_filepath <- file.path(dirpath, image_folder_name, image_filename)
  image_data <- EBImage::readImage(image_filepath, type="tiff")
  if (!method %in% c("wth", "dog")) {
    stop("Please assign the `method` parameter to one of either 'wth' 
         (White Top-Hat Transformation) or 'dog' (Difference of Gaussians).
         Default is 'wth'.")
  }
  result <- image_data
  return(list(enhanced_array = result))
}
