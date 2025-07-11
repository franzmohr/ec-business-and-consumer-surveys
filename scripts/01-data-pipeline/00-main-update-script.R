
rm(list = ls())

library(arrow)
library(dplyr)
library(lubridate)
library(readxl)
library(tidyr)
library(zoo)

source("scripts/01-data-pipeline/helper_functions.R")

dl_folder <- getwd()

# Update bronze layer
source("scripts/01-data-pipeline/01-download-raw-files.R")

# Update silver layer
source("scripts/01-data-pipeline/02-update-silver-layer.R")


