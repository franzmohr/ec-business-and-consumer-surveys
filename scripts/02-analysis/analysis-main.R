rm(list = ls())

library(arrow)
library(dplyr)
library(tidyr)
library(ggplot2)

raw <- read_parquet("data/silver/main.parquet")

# Overview ----

temp <- raw %>%
  filter(!sector %in% c("EEI", "ESI"))

ggplot(temp, aes(x = date, y = value, colour = ctry)) +
  geom_hline(yintercept = 0) +
  geom_line() +
  facet_wrap(~sector)


# Overview ----

temp <- raw %>%
  filter(sector %in% c("EEI", "ESI"))

ggplot(temp, aes(x = date, y = value, colour = ctry)) +
  geom_hline(yintercept = 100) +
  geom_line() +
  facet_wrap(~sector)
