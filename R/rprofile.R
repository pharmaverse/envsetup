#' Function used to pass through code to the .Rprofile
#'
#' @param config configuration object from config::get()
#' @param overwrite logical indicating if sourcing of autos should overwrite an object in global if it already exists
#' @export
#' @return Called for its side effects.  Directory paths and autos are added to the search path based on your config.
#'
#' @examples
#' # temp location to store configuration files
#' tmpdir <- tempdir()
#' print(tmpdir)
#'
#' # Create an example config file
#' hierarchy <- "default:
#'   paths:
#'     data: !expr list(DEV = '/demo/DEV/username/project1/data',
#'                      PROD = '/demo/PROD/project1/data')
#'     output: !expr list(DEV = '/demo/DEV/username/project1/output',
#'                        PROD = '/demo/PROD/project1/output')
#'     programs: !expr list(DEV = '/demo/DEV/username/project1/programs',
#'                          PROD = '/demo/PROD/project1/programs')"
#'
#' writeLines(hierarchy, file.path(tmpdir, "hierarchy.yml"))
#'
#' rprofile(config::get(file = file.path(tmpdir, "hierarchy.yml")))
rprofile <- function(config, overwrite = TRUE) {
  if ("envsetup:paths" %in% search()) {
    detach("envsetup:paths", character.only = TRUE)
  }

  # remove autos and pass everything else to "envsetup:paths"
  config_minus_autos <- config
  config_minus_autos$autos <- NULL

  # attach after package to allow functions from package to be used in config
  if (any(search() == "package:envsetup")) {
    pos <- which(search() == "package:envsetup") + 1
  } else {
    (pos <- 2L)
  }

  attach(config_minus_autos$paths,
    name = "envsetup:paths",
    pos = pos
  )

  message("Attaching paths to envsetup:paths")

  # store config with a standard name in a standard location
  # this will allow `envsetup::library()` to re-attach autos
  assign("auto_stored_envsetup_config", config, pos)

  # If autos exist, set them
  if (!is.null(config$autos)) {
    set_autos(config$autos, overwrite = overwrite)
  }
}
