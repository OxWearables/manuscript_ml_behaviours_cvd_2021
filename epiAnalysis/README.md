# epiAnalysis

This subfolder contains files related to the epidemiological analyses.

The script `scripts/analysis.R` contains documented code for descriptive analyses, modelling, plotting and documenting models, and some sense checks. 

Various helper functions are contained in the `useful_functions` folder. These are sourced in the `analysis.R` script. 

The script `scripts/ggtern_plots.R` contains functions for plotting distributions on the simplex using ggtern. These were separated from the main script due to a bug with some versions of `ggtern` whereby loading `ggtern` suppressed plot labels on `ggplot2` plots. 
