#' Read TIFF file
#'
#' This function ingests an image file in tiff format
#' (typically in an `ImageResults` subfolder) from
#' the Pamgene Pamstation kinome array device
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
#' @return A named list, with one list item being named "raw_array",
#' which contains an S4Vectors Dataframe of single-channel greyscale intensities
#' enhanced for visibility
#' @keywords raw-data data import image
#' @export
#' @examples
#' test_dir <- system.file('extdata', 'test_dir', package = "pamstationR")
#' read_tiff(dirpath = test_dir, image_filename='test_image_PTK.tif')

read_tiff <- function(dirpath,
                      image_filename,
                      image_folder_name = "ImageResults") {
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
  image_data <- suppressWarnings(EBImage::readImage(image_filepath, type="tiff"))
  img_matrix <- EBImage::imageData(image_data)
  img_dims <- dim(image_data)
  coords <- expand.grid(X = 1:img_dims[1], Y = 1:img_dims[2])
  tidy_df <- data.frame(
    coords,
    Value = as.vector(img_matrix)
  )
  s4_df <- S4Vectors::DataFrame(tidy_df)
  return(list(raw_array = s4_df))
}
