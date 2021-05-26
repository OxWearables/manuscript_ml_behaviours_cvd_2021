#' Produce a forest plot indicating model prediction at given compositions
#'
#' This function takes a named list of compositions, and plots a model prediction at each composition.
#'
#' @param composition_list Named list of compositions. Note each composition should be stored as a data frame. For example, use the output of \code{change_composition}.
#' @param models_list If \code{model} is \code{NULL} (or not set), a named list of models for which to plot model predictions in the forest plot. Note all models should have the same type or the results will be meaningless.
#' @param x_label Label for x axis in plot.
#' @param xllimit Minimum value for x axis.
#' @param xulimit Maximum value for x axis.
#' @param text_settings An optional argument which should be an \code{fpTxtGp} object as specified in the \code{forestplot} package.
#' @param plot_log If this is \code{TRUE}, the x-axis will be log-transformed.
#' @param boxsize Sets the size of the boxes plotted on the forest plot to show predictions.
#' @inheritParams predict_fit_and_ci
#' @inheritDotParams forestplot::forestplot
#' @return Forest plot illustrating prediction of the model at given compositions.
#' @export
forest_plot_comp_with_evals <- function (
  composition_list,
  model = NULL,
  comp_labels,
  x_label = NULL,
  xllimit = NULL,
  xulimit = NULL,
  plot_log = FALSE,
  text_settings = NULL,
  pred_name = NULL,
  boxsize = 0.05,
  terms = TRUE,
  fixed_values = NULL,
  units = "unitless",
  specified_units = NULL,
  part_1 = NULL,
  temp_in_col = NULL,
  ...
)
{
  # This part of function is all the same as forest_plot_comp in the package
  if (!is.list(composition_list)) {
    stop("`composition_list` should be a list.")
  }
  if (is.null(pred_name)) {
    pred_name <- "Model prediction (95% CI)"
  }
  if (is.null(text_settings)) {
    text_settings <-
      forestplot::fpTxtGp(
        label = grid::gpar(
          fontfamily = "sans",
          cex = 1,
          fontface = 2
        ),
        xlab = grid::gpar(
          fontfamily = "sans",
          cex = 1,
          fontface = 2
        ),
        ticks = grid::gpar(cex = 0.75,
                           fontface = 2)
      )
  }
  if (!is.null(model)) {
    type <- epicoda:::process_model_type(model)
  }

  x_label <- epicoda:::process_axis_label(label = x_label,
                                type = type,
                                terms = terms)
  if (terms) {
    if (type == "cox" | type == "logistic") {
      vline_loc <- 1
    }
    if (type == "linear") {
      vline_loc <- 0
    }
  }
  if (!terms) {
    vline_loc <- NA
  }

  col_of_names <- names(composition_list)
  df <- data.table::rbindlist(composition_list, use.names = TRUE)
  if (!is.null(model)) {
    dNew <- predict_fit_and_ci(
      model = model,
      new_data = df,
      fixed_values = fixed_values,
      part_1 = part_1,
      comp_labels = comp_labels,
      units = units,
      specified_units = specified_units,
      terms = terms
    )
    if (is.null(xllimit)) {
      xllimit <- min(dNew$lower_CI)
    }
    if (is.null(xulimit)) {
      xulimit <- max(dNew$upper_CI)
    }
    if (terms) {
      xllimit <- min(xllimit, vline_loc)
      xulimit <- max(xulimit, vline_loc)
    }
    if (((xulimit - xllimit) / 0.05) <= 10) {
      req_seq <- seq(floor((xllimit - 0.05) / 0.05) * 0.05,
                     ceiling((xulimit + 0.05) / 0.05) * 0.05, by = 0.05)
      req_seq_labs <- formatC(req_seq, format = "f",
                              digits = 2)
    }
    if ((((xulimit - xllimit) / 0.05) > 10) & (((xulimit -
                                                 xllimit) / 0.05) <= 20)) {
      req_seq <- seq(floor((xllimit - 0.1) / 0.1) * 0.1,
                     ceiling((xulimit + 0.1) / 0.1) * 0.1, by = 0.1)
      req_seq_labs <- formatC(req_seq, format = "f",
                              digits = 1)
    }
    if ((((xulimit - xllimit) / 0.05) > 20)) {
      req_seq <- seq(floor((xllimit - 0.5) / 0.5) * 0.5,
                     ceiling((xulimit + 0.5) / 0.5) * 0.5, by = 0.5)
      req_seq_labs <- formatC(req_seq, format = "f",
                              digits = 1)
    }
    attr(req_seq, "labels") <- req_seq_labs
    data_frame_for_forest_plot <- dNew[, c("fit", "lower_CI",
                                           "upper_CI")]
    colnames(data_frame_for_forest_plot) <- c("coef",
                                              "low", "high")
    data_frame_for_forest_plot <- rbind(data.frame(
      coef = c(NA,
               vline_loc),
      low = c(NA, vline_loc),
      high = c(NA,
               vline_loc)
    ),
    data_frame_for_forest_plot)
    text_col <- paste(
      format(
        round(data_frame_for_forest_plot$coef,
              digits = 2),
        nnsmall = 2
      ),
      " (",
      format(round(
        data_frame_for_forest_plot$low,
        digits = 2
      ), nsmall = 2),
      ", ",
      format(
        round(data_frame_for_forest_plot$high,
              digits = 2),
        nsmall = 2
      ),
      ")",
      sep = ""
    )

    # This is where treatment diverges from basic forest_plot_comp
    col_of_names <- temp_in_col
    new_col <- c()
    for (name in col_of_names) {
      new_col <- c(new_col, name)
    }
    text_col <-
      paste(
        format(round(
          data_frame_for_forest_plot$coef , digits = 2
        ), nsmall = 2),
        " (",
        format(round(data_frame_for_forest_plot$low, digits = 2), nsmall = 2),
        ", ",
        format(round(
          data_frame_for_forest_plot$high, digits = 2
        ), nsmall = 2),
        ")",
        sep = ""
      )
    text_col[grepl("NA", text_col)] <- " "


    # We calculate E values using the EValue package
    evalue_main <- c()
    evalue_low <- c()

    for (i in 1:nrow(data_frame_for_forest_plot)) {
      if (!is.na(data_frame_for_forest_plot$low[i])) {
        e_val <-
          EValue::evalues.HR(
            est = data_frame_for_forest_plot$coef[i],
            lo = data_frame_for_forest_plot$low[i],
            hi = data_frame_for_forest_plot$high[i],
            rare = 1
          )
        cis <- e_val["E-values", c("lower", "upper")]
        evalue_main <- c(evalue_main, e_val["E-values", "point"])
        evalue_low <- c(evalue_low, cis[!is.na(cis)])
      }
      else{
        evalue_main <- c(evalue_main,  NA)
        evalue_low <- c(evalue_low, NA)
      }
    }

    evalue <-
      c("E-value: \nEstimate (Interval bound)",
        " ",
        paste0(format(round(
          evalue_main[3:length(evalue_main)], digits = 2
        ), nsmall = 2), " (", format(round(
          evalue_low[3:length(evalue_low)], digits = 2
        ), nsmall = 2), ")"))
    evalue[evalue == "  NA (  NA)"] <- " "

    # We write custom text for the table using the Evalues
    tabletext <-
      cbind(
        c("  \n ", "REFERENCE: At compositional mean", temp_in_col),
        c(pred_name, vline_loc, text_col[3:nrow(data_frame_for_forest_plot)]),
        evalue
      )

    # We make the plot
    fp <- forestplot::forestplot(
      tabletext,
      graph.pos = 2,
      mean = as.numeric(c(data_frame_for_forest_plot[, "coef"])),
      lower = as.numeric(c(data_frame_for_forest_plot[, "low"])),
      upper = as.numeric(c(data_frame_for_forest_plot[, "high"])),
      xlog = plot_log,
      clip = c(xllimit - 0.05, xulimit + 0.05),
      xticks = req_seq,
      xlab = x_label,
      zero = vline_loc,
      txt_gp = text_settings,
      col = forestplot::fpColors(lines = "black", zero = "black"),
      boxsize = boxsize,
      ...
    )

    # In this case we won't need to deal with a model list
  }

  return(fp)
}
