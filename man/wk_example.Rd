% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{wk_example}
\alias{wk_example}
\alias{wk_example_wkt}
\title{Create example geometry objects}
\format{
An object of class \code{list} of length 29.
}
\usage{
wk_example(which = "nc", crs = NA, geodesic = FALSE)

wk_example_wkt
}
\arguments{
\item{which}{An example name. Valid example names are
\itemize{
\item "nc" (data derived from the sf package)
\item "point", "linestring", "polygon", "multipoint",
"multilinestring", "multipolygon", "geometrycollection"
\item One of the above with the "_z", "_m", or "_zm" suffix.
}}

\item{crs}{An object that can be interpreted as a CRS}

\item{geodesic}{\code{TRUE} if edges must be interpolated as geodesics when
coordinates are spherical, \code{FALSE} otherwise.}
}
\value{
A \code{\link[=wkt]{wkt()}} with the specified example.
}
\description{
Create example geometry objects
}
\examples{
wk_example("polygon")

}
\keyword{datasets}
