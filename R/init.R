#' Initialize the R environment with envsetup
#'
#' @param project Character. The path to the project directory. Defaults to the current working directory.
#' @param config_path Character. The path of the config file. Defaults to NULL.
#' @param create_paths Logical indicating if missing paths should be created. Defaults to NULL.
#' @export
#' @importFrom usethis ui_yeah ui_oops ui_info ui_done
#' @importFrom config get
#' @return Logical. TRUE if successful.
#'
#' @examples
#' \dontrun{
#' init()
#' }
init <- function(project = getwd(), config_path = NULL, create_paths = NULL) {

  create_config <- FALSE
  config_found <- FALSE

  if (is.null(config_path)) {
    create_config <- ui_yeah("No path to an exisiting configuration file was provided.
                             Would you like us to create a default configuration in your project directory?",
      n_no = 1
    )
  } else {
    if (file.exists(config_path) && !dir.exists(config_path)) {
      config_found <- TRUE

      usethis::ui_done("Configuration file found!")

      # verify directories exist
      config <- config::get(file = config_path)

      if (!exists("paths", where = config)) {
        ui_oops("No paths are specified as part of your configuration.  Update your config file to add paths.")
        return(invisible())
      }

      paths <- unlist(config$paths, use.names = FALSE)

      missing_directories <- !vapply(paths, dir.exists, TRUE)

      if (any(missing_directories)) {
        ui_info(
          c("The following paths in your configuration do not exist:",
            paths[missing_directories])
          )

        # if not, ask if user would like them built
        if (is.null(create_paths)) {
          create_paths <-
            usethis::ui_yeah(
              "Would you like us to create your directories to match your configuration?",
              n_no = 1
          )
        }

        if (!create_paths) {
          ui_info("All path objects will not work since directories are missing.")
        }
      }
    } else {
      stop(paste("No configuration file is found at", config_path), call. = FALSE)
    }
  }

  # if user agrees, write a configuration file to the project directory and create paths
  if (create_config) {
    default_path <- system.file("default_envsetup.yml", package = "envsetup", mustWork = TRUE)

    config_path <- file.path(project, "envsetup.yml")

    file.copy(default_path, config_path, overwrite = TRUE)

    ui_done(paste("Configuration file (envsetup.yml) has been written to", project))

    create_paths <- TRUE
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

  if (create_paths) {
    build_from_config(
      config::get(file = config_path)
    )
  }

  ui_done("envsetup initialization complete")
}

envsetup_write_rprofile <- function(add, file) {
  if (!file.exists(file)) {
    writeLines(add, file)
    return(TRUE)
  }

  before <- readLines(file, warn = FALSE)

  # if there is a call to `rprofile()` in the .Rprofile, assume setup was already done and exit
  if (any(grepl("rprofile\\(", before))) {
    warning("It looks like your project has already been initialized to use envsetup. Manually adjust your .Rprofile if you need to change the environment setup.",
      call. = FALSE
    )
    return(invisible())
  }

  after <- c(add, before)

  writeLines(after, file)

  ui_done(paste(".Rprofile created"))
}
