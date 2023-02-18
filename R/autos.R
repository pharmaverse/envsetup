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
#' @return Directory paths of the R autos
#'
#' @importFrom purrr walk walk2
#' @noRd
#'
#' @examples
#' \dontrun{
#' set_autos(envsetup_config$autos)
#' }
set_autos <- function(autos, envsetup_environ = Sys.getenv("ENVSETUP_ENVIRON")) {

  # Must be named list
  if (!rlang::is_named(autos)) {
    stop("Paths for autos in _envsetup.yml must be named", call.=FALSE)
  }

  for (i in seq_along(autos)) {
    cur_autos <- autos[[i]]

    if (length(cur_autos) > 1) {
      # Hierarchical paths must be named
      if (!rlang::is_named(cur_autos)) {
        stop("Hierarchical autos paths in _envsetup_yml must be named", call.=FALSE)
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
        && envsetup_environ != ""){
      warning(paste(
        "The", usethis::ui_field(names(autos[i])), "autos has named",
        "environments",  usethis::ui_field(names(cur_autos)),
        "that do not match with the envsetup_environ parameter",
        "or ENVSETUP_ENVIRON environment variable",
        usethis::ui_field(envsetup_environ)
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


#' Attach a function directory
#'
#' This function is used to create an rautos path. All .R files from a given
#' path are sourced. Functions are imported into from a directory and returned
#' to an environment. This environment can then be used to attach on to the
#' search path. This function should not be called directly. To apply autos,
#' use `set_autos()`.
#'
#'
#' @param path Directory path
#' @param name Directory name
#'
#' @return Environment containing functions
#'
#' @examples
#' \dontrun{
#' attach_auto("./my_funcs", "my_autos")
#' }
attach_auto <- function(path, name) {
  name_with_prefix <- paste0("autos:", name)

  if (!(dir.exists(path) || file.exists(path))) {
    # Check if the auto actually exists
    warning(sprintf("Autos path specified in _envsetup.yml does not exist: %s = %s", name, path),
         call.=FALSE)
  } else if (file.exists(path) && !dir.exists(path)) {
    # if file, source it
    sys.source(path, envir = attach(NULL, name = name_with_prefix))

    message("Attaching functions from ", path, " to ", name_with_prefix)
  } else {
    # Find all the R files in the given path
    r_scripts <- list.files(path,
      pattern = ".r$",
      ignore.case = TRUE,
      full.names = TRUE
    )

    if (!identical(r_scripts, character(0))) {
      walk(r_scripts,
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
#' @export
#'
#' @examples
#' \dontrun{
#' detach_autos()
#' }
detach_autos <- function() {
  in_search <- search()[grepl("^autos:", search())]

  # Walk the list of autos and detach them
  walk(
    in_search,
    detach,
    character.only = TRUE
  )
}

#' Wrapper around library to re-set autos
#'
#' Autos need to immediately follow the global environment.
#' This wrapper around `base::library()` will reset the autos after each new
#' library is attached to ensure this behavior is followed.
#'
#' @usage NULL
#' @param ... pass directly through to base::library
#'
#' @return returns (invisibly) the list of attached packages
#' @export
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' }
library <- function(...) {
  tmp <- withVisible(base::library(...))

  # Reset autos back if any are present
  if (any(grepl("^autos:", search()))) {
    if (!any(search() == "envsetup:paths")) {
      warning("envsetup::rprofile was not run! Autos cannot be restored!")
    } else {
      stored_config <- get("auto_stored_envsetup_config",
                           pos = which(search() == "envsetup:paths")
      )
      suppressMessages(set_autos(stored_config$autos))
    }
  }

  if (tmp$visible) {
    tmp$value
  } else {
    invisible(tmp$value)
  }
}
