% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/paths.R
\name{build_from_config}
\alias{build_from_config}
\title{Build directory structure from a configuration file}
\usage{
build_from_config(config, root = NULL)
}
\arguments{
\item{config}{configuration object from config::get() containing paths}

\item{root}{root directory to build from.
Leave as NULL if using absolute paths.  Set to working directory if using relative paths.}
}
\value{
Called for its side-effects. The directories build print as a tree-like format from \code{fs::dir_tree()}.
}
\description{
Build directory structure from a configuration file
}
\examples{
tmpdir <- tempdir()

hierarchy <- "default:
  paths:
    data: !expr list(DEV = '/demo/DEV/username/project1/data',
                     PROD = '/demo/PROD/project1/data')
    output: !expr list(DEV = '/demo/DEV/username/project1/output',
                       PROD = '/demo/PROD/project1/output')
    programs: !expr list(DEV = '/demo/DEV/username/project1/programs',
                         PROD = '/demo/PROD/project1/programs')
    docs: !expr list(DEV = 'docs',
                     PROD = 'docs')"

writeLines(hierarchy, file.path(tmpdir, "hierarchy.yml"))

config <- config::get(file = file.path(tmpdir, "hierarchy.yml"))

build_from_config(config, tmpdir)
}
