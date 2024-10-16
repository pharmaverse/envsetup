r_version <- function() paste0("R", getRversion()[, 1:2])

tmpdir <- base::tempdir()

Sys.setenv(testpath = (tmpdir))

file.copy(testthat::test_path("man/testdir/DEV"), tmpdir, recursive = TRUE)
file.copy(testthat::test_path("man/testdir/global"), tmpdir, recursive = TRUE)
file.copy(testthat::test_path("man/testdir/PROD"), tmpdir, recursive = TRUE)
file.copy(testthat::test_path("man/testdir/QA"), tmpdir, recursive = TRUE)
dir.create(file.path(tmpdir, "returns_null"))

custom_name <- config::get(
  file = testthat::test_path("man/_envsetup_testthat.yml")
)

# Dev tests
Sys.setenv(ENVSETUP_ENVIRON = "DEV")

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Autos set and test_dev from highest level appears correctly", {
  suppressMessages(set_autos(custom_name$autos))
  expect_equal(c(test_dev()), c("Test of dev autos"))
  expect_equal(c(test_global()), c("Test of global autos"))
})

#' @editor Gabe Becker
#' @editDate 2023-11-22
test_that("library returns invisibly", {
  # Detatch envsetup:paths if it exists
  if (any(search() == "envsetup:paths")) {
    detach("envsetup:paths")
  }
  expect_silent(expect_invisible(suppressPackageStartupMessages(library("purrr"))))
  suppressMessages(rprofile(custom_name))
  detach("package:purrr")
})


#' @editor Aidan Ceney
#' @editDate 2022-05-12
test_that("Autos validation from yml happens correctly", {
  # List is named
  expect_error(set_autos(list(c("path"))))

  # Hierarchical list is named
  expect_error(
    set_autos(list(project = c("path1", "path2"))),
    "Hierarchical autos paths in your envsetup configuration file must be named"
  )

  # Paths are characters
  expect_error(set_autos(list(global = 1)),
               "Paths provided for autos must be directories")

  expect_warning(set_autos(list(x = "/bad/path/")),
                 "An autos path specified in your envsetup configuration file does not exist")
})

# Detatch and re-setup for QA now
detach_autos()
Sys.setenv(ENVSETUP_ENVIRON = "QA")

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Setting environment to QA filters out dev autos", {
  suppressMessages(set_autos(custom_name$autos))
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
  suppressMessages(set_autos(custom_name$autos))
  expect_equal(mtcars, iris)
})

#' @editor Mike Stackhouse
#' @editDate 2022-02-11
test_that("set_autos effectively clears and resets namespace", {
  Sys.setenv(ENVSETUP_ENVIRON = "QA")
  suppressMessages(set_autos(custom_name$autos))
  expect_error(test_dev())
  expect_equal(c(test_global()), c("Test of global autos"))
  Sys.setenv(ENVSETUP_ENVIRON = "PROD")
  suppressMessages(set_autos(custom_name$autos))
  expect_error(test_qa())
  expect_equal(c(test_global()), c("Test of global autos"))
})

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Functions in higher level hierarchy export and multiple functions may be captured", {
  suppressMessages(set_autos(custom_name$autos))
  expect_equal(test_prod(), "Test of prod autos")
  expect_equal(test_prod2(), "Test of prod autos second")
})

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Autos no longer exist when detached", {
  detach_autos()
  expect_error(test_qa())
  expect_error(test_prod())
})

test_that("the configuration can be named anything and library will
          reattach the autos correctly", {
    suppressMessages(rprofile(custom_name))

    expect_invisible(suppressPackageStartupMessages(library("purrr")))

    purrr_location <- which(search() == "package:purrr")
    autos_locatios <- which(grepl("^autos:", search()))

    expect_true(all(purrr_location > autos_locatios))
    detach("package:purrr")
  }
)


test_that("Autos warns user when ENVSETUP_ENVIRON does not match named environments in autos", {
  withr::local_envvar(ENVSETUP_ENVIRON = "bad_name")

  expect_snapshot(suppressMessages(rprofile(custom_name)), variant = r_version())
})


#' @editor Nick Masel
#' @editDate 2024-10-24
detach_autos()
Sys.setenv(ENVSETUP_ENVIRON = "QA")
null_test <- config::get(
  file = testthat::test_path("man/_envsetup_testthat_null.yml")
)
test_that("NULL paths do not throw an error", {
  expect_no_error(set_autos(null_test$autos))
})
