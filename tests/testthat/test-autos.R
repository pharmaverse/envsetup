
tmpdir <- base::tempdir()

Sys.setenv(ENVSETUP_ENVIRON = "DEV")

Sys.setenv(testpath = (tmpdir))


system(paste0("cp ", testthat::test_path("man/testdir/*"), " ", tmpdir, " -r"))

custom_name <- config::get(
  file = testthat::test_path("man/_envsetup_testthat.yml")
)


test_that("library returns invisibly",{
  expect_invisible(library("dplyr"))
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.1", {
  set_autos(custom_name$autos)
  expect_equal(c(test_dev()), c("Test of dev autos"))
})
#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.2", {
  expect_error(set_autos(1), "Paths must be directories")
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.3", {
  custom_name_tmp <- custom_name
  custom_name_tmp$autos[2] <- custom_name$autos[1]
  set_autos(custom_name_tmp$autos)
  expect_equal(
    c(test_dev(), test_prod()),
    c("Test of dev autos", "Test of prod autos")
  )
  expect_error(test_qa())
})


#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.4", {
  print(custom_name$autos)
  set_autos(custom_name$autos)
  expect_equal(mtcars, iris)
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.5", {
  set_autos(custom_name$autos)
  expect_equal(test_prod(), "Test of prod autos")
  expect_equal(test_prod2(), "Test of prod autos second")
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.6", {
  set_autos(custom_name$autos)
  expect_equal(mtcars, iris)
})


#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.7", {
  Sys.setenv(ENVSETUP_ENVIRON = "QA")
  set_autos(custom_name$autos)
  expect_error(test_dev())
  Sys.setenv(ENVSETUP_ENVIRON = "PROD")
  set_autos(custom_name$autos)
  expect_error(test_dev())
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.8", {
  Sys.setenv(ENVSETUP_ENVIRON = "QA")
  set_autos(custom_name$autos)
  expect_error(test_dev())
  expect_equal(
    c(test_qa(), test_prod()),
    c("Test of qa autos", "Test of prod autos")
  )
})


#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("2.1", {
  detach_autos(c("autos:QA", "autos:PROD"))
  expect_error(test_qa())
  expect_error(test_prod())
})


test_that("the configuration can be named anything and library will
          reattch the autos correctly", {
  rprofile(custom_name)

  library("dplyr")

  dplyr_location <- which(search() == "package:dplyr")
  autos_locatios <- which(grepl("^autos:", search()))

  expect_true(all(dplyr_location > autos_locatios))
})
