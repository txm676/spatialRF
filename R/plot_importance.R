#' @title Plots the variable importance of a model
#' @description Plots variable importance scores of [rf()], [rf_repeat()], and [rf_spatial()] models.
#' @usage
#' plot_importance(
#'   x,
#'   verbose = TRUE
#' )
#' @param x A model fitted with [rf()], [rf_repeat()], or [rf_spatial()].
#' @param verbose Logical, if `TRUE`, the plot is printed. Default: `TRUE`
#' @return A ggplot.
#' @seealso [print_importance()], [get_importance()]
#' @examples
#' \donttest{
#' if(interactive()){
#'
#' data(plant_richness_df)
#' data(distance.matrix)
#'
#' rf.model <- rf(
#'   data = plant_richness_df,
#'  dependent.variable.name = "richness_species_vascular",
#'  predictor.variable.names = colnames(plant_richness_df)[5:21],
#'  distance.matrix = distance_matrix,
#'  distance.thresholds = c(0, 1000, 2000),
#'  verbose = FALSE
#' )
#'
#' plot_importance(x = rf.model)
#'
#' }
#' }
#' @rdname plot_importance
#' @export
#' @importFrom ggplot2 ggplot aes geom_point scale_fill_viridis_c ylab xlab theme geom_boxplot scale_fill_viridis_d
plot_importance <- function(x, verbose = TRUE){

  #declaring variables
  importance <- NULL
  variable <- NULL

  #if x is not a data frame
  if(!is.data.frame(x)){

    #importance from rf
    if(inherits(x, "rf") & !inherits(x, "rf_spatial") & !inherits(x, "rf_repeat")){
      x <- x$variable.importance$per.variable
    }

    #importance from rf_repeat
    if(inherits(x, "rf_repeat") & !inherits(x, "rf_spatial")){
      x <- x$variable.importance$per.repetition
    }

    #importance from rf_spatial and rf
    if(inherits(x, "rf_spatial")){
      x <- x$variable.importance$spatial.predictors
    }

  }

  #find duplicates in "variable"
  variable.duplicated <- duplicated(x$variable)

  #no duplicates, rf
  if(sum(variable.duplicated) == 0){

    p <- ggplot2::ggplot(data = x) +
      ggplot2::aes(
        x = importance,
        y = reorder(
          variable,
          importance,
          FUN = max
        ),
        fill = importance
      ) +
      ggplot2::geom_point(size = 4, shape = 21) +
      ggplot2::scale_fill_viridis_c(direction = -1, alpha = 0.8) +
      ggplot2::ylab("") +
      ggplot2::xlab("Variable importance") +
      ggplot2::theme_bw() +
      ggplot2::theme(legend.position = "none")

  } else {

    #no "spatial_predictors" in variable, rf_repeat
    if(!("spatial_predictors" %in% x$variable)){

      p <- ggplot2::ggplot(data = x) +
        ggplot2::aes(
          x = importance,
          y = reorder(
            variable,
            importance,
            FUN = stats::median
          ),
          fill = reorder(
            variable,
            importance,
            FUN = stats::median
          )
        ) +
        ggplot2::geom_boxplot() +
        ggplot2::scale_fill_viridis_d(direction = -1, alpha = 0.8) +
        ggplot2::ylab("") +
        ggplot2::xlab("Variable importance") +
        ggplot2::theme_bw() +
        ggplot2::theme(legend.position = "none")

    }

    #spatial_predictors, rf_spatial
    if("spatial_predictors" %in% x$variable){

      #if no predictors duplicated, rf_spatial rf
      if(sum(duplicated(x$variable[x$variable != "spatial_predictors"])) == 0){

        p <- ggplot2::ggplot(data = x) +
          ggplot2::aes(
            x = importance,
            y = reorder(
              variable,
              importance,
              FUN = max
            ),
            fill = importance
          ) +
          ggplot2::geom_point(size = 4, shape = 21) +
          ggplot2::scale_fill_viridis_c(direction = -1, alpha = 0.8) +
          ggplot2::ylab("") +
          ggplot2::xlab("Variable importance") +
          ggplot2::theme_bw() +
          ggplot2::theme(legend.position = "none")

        #rf_spatial rf_repeat
      } else {

        p <- ggplot2::ggplot(data = x) +
          ggplot2::aes(
            x = importance,
            y = reorder(
              variable,
              importance,
              FUN = mean
            ),
            fill = reorder(
              variable,
              importance,
              FUN = mean
            )
          ) +
          ggplot2::geom_boxplot() +
          ggplot2::scale_fill_viridis_d(direction = -1, alpha = 0.8) +
          ggplot2::ylab("") +
          ggplot2::xlab("Variable importance") +
          ggplot2::theme_bw() +
          ggplot2::theme(legend.position = "none")

      }

    }

  }

  if(verbose == TRUE){
    suppressMessages(print(p))
  }

  return(p)

}
