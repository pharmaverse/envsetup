#' Set the R autos
#'
#' Set the directory paths of any 'autos'. 'Autos' are
#' directory paths that hold .R files containing R functions. These paths may be
#' used when functions apply to an analysis, protocol, or even at a global
#' level, but don't fit in or necessarily require a package or haven't been
#' incorporated into a package.
#'
#' @param autos named list of character vectors
#' @param envsetup_environ name of the environment you would like to read from;
#' default values comes from the value in the system variable ENVSETUP_ENVIRON
#' which can be set by Sys.setenv(ENVSETUP_ENVIRON = "environment name")
#'
#' @return Called for side-effects. Directory paths of the R autos added to search path are printed.
#'
#' @importFrom purrr walk walk2
#' @importFrom rlang is_named
#' @importFrom usethis ui_field
#' @noRd
set_autos <- function(autos, envsetup_environ = Sys.getenv("ENVSETUP_ENVIRON")) {

  # Must be named list
  if (!is_named(autos)) {
    stop("Paths for autos in your envsetup configuration file must be named", call. = FALSE)
  }

  # remove NULL before further processing
  # NULL is expected for hierarchical paths when running in an environment
  # after the first level of the hierarchy
  autos <- autos[!vapply(autos, is.null, FALSE)]

  for (i in seq_along(autos)) {
    cur_autos <- autos[[i]]

    if (length(cur_autos) > 1) {
      # Hierarchical paths must be named
      if (!is_named(cur_autos)) {
        stop("Hierarchical autos paths in your envsetup configuration file must be named", call. = FALSE)
      }

      # envsetup_environ must be used if using hierarchical paths
      if (envsetup_environ == "") {
        stop(paste(
          "The envsetup_environ parameter or ENVSETUP_ENVIRON environment",
          "variable must be used if hierarchical autos are set."
        ), call. = FALSE)
      }
    }

    if (!is.null(names(cur_autos)) && !envsetup_environ %in% names(cur_autos)
        && envsetup_environ != "") {
      warning(paste(
        "The", ui_field(names(autos[i])), "autos has named",
        "environments",  ui_field(names(cur_autos)),
        "that do not match with the envsetup_environ parameter",
        "or ENVSETUP_ENVIRON environment variable",
        ui_field(envsetup_environ)
      ), call. = FALSE)
    }

    filtered_autos <- cur_autos

    if (envsetup_environ %in% names(cur_autos)) {
      filtered_autos <-
        cur_autos[which(names(cur_autos) == envsetup_environ):length(cur_autos)]
    }

    autos[[i]] <- filtered_autos
  }

  # Flatten the paths to collapse the names down to a single vector
  flattened_paths <- unlist(autos)

  # Check the autos before they're set
  if (!(is.null(flattened_paths) || is.character(flattened_paths))) {
    stop("Paths provided for autos must be directories", call. = FALSE)
  }

  # If there are any existing autos then reset them
  detach_autos()

  # Now attach everything. Note that attach will put an environment behind
  # global and in front of the package namespaces. By reversing the list,
  # the search path will be set to apply the autos to the name space so that
  # the path at element one of the list is directly behind global
  walk2(
    rev(flattened_paths),
    rev(names(flattened_paths)),
    ~ attach_auto(.x, .y)
  )
}

#' Source order of functions
#'
#' This function is used to define the sorting order of functions if
#' `@include` is used to define function dependencies.
#'
#' @param path Directory path
#' @noRd
collate_func <- function(path){
  r_scripts <- list.files(path,
                          pattern = ".r$",
                          ignore.case = TRUE,
                          full.names = TRUE
  )

  collated_func <- roxygen2:::generate_collate(path)

  if (is.null(collated_func)) {
    r_scripts
  } else {
    sapply(1:length(collated_func), function(x) file.path(path, collated_func[[x]]))
  }

}


#' Attach a function directory
#'
#' This function is used to create an rautos path. All .R files from a given
#' path are sourced. Functions are imported into from a directory and returned
#' to an environment. This environment can then be used to attach on to the
#' search path. This function should not be called directly. To apply autos,
#' use `set_autos()`.
#'
#' @param path Directory path
#' @param name Directory name
#' @noRd
#'
#' @return Called for side-effects. Directory paths of the R autos added to search path are printed.
attach_auto <- function(path, name) {
  name_with_prefix <- paste0("autos:", name)

  if (!(dir.exists(path) || file.exists(path))) {
    # Check if the auto actually exists
    warning(sprintf("An autos path specified in your envsetup configuration file does not exist: %s = %s", name, path),
            call. = FALSE)
  } else if (file.exists(path) && !dir.exists(path)) {
    # if file, source it
    sys.source(path, envir = attach(NULL, name = name_with_prefix))

    message("Attaching functions from ", path, " to ", name_with_prefix)
  } else {
    collated_r_scripts <- collate_func(path)

    if (!identical(collated_r_scripts, character(0))) {
      walk(collated_r_scripts,
        sys.source,
        envir = attach(NULL, name = name_with_prefix)
      )
      message("Attaching functions from ", path, " to ", name_with_prefix)
    } else {
      message("No files found in ", path, ". Nothing to attach.")
    }
  }
}

