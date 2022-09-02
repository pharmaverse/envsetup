

tmpdir <- base::tempdir()
Sys.setenv(testpath = (tmpdir))

system(paste0("cp ", test_path("man/testdir/*"), " ", tmpdir, " -r"))

rootpath_dev <- "DEV"
rootpath_qa <- "QA"
rootpath_prod <- "PROD"

envsetup_config <- config::get(file = test_path("man/_envsetup_testthat.yml"))
Sys.setenv(ENVSETUP_ENVIRON = "DEV")
rprofile(envsetup_config)

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.1", {
  readin <- readr::read_csv(read_path(data,
                                      "iris.csv",
                                      full.path = TRUE,
                                      envsetup_environ = "DEV"))
  expect_equal(tidyr::as_tibble(iris)$Petal.Length, readin$Petal.Length)
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.2", {
  expect_error(readr::read_csv(read_path(data,
                                         "iris.csv",
                                         full.path = TRUE,
                                         envsetup_environ = "PROD")))
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.3", {
  expect_equal(read_path(data,
                         "iris.csv",
                         full.path = FALSE,
                         envsetup_environ = "DEV"),
               paste0(tmpdir, "/DEV/data"))
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.4", {
  readin <- readr::read_csv(read_path(data,
                                      "iris2.csv",
                                      full.path = TRUE,
                                      envsetup_environ = "DEV"))
  expect_equal(tidyr::as_tibble(iris)$Petal.Length, readin$Petal.Length)
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("2.1", {
  readin <- write_path(data, envsetup_environ = "DEV")
  expect_equal(readin, paste0(tmpdir, "/DEV/data"))
})
