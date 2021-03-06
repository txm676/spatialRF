% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prepare_importance_spatial.R
\name{prepare_importance_spatial}
\alias{prepare_importance_spatial}
\title{Prepares variable importance objects for spatial models}
\usage{
prepare_importance_spatial(x)
}
\arguments{
\item{x}{An importance data frame with spatial predictors.}
}
\value{
A list with importance data frames in different formats depending on whether the model was fitted with \code{\link[=rf]{rf()}} or \code{\link[=rf_repeat]{rf_repeat()}}.
}
\description{
Prepares variable importance data frames and plots for models fitted with \code{\link[=rf_spatial]{rf_spatial()}}.
}
\examples{
\dontrun{
if(interactive()){

 data(distance_matrix)
 data(plant_richness_df)

 model <- rf_spatial(
   data = plant_richness_df,
   dependent.variable.name = "richness_species_vascular",
   predictor.variable.names = colnames(plant_richness_df)[5:21],
   distance.matrix = distance_matrix,
   distance.thresholds =  c(0, 500, 1000)
 )

 importance <- prepare_importance_spatial(model)
 names(importance)

 }
}
}
