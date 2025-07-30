#' Function used to pass through code to the .Rprofile
#'
#' @param config configuration object from config::get()
#' @param envir The environment to search for the path object. Defaults to the
#'   value of `getOption("envsetup.path.environment")`.
#' @param overwrite logical indicating if sourcing of autos should overwrite an object in global if it already exists
#' @importFrom envnames environment_name
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
rprofile <- function(config,
                     envir = getOption("envsetup.path.environment"),
                     overwrite = TRUE) {

  # remove autos and pass everything else to "envsetup:paths"
  config_minus_autos <- config
  config_minus_autos$autos <- NULL

  walk2(names(config_minus_autos$paths),
        config_minus_autos$paths,
        assign,
        envir = envir)

  message(paste0("Assigned paths to ", environment_name(envir)))

  # store config with a standard name in a standard location
  assign("auto_stored_envsetup_config", config, envir = envir)

  # If autos exist, set them
  if (!is.null(config$autos)) {
    set_autos(config$autos, overwrite = overwrite)
  }
}
