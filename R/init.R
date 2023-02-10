#' Initialize the R environment with envsetup
#'
#' @param project Character. The path to the project directory. Defaults to the current working directory.
#' @param config_path Character. The path of the config file. Defaults to "envsetup.yml".
#' @export
#' @return Logical. TRUE if successful.
#'
#' @examples
#' \dontrun{
#' init()
#' }
init <- function(project = getwd(), config_path = "envsetup.yml") {
  # create the .Rprofile or add envsetup to the top
  add <- sprintf(
    'library(envsetup)\nenvsetup_config <- config::get(file = "%s")\nrprofile(envsetup_config)',
    config_path
  )

  envsetup_write_rprofile(
    add    = add,
    file   = file.path(project, ".Rprofile")
  )
}

envsetup_write_rprofile <- function(add, file) {
  if (!file.exists(file)) {
    writeLines(add, file)
    return(TRUE)
  }

  before <- readLines(file, warn = FALSE)

  # if there is a call to `rprofile()` in the .Rprofile, assume setup was already done and exit
  if (any(grepl("rprofile\\(", before))) {
    stop("It looks like your project has already been initialized to use envsetup.  Manually adjust your .Rprofile if you need to change the environment setup.")
  }

  after <- c(add, before)

  writeLines(after, file)

  TRUE
}
