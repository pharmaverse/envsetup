tmpdir <- base::tempdir()
Sys.setenv(testpath = (tmpdir))

system(paste0("cp ", test_path("man/testdir/*"), " ", tmpdir, " -r"))

rootpath_dev <- "DEV"
rootpath_qa <- "QA"
rootpath_prod <- "PROD"

envsetup_config <- config::get(file = test_path("man/_envsetup_testthat.yml"))
Sys.setenv(ENVSETUP_ENVIRON = "DEV")
rprofile(envsetup_config)

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
  expect_error(readr::read_csv(read_path(data,
    "iris.csv",
    full.path = TRUE,
    envsetup_environ = "PROD"
  )))
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
