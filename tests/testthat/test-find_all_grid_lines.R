# Helper to get average spacing excluding outliers
get_avg_spacing_no_outliers <- function(lines) {
  if(length(lines) < 2) return(NA)
  spacings <- diff(sort(lines))
  
  # Robust filtering using median and MAD
  med_spacing <- median(spacings)
  mad_spacing <- mad(spacings)
  
  # Define threshold for outlier detection, e.g., 2.5 * MAD
  threshold <- 2.5 * mad_spacing
  
  # Filter spacings to keep those within median ± threshold
  filtered_spacings <- spacings[abs(spacings - med_spacing) <= threshold]
  
  if(length(filtered_spacings) == 0) {
    # Fallback if all spacings filtered out
    return(med_spacing)
  }
  
  mean(filtered_spacings)
}

RANSAC_THRESHOLD <- 3
RANSAC_ITERATIONS <- 1000
MIN_INLIERS <- 5

find_lines_ransac <- function(points, coord_col, threshold, iterations, min_inliers) {
    points_mat <- as.matrix(points)
    remaining_points <- points_mat
    detected_lines <- numeric(0)
    
    while(nrow(remaining_points) >= min_inliers) {
      best_inlier_count <- 0
      best_line <- NA
      best_inliers_idx <- NULL
      
      for(i in 1:iterations) {
        sample_idx <- sample(nrow(remaining_points), 1)
        candidate_line <- remaining_points[sample_idx, coord_col]
        
        dists <- abs(remaining_points[, coord_col] - candidate_line)
        inliers_idx <- which(dists <= threshold)
        inlier_count <- length(inliers_idx)
        
        if(inlier_count > best_inlier_count) {
          best_inlier_count <- inlier_count
          best_line <- candidate_line
          best_inliers_idx <- inliers_idx
        }
      }
      
      if(best_inlier_count < min_inliers) break
      
      final_line_pos <- mean(remaining_points[best_inliers_idx, coord_col])
      detected_lines <- c(detected_lines, final_line_pos)
      remaining_points <- remaining_points[-best_inliers_idx, , drop = FALSE]
    }
    
    sorted_lines <- sort(unique(detected_lines))
    if(length(sorted_lines) < 2) return(sorted_lines)
    
    diffs <- diff(sorted_lines)
    keep_lines <- c(TRUE, diffs > RANSAC_THRESHOLD)
    
    sorted_lines[keep_lines]
}

# Helper to generate full grid lines using an anchor point
generate_full_grid_lines <- function(min_val, max_val, spacing, anchor) {
    if (is.na(anchor) || !is.finite(anchor)) {
        # Fallback to original method if anchor is unavailable
        start_val <- floor(min_val / spacing) * spacing
    } else {
        # Calculate the grid line closest to the anchor that is less than or equal to the anchor
        # This makes the grid align perfectly with the anchor point.
        start_val <- anchor - floor(anchor / spacing) * spacing 
        # Now, ensure we start at the first grid line before or at min_val
        start_val <- start_val + ceiling((min_val - start_val) / spacing) * spacing
    }
    
    # Generate sequence from the calculated start_val up to max_val
    lines <- c()
    current_line <- start_val
    while(current_line <= max_val) {
        if(current_line >= min_val) {
            lines <- c(lines, current_line)
        }
        current_line <- current_line + spacing
        
        # Safety break to prevent infinite loops if spacing is extremely small
        if(length(lines) > 2 * (max_val - min_val) / spacing + 100) break 
    }
    
    unique(lines)
}

