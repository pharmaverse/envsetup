
<!-- README.md is generated from README.Rmd. Please edit that file -->

# envsetup <img src='man/figures/logo.png' align="right" height="200" style="float:right; height:200px;" />

<!-- badges: start -->
<!-- badges: end -->

## Overview

The purpose of this package is to support the setup the R environment.
The two main features are:

-   `autos` to automatically source files and/or directories into your
    environment

-   `paths` to consistently set path objects across projects for I/O

Both are implemented using a configuration file to allow easy, custom
configurations that can be used for multiple or all projects.

## Installation

### Development version

``` r
# install.packages("devtools")
devtools::install_github("pharmaverse/envsetup")
```

## Usage

1.  Create the \_envsetup.yml configuration file to specify your autos
    and paths and store centrally.
2.  Create or update your `.Rprofile` to read in the config and call
    `rprofile()`

``` r
library(envsetup)

# read configuration
envsetup_config <- config::get(file = "path/to/_envsetup.yml")

# pass configuration to rprofile() to setup the environment
rprofile(envsetup_config)
```
