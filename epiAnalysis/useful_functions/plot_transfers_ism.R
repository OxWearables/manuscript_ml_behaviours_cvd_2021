plot_transfers_ism <- function(from_part,
         to_part,
         model,
         dataset,
         fixed_values = NULL,
         part_1 = NULL,
         comp_labels,
         yllimit = NULL,
         yulimit = NULL,
         xllimit = NULL,
         xulimit = NULL,
         y_label = NULL,
         plot_log = FALSE,
         lower_quantile = 0.05,
         upper_quantile = 0.95,
         units = "unitless",
         specified_units = NULL,
         terms = TRUE,
         granularity = 2000,
         point_specification = ggplot2::geom_point(size = 2),
         error_bar_colour = "grey",
         theme = NULL,
         cm = NULL) {

  # Set theme for plotting
  if (is.null(theme)){
    theme_for_plots <-
      ggplot2::theme(
        line = ggplot2::element_line(size = 1),
        axis.ticks = ggplot2::element_line(size= 2),
        text = ggplot2::element_text(size = 15, face = "bold"),
        axis.text.y = ggplot2::element_text(
          size = 15,
          face = "bold",
          colour = "black"
        ),
        axis.text.x = ggplot2::element_text(
          size = 15,
          face = "bold",
          colour = "black"
        )
      )
  }
  else{
    theme_for_plots <- theme
  }


  # We set units
  comp_sum <- as.numeric(epicoda:::process_units(units, specified_units)[2])
  units <- epicoda:::process_units(units, specified_units)[1]

  # We take dataset
  dataset_ready <-dataset


  # We assign some internal parameters
  type <- epicoda:::process_model_type(model)


  # We make sure there will be a y_label, unless this is specified as "suppressed"
  y_label <- epicoda:::process_axis_label(label = y_label, type = type, terms = terms)


  # We calculate the compositional mean so we can use it in future calculations
  if (is.null(cm)){
    stop("Compositional mean should be specified to match other model being plotted.")
  }
  cm_on_scale <- epicoda:::rescale_comp(cm, comp_labels = comp_labels, comp_sum = comp_sum)


  # We assign some fixed_values to use in setting up new_data
  if (!(is.null(fixed_values))) {
    if (length(colnames(fixed_values)[colnames(fixed_values) %in% comp_labels]) > 0) {
      warning(
        "fixed_values will be updated to have compositional parts fixed at the compositional mean. For technical and pragmatic reasons, use of a different reference for the compositional parts is not currently possible."
      )
    }
    fixed_values <- cbind(fixed_values, cm)
  }
  if (is.null(fixed_values)) {
    fixed_values <-
      epicoda:::generate_fixed_values(
        dataset,
        comp_labels
      )
    fixed_values <- cbind(fixed_values, cm)
  }
  fixed_values <- epicoda:::normalise_comp(fixed_values, comp_labels)
  fixed_values_on_scale <- epicoda:::rescale_comp(fixed_values, comp_labels = comp_labels, comp_sum = comp_sum)

  # We make some new data for predictions
  # Note all predictions are done on the data scale, not the output scale
  new_data <-
    epicoda:::make_new_data(
      from_part,
      to_part,
      fixed_values = fixed_values,
      dataset  = dataset_ready,
      units = "hr/day",
      comp_labels = comp_labels,
      lower_quantile = lower_quantile,
      upper_quantile = upper_quantile,
      granularity = granularity
    )
  new_data <- epicoda:::normalise_comp(new_data, comp_labels)

  # This is to allow visual checks
  behaviour_terms <- c("MVPA", "LIPA", "SB")
  print(head(new_data[, behaviour_terms]))
  print(tail(new_data[, behaviour_terms]))

  # This does predictions
  predictions <- data.frame(stats::predict(
    model,
    newdata = new_data,
    type = "terms",
    terms =  behaviour_terms
  ))

  # This does predictions at compositional mean to normalise to
  acm <- stats::predict(model,
                        newdata = fixed_values,
                        type = "terms",
                        terms = behaviour_terms)


  dNew <- data.frame(new_data, predictions)

  # This makes the sum
  vector_for_args <-   paste("predictions$", behaviour_terms, sep = "")
  sum_for_args <- paste0(vector_for_args, collapse = "+")

  # This calculates log hazard change and HR between new composition and compositional mean
  dNew$log_hazard_change <- eval(parse(text = sum_for_args)) - sum(acm)
  dNew$fit <- exp(dNew$log_hazard_change)

  # This calculates confidence interval
  middle_matrix <- stats::vcov(model)[behaviour_terms, behaviour_terms] # variance-covariance matrix of model coefficients
  x <- new_data[, behaviour_terms] # We create delta-x vector
  for (term in behaviour_terms){
    x[, term] <- new_data[, term] - cm[, term]
  }
  x <- data.matrix(x)
  t_x <- data.matrix(as.matrix(t(x)))
  in_sqrt_true <- diag((x %*% middle_matrix) %*% t_x) # This is the variance of the log-hazard difference
  value <- sqrt(data.matrix(in_sqrt_true)) # This is the standard error of the log-hazard difference

  z_value <- stats::qnorm(0.975) # We find the appropriate z value

  alpha_lower <- dNew$log_hazard_change - z_value*value # We calculate the upper and lower limits of the CI on the log hazard schale
  alpha_upper <- dNew$log_hazard_change + z_value*value

  dNew$lower_CI <- exp(alpha_lower) # We exponentiate to get the confidence intervals
  dNew$upper_CI <- exp(alpha_upper)

  # We pull out the required axis values on the needed scale
  dToScale <- epicoda:::rescale_comp(data = dNew, comp_labels = comp_labels, comp_sum = comp_sum)
  dNew$axis_vals <-
    dToScale[, to_part] - rep(cm_on_scale[1, to_part], by = nrow(dNew))

  # We calculate some utilities for the plot
  if (is.null(yllimit)) {
    yllimit <- min(dNew$lower_CI)
  }
  if (is.null(yulimit)) {
    yulimit <- max(dNew$upper_CI)
  }
  if (is.null(xllimit)) {
    xllimit <- min(dNew$axis_vals)
  }
  if (is.null(xulimit)) {
    xulimit <- max(dNew$axis_vals)
  }

  dNew$lower_CI <-
    pmax(rep(yllimit, by = length(dNew$lower_CI)), dNew$lower_CI)
  dNew$upper_CI <-
    pmin(rep(yulimit, by = length(dNew$lower_CI)), dNew$upper_CI)


  if (type == "cox") {
    if (plot_log == TRUE) {
      plot_of_this <-
        ggplot2::ggplot(data = dNew,
                        mapping = ggplot2::aes_(x = dNew$axis_vals, y = dNew$fit)) +
        ggplot2::xlim(xllimit, xulimit) +
        ggplot2::geom_errorbar(ggplot2::aes_(
          x = dNew$axis_vals,
          ymin = dNew$lower_CI,
          ymax = dNew$upper_CI
        ),
        color = error_bar_colour) +
        point_specification +
        ggplot2::labs(
          x = paste("More", from_part, "\U2194", "More", to_part, "\n " , units),
          y = y_label
        ) +
        ggplot2::geom_hline(yintercept = 1) +
        ggplot2::geom_vline(xintercept = 0) +
        ggplot2::scale_y_continuous(
          trans = scales::log_trans(),
          breaks = seq(round(yllimit, digits = 1), round(yulimit, digits = 1), by = 0.1),
          labels = seq(round(yllimit, digits = 1), round(yulimit, digits = 1), by = 0.1),
          minor_breaks = NULL,
          limits = c(yllimit, yulimit)
        )+
        theme_for_plots
    }
}


  print("Please note that plotting may take some time.")
  return(plot_of_this)
}
