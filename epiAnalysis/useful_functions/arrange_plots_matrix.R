plot_maxi_matrix_transfers <-
  function(comp_model,
           fixed_values = NULL,
           part_1 = NULL,
           comp_labels,
           yllimit = NULL,
           yulimit = NULL,
           plot_log = FALSE,
           lower_quantile = 0.05,
           upper_quantile = 0.95,
           units = "unitless",
           specified_units = NULL,
           terms = TRUE,
           granularity = 10000,
           point_specification = ggplot2::geom_point(size = 2),
           theme = NULL,
           plotstitle = NULL) {
    #------------------------------------------------------------------
    # First we calculate the shared limits for all the plots
    # We assign some internal parameters
    # Model type
    type <- epicoda:::process_model_type(comp_model)

    # Labels
    if (!is.null(part_1)) {
      comp_labels <- alter_order_comp_labels(comp_labels, part_1)
    }
    transf_labels <-
      transf_labels(comp_labels,
                    transformation_type = "ilr",
                    part_1 = part_1)
    # Datasets
    dataset1 <- get_dataset_from_model(model = comp_model, comp_labels = comp_labels, transf_labels = transf_labels, type = type)

    # Reference values
    cm1 <- get_cm_from_model(
      model = comp_model,
      comp_labels = comp_labels, transf_labels = transf_labels)$cm

    # Use pragmatic plotting limits shared for all plots (this tends to be widest variation)
    xllimit <- 24*(quantile(dataset1$LIPA, 0.05)-data.frame(cm1)[1, "LIPA"]) # Multiplication by 24 to put on right scale
    xulimit <- 24*(quantile(dataset1$LIPA, 0.95)-data.frame(cm1)[1, "LIPA"]) # Based off one of the two models as similar enough

    # Generate plots
    for (i in 1:3){
      for (j in (i+1):4){

        if (i == 1){
          y_label <- "Estimated Hazard Ratio"
        }
        else {
          y_label <- " "
        }

        pfirst <- plot_transfers(
          from_part = comp_labels[i],
          to_part = comp_labels[j],
          model = comp_model,
          granularity = granularity,
          units = "hr/day",
          comp_labels = comp_labels,
          terms = terms,
          plot_log = plot_log,
          yllimit = yllimit,
          yulimit = yulimit,
          xllimit = xllimit,
          xulimit = xulimit,
          y_label = y_label,
          fixed_values = fixed_values,
          point_specification = ggplot2::geom_point(size = 1.5)
        )
        assign(paste0("p_", comp_labels[i], "_", comp_labels[j], "_model1"), pfirst )

      }
    }

    g <- gridExtra::grid.arrange(
      grobs = list(p_sleep_SB_model1,
                   p_sleep_LIPA_model1,
                   p_sleep_MVPA_model1,
                   p_SB_LIPA_model1,
                   p_SB_MVPA_model1,
                   p_LIPA_MVPA_model1),
      widths = c(1, 1, 1),
      heights = c(1, 1, 1),
      layout_matrix = cbind(c(1,  2, 3), c(NA, 4, 5), c(NA, NA, 6)),
      top = grid::textGrob(plotstitle, gp=grid::gpar(fontsize=40))
    )
    attr(g, "cm") <- attr(pfirst, "cm")

    return(g)

  }
