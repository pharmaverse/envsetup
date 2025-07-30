tmpdir <- base::tempdir()
Sys.setenv(testpath = (tmpdir))

system(paste0("cp ", test_path("man/testdir/*"), " ", tmpdir, " -r"))

rootpath_dev <- "DEV"
rootpath_qa <- "QA"
rootpath_prod <- "PROD"

envsetup_config <- config::get(file = test_path("man/_envsetup_testthat.yml"))
Sys.setenv(ENVSETUP_ENVIRON = "DEV")
rprofile(envsetup_config)

test_that("read_path will return the correct path if the object exists in another environment", {
  data <- function() {
    stop()
  }

  expect_equal(read_path(data, "iris.csv"), file.path(tmpdir, "DEV", "data", "iris.csv"))

  rm(data)
})

test_that("read_path checks fire as expected", {
  expect_error(
    read_path("data", "iris.csv"),
    "The lib argument should be an object containing the paths for all environments of a directory, not a string."
    )

  withr::local_envvar(ENVSETUP_ENVIRON = "dev")

  expect_warning(
    read_path(data, "iris.csv"),
    "The path has named environments DEV, QA, PROD that do not match with the envsetup_environ parameter or ENVSETUP_ENVIRON environment variable"
  )


})

test_that("write_path will return the correct path if the object exists in another environment", {
  data <- function() {
    stop()
  }

  expect_equal(write_path(data, "iris.csv"), file.path(tmpdir, "DEV", "data", "iris.csv"))

  rm(data)
})

test_that("write_path checks fire as expected", {
  expect_error(
    write_path("data", "iris.csv"),
    "The lib argument should be an object containing the paths for all environments of a directory, not a string."
  )
  expect_error(
    write_path(data, "iris.csv", envsetup_environ = ""),
    "The envsetup_environ parameter or ENVSETUP_ENVIRON environment variable must be used if hierarchical paths are set."
  )

  withr::local_envvar(ENVSETUP_ENVIRON = "dev")

  expect_warning(
    write_path(data, "iris.csv"),
    "The path has named environments DEV, QA, PROD that do not match with the envsetup_environ parameter or ENVSETUP_ENVIRON environment variable"
  )


})

test_that("build_from_config checks fire as expected", {
  build_tmpdir <- tempdir()
  withr::defer(unlink(build_tmpdir))

  hierarchy <- "default:
    path:
      data: !expr list(DEV = '/demo/DEV/username/project1/data',
                       PROD = '/demo/PROD/project1/data')
      output: !expr list(DEV = '/demo/DEV/username/project1/output',
                         PROD = '/demo/PROD/project1/output')
      programs: !expr list(DEV = '/demo/DEV/username/project1/programs',
                           PROD = '/demo/PROD/project1/programs')
      docs: !expr list(DEV = 'docs',
                       PROD = 'docs')"

  writeLines(hierarchy, file.path(build_tmpdir, "hierarchy.yml"))

  config <- config::get(file = file.path(build_tmpdir, "hierarchy.yml"))

  expect_message(
    build_from_config(config, build_tmpdir),
    "No paths are specified as part of your configuration.  Update your config file to add paths."
  )

})

test_that("build_from_config builds the correct directories", {
  build_tmpdir <- tempdir()
  withr::defer(unlink(build_tmpdir))

  hierarchy <- "default:
    paths:
      data: !expr list(DEV = '/demo/DEV/username/project1/data',
                       PROD = '/demo/PROD/project1/data')
      output: !expr list(DEV = '/demo/DEV/username/project1/output',
                         PROD = '/demo/PROD/project1/output')
      programs: !expr list(DEV = '/demo/DEV/username/project1/programs',
                           PROD = '/demo/PROD/project1/programs')
      docs: !expr list(DEV = 'docs',
                       PROD = 'docs')"

  writeLines(hierarchy, file.path(build_tmpdir, "hierarchy.yml"))

  config <- config::get(file = file.path(build_tmpdir, "hierarchy.yml"))

  build_from_config(config, build_tmpdir)

  paths <- file.path(build_tmpdir, unlist(config$paths, use.names = FALSE))

  expect_true(dir.exists(file.path(build_tmpdir, "/demo/DEV/username/project1/data")))
  expect_true(dir.exists(file.path(build_tmpdir, "/demo/PROD/project1/data")))
  expect_true(dir.exists(file.path(build_tmpdir, "/demo/DEV/username/project1/output")))
  expect_true(dir.exists(file.path(build_tmpdir, "/demo/PROD/project1/output")))
  expect_true(dir.exists(file.path(build_tmpdir, "/demo/DEV/username/project1/programs")))
  expect_true(dir.exists(file.path(build_tmpdir, "/demo/PROD/project1/programs")))
  expect_true(dir.exists(file.path(build_tmpdir, "docs")))
})


#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.1", {
  # First check if
  expect_error(
    read_path(data,
      "iris.csv",
      full.path = TRUE,
      envsetup_environ = ""
    )
  )

  readin <- readr::read_csv(read_path(data,
    "iris.csv",
    full.path = TRUE,
    envsetup_environ = "DEV"
  ))
  expect_equal(tidyr::as_tibble(iris)$Petal.Length, readin$Petal.Length)
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.2", {
  expect_error(
    readr::read_csv(
      read_path(
        data,
        "iris.csv",
        full.path = TRUE,
        envsetup_environ = "PROD"
      )
    )
  )
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.3", {
  expect_equal(
    read_path(data,
      "iris.csv",
      full.path = FALSE,
      envsetup_environ = "DEV"
    ),
    paste0(tmpdir, "/DEV/data")
  )
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.4", {
  readin <- readr::read_csv(read_path(data,
    "iris2.csv",
    full.path = TRUE,
    envsetup_environ = "DEV"
  ))
  expect_equal(tidyr::as_tibble(iris)$Petal.Length, readin$Petal.Length)
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("2.1", {
  readin <- write_path(data, envsetup_environ = "DEV")
  expect_equal(readin, paste0(tmpdir, "/DEV/data"))
})

# Tests for configs without envsetup_environ set
envsetup_config <- config::get(file = test_path("man/_envsetup_testthat2.yml"))
Sys.unsetenv("ENVSETUP_ENVIRON")
rprofile(envsetup_config)

#' @editor Mike stackhouse
#' @editDate 2023-02-10
test_that("read_path works with unset envsetup_environ and non-hierarhical paths", {
  readin <- readr::read_csv(read_path(data,
    "iris.csv",
    full.path = TRUE
  ))
  expect_equal(tidyr::as_tibble(iris)$Petal.Length, readin$Petal.Length)
})

#' @editor Mike stackhouse
#' @editDate 2023-02-10
test_that("write_path works with unset envsetup_environ and non-hierarhical paths", {
  readin <- write_path(data)
  expect_equal(readin, paste0(tmpdir, "/DEV/data"))
})

#' @editor Nick Masel
#' @editDate 2025-07-16
test_that("path environment option will store and retrieve paths from envsetup environment", {
  withr::local_options(
    envsetup.path.environment = envsetup_environment
  )

  expect_message(rprofile(envsetup_config), "^Assigned paths to package\\:envsetup\\$envsetup_environment")

  expect_equal(getOption("envsetup.path.environment"), envsetup_environment)

  expect_equal(all(c("auto_stored_envsetup_config", "data", "programs", "functions", "output") %in% ls(envir = envsetup_environment)), TRUE)

  expect_equal(get_path(data), envsetup_environment$data)
})

