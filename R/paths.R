#' Environment Setup Environment
#'
#' A dedicated environment object used to store and manage path configurations
#' and other setup variables for the envsetup package. This environment provides
#' an isolated namespace for storing path objects that can be retrieved using
#' the package's path management functions.
#'
#' @format An environment object created with \code{new.env()}.
#'
#' @details
#' This environment serves as the default storage location for path objects
#' when using envsetup package functions. It helps maintain clean separation
#' between user workspace and package-managed paths.
#'
#' @examples
#' # Store a path in the envsetup environment
#' assign("project_root", "/path/to/project", envir = envsetup_environment)
#'
#' # List objects in the environment
#' ls(envir = envsetup_environment)
#'
#' # Check if the environment exists and is an environment
#' exists("envsetup_environment")
#' is.environment(envsetup_environment)
#'
#' @seealso \code{\link{get_path}}, \code{\link[base]{new.env}}
#'
#' @export
envsetup_environment <- new.env()

#' Get Path Object from Environment
#'
#' Retrieves a path object from the specified environment using non-standard
#' evaluation. The function uses `substitute()` to capture the unevaluated
#' expression and `get()` to retrieve the corresponding object.
#'
#' @param path An unquoted name of the path object to retrieve from the environment.
#' @param envir The environment to search for the path object. Defaults to the
#'   value of `getOption("envsetup.path.environment")`.
#'
#' @return The path object stored in the specified environment under the given name.
#'
#' @examples
#' # Create a custom environment and store some paths
#' path_env <- new.env()
#' assign("data_dir", "/home/user/data", envir = path_env)
#' assign("output_dir", "/home/user/output", envir = path_env)
#'
#' # Set up the option to use our custom environment
#' options(envsetup.path.environment = path_env)
#'
#' # Retrieve paths using the function
#' data_path <- get_path(data_dir)
#' output_path <- get_path(output_dir)
#'
#' print(data_path)    # "/home/user/data"
#' print(output_path)  # "/home/user/output"
#'
#' # Using with a different environment
#' temp_env <- new.env()
#' assign("temp_dir", "/tmp/analysis", envir = temp_env)
#' temp_path <- get_path(temp_dir, envir = temp_env)
#' print(temp_path)    # "/tmp/analysis"
#'
#' @seealso \code{\link[base]{get}}, \code{\link[base]{substitute}}
#'
#' @export
get_path <- function(path, envir = getOption("envsetup.path.environment")){
  base::get(substitute(path), envir)
}

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
#' @param envir The environment to search for the path object. Defaults to the
#'   value of `getOption("envsetup.path.environment")`.
#'
#' @importFrom rlang quo_get_expr enquo is_string
#'
#' @return string containing the path of the first directory the file is found
#' @export
#'
#' @examples
#' tmpdir <- tempdir()
#'
#' # account for windows
#' if (Sys.info()['sysname'] == "Windows") {
#'   tmpdir <- gsub("\\", "\\\\", tmpdir, fixed = TRUE)
#' }
#'
#' # add config for just the data location
#' hierarchy <- paste0("default:
#'   paths:
#'     data: !expr list(
#'       DEV = file.path('",tmpdir,"', 'demo', 'DEV', 'username', 'project1', 'data'),
#'       PROD = file.path('",tmpdir,"', 'demo', 'PROD', 'project1', 'data'))")
#'
#' # write config file to temp directory
#' writeLines(hierarchy, file.path(tmpdir, "hierarchy.yml"))
#'
#' config <- config::get(file = file.path(tmpdir, "hierarchy.yml"))
#'
#' # build folder structure from config
#' build_from_config(config)
#'
#' # setup environment based on config
#' rprofile(config::get(file = file.path(tmpdir, "hierarchy.yml")))
#'
#' # place data in prod data folder
#' saveRDS(mtcars, file.path(tmpdir, "demo/PROD/project1/data/mtcars.rds"))
#'
#' # find the location of mtcars.rds
#' read_path(data, "mtcars.rds")
read_path <- function(lib,
                      filename,
                      full.path = TRUE,
                      envsetup_environ = Sys.getenv("ENVSETUP_ENVIRON"),
                      envir = getOption("envsetup.path.environment")) {

  # lib can be a object in a different environment
  # get this directly from envsetup_environment
  lib_arg <- quo_get_expr(enquo(lib))

  if (is_string(lib_arg)) {
    stop(paste(
      "The lib argument should be an object containing the paths",
      "for all environments of a directory, not a string."
    ), call. = FALSE)
  }

  read_lib <- base::get(toString(lib_arg), envir)

  restricted_paths <- read_lib

  if (length(read_lib) > 1 && envsetup_environ == "") {
    stop(paste(
      "The envsetup_environ parameter or ENVSETUP_ENVIRON environment",
      "variable must be used if hierarchical paths are set."
    ), call. = FALSE)
  }

  if (envsetup_environ %in% names(read_lib)) {
    restricted_paths <- read_lib[which(names(read_lib) == envsetup_environ):length(read_lib)]
  } else if (length(read_lib) > 1) {
    warning(paste(
      "The path has named environments",
      usethis::ui_field(names(read_lib)),
      "that do not match with the envsetup_environ parameter",
      "or ENVSETUP_ENVIRON environment variable",
      usethis::ui_field(envsetup_environ)
    ), call. = FALSE)
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
    stop(paste0(filename, " not found in ", substitute(read_lib)))
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
#' @param envir The environment to search for the path object. Defaults to the
#'   value of `getOption("envsetup.path.environment")`.
#'
#' @importFrom rlang quo_get_expr enquo is_string
#'
#' @return path to write
#' @export
#'
#' @examples
#' tmpdir <- tempdir()
#'
#' # account for windows
#' if (Sys.info()['sysname'] == "Windows") {
#'   tmpdir <- gsub("\\", "\\\\", tmpdir, fixed = TRUE)
#' }
#'
#' # add config for just the data location
#' hierarchy <- paste0("default:
#'   paths:
#'     data: !expr list(
#'       DEV = file.path('",tmpdir,"', 'demo', 'DEV', 'username', 'project1', 'data'),
#'       PROD = file.path('",tmpdir,"', 'demo', 'PROD', 'project1', 'data'))")
#'
#' # write config file to temp directory
#' writeLines(hierarchy, file.path(tmpdir, "hierarchy.yml"))
#'
#' config <- config::get(file = file.path(tmpdir, "hierarchy.yml"))
#'
#' # build folder structure from config
#' build_from_config(config)
#'
#' # setup environment based on config
#' rprofile(config::get(file = file.path(tmpdir, "hierarchy.yml")))
#'
#' # find location to write mtcars.rds
#' write_path(data, "mtcars.rds")
#'
#' # save data in data folder using write_path
#' saveRDS(mtcars, write_path(data, "mtcars.rds"))
write_path <- function(lib, filename = NULL, envsetup_environ = Sys.getenv("ENVSETUP_ENVIRON"),
                       envir = getOption("envsetup.path.environment")) {
  # examine lib to ensure it's not a string
  # if it's a string, you end up with an incorrect path
  lib_arg <- quo_get_expr(enquo(lib))

  if (is_string(lib_arg)) {
    stop(paste(
      "The lib argument should be an object containing the paths",
      "for all environments of a directory, not a string."
    ), call. = FALSE)
  }

  write_path <- base::get(toString(lib_arg), envir)
  path <- write_path

  if (length(write_path) > 1 && envsetup_environ == "") {
    stop(paste(
      "The envsetup_environ parameter or ENVSETUP_ENVIRON environment",
      "variable must be used if hierarchical paths are set."
    ), call. = FALSE)
  }

  if (envsetup_environ %in% names(write_path)) {
    path <- path[[envsetup_environ]]
  } else if (length(write_path) > 1) {
    warning(paste(
      "The path has named environments",
      usethis::ui_field(names(lib)),
      "that do not match with the envsetup_environ parameter",
      "or ENVSETUP_ENVIRON environment variable",
      usethis::ui_field(envsetup_environ)
    ), call. = FALSE)
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




#' Build directory structure from a configuration file
#'
#' @param config configuration object from config::get() containing paths
#' @param root root directory to build from.
#' Leave as NULL if using absolute paths.  Set to working directory if using relative paths.
#'
#' @importFrom fs dir_tree
#' @importFrom usethis ui_done
#'
#' @return Called for its side-effects. The directories build print as a tree-like format from `fs::dir_tree()`.
#' @export
#'
#' @examples
#' tmpdir <- tempdir()
#'
#' hierarchy <- "default:
#'   paths:
#'     data: !expr list(DEV = '/demo/DEV/username/project1/data',
#'                      PROD = '/demo/PROD/project1/data')
#'     output: !expr list(DEV = '/demo/DEV/username/project1/output',
#'                        PROD = '/demo/PROD/project1/output')
#'     programs: !expr list(DEV = '/demo/DEV/username/project1/programs',
#'                          PROD = '/demo/PROD/project1/programs')
#'     docs: !expr list(DEV = 'docs',
#'                      PROD = 'docs')"
#'
#' writeLines(hierarchy, file.path(tmpdir, "hierarchy.yml"))
#'
#' config <- config::get(file = file.path(tmpdir, "hierarchy.yml"))
#'
#' build_from_config(config, tmpdir)
build_from_config <- function(config, root = NULL) {
  if (!exists("paths", where = config)) {
    usethis::ui_oops("No paths are specified as part of your configuration.  Update your config file to add paths.")
    return(invisible())
  }

  if (is.null(root)) {
    paths <- unlist(config$paths, use.names = FALSE)
  } else {
    paths <- file.path(root, unlist(config$paths, use.names = FALSE))
  }

  walk(paths, ~ {
    if (!dir.exists(.x)) {
      dir.create(.x, recursive = TRUE)
    }
  })

  # find the root of the paths provided in the config
  if (is.null(root)) {
    base_path <- strsplit(paths[1], "")[[1]]

    for (i in seq_along(paths)) {
      compare_path <- strsplit(paths[i], "")[[1]]

      end <- min(length(base_path), length(compare_path))

      tf <- base_path[1:end] == compare_path[1:end]

      first_false <- min(which(tf == FALSE), end + 1)

      base_path <- base_path[1:first_false - 1]
    }

    root <- paste0(base_path, collapse = "")
  }

  ui_done("Directories built")
  dir_tree(root, type = "directory")
}
