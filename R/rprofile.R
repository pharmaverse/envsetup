#' Function used to pass through code to the .Rprofile
#'
#' @param config configuration object from config::get()
#' @export
#' @return Directory paths of the R autos
#'
#' @examples
#' \dontrun{
#' rprofile(config::get("path/to/config/_envsetup.yml"))
#' }
rprofile <- function(config) {
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

  set_autos(config$autos)
}
