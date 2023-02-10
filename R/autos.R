#' Set the R autos
#'
#' Set the directory paths of any 'autos'. 'Autos' are
#' directory paths that hold .R files containing R functions. These paths may be
#' used when functions apply to an analysis, protocol, or even at a global
#' level, but don't fit in or necessarily require a package or haven't been
#' incorporated into a package.
#'
#' @param ... named vector of directories
#' @param envsetup_environ name of the environment you would like to read from;
#' default values comes from the value in the system variable ENVSETUP_ENVIRON
#' which can be set by Sys.setenv(ENVSETUP_ENVIRON = "environment name")
#'
#' @return Directory paths of the R autos
#'
#' @importFrom purrr walk walk2
#' @importFrom assertthat assert_that
#' @export
#'
#' @examples
#' \dontrun{
#' set_autos(envsetup_config$autos)
#' }
set_autos <- function(..., envsetup_environ = Sys.getenv("ENVSETUP_ENVIRON")) {

  autos_paths <- list(...)

  for (i in seq_along(autos_paths)) {

    cur_autos <- autos_paths[[i]]

    if (length(cur_autos) > 1 && envsetup_environ == "") {
      stop(paste(
        "The envsetup_environ parameter or ENVSETUP_ENVIRON environment",
        "variable must be used if hierarchical autos are set."), call.=FALSE)
    }

    filtered_autos <- cur_autos
    if (envsetup_environ %in% names(cur_autos)) {
      filtered_autos <-
        cur_autos[which(names(cur_autos) == envsetup_environ):length(cur_autos)]
    }

    autos_paths[[i]] <- filtered_autos
  }

  # Check the autos before they're set
  assert_that(
    is.null(autos_paths) || is.character(autos_paths),
    msg = "Paths must be directories"
  )
  # If there are any existing autos then reset them
  detach_autos(paste0("autos:", names(autos_paths)))

  # Check that the directories and/or files actually exist
  walk(unlist(autos_paths), {
    function(p) {
      if (!dir.exists(p) && !file.exists(p)) {
        warning(paste("Directory or file", p, "does not exist!"))
      }
    }
  })

  # Make sure everything came through here ok - the directories should have validated
  browser()

  # Now I need to get the autos into a name of hte list with a character vector of length >=1
  # from there run that in attach_auto for both paths in the same namespace

  # Now attach everything. Note that attach will put an environment behind
  # global and in front of the package namespaces. By reversing the list,
  # the search path will be set to apply the autos to the name space so that
  # the path at element one of the list is directly behind global
  walk2(
    rev(autos_paths),
    rev(names(autos_paths)),
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


  # if file, source it
  if (file.exists(path) && !dir.exists(path)) {
    sys.source(path, envir = attach(NULL, name = name_with_prefix))

    message("Attaching functions from", path, " to ", name_with_prefix)
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
      message("Attaching functions from", path, " to ", name_with_prefix)
    }
  }
}

#' Detach the autos from the current session
#'
#' This function will remove any autos that have been set from the search path
#'
#' @param names vector of names of attached packages to detach
#'
#' @return names found in the search path
#' @export
#'
#' @examples
#' \dontrun{
#' detach_autos()
#' }
detach_autos <- function(names) {

  # find auto names in search
  in_search <- names[names %in% search()]

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
  tmp <- base::library(...)

  # Reset autos back if any are present
  if (any(grepl("^autos:", search()))) {
    suppressMessages(set_autos(envsetup_config$autos))
  }
  tmp
}
