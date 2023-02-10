init_tmpdir <- base::tempdir()

test_that("init creates a .Rprofile", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  init(init_tmpdir)
  expect_true(file.exists(file.path(init_tmpdir, ".Rprofile")))
})

test_that("init initializes an .Rprofile correcty when one does not exist", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  init(init_tmpdir)
  expected <- c("library(envsetup)", "envsetup_config <- config::get(file = \"envsetup.yml\")", "rprofile(envsetup_config)")
  actual <- readLines(file.path(init_tmpdir, ".Rprofile"))
  expect_equal(expected, actual)
})

test_that("init initializes an .Rprofile correcty when one does exist", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  writeLines("test <- 'TRUE'", file.path(init_tmpdir, ".Rprofile"))
  init(init_tmpdir)
  expected <- c("library(envsetup)", "envsetup_config <- config::get(file = \"envsetup.yml\")", "rprofile(envsetup_config)",
                "test <- 'TRUE'")
  actual <- readLines(file.path(init_tmpdir, ".Rprofile"))
  expect_equal(expected, actual)
})

test_that("init does not update the .Rprofile when it has already be initialized", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  init(init_tmpdir)
  expect_error(init(init_tmpdir))
})
