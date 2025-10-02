# custom_expectations.R

has_roxygen_doc <- function(path) {
  
  if (!file.exists(path)) {
    warning(paste("File not found:", path), call. = FALSE)
    return(FALSE)
  }
  lines <- readLines(path, warn = FALSE)
  function_def_indices <- grep("<-[[:space:]]*function\\(|=[[:space:]]*function\\(", lines)
  if (length(function_def_indices) == 0) {
    return(TRUE) 
  }
  for (i in function_def_indices) {
    k <- i - 1
    while (k >= 1) {
      current_line_trimmed <- trimws(lines[k])
      if (current_line_trimmed != "") {
        if (startsWith(current_line_trimmed, "#'")) {
          return(TRUE)
        } else {
          return(FALSE)
        }
      }
      k <- k - 1
    }
    if (k < 1) {
      return(FALSE)
    }
  }
  return(TRUE)
}

uses_ellipsis <- function(fun) {
  fun <- get(fun)
  if (!is.function(fun)) {
    warning("Input to uses_ellipsis() is not a function.", call. = FALSE)
    return(FALSE)
  }
  arg_names <- names(formals(fun))
  return("..." %in% arg_names)
}

is_exported <- function(fun_name, pkg_name) {
  if (!requireNamespace(pkg_name, quietly = TRUE)) {
    warning(paste("Package", pkg_name, "is not installed or available."), call. = FALSE)
    return(FALSE)
  }
  exported_objects <- ls(name = paste0("package:", pkg_name), all.names = TRUE)
  return(fun_name %in% exported_objects)
}

uses_pipe_operator <- function(expr, pipe_operator) {
  if (!is.call(expr)) {
    return(FALSE)
  }
  if (identical(deparse1(expr[[1]]), pipe_operator)) {
    return(TRUE)
  }
  for (i in seq_along(expr)) {
    if (uses_pipe_operator(expr[[i]], pipe_operator)) {
      return(TRUE)
    }
  }
  return(FALSE)
}

uses_forbidden_pipe <- function(expr) {
  forbidden_pipe <- "%>%"
  if (!is.call(expr)) {
    return(FALSE)
  }
  if (identical(deparse1(expr[[1]]), forbidden_pipe)) {
    return(TRUE)
  }
  for (i in seq_along(expr)) {
    if (uses_forbidden_pipe(expr[[i]])) {
      return(TRUE)
    }
  }
  return(FALSE)
}

find_unprefixed_calls <- function(expr, local_fun_names) {
  unprefixed_calls <- character(0)
  if (!is.call(expr)) {
    return(unprefixed_calls)
  }
  base_functions <- ls(envir = as.environment("package:base"))
  safe_whitelist <- c(base_functions, local_fun_names)
  if (is.symbol(expr[[1]])) {
    fun_name <- as.character(expr[[1]])
    if (fun_name %in% c("<-", "=", "<<-", "$", "[", "::", ":::", "function", "if", "for", "while")) {
      # Do nothing; these are safe operators
    } 
    else if (fun_name %in% safe_whitelist) {
      # Do nothing; it's a base R or local function
    } 
    # If it's not a primitive, not base R, and not local, it MUST be an external package call
    else {
      unprefixed_calls <- c(unprefixed_calls, fun_name)
    }
  }
  for (i in seq_along(expr)) {
    unprefixed_calls <- c(unprefixed_calls, find_unprefixed_calls(expr[[i]], local_fun_names))
  }
  return(unique(unprefixed_calls))
}

is_named_list <- function(object) {
  
  # Check 1: Must be a list
  if (!is.list(object)) {
    return(FALSE)
  }
  
  # Check 2: Must have names (and names are not NULL)
  obj_names <- names(object)
  if (is.null(obj_names)) {
    return(FALSE)
  }
  
  # Check 3: Every element must have a non-empty, non-NA name
  # nchar("") == 0, so we check for nchar == 0
  if (any(is.na(obj_names) | nchar(trimws(obj_names)) == 0)) {
    return(FALSE)
  }
  
  # If all checks pass
  return(TRUE)
}
