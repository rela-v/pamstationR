#' Get Candidate Centroids (Modified for Size Filtering)
#'
#' This function ingests an enhanced image object of class Image
#' from the EBImage package in R and outputs an object of
#' class S4Vectors::DataFrame. It now only fills the hull of rings
#' that are larger than a specified minimum area.
#' @param normalized_img_obj An R object of class Image from the
#' EBImage package (EBImage::Image) which has been enhanced
#' using the **enhance_spots** function.
#' @param min_area_threshold The minimum area (in pixels) for a ring
#' to have its hull filled. Objects smaller than this are left unfilled.
#' @return A named list, with one list item being named "candcentroid_array",
#' which contains an S4Vectors Dataframe of centroid coordinates.
#' @keywords data import image image-analysis preprocessing
#' @export

library(EBImage)
library(imager)
library(dplyr)
library(S4Vectors)

get_candidate_centroids <- function(normalized_img_obj, min_area_threshold = 40) {
  if (!inherits(normalized_img_obj, "Image")) {
    stop("Input object is not of class EBImage::Image. Please retry.")
  }
  if (all(dim(normalized_img_obj) == 0) || all(is.na(normalized_img_obj))) {
    stop("Input EBImage::Image is empty or contains only NA/NULL values.")
  }

  # Step 1: Threshold and label
  threshold_value <- max(normalized_img_obj) * 0.35
  binary_rings <- normalized_img_obj > threshold_value
  labeled_rings <- EBImage::bwlabel(binary_rings)

  # Step 2: Compute areas
  features <- EBImage::computeFeatures.shape(labeled_rings, binary_rings)
  areas <- features[, "s.area"]

  # Step 3: Separate large and small labels
  large_labels <- which(areas >= min_area_threshold)
  small_labels <- which(areas < min_area_threshold)

  # Step 4: Create masks by relabeling
  large_mask <- EBImage::rmObjects(labeled_rings, setdiff(seq_along(areas), large_labels))
  small_mask <- EBImage::rmObjects(labeled_rings, large_labels)

  # Convert masks to binary
  large_binary <- large_mask > 0
  small_binary <- small_mask > 0

  # Step 5: Fill hulls of large objects only
  filled_large_mask <- EBImage::fillHull(large_binary)

  # Step 6: Combine: filled large + unfilled small
  final_binary_image <- filled_large_mask

  # Step 7: Relabel and compute centroids
  final_labeled_image <- EBImage::bwlabel(final_binary_image)
  EBImage::display(final_labeled_image)

  # Compute centroids
  moment_features <- EBImage::computeFeatures.moment(final_labeled_image, final_binary_image)
  centroids <- S4Vectors::DataFrame(x = moment_features[, "m.cx"],
                                    y = moment_features[, "m.cy"])

  return(list(candcentroid_array = centroids))
}


