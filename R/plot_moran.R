#' @title Plots a Moran's I test of model residuals
#' @description Plots the results of spatial autocorrelation tests for a variety of functions within the package.
#' @usage
#' plot_moran(
#'   x,
#'   verbose = TRUE
#' )
#' @param x A model fitted with [rf()], [rf_repeat()], or [rf_spatial()]. Default: `NULL`
#' @param verbose Logical, if `TRUE`, the resulting plot is printed, Default: `TRUE`
#' @return A ggplot.
#' @seealso [moran()], [moran_multithreshold()]
#' @examples
#' \donttest{
#' if(interactive()){
#'
#'  data(plant_richness_df)
#'  data(distance.matrix)
#'
#'  rf.model <- rf(
#'    data = plant_richness_df,
#'    dependent.variable.name = "richness_species_vascular",
#'    predictor.variable.names = colnames(plant_richness_df)[5:21],
#'    distance.matrix = distance_matrix,
#'    distance.thresholds = c(0, 1000, 2000),
#'    verbose = FALSE
#'  )
#'
#'  plot_moran(x = rf.model)
#'
#' }
#' }
#' @rdname plot_moran
#' @export
#' @importFrom ggplot2 ggplot aes geom_hline geom_point geom_line xlab ylab ggtitle theme labs scale_colour_manual
#' @export
plot_moran <- function(x, verbose = TRUE){

  #declaring variables
  distance.threshold <- NULL
  moran.i <- NULL
  p.value.binary <- NULL
  repetition <- NULL
  model <- NULL


  #if x is not a data frame
  if(!is.data.frame(x)){

    #importance from rf
    if(inherits(x, "rf") & !inherits(x, "rf_spatial")){
      x <- x$spatial.correlation.residuals$per.distance
    }

    #importance from rf_repeat
    if(inherits(x, "rf_repeat") & !inherits(x, "rf_spatial")){
      x <- x$spatial.correlation.residuals$per.repetition
    }

    #importance from rf_spatial and rf
    if(inherits(x, "rf_spatial") & inherits(x, "rf")){
      x <- x$spatial.correlation.residuals$per.distance
    }

    if(inherits(x, "rf_spatial") & inherits(x, "rf_repeat")){
      x <- x$spatial.correlation.residuals$per.repetition
    }

  }

  #adding binary p.value
  x$p.value.binary <- "< 0.05"
  x[x$p.value >= 0.05, "p.value.binary"] <- ">= 0.05"
  x$p.value.binary <- factor(x$p.value.binary, levels = c("< 0.05", ">= 0.05"))

  #plotting rf
  if(!("repetition" %in% colnames(x))){

    p <- ggplot2::ggplot(data = x) +
      ggplot2::aes(
        x = distance.threshold,
        y = moran.i,
        size = p.value.binary
      ) +
      ggplot2::geom_hline(
        yintercept = 0,
        col = "gray10",
        size = 0.7,
        linetype = "dashed"
      ) +
      ggplot2::geom_point(color = "#440154FF") +
      ggplot2::geom_line(size = 1, color = "#440154FF") +
      ggplot2::scale_size_manual(
        breaks = c("< 0.05", ">= 0.05"),
        values = c(1, 5),
        drop = FALSE
        ) +
      ggplot2::scale_x_continuous(breaks = x$distance.threshold) +
      ggplot2::xlab("Distance thresholds") +
      ggplot2::ylab("Moran's I of residuals") +
      ggplot2::ggtitle("Multiscale Moran's I") +
      ggplot2::theme_bw() +
      ggplot2::theme(legend.position = "bottom") +
      ggplot2::labs(size = "Moran's I p-value")

  }

  #plotting rf_repeat
  if("repetition" %in% colnames(x)){

    p <- ggplot2::ggplot(data = x) +
      ggplot2::aes(
        x = distance.threshold,
        y = moran.i,
        group = repetition,
        size = p.value.binary
      ) +
      ggplot2::geom_hline(
        yintercept = 0,
        col = "gray10",
        size = 0.7,
        linetype = "dashed"
      ) +
      ggplot2::geom_point(
        color = "#440154FF",
        alpha = 0.7
        ) +
      ggplot2::geom_line(
        size = 1,
        color = "#440154FF",
        alpha = 0.7
        ) +
      ggplot2::scale_size_manual(
        breaks = c("< 0.05", ">= 0.05"),
        values = c(1, 5),
        drop = FALSE
      ) +
      ggplot2::scale_x_continuous(breaks = x$distance.threshold) +
      ggplot2::xlab("Distance thresholds") +
      ggplot2::ylab("Moran's I of residuals") +
      ggplot2::ggtitle("Moran's I of the residuals") +
      ggplot2::theme_bw() +
      ggplot2::theme(legend.position = "bottom") +
      ggplot2::labs(color = "Model", size = "Moran's I p-value")

  }

  if(verbose == TRUE){
    suppressWarnings(print(p))
  }

  return(p)

}
