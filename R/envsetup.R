.onLoad <- function(libname, pkgname) {
  op <- options()
  op.envsetup <- list(
    envsetup.config.path = system.file("_envsetup.yml",
      package = "envsetup",
      mustWork = TRUE
    ),
    envsetup.rprofile.path = system.file(".Rprofile", package = "envsetup"),
    envsetup.renviron.path = system.file(".Renviron", package = "envsetup")
  )

  toset <- !(names(op.envsetup) %in% names(op))
  if (any(toset)) options(op.envsetup[toset])

  invisible()
}
