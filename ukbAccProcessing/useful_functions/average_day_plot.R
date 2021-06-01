
plotAverageDay <- function(data, exposurePrefix, exposureSuffix, yAxisLabel = exposurePrefix, outPng = NULL){
  
  hrPACols <- c()
  mean_PACols <- c()
  se_PACols <- c()
  low_PACols <- c()
  high_PACols <- c()
  hrs <- c()
  for (hr in 0:23){
    hrs <- c(hrs, as.numeric(hr))
    hrPACols <- c(hrPACols , paste(exposurePrefix, hr, exposureSuffix, sep = ""))
    mean_PACols <- c(mean_PACols, as.numeric(mean(data[,hrPACols[hr+1]], na.rm = TRUE)))
    se_PACols <- c(se_PACols, as.numeric(sqrt(var(data[, hrPACols[hr+1]], na.rm = TRUE))/sqrt(nrow(data))))
    low_PACols <- c(low_PACols, mean_PACols[hr+1] - 1.96*se_PACols[hr+1])
    high_PACols <- c(high_PACols, mean_PACols[hr+1] + 1.96*se_PACols[hr+1])
  }
  plot <- ggplot(data = data.frame(cbind(hrs, mean_PACols, low_PACols, high_PACols)), aes(x = hrs, y = mean_PACols))+
    geom_ribbon(aes(x = hrs, ymin = low_PACols, 
                    ymax = high_PACols), fill = "grey80")+ 
    geom_line(size = 1)+ 
    ylim(0, 1)+
    labs(
         y = yAxisLabel, 
         x = "Hour of Day")
  
  if (!(is.null(outPng))){
    ggsave(outPng, plot = plot, device = png())
  }
  
  return(plot)
  
}