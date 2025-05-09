#' Validate a configuration file
#'
#' A helper function to help troubleshoot common problems that can occur when
#' building your configuration file.
#'
#' @param config configuration object from config::get()
#'
#' @return Called for its side-effects. Prints findings from validation checks.
#' @export
#'
#' @examples
#' # temp location to store configuration files
#' tmpdir <- tempdir()
#' print(tmpdir)
#'
#' # Each path only points to one location, i.e. there is no hierarchy for a path
#' no_hierarchy <- 'default:
#'   paths:
#'     data: "/demo/DEV/username/project1/data"
#'     output: "/demo/DEV/username/project1/output"
#'     programs: "/demo/DEV/username/project1/programs"'
#'
#' writeLines(no_hierarchy, file.path(tmpdir, "no_hierarchy.yml"))
#'
#' validate_config(config::get(file = file.path(tmpdir, "no_hierarchy.yml")))
#'
#' # A path can point to multiple locations, i.e. there is a hierarchy
#' hierarchy <- "default:
#'   paths:
#'     data: !expr list(DEV = '/demo/DEV/username/project1/data',
#'                      PROD = '/demo/PROD/project1/data')
#'     output: !expr list(DEV = '/demo/DEV/username/project1/output',
#'                        PROD = '/demo/PROD/project1/output')
#'     programs: !expr list(DEV = '/demo/DEV/username/project1/programs',
#'                          PROD = '/demo/PROD/project1/programs')
#'     envsetup_environ: !expr Sys.setenv(ENVSETUP_ENVIRON = 'DEV'); 'DEV'"
#'
#' writeLines(hierarchy, file.path(tmpdir, "hierarchy.yml"))
#'
#' validate_config(config::get(file = file.path(tmpdir, "hierarchy.yml")))
#'
#' # A hierarchy is present for paths, but they are not named
#' hierarchy_no_names <- "default:
#'   paths:
#'     data: !expr list('/demo/DEV/username/project1/data', '/demo/PROD/project1/data')
#'     output: !expr list('/demo/DEV/username/project1/output', '/demo/PROD/project1/output')
#'     programs: !expr list('/demo/DEV/username/project1/programs', '/demo/PROD/project1/programs')
#'     envsetup_environ: !expr Sys.setenv(ENVSETUP_ENVIRON = 'DEV'); 'DEV'"
#'
#'
#' writeLines(hierarchy_no_names, file.path(tmpdir, "hierarchy_no_names.yml"))
#'
#' validate_config(config::get(file = file.path(tmpdir, "hierarchy_no_names.yml")))
#'
#'
#' # No paths are specified
#' no_paths <- "default:
#'   autos:
#'     my_functions: '/demo/PROD/project1/R'"
#'
#' writeLines(no_paths, file.path(tmpdir, "no_paths.yml"))
#'
#' validate_config(config::get(file = file.path(tmpdir, "no_paths.yml")))
validate_config <- function(config) {
  validate_paths(config)
}


#' Validate the paths in a configuration
#'
#' @param config configuration object from config::get()
#'
#' @importFrom usethis ui_done ui_info
#' @importFrom purrr walk
#'
#' @noRd
validate_paths <- function(config) {
  # does the paths element exist?
  if (exists("paths", where = config)) {
    ui_done("paths are specified as part of your configuration")
  } else {
    ui_info("no paths are specified as part of your configuration, skipping path valiation")
    return(invisible())
  }

  # any hierarchical paths?
  if (is_hierarchical(config$paths)) {
    ui_done(c("hierarchal paths found for:", names(config$paths[sapply(config$paths, is.list)])))
  } else {
    ui_info("no hierarchical paths found")
    return(invisible())
  }

  # are your hierarchical paths named
  has_hierarchy <- sapply(config$paths, is.list)

  check_for_names <- names(config$paths[has_hierarchy])

  has_names <- function(.x) {
    !is.null(names(config$paths[has_hierarchy][[.x]]))
  }

  name_results <- sapply(check_for_names, has_names)

  walk(
    names(name_results[!name_results]),
    ~ usethis::ui_todo(
      paste0(
        usethis::ui_field(.),
        " has a hierarchy but they are not named.  Please update your configuration to name the hierarchy for ",
        usethis::ui_field(.), "."
      )
    )
  )
}

is_hierarchical <- function(x) {
  tf <- sapply(x, is.list)
  any(tf)
}
