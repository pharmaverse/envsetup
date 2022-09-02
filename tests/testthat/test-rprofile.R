
tmpdir <- base::tempdir()

Sys.setenv(ENVSETUP_ENVIRON = "DEV")

Sys.setenv(testpath = (tmpdir))


system(paste0("cp ", testthat::test_path("man/testdir/*"), " ", tmpdir, " -r"))

envsetup_config <- config::get(
  file = testthat::test_path("man/_envsetup_testthat.yml")
)

rootpath_dev <- "DEV"
rootpath_qa <- "QA"
rootpath_prod <- "PROD"




#' @editor Aidan Ceney
#' @editDate 2022-05-18
test_that("1.1", {
  rprofile(envsetup_config)

  withr::defer(detach(envsetup:paths))

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

  withr::defer(detach(envsetup:paths))

  expect_equal(c(Test_Dev()), c("Test of dev autos"))
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

  withr::defer(detach(envsetup:paths))

  expect_equal(tidyr::as_tibble(iris)$Petal.Length, readin$Petal.Length)
})
