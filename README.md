# Dallas Lab Cherry Blossom Peak Bloom Prediction

This repository contains the code and data to reproduce the [Dallas Lab](https://taddallas.github.io/)'s entry in the [Cherry Blossom Prediction Competition](https://competition.statistics.gmu.edu) sponsored by GMU. Here we use an ensemble machine learning approach to predict the peak bloom dates of cherry blossoms in 4 locations across the world.

## Reproduce this work

In order to reproduce our data handling, analyses, and output you will have to run (or `knit`) three Rmd files sequentially (_All data required to run analyses in Rmd #3 are already included in this repo. Therefore the first two Rmds are included primarily for reproducibility of data sourcing_):

1. `Get_Climatic_Data.Rmd` This code downloads and formats the daily past climate and forecast data we use to construct model covariates. Note that it includes API queries using python. These data are too large to host on github within this repo.
2. `Features.Rmd` This code constructs a large number of covariates or features for model training from the raw daily weather data. These features are largely based on calculating the number of days which do or do not exceed a range of temperature thresholds over set time periods.
3. `model_fitting.Rmd` This code tunes, trains, and evaluates models, measures variable importance and produces forecasting predictions.

## License

![CC-BYNCSA-4](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)

Unless otherwise noted, the content in this repository is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

For the data sets in the _data/_ folder, please see [_data/README.md_](data/README.md) for the applicable copyrights and licenses.
