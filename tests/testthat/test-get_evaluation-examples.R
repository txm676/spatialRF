test_that("`get_evaluation()` works", {
  data(plant_richness_df)
  data(distance_matrix)
  rf.model <- rf(
    data = plant_richness_df, dependent.variable.name = "richness_species_vascular",
    predictor.variable.names = colnames(plant_richness_df)[5:21],
    distance.matrix = distance_matrix, distance.thresholds = c(
      0,
      1000, 2000
    ), verbose = FALSE
  )
  rf.model <- rf_evaluate(model = rf.model, xy = plant_richness_df[
    ,
    c("x", "y")
  ], verbose = FALSE,
  n.cores = 1)
  x <- get_evaluation(x = rf.model)
  expect_s3_class(x, "data.frame")
  expect_named(x, c("model", "metric", "mean", "sd", "min", "max"))
})