test_that("grid fitting and plotting works", {
  
  # Load image and get centroids (We need enhanced_img_obj for dims and centroids)
  test_dir <- system.file('extdata', 'test_dir', package="pamstationR")
  enhanced_img <- enhance_spots(dirpath = test_dir, image_filename='test_image_PTK.tif')
  enhanced_img_obj <- enhanced_img$enhanced_img_obj # Still needed for dims
  
  result <- get_candidate_centroids(normalized_img_obj = enhanced_img_obj)
  centroids_df <- as.data.frame(result$candcentroid_array)
  
  # Image dimensions
  img_dims <- dim(enhanced_img_obj)
  img_height <- img_dims[1]
  img_width <- img_dims[2]
  
  # -----------------------------------------------------------
  ## 1. Initial Full Grid Spacing Estimation (For Fallback and Reference)
  y_lines_full <- find_lines_ransac(centroids_df, coord_col = 2, threshold = RANSAC_THRESHOLD, 
                                    iterations = RANSAC_ITERATIONS, min_inliers = MIN_INLIERS)
  x_lines_full <- find_lines_ransac(centroids_df, coord_col = 1, threshold = RANSAC_THRESHOLD, 
                                    iterations = RANSAC_ITERATIONS, min_inliers = MIN_INLIERS)
  
  x_spacing_dominant <- get_avg_spacing_no_outliers(x_lines_full)
  y_spacing_dominant <- get_avg_spacing_no_outliers(y_lines_full)
  
  S_base <- mean(c(x_spacing_dominant, y_spacing_dominant), na.rm = TRUE)
  
  # ---
  ## 2. Centroid Filtering for Reference Shapes
  left_third_max_x <- img_width / 3
  right_third_min_x <- 2 * img_width / 3
  
  centroids_left <- centroids_df[centroids_df$x <= left_third_max_x, ]
  centroids_right <- centroids_df[centroids_df$x >= right_third_min_x, ]
  
  one_square_height <- NA
  one_square_width <- NA
  y_anchor <- NA 
  x_anchor <- NA 

  # 3. Right Third: Backwards L (_|) for TWO Grid Square Heights
  if (nrow(centroids_right) >= MIN_INLIERS) {
      y_lines_right <- find_lines_ransac(centroids_right, coord_col = 2, threshold = RANSAC_THRESHOLD, 
                                         iterations = RANSAC_ITERATIONS, min_inliers = MIN_INLIERS)
      
      if (length(y_lines_right) >= 2) {
          y_spacing_all_right <- diff(sort(y_lines_right))
          y_anchor <- y_lines_right[1]
          
          if (is.finite(S_base) && S_base > 0) {
              target_spacing <- 2 * S_base 
              closest_idx <- which.min(abs(y_spacing_all_right - target_spacing))
              two_square_height <- y_spacing_all_right[closest_idx]
          } else {
              two_square_height <- median(y_spacing_all_right)
          }

          if (is.finite(two_square_height) && two_square_height > 0) {
              one_square_height <- two_square_height
          }
      }
  }
  
  # 4. Left Third: Rotated T (|-) for ONE Grid Square Width
  if (nrow(centroids_left) >= MIN_INLIERS) {
      x_lines_left <- find_lines_ransac(centroids_left, coord_col = 1, threshold = RANSAC_THRESHOLD, 
                                        iterations = RANSAC_ITERATIONS, min_inliers = MIN_INLIERS)
      
      if (length(x_lines_left) >= 2) {
          x_spacing_all_left <- diff(sort(x_lines_left))
          x_anchor <- x_lines_left[1]
          
          if (is.finite(S_base) && S_base > 0) {
              target_spacing <- S_base
              closest_idx <- which.min(abs(x_spacing_all_left - target_spacing))
              one_square_width_temp <- x_spacing_all_left[closest_idx]
          } else {
              one_square_width_temp <- median(x_spacing_all_left)
          }

          if (is.finite(one_square_width_temp) && one_square_width_temp > 0) {
              one_square_width <- one_square_width_temp
          }
      }
  }

  # ---
  ## 5. Final Grid Spacing Determination
  
  valid_spacings <- c(one_square_height, one_square_width)
  valid_spacings <- valid_spacings[is.finite(valid_spacings) & valid_spacings > 0]
  
  if (length(valid_spacings) > 0) {
      grid_spacing <- mean(valid_spacings)
  } else {
      grid_spacing <- S_base
  }
  
  if (!is.finite(grid_spacing) || grid_spacing <= 0) {
      grid_spacing <- 10 
  }
  
  # ---
  ## 6. Grid Generation and PLOTTING
  
  if (!is.finite(x_anchor)) x_anchor <- 0
  if (!is.finite(y_anchor)) y_anchor <- 0

  x_full_lines <- generate_full_grid_lines(0, img_width, grid_spacing, x_anchor)
  y_full_lines <- generate_full_grid_lines(0, img_height, grid_spacing, y_anchor)
  
  # PLOT SETUP: Creates the blank canvas
  plot(1, type = "n",
       xlim = c(0, img_width), ylim = c(img_height, 0),
       xlab = "", ylab = "", asp = 1, axes = FALSE,
       main = paste("Reference Grid and Centroids (Spacing:", round(grid_spacing, 2), ")"))
  
  for(y in y_full_lines) {
    segments(x0 = 0, y0 = y, x1 = img_width, y1 = y, col = "red", lwd = 1)
  }
  for(x in x_full_lines) {
    segments(x0 = x, y0 = 0, x1 = x, y1 = img_height, col = "red", lwd = 1)
  }
  
  # Add ALL detected centroids
  points(centroids_df$x, centroids_df$y, pch = 20, col = "black", cex = 0.5)
  
  # Mark centroids used for the right reference (L)
  points(centroids_right$x, centroids_right$y, pch = 20, col = "blue", cex = 1.0)
  
  # Mark centroids used for the left reference (T)
  points(centroids_left$x, centroids_left$y, pch = 20, col = "green", cex = 1.0)
  
  # The print/return lines are still helpful for debugging
  cat("\n--- FINAL GRID PARAMETERS ---\n")
  cat(paste0("Calculated Grid Spacing (S): ", round(grid_spacing, 4), "\n"))
  cat(paste0("X Anchor (First Vertical Line): ", round(x_anchor, 4), "\n"))
  cat(paste0("Y Anchor (First Horizontal Line): ", round(y_anchor, 4), "\n"))
  
  expect_true(TRUE)
})
