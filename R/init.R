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
init <- function(project = getwd(), config_path = "envsetup.yml"){

  # create the .Rprofile or add envsetup to the top
  add <- sprintf('library(envsetup)\nenvsetup_config <- config::get(file = "%s")\nrprofile(envsetup_config)',
                 config_path)

  envsetup_write_rprofile(
    add    = add,
    file   = file.path(project, ".Rprofile"),
    create = TRUE
  )

}

envsetup_write_rprofile <- function(add, file, create) {

  # check to see if file doesn't exist
  if (!file.exists(file)) {

    # if we're not forcing file creation, just bail
    if (!create)
      return(TRUE)

    # otherwise, write the file
    # ensure_parent_directory(file)
    writeLines(add, file)
    return(TRUE)

  }

  # if the file already has the requested line, nothing to do
  before <- readLines(file, warn = FALSE)
  after <- c(add, before)

  # write to file if we have changes
  writeLines(after, file)

  TRUE

}
