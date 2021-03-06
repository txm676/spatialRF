% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_predictions.R
\name{get_predictions}
\alias{get_predictions}
\title{Gets model predictions}
\usage{
get_predictions(x)
}
\arguments{
\item{x}{A model produced by \code{\link[=rf]{rf()}}, \code{\link[=rf_repeat]{rf_repeat()}}, or \code{\link[=rf_spatial]{rf_spatial()}}.}
}
\value{
A data frame with predictions, or mean and standard deviation of the predictions if the model was fitted with \code{\link[=rf_repeat]{rf_repeat()}}.
}
\description{
Returns model predictions from a model fitted with \code{\link[=rf]{rf()}}, \code{\link[=rf_repeat]{rf_repeat()}}, or \code{\link[=rf_spatial]{rf_spatial()}}.
}
\examples{
\donttest{
if(interactive()){

data(plant_richness_df)

rf.model <- rf(
  data = plant_richness_df,
  dependent.variable.name = "richness_species_vascular",
  predictor.variable.names = colnames(plant_richness_df)[5:21],
  verbose = FALSE
)

x <- get_predictions(x = rf.model)
x

}
}
}
