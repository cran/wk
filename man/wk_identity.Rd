% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filter.R
\name{wk_identity}
\alias{wk_identity}
\alias{wk_identity_filter}
\alias{wk_restore}
\alias{wk_restore.default}
\title{Copy a geometry vector}
\usage{
wk_identity(handleable, ...)

wk_identity_filter(handler)

wk_restore(handleable, result, ...)

\method{wk_restore}{default}(handleable, result, ...)
}
\arguments{
\item{handleable}{A geometry vector (e.g., \code{\link[=wkb]{wkb()}}, \code{\link[=wkt]{wkt()}}, \code{\link[=xy]{xy()}},
\code{\link[=rct]{rct()}}, or \code{\link[sf:sfc]{sf::st_sfc()}}) for which \code{\link[=wk_handle]{wk_handle()}} is defined.}

\item{...}{Passed to the \code{\link[=wk_handle]{wk_handle()}} method.}

\item{handler}{A \link[=wk_handle]{wk_handler} object.}

\item{result}{The result of a filter operation intended to be a
transformation.}
}
\value{
A copy of \code{handleable}.
}
\description{
Copy a geometry vector
}
\examples{
wk_identity(wkt("POINT (1 2)"))

}
