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

remove_sourcing_file <- function(x) {
  # Use regular expressions to remove the line containing "Sourcing file"
  x[!grepl("^Sourcing file:", x)]
}

# Dev tests
Sys.setenv(ENVSETUP_ENVIRON = "DEV")

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Autos set and test_dev from highest level appears correctly", {
  suppressMessages(set_autos(custom_name$autos))
  expect_equal(c(test_dev()), c("Test of dev autos"))
  expect_equal(c(test_global()), c("Test of global autos"))

  detach_autos()
})


#' @editor Nick Masel
#' @editDate 2025-07-10
test_that("Order of functions appears correctly when @include is used", {
  dev_order <- collate_func(custom_name$autos$projects$DEV)
  expect_equal(dev_order,
               c(file.path(tmpdir, "DEV/functions/TestDev.R"),
                 file.path(tmpdir, "DEV/functions/conflicts.R"),
                 file.path(tmpdir, "DEV/functions/inc3.R"),
                 file.path(tmpdir, "DEV/functions/inc2.R"),
                 file.path(tmpdir, "DEV/functions/inc1.R")
                 )
               )
})


#' @editor Nick Masel
#' @editDate 2025-07-10
test_that("Order of functions appears correctly when @include is not used", {
  qa_order <- collate_func(custom_name$autos$projects$QA)
  expect_equal(qa_order,
               c(file.path(tmpdir, "QA/functions/QATest.R"),
                 file.path(tmpdir, "QA/functions/conflicts.R"),
                 file.path(tmpdir, "QA/functions/inc1.R"),
                 file.path(tmpdir, "QA/functions/inc2.R"),
                 file.path(tmpdir, "QA/functions/inc3.R")
                 )
               )
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

  detach_autos()
})

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Data output in namespace appears", {
  suppressMessages(set_autos(custom_name$autos))
  expect_equal(mtcars, iris)

  detach_autos()
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
  detach_autos()
})

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Functions in higher level hierarchy export and multiple functions may be captured", {
  suppressMessages(set_autos(custom_name$autos))
  expect_equal(test_prod(), "Test of prod autos")
  expect_equal(test_prod2(), "Test of prod autos second")

  detach_autos()
})

#' @editor Mike Stackhouse
#' @editDate 2023-02-11
test_that("Autos no longer exist when detached", {
  detach_autos()
  expect_error(test_qa())
  expect_error(test_prod())
})

#' @editor Nick Masel
#' @editDate 2025-07-10
test_that("Autos warns user when ENVSETUP_ENVIRON does not match named environments in autos", {
  withr::local_envvar(ENVSETUP_ENVIRON = "bad_name")

  expect_snapshot(
    suppressMessages(rprofile(custom_name)),
    variant = r_version(),
    transform = remove_sourcing_file
    )
})


#' @editor Nick Masel
#' @editDate 2024-10-24
Sys.setenv(ENVSETUP_ENVIRON = "QA")
null_test <- config::get(
  file = testthat::test_path("man/_envsetup_testthat_null.yml")
)
test_that("NULL paths do not throw an error", {
  expect_no_error(set_autos(null_test$autos))
})



#' @editor Nick Masel
#' @editDate 2025-07-10
test_that("source_warn_conflicts works with one directory", {
  dirs <- testthat::test_path("man/testdir/DEV/functions/conflicts.R")

  expect_snapshot(
    source_warn_conflicts(dirs),
    transform = remove_sourcing_file
  )

  # check object_metadata
  expect_snapshot(envsetup_environment$object_metadata$object_name)
})

#' @editor Nick Masel
#' @editDate 2025-07-10
test_that("source_warn_conflicts works when adding a second directory with conflicts", {
  dirs <- list(
    testthat::test_path("man/testdir/DEV/functions/conflicts.R"),
    testthat::test_path("man/testdir/QA/functions/conflicts.R")
  )

  # source first file
  source_warn_conflicts(dirs[[1]])

  # now source second to confirm functions added, and those not added to global
  expect_snapshot(
    source_warn_conflicts(dirs[[2]]),
    transform = remove_sourcing_file
  )

})

#' @editor Nick Masel
#' @editDate 2025-07-10
test_that("source_warn_conflicts throws an error when a path is not valid", {

  dirs <- testthat::test_path("man/testdir/DEV/functions/conflictss.R")
  expect_error(source_warn_conflicts(dirs))

})
