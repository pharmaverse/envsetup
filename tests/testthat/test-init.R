init_tmpdir <- base::tempdir()
config_path <- test_path("man/default_hierarchy_envsetup.yml")
r_version <- function() paste0("R", getRversion()[, 1:2])

test_that("init creates a .Rprofile", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  expect_snapshot(init(init_tmpdir, config_path, create_paths = FALSE), variant = r_version())
  expect_true(file.exists(file.path(init_tmpdir, ".Rprofile")))
})

test_that("init initializes an .Rprofile correcty when one does not exist", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  expect_snapshot(init(init_tmpdir, config_path, create_paths = FALSE), variant = r_version())
})

test_that("init initializes an .Rprofile correcty when one does exist", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  writeLines("test <- 'TRUE'", file.path(init_tmpdir, ".Rprofile"))
  expect_snapshot(init(init_tmpdir, config_path, create_paths = FALSE), variant = r_version())
})

test_that("init does not update the .Rprofile when it has already be initialized", {
  withr::defer(unlink(file.path(init_tmpdir, ".Rprofile")))
  init(init_tmpdir, config_path, create_paths = FALSE)
  expect_warning(init(init_tmpdir, config_path, create_paths = FALSE))
})
