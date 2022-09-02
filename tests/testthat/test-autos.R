
tmpdir <- base::tempdir()

Sys.setenv(ENVSETUP_ENVIRON = "DEV")

Sys.setenv(testpath = (tmpdir))


system(paste0("cp ", testthat::test_path("man/testdir/*"), " ", tmpdir, " -r"))

envsetup_config <- config::get(
  file = testthat::test_path("man/_envsetup_testthat.yml")
  )


#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.1", {
  set_autos(envsetup_config$autos)
  expect_equal(c(Test_Dev()), c("Test of dev autos"))
})
#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.2", {
  expect_error(set_autos(1), "Paths must be directories")
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.3", {
  envsetup_config_tmp <- envsetup_config
  envsetup_config_tmp$autos[2] <- envsetup_config$autos[1]
  set_autos(envsetup_config_tmp$autos)
  expect_equal(c(Test_Dev(), Test_Prod()),
               c("Test of dev autos", "Test of prod autos"))
  expect_error(Test_QA())
})


#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.4", {
  print(envsetup_config$autos)
  set_autos(envsetup_config$autos)
  expect_equal(mtcars, iris)
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.5", {
  set_autos(envsetup_config$autos)
  expect_equal(Test_Prod(), "Test of prod autos")
  expect_equal(Test_Prod2(), "Test of prod autos second")
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.6", {
  set_autos(envsetup_config$autos)
  expect_equal(mtcars, iris)
})


#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.7", {
  Sys.setenv(ENVSETUP_ENVIRON = "QA")
  set_autos(envsetup_config$autos)
  expect_error(Test_DEV())
  Sys.setenv(ENVSETUP_ENVIRON = "PROD")
  set_autos(envsetup_config$autos)
  expect_error(Test_DEV())
})

#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("1.8", {
  Sys.setenv(ENVSETUP_ENVIRON = "QA")
  set_autos(envsetup_config$autos)
  expect_error(Test_Dev())
  expect_equal(c(Test_QA(), Test_Prod()),
               c("Test of qa autos", "Test of prod autos"))
})


#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("2.1", {
  detach_autos(c("autos:QA", "autos:PROD"))
  expect_error(Test_QA())
  expect_error(Test_Prod())
})


