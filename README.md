
<!-- README.md is generated from README.Rmd. Please edit that file -->

# envsetup <img src='man/figures/logo.png' align="right" height="200" style="float:right; height:200px;" />

<!-- start badges -->

[<img src="http://pharmaverse.org/shields/envsetup.svg">](https://pharmaverse.org)
[![Check
🛠](https://github.com/pharmaverse/envsetup/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pharmaverse/envsetup/actions/workflows/R-CMD-check.yaml)
[![Docs
📚](https://github.com/pharmaverse/envsetup/actions/workflows/pkgdown.yaml/badge.svg)](https://pharmaverse.github.io/envsetup/)
[![Code Coverage
📔](https://raw.githubusercontent.com/pharmaverse/envsetup/refs/heads/gh-pages/_xml_coverage_reports/badge.svg)](https://pharmaverse.github.io/envsetup/_xml_coverage_reports/coverage.html)
![GitHub commit
activity](https://img.shields.io/github/commit-activity/m/pharmaverse/envsetup)
![GitHub
contributors](https://img.shields.io/github/contributors/pharmaverse/envsetup)
![GitHub last
commit](https://img.shields.io/github/last-commit/pharmaverse/envsetup)
![GitHub pull
requests](https://img.shields.io/github/issues-pr/pharmaverse/envsetup)
![GitHub repo
size](https://img.shields.io/github/repo-size/pharmaverse/envsetup)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Current
Version](https://img.shields.io/github/r-package/v/pharmaverse/envsetup/main?color=purple&label=package%20version)](https://github.com/pharmaverse/envsetup/tree/main)
[![Open
Issues](https://img.shields.io/github/issues-raw/pharmaverse/envsetup?color=red&label=open%20issues)](https://github.com/pharmaverse/envsetup/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc)
![GitHub
forks](https://img.shields.io/github/forks/pharmaverse/envsetup?style=social)
![GitHub repo
stars](https://img.shields.io/github/stars/pharmaverse/envsetup?style=social)
<!-- badges: end -->

# Overview

The `envsetup` package helps you manage R project environments by
providing a flexible configuration system that adapts to different
deployment stages (development, testing, production) without requiring
code changes.

## Why Use envsetup?

When working on R projects, you often need to:

- Point to different data sources across environments

- Use different output directories

- Load environment-specific functions

- Maintain consistent code across environments like dev, qa, and prod

Instead of hardcoding paths or manually changing configurations,
`envsetup` uses YAML configuration files to manage these differences
automatically.

## Basic Concepts

The `envsetup` package works with two main components:

1.  **PATHS**: Manages file system locations (data, output, programs)
2.  **AUTOS**: Automatically sources R scripts from specified
    directories

## Your First Configuration

Here’s the simplest possible `_envsetup.yml` configuration:

``` yaml
default:
  paths:
    data: "/path/to/your/data"
    output: "/path/to/your/output"
```

## Quick Start Example

``` r
library(envsetup)

# Load your configuration
envsetup_config <- config::get(file = "_envsetup.yml")

# Apply the configuration
rprofile(envsetup_config)

# Now you can use the configured paths
print(data)    # Points to your data directory
print(output)  # Points to your output directory
```

## Installation

``` r
install.packages("envsetup")
```

### Development version

``` r
# install.packages("devtools")
devtools::install_github("pharmaverse/envsetup")
```

## What’s Next?

In the following guides, you’ll learn:

- How to set up basic path configurations

- Managing multiple environments

- Advanced path resolution

- Automatic script sourcing

- Real-world examples and best practices

Let’s start with basic path configuration in the next section.
