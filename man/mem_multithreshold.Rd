% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mem_multithreshold.R
\name{mem_multithreshold}
\alias{mem_multithreshold}
\title{mem_multithreshold}
\usage{
mem_multithreshold(
  x = NULL,
  distance.thresholds = 0,
  max.spatial.predictors = 1000
)
}
\arguments{
\item{x}{x Numeric matrix or data frame, generally a distance matrix, Default: NULL}

\item{distance.thresholds}{(optional) numeric vector with distance thresholds defining neighborhood in the distance matrix, Default: 0}

\item{max.spatial.predictors}{(optional) maximum number of spatial predictors to generate. Only useful when the distance matrix \code{x} is very large. Default: 1000}
}
\value{
a data frame with as many rows as the matrix \code{x} with Moran's Eigenvector Maps. The data frame columns are named "spatial_predictor_DISTANCE_COLUMN", where distance is the given distance threshold, and column is the column index of the given predictor.
}
\description{
Computes Moran's Eigenvector Maps of a distance matrix (using \link{mem}) over different distance thresholds
}
\details{
The function takes the distance matrix \code{x}, computes its weights at difference distance thresholds, double-centers the resulting weight matrices with \link{double_center_distance_matrix}, applies \link[base]{eigen} to each double-centered matrix, and returns eigenvectors with positive normalized eigenvalues for different distance thresholds.
}
\examples{
\dontrun{
if(interactive()){
 data(distance_matrix)
 x <- mem_multithreshold(
   x = distance_matrix,
   distance.thresholds = c(0, 1000, 2000)
   )
 }
}
}