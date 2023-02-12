#' Read path
#'
#' Check each environment for the file and return the path to the first.
#'
#' The environments searched depends on the current environment.
#' For example, if your workflow contains a development (dev) area and
#' production area (prod), and the code is executing in the dev environment,
#' we search dev and prod. If in prod, we only search prod.
#'
#' @param lib object containing the paths for all environments of a directory
#' @param filename name of the file you would like to read
#' @param full.path logical to return the path including the file name
#' @param envsetup_environ name of the environment you would like to read the file from;
#' default values comes from the value in the system variable ENVSETUP_ENVIRON
#' which can be set by Sys.setenv(ENVSETUP_ENVIRON = "environment name")
#'
#' @return path of the first place the file is found
#' @export
#'
#' @examples
#' \dontrun{
#' read_path(a_in, "adsl.sas7bdat")
#' }
read_path <- function(lib,
                      filename,
                      full.path = TRUE,
                      envsetup_environ = Sys.getenv("ENVSETUP_ENVIRON")) {
  restricted_paths <- lib

  if (length(lib) > 1 && envsetup_environ == "") {
    stop(paste(
      "The envsetup_environ parameter or ENVSETUP_ENVIRON environment",
      "variable must be used if hierarchical paths are set."
    ), call. = FALSE)
  }

  if (envsetup_environ %in% names(lib)) {
    restricted_paths <- lib[which(names(lib) == envsetup_environ):length(lib)]
  }

  # find which paths have the object
  path_has_object <-
    sapply(
      unlist(restricted_paths),
      object_in_path,
      filename,
      simplify = TRUE
    )

  if (any(path_has_object) == FALSE) {
    stop(paste0(filename, " not found in ", substitute(lib)))
  }

  # subset and keep the first
  first_directory_found <- unlist(restricted_paths)[path_has_object][[1]]

  if (full.path == TRUE) {
    out_path <- file.path(first_directory_found, filename)
  } else {
    out_path <- first_directory_found
  }

  message("Read Path:", out_path, "\n")
  out_path
}


#' Retrieve a file path from an envsetup object containing paths
#'
#' Paths will be filtered to produce the lowest available level from a hierarchy
#' of paths based on envsetup_environ
#'
#' @param lib Object containing the paths for all environments of a directory
#' @param filename Name of the file you would like to write
#' @param envsetup_environ Name of the environment to which you would like to
#'   write. Defaults to the ENVSETUP_ENVIRON environment variable
#'
#' @return path to write
#' @export
#'
#' @examples
#' \dontrun{
#' write_path(a_in, "PROD")
#' }
write_path <- function(lib, filename = NULL, envsetup_environ = Sys.getenv("ENVSETUP_ENVIRON")) {
  # examine lib to ensure it's not a string
  # if it's a string, you end up with an incorrect path
  lib_arg <- rlang::quo_get_expr(rlang::enquo(lib))
  if(rlang::is_string(lib_arg)){
    stop(paste(
      "The lib argument should be an object containing the paths",
      "for all environments of a directory, not a string."
    ), call. = FALSE)
  }
  
  path <- lib

  if (length(lib) > 1 && envsetup_environ == "") {
    stop(paste(
      "The envsetup_environ parameter or ENVSETUP_ENVIRON environment",
      "variable must be used if hierarchical paths are set."
    ), call. = FALSE)
  }

  if (envsetup_environ %in% names(lib)) {
    path <- path[[envsetup_environ]]
  }

  out_path <- path

  if (!is.null(filename)) {
    out_path <- file.path(path, filename)
  }

  message("Write Path:", out_path, "\n")
  out_path
}


# return T/F for if the data exists in the directories
object_in_path <- function(path, object) {
  f_path <- file.path(path, object)
  file.exists(f_path)
}
