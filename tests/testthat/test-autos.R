
tmpdir <- base::tempdir()

Sys.setenv(testpath = (tmpdir))

system(paste0("cp ", testthat::test_path("man/testdir/*"), " ", tmpdir, " -r"))

envsetup_config <- config::get(
  file = testthat::test_path("man/_envsetup_testthat.yml")
)

# Dev tests
Sys.setenv(ENVSETUP_ENVIRON = "DEV")

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Autos set and test_dev from highest level appears correctly", {
  do.call(set_autos, envsetup_config$autos)
  expect_equal(c(test_dev()), c("Test of dev autos"))
  expect_equal(c(test_global()), c("Test of global autos"))
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.2", {
  expect_error(set_autos(1), "Paths provided for autos must be directories")
})

# Detatch and re-setup for QA now
detach_autos()
Sys.setenv(ENVSETUP_ENVIRON = "QA")

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Setting environment to QA filters out dev autos", {
  do.call(set_autos, envsetup_config$autos)
  expect_equal(
    c(test_qa(), test_prod()),
    c("Test of qa autos", "Test of prod autos")
  )
  expect_error(test_dev())
  expect_equal(c(test_global()), c("Test of global autos"))
})


#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Data output in namespace appears", {
  do.call(set_autos,envsetup_config$autos)
  expect_equal(mtcars, iris)
})

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Functions in higher level hierarchy export and multiple functions may be captured", {
  do.call(set_autos,envsetup_config$autos)
  expect_equal(test_prod(), "Test of prod autos")
  expect_equal(test_prod2(), "Test of prod autos second")
})

#' @editor Mike Stackhouse
#' @editDate 2022-02-11
test_that("set_autos effectively clears and resets namespace", {
  Sys.setenv(ENVSETUP_ENVIRON = "QA")
  do.call(set_autos,envsetup_config$autos)
  expect_error(test_dev())
  expect_equal(c(test_global()), c("Test of global autos"))
  Sys.setenv(ENVSETUP_ENVIRON = "PROD")
  do.call(set_autos,envsetup_config$autos)
  expect_error(test_qa())
  expect_equal(c(test_global()), c("Test of global autos"))
})

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Autos no longer exist when detached", {
  detach_autos()
  expect_error(test_qa())
  expect_error(test_prod())
})
