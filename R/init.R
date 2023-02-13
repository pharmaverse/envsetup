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
init <- function(project = getwd(), config_path = NULL) {
  create_config <- FALSE
  config_found <- FALSE

  if (is.null(config_path)) {
    create_config <- usethis::ui_yeah("No path to an exisiting configuration file was provided.
                                      Would you like us to create a default configuration in your project directory?",
      n_no = 1
    )
  } else {
    if (file.exists(config_path) && !dir.exists(config_path)) {
      config_found <- TRUE
      usethis::ui_done("Configuration file found!")
    } else {
      stop(paste("No configuration file is found at", config_path), call. = FALSE)
    }
  }

  # if user agrees, write a configuration file to the project directory
  if (create_config) {
    default_path <- system.file("default_envsetup.yml", package = "envsetup", mustWork = TRUE)

    config_path <- file.path(project, "envsetup.yml")

    file.copy(default_path, config_path)

    usethis::ui_done(paste("Configuration file (envsetup.yml) has been written to", project))

    # build out the default directory structure in the project
    build_from_config(
      config::get(file = config_path)
    )
  } else if (config_found <- FALSE) {
    stop("Aborting envsetup initialization.  A configuration file is needed.", call. = FALSE)
  }

  # create the .Rprofile or add envsetup to the top
  add <- sprintf(
    'library(envsetup)\nenvsetup_config <- config::get(file = "%s")\nrprofile(envsetup_config)',
    config_path
  )

  envsetup_write_rprofile(
    add    = add,
    file   = file.path(project, ".Rprofile")
  )

  usethis::ui_done("envsetup initialization complete")
}

envsetup_write_rprofile <- function(add, file) {
  if (!file.exists(file)) {
    writeLines(add, file)
    return(TRUE)
  }

  before <- readLines(file, warn = FALSE)

  # if there is a call to `rprofile()` in the .Rprofile, assume setup was already done and exit
  if (any(grepl("rprofile\\(", before))) {
    stop("It looks like your project has already been initialized to use envsetup.
         Manually adjust your .Rprofile if you need to change the environment setup.",
      call. = FALSE
    )
  }

  after <- c(add, before)

  writeLines(after, file)

  usethis::ui_done(paste(".Rprofile created"))
}
