
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ec-business-and-consumer-surveys

This repository provides R code for the construction of a data lake,
which contains data from the [European Commission’s Business and
Consumer
Surveys](https://economy-finance.ec.europa.eu/economic-forecast-and-surveys/business-and-consumer-surveys_en).

Structure of this repository:

- `scripts`:
  - `01-data-pipeline`: Scripts for constructing and updating the data
    lake.
  - `02-analysis`: Scripts for analysing the data. The folder contains a
    README file with further information.
- `data`:
  - `bronze`: Raw data as downloaded from the Commission’s website.
  - `silver`: Prepared data for analysis. Stored as partitioned parquet
    files.

## Usage

### Data update

``` r
source("scripts/01-data-pipeline/00-main-update-script.R")
```

### Analysis

Folder `scripts/02-analysis` contains scripts for various analyses.
