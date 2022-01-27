# epiAnalysis

This subfolder contains files related to the final epidemiological analyses: associating the machine-learned movement behaviour variables with risk of incident cardiovascular disease using a Compositional Data Analysis Cox regression approach. The [R package `epicoda`](https://github.com/activityMonitoring/epicoda) was developed to enable these analyses.

- The script `scripts/analysis.R` contains documented code for descriptive analyses, modelling, plotting and documenting models, and some sense checks of the code.
- Various helper functions (e.g. to arrange plots in a grid) are contained in the `useful_functions` folder, and are sourced in the `analysis.R` script. 
- The script `scripts/ggtern_plots.R` contains functions for plotting distributions on the simplex using `ggtern`. These were separated from the main script due to a bug with some versions of `ggtern` whereby loading `ggtern` suppressed plot labels on `ggplot2` plots. 
