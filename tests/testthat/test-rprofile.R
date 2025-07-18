
tmpdir <- base::tempdir()

Sys.setenv(ENVSETUP_ENVIRON = "DEV")

Sys.setenv(testpath = (tmpdir))

file.copy(testthat::test_path("man/testdir/DEV"), tmpdir, recursive = TRUE)
file.copy(testthat::test_path("man/testdir/global"), tmpdir, recursive = TRUE)
file.copy(testthat::test_path("man/testdir/PROD"), tmpdir, recursive = TRUE)
file.copy(testthat::test_path("man/testdir/QA"), tmpdir, recursive = TRUE)

envsetup_config <- config::get(
  file = testthat::test_path("man/_envsetup_testthat.yml")
)

rootpath_dev <- "DEV"
rootpath_qa <- "QA"
rootpath_prod <- "PROD"

#' @editor Nick Masel
#' @editDate 2025-07-17
test_that("rprofile stores the configuration", {
  config_tmpdir <- tempdir()
  withr::defer(unlink(file.path(config_tmpdir, ".Rprofile")))
  hierarchy <- "default:
  paths:
    data: !expr list(DEV = '/demo/DEV/username/project1/data',
                     PROD = '/demo/PROD/project1/data')
    output: !expr list(DEV = '/demo/DEV/username/project1/output',
                       PROD = '/demo/PROD/project1/output')
    programs: !expr list(DEV = '/demo/DEV/username/project1/programs',
                         PROD = '/demo/PROD/project1/programs')
    envsetup_environ: !expr Sys.setenv(ENVSETUP_ENVIRON = 'DEV'); 'DEV'"

  writeLines(hierarchy, file.path(config_tmpdir, "hierarchy.yml"))

  custom_name <- config::get(file = file.path(config_tmpdir, "hierarchy.yml"))

  rprofile(custom_name)

  expect_equal(custom_name, auto_stored_envsetup_config)
})


#' @editor Aidan Ceney
#' @editDate 2022-05-18
test_that("1.1", {
  rprofile(envsetup_config)

  expected <- list()
  folder <- "data"
  expected$DEV <- file.path(tmpdir, rootpath_dev, folder)
  expected$QA <- file.path(tmpdir, rootpath_qa, folder)
  expected$PROD <- file.path(tmpdir, rootpath_prod, folder)

  expect_identical(expected, data)
})


#' @editor Aidan Ceney
#' @editDate 2022-05-18
test_that("2.1", {
  Sys.setenv(ENVSETUP_ENVIRON = "DEV")
  rprofile(envsetup_config)

  expect_equal(c(test_dev()), c("Test of dev autos"))
})


#' @editor Aidan Ceney
#' @editDate 2022-05-18
test_that("3.1", {
  envsetup_config <- config::get(
    file = testthat::test_path("man/_envsetup_testthat.yml")
  )

  rprofile(envsetup_config)

  readin <- readr::read_csv(
    read_path(data, "iris.csv", full.path = TRUE, envsetup_environ = "DEV")
  )

  expect_equal(tidyr::as_tibble(iris)$Petal.Length, readin$Petal.Length)
})
