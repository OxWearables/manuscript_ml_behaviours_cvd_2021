plotAverageDayGroupWise <- function(data, group, exposurePrefix, exposureSuffix, yAxisLabel = exposurePrefix, title = NULL, ylim = 1){
  # PREP DATA FRAME ================================================================
  groups_data <- data.frame("hrs" = c(), "mean_PAcols" = c(), "group" = c())
  l <- levels(data[, group])

  # CYCLE THROUGH LEVELS OF GROUPS ==================================================
  for (g in l){
    print(g)
    dat_local <- data[data[, group] == g,]

    # SET UP RECORD OF MEAN VALUES FOR COL ==========================================
    hrPACols <- c()
    mean_PACols <- c()
    hrs <- c()
    gp <- c()
    for (hr in 0:23){
      hrs <- c(hrs, as.numeric(hr))
      hrPACols <- c(hrPACols , paste(exposurePrefix, hr, exposureSuffix, sep = ""))
      mean_PACols <- c(mean_PACols, as.numeric(mean(dat_local[,hrPACols[hr+1]], na.rm = TRUE)))
      gp <- c(gp, g)

      # CHECK
      if (hrPACols[hr+1] != hrPACols[length(hrPACols)]){
        stop("Not pulling correct label")
      }
    }

    # BIND ALL MEAN VALUES INTO OVERALL GROUPS DATA
    groups_data <- rbind(groups_data, data.frame("hrs" = hrs, "mean_PAcols" = mean_PACols, "group" = gp))
  }

  # REFORMAT GROUPS DATA
  groups_data$group <- factor(groups_data$group, levels = l, ordered = TRUE)

  # PRODUCE PLOT
  plot <- ggplot(data = groups_data, aes(x = hrs, y = mean_PAcols, colour = group))+
    geom_line(size = 1)+
    ylim(0, ylim)+
    labs(
         y = yAxisLabel,
         x = "Hour of Day",
         title = tit)+
    theme(legend.title=element_blank()) # MAKE SURE LEGEND TITLE BLANK


 return(plot)

}