#' Detach the autos from the current session
#'
#' This function will remove any autos that have been set from the search path
#'
#' @return Called for its side-effects.
#' @export
#'
#' @examples
#' tmpdir <- tempdir()
#' print(tmpdir)
#'
#' # account for windows
#' if (Sys.info()['sysname'] == "Windows") {
#'   tmpdir <- gsub("\\", "\\\\", tmpdir, fixed = TRUE)
#' }
#'
#' # Create an example config file\
#' hierarchy <- paste0("default:
#'   paths:
#'     functions: !expr list(DEV = file.path('",tmpdir,"',
#'                                           'demo',
#'                                           'DEV',
#'                                           'username',
#'                                           'project1',
#'                                           'functions'),
#'                           PROD = file.path('",tmpdir,"',
#'                                            'demo',
#'                                            'PROD',
#'                                            'project1',
#'                                            'functions'))
#'   autos:
#'      my_functions: !expr list(DEV = file.path('",tmpdir,"',
#'                                               'demo',
#'                                               'DEV',
#'                                               'username',
#'                                               'project1',
#'                                               'functions'),
#'                               PROD = file.path('",tmpdir,"',
#'                                                'demo',
#'                                                'PROD',
#'                                                'project1',
#'                                                'functions'))")
#'
#' # write config
#' writeLines(hierarchy, file.path(tmpdir, "hierarchy.yml"))
#'
#' config <- config::get(file = file.path(tmpdir, "hierarchy.yml"))
#'
#' build_from_config(config)
#'
#' # write function to DEV
#' writeLines("dev_function <- function() {print(environment(dev_function))}",
#'            file.path(tmpdir, 'demo', 'DEV', 'username', 'project1', 'functions', 'dev_function.r'))
#'
#' # write function to PROD
#' writeLines("prod_function <- function() {print(environment(prod_function))}",
#'            file.path(tmpdir, 'demo', 'PROD', 'project1', 'functions', 'prod_function.r'))
#'
#' # setup the environment
#' Sys.setenv(ENVSETUP_ENVIRON = "DEV")
#' rprofile(config::get(file = file.path(tmpdir, "hierarchy.yml")))
#'
#' # show dev_function() and prod_function() are available and print their location
#' dev_function()
#' prod_function()
#'
#' # remove autos from search
#' detach_autos()
detach_autos <- function() {
  in_search <- search()[grepl("^autos:", search())]

  # Walk the list of autos and detach them
  walk(
    in_search,
    detach,
    character.only = TRUE
  )
}

#' Wrapper around library to place packages after any current autos
#'
#' Autos need to immediately follow the global environment.
#' This wrapper around `base::library()` will position any
#' attached packages in the earliest position on the
#' search path currently occupied by a package environment,
#' guaranteeing newly loaded packages appear before previously
#' loaded packages but after any currently attached non-packages.
#'
#' @usage NULL
#' @param ... pass directly through to base::library
#' @param pos see base::library. NULL (the default) is taken
#' to mean the earliest position of a package environment
#' within the current search path. If non-null, underlying
#' behavior of base::library is respected.
#'
#' @return returns (invisibly) the list of attached packages
#' @export
#'
#' @examples
#' # Simple example
#' library(purrr)
#'
#' # Illustrative example to show that autos will always remain above attached libraries
#' tmpdir <- tempdir()
#' print(tmpdir)
#'
#' # account for windows
#' if (Sys.info()['sysname'] == "Windows") {
#'   tmpdir <- gsub("\\", "\\\\", tmpdir, fixed = TRUE)
#' }
#'
#' # Create an example config file
#' hierarchy <- paste0("default:
#'   paths:
#'     functions: !expr list(
#'       DEV = file.path('",tmpdir,"', 'demo', 'DEV', 'username', 'project1', 'functions'),
#'       PROD = file.path('",tmpdir,"', 'demo', 'PROD', 'project1', 'functions'))
#'   autos:
#'     my_functions: !expr list(
#'       DEV = file.path('",tmpdir,"', 'demo', 'DEV', 'username', 'project1', 'functions'),
#'       PROD = file.path('",tmpdir,"', 'demo', 'PROD', 'project1', 'functions'))")
#'
#'
#' # write config
#' writeLines(hierarchy, file.path(tmpdir, "hierarchy.yml"))
#'
#' config <- config::get(file = file.path(tmpdir, "hierarchy.yml"))
#'
#' build_from_config(config)
#'
#' # write function to DEV
#' writeLines("dev_function <- function() {print(environment(dev_function))}",
#'            file.path(tmpdir, 'demo/DEV/username/project1/functions/dev_function.r'))
#'
#' # write function to PROD
#' writeLines("prod_function <- function() {print(environment(prod_function))}",
#'            file.path(tmpdir, 'demo/PROD/project1/functions/prod_function.r'))
#'
#' # setup the environment
#' Sys.setenv(ENVSETUP_ENVIRON = "DEV")
#' rprofile(config::get(file = file.path(tmpdir, "hierarchy.yml")))
#'
#' # show search
#' search()
#'
#' # now attach purrr
#' library(purrr)
#'
#' # see autos are still above purrr in the search path
#' search()
library <- function(..., pos = NULL) {
  if (is.null(pos)) {
    ## we have at least one package loaded (envsetup itself)
    ## use earliest current package position as place to
    ## attach all future packages, regardless of what
    ## envsetup, devtools, or anything else has put
    ## in front of them
    pos <- min(grep("^package:", search()))
  }
  base::library(..., pos = pos)
}
