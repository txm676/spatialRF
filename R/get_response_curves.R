#' @title Gets data to allow custom plotting of response curves
#' @description Generates and returns the data required to plot the response curves of a model fitted with [rf()], [rf_repeat()], or [rf_spatial()].
#' @param x A model fitted with [rf()], [rf_repeat()], or [rf_spatial()].
#' @param variables Character vector, names of predictors to plot. If `NULL`, the most important variables (importance higher than the median) in `x` are selected. Default: `NULL`.
#' @param quantiles Numeric vector with values between 0 and 1, argument `probs` of \link[stats]{quantile}. Quantiles to set the other variables to. Default: `c(0.1, 0.5, 0.9)`
#' @param grid.resolution Integer between 20 and 500. Resolution of the plotted curve Default: `100`
#' @param verbose Logical, if TRUE the plot is printed. Default: `TRUE`
#' @return A data frame with the following columns:
#' \itemize{
#'   \item `response`: Predicted values of the response, obtained with `stats::predict()`.
#'   \item `predictor`: Values of the given predictor.
#'   \item `quantile`: Grouping column, values of the quantiles at which the other predictors are set to generate the response curve.
#'   \item `model`: Model number, only relevant if the model was produced with [rf_repeat()].
#'   \item `predictor.name`: Grouping variable, name of the predictor.
#'   \item `response.name`: Grouping variable, name of the response variable.
#' }
#' @details All variables that are not plotted in a particular response curve are set to the values of their respective quantiles, and the response curve for each one of these quantiles is shown in the plot.
#' @seealso [plot_response_curves()]
#' @examples
#' \donttest{
#' if(interactive()){
#'
#'data(plant_richness_df)
#'
#'out <- rf(
#'  data = plant_richness_df,
#'  dependent.variable.name = "richness_species_vascular",
#'  predictor.variable.names = colnames(plant_richness_df)[5:21],
#'  verbose = FALSE
#')
#'
#'p <- get_response_curves(x = out)
#'head(p)
#'
#' }
#' }
#' @rdname get_response_curves
#' @export
get_response_curves <- function(
  x = NULL,
  variables = NULL,
  quantiles = c(0.1, 0.5, 0.9),
  grid.resolution = 200,
  verbose = TRUE
){

  if(is.null(x)){
    stop("Argument 'x' must not be empty.")
  }

  #preparing grid resolution
  grid.resolution <- floor(grid.resolution)
  if(grid.resolution > 500){grid.resolution <- 500}
  if(grid.resolution < 20){grid.resolution <- 20}

  #quantile limits
  quantiles <- quantiles[quantiles >= 0]
  quantiles <- quantiles[quantiles <= 1]

  #getting the training data
  data <- x$ranger.arguments$data

  #getting the response variable
  response.variable <- x$ranger.arguments$dependent.variable.name
  predictors <- x$ranger.arguments$predictor.variable.names
  if(inherits(x, "rf_spatial")){

    predictors <- predictors[!(predictors %in% x$selection.spatial.predictors$names)]

  }

  #default values for variables
  if(is.null(variables)){

    variables <- x$variable.importance$per.variable[x$variable.importance$per.variable$variable %in% predictors, "variable"][1:floor(length(predictors) / 2)]

  }

  if(sum(variables %in% colnames(data)) != length(variables)){

    stop("Variable names in 'variables' must be column names of x$ranger.arguments$data.")

  }

  #PREPARING NEWDATA

  #list to store plots
  variables.list <- list()

  #iterating through variables
  for(variable.i in variables){

    #names of the other variables
    other.variables <- setdiff(x$ranger.arguments$predictor.variable.names, variable.i)

    #generating grid
    variable.i.grid <- data.frame(
      variable = seq(
        min(data[, variable.i]),
        max(data[, variable.i]),
        length.out = grid.resolution
      )
    )
    colnames(variable.i.grid) <- variable.i
    variable.i.grid$id <- seq(1, nrow(variable.i.grid))

    #list to store quantile results
    variable.i.quantiles <- list()

    #iterating through quantiles
    for(quantile.i in quantiles){

      #grid copy
      variable.i.grid.copy <- variable.i.grid

      #iterating through variables
      for(variable.j in other.variables){

        variable.i.grid.copy[, variable.j] <- quantile(data[, variable.j], quantile.i)

      }

      #adding quantile column
      variable.i.grid.copy$quantile <- quantile.i

      #save to list
      variable.i.quantiles[[as.character(quantile.i)]] <- variable.i.grid.copy

    }

    #plot data frame
    quantiles.temp <- do.call("rbind", variable.i.quantiles)
    quantiles.temp$quantile <- factor(quantiles.temp$quantile)

    #saving into variables.list
    variables.list[[variable.i]] <- quantiles.temp

  }

  #ITERATING THROUGH VARIABLES AND MODELS TO PREDICT AND PLOT

  #list to store plots
  variables.df.list <- list()

  #models
  if("models" %in% names(x)){
    models.list <- x$models
  } else {
    models.list <- list()
    models.list[[1]] <- x
  }

  #iterating through variables to predict
  for(variable.i in variables){

    #list to store predictions by different models
    variable.i.list <- list()

    #predictions by models
    for(i in seq(1, length(models.list))){

      #add new data to variable.i.list
      variable.i.list[[i]] <-  variables.list[[variable.i]]

      #get model.i
      model.i <- models.list[[i]]
      class(model.i) <- "ranger"

      #predict
      variable.i.list[[i]][, response.variable] <- stats::predict(
        object = model.i,
        data = variable.i.list[[i]])$predictions

      #add model index
      variable.i.list[[i]][, "model"] <- i

    }

    #putting together data frame for plotting
    variable.i.df <- do.call("rbind", variable.i.list)

    #subsetting
    variable.i.df <- variable.i.df[, c(
      response.variable,
      variable.i,
      "quantile",
      "model"
    )]

    #adding predictor name
    variable.i.df$predictor.name <- variable.i
    variable.i.df$response.name <- response.variable

    #replacing colnames
    colnames(variable.i.df)[c(1, 2)] <- c("response", "predictor")

    #adding to variables.df list
    variables.df.list[[variable.i]] <- variable.i.df

  }#end of plotting


  #turning list into df
  variables.df <- do.call("rbind", variables.df.list)


  #reseting rownames
  rownames(variables.df) <- NULL

  #returning variables.df
  variables.df

}
