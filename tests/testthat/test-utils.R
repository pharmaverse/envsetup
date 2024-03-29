# temp location to store configuration files
util_tmpdir <- tempdir()

test_that("validate_config, no hierarchy paths return correct messages", {
  no_hierarchy <- 'default:
  paths:
    data: "/demo/DEV/username/project1/data"
    output: "/demo/DEV/username/project1/output"
    programs: "/demo/DEV/username/project1/programs"'

  path <- file.path(util_tmpdir, "no_hierarchy.yml")
  writeLines(no_hierarchy, path)
  withr::defer(unlink(path, recursive = TRUE))

  expect_snapshot(validate_config(config::get(file = path)))
})

test_that("validate_config, hierarchy paths return correct messages", {
  hierarchy <- "default:
  paths:
    data: !expr list(DEV = '/demo/DEV/username/project1/data',
                     PROD = '/demo/PROD/project1/data')
    output: !expr list(DEV = '/demo/DEV/username/project1/output',
                       PROD = '/demo/PROD/project1/output')
    programs: !expr list(DEV = '/demo/DEV/username/project1/programs',
                         PROD = '/demo/PROD/project1/programs')"

  path <- file.path(util_tmpdir, "hierarchy.yml")
  writeLines(hierarchy, path)
  withr::defer(unlink(path, recursive = TRUE))

  expect_snapshot(validate_config(config::get(file = path)))
})

test_that("validate_config, hierarchy paths return todo item/s when unnamed", {
  hierarchy_no_names <- "default:
  paths:
    data: !expr list('/demo/DEV/username/project1/data', '/demo/PROD/project1/data')
    output: !expr list('/demo/DEV/username/project1/output', '/demo/PROD/project1/output')
    programs: !expr list('/demo/DEV/username/project1/programs', '/demo/PROD/project1/programs')
    envsetup_environ: !expr Sys.setenv(ENVSETUP_ENVIRON = 'DEV'); 'DEV'"


  path <- file.path(util_tmpdir, "hierarchy_no_names.yml")
  writeLines(hierarchy_no_names, path)
  withr::defer(unlink(path, recursive = TRUE))

  expect_snapshot(validate_config(config::get(file = path)))
})

test_that("validate_config, no paths return correct message", {
  no_paths <- "default:
  autos:
    my_functions: '/demo/PROD/project1/R'"


  path <- file.path(util_tmpdir, "no_paths.yml")
  writeLines(no_paths, path)
  withr::defer(unlink(path, recursive = TRUE))

  expect_snapshot(validate_config(config::get(file = path)))
})
