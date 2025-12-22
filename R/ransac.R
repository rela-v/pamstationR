point_line_distance <- function(point_coords, line_val, coord_col) {
  # For horizontal lines (y=c), distance is |point_y - c|
  # For vertical lines (x=c), distance is |point_x - c|
  abs(point_coords[[coord_col]] - line_val)
}

find_best_line_RANSAC <- function(data, threshold, iterations, coord_col) {
  best_inlier_count <- 0
  best_line_val <- NA
  data_matrix <- as.matrix(data)
  
  for (i in 1:iterations) {
    # 1. Random Sample: Select 1 random point (1 point defines a constant line)
    # The centroid coordinates are the list of points
    sample_index <- sample(nrow(data_matrix), 1)
    
    # The line model (the intercept 'c') is the coordinate of the sampled point
    proposed_line_val <- data_matrix[sample_index, coord_col]
    
    # 2. Consensus: Count inliers
    distances <- point_line_distance(data_matrix, proposed_line_val, coord_col)
    inliers <- distances < threshold
    inlier_count <- sum(inliers)
    
    # 3. Save: Check if this is the new best model
    if (inlier_count > best_inlier_count) {
      best_inlier_count <- inlier_count
      best_line_val <- proposed_line_val
    }
  }
  
  # Return the best line's intercept and its supporting points
  return(list(line_val = best_line_val, 
              inlier_count = best_inlier_count, 
              inliers = data_matrix[distances < threshold, ]))
}

find_all_lines <- function(data, threshold, iterations, coord_col) {
  all_lines <- c()
  current_data <- data
  
  # Keep searching as long as a line supports a minimum number of points
  min_points_per_line <- 5 # Tuning parameter
  
  while (nrow(current_data) >= min_points_per_line) {
    best_result <- find_best_line_RANSAC(current_data, threshold, iterations, coord_col)
    
    if (best_result$inlier_count >= min_points_per_line) {
      all_lines <- c(all_lines, best_result$line_val)
      
      # Remove inliers from current data for the next iteration
      # (Exclude points used in the best line to find the next parallel line)
      inlier_indices <- sapply(1:nrow(current_data), function(i) {
  point_line_distance(current_data[i, ], best_result$line_val, coord_col) < threshold
})
      current_data <- current_data[!inlier_indices, ]
    } else {
      break # Stop if no strong line is found
    }
  }
  return(sort(unique(all_lines)))
}

infer_regular_grid <- function(lines) {
  if (length(lines) < 2) {
    return(lines) # Not enough lines to infer a grid
  }
  
  # 1. Calculate the raw spacings (gaps) between adjacent lines
  spacings <- diff(lines)
  
  # 2. Determine the common mean spacing (Delta)
  mean_spacing <- mean(spacings)
  sd_spacing <- sd(spacings)
  
  # 3. Filter/Refine Lines based on regularity
  
  # Find the position of the first line (offset)
  first_line <- lines[1]
  
  # Determine which lines are close to a predicted regular position
  # A line is regular if its position is close to: first_line + k * mean_spacing
  
  regular_lines <- c()
  
  for (line_val in lines) {
    # Calculate the expected index (k) if this line were perfectly regular
    k_expected <- round((line_val - first_line) / mean_spacing)
    
    # Calculate the predicted position for that index
    predicted_pos <- first_line + k_expected * mean_spacing
    
    # Keep the line if its actual position is close to the predicted position
    # Tolerance is set by a multiple of the standard deviation (e.g., 2*SD)
    if (abs(line_val - predicted_pos) < 2 * sd_spacing) {
      regular_lines <- c(regular_lines, line_val)
    }
  }
  
  return(list(
    lines = sort(unique(regular_lines)),
    mean_spacing = mean_spacing
  ))
}
