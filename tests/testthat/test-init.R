init_tmpdir <- base::tempdir()
config_path <- test_path("man/_envsetup_testthat.yml")

test_that("init creates a .Rprofile", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  expect_snapshot(init(init_tmpdir, config_path))
  expect_true(file.exists(file.path(init_tmpdir, ".Rprofile")))
})

test_that("init initializes an .Rprofile correcty when one does not exist", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  expect_snapshot(init(init_tmpdir, config_path))
})

test_that("init initializes an .Rprofile correcty when one does exist", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  writeLines("test <- 'TRUE'", file.path(init_tmpdir, ".Rprofile"))
  expect_snapshot(init(init_tmpdir, config_path))
})

test_that("init does not update the .Rprofile when it has already be initialized", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  init(init_tmpdir, config_path)
  expect_error(init(init_tmpdir, config_path))
})
