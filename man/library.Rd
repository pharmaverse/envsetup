% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/autos.R
\name{library}
\alias{library}
\title{Wrapper around library to re-set autos}
\arguments{
\item{...}{pass directly through to base::library}
}
\value{
returns (invisibly) the list of attached packages
}
\description{
Autos need to immediately follow the global environment.
This wrapper around \code{base::library()} will reset the autos after each new
library is attached to ensure this behavior is followed.
}
\examples{
\dontrun{
library(dplyr)
}
}
