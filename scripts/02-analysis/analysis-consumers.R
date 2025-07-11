rm(list = ls())

library(arrow)
library(dplyr)
library(tidyr)
library(ggplot2)

question_levels <- c("COF", 7, 1:6, 8:9, 11:12, 14:15)
question_labels <- c("Confidence Indicator",
                     "Unemployment expectations over next 12 months",
                     "Financial situation over last 12 months",
                     "Financial situation over next 12 months",
                     "General economic situation over last 12 months",
                     "General economic situation over next 12 months",
                     "Price trends over last 12 months", 
                     "Price trends over next 12 months", 
                     "Major purchases at present", 
                     "Major purchases over next 12 months",
                     "Savings over next 12 months",
                     "Statement on financial situation of household",
                     "Purchase or build a home within the next 12 months",
                     "Home improvements over the next 12 months")

## Seasonally adjusted ----

raw <- open_dataset("data/silver/ec-business-and-consumer-surveys") %>%
  filter(sector == "CONS",
         sadj == TRUE,
         ctry == "AT") %>%
  collect() %>%
  mutate(question = factor(question, levels = question_levels, labels = question_labels))

## Overview ----

temp <- raw

ggplot(temp, aes(x = date, y = value, colour = subsector)) +
  geom_line() +
  facet_wrap( ~ question, ncol = 2)

# Confidence overall ----

temp <- raw %>%
  filter(subsector == "TOT")

ggplot(temp, aes(x = date, y = value, colour = question)) +
  geom_line(show.legend = FALSE) +
  facet_wrap( ~ question, ncol = 2)

# Confidence by income ----

temp <- raw %>%
  filter(subsector %in% c("RE1", "RE2", "RE3", "RE4"))

ggplot(temp, aes(x = date, y = value, colour = subsector)) +
  geom_line() +
  facet_wrap( ~ question, ncol = 2)


# Confidence by occupational status ----

temp <- raw %>%
  filter(subsector %in% paste0("PR", 0:9))

ggplot(temp, aes(x = date, y = value, colour = subsector)) +
  geom_line() +
  facet_wrap( ~ question, ncol = 2)


# Confidence by education ----

temp <- raw %>%
  filter(subsector %in% c("ED1", "ED2", "ED3"))

ggplot(temp, aes(x = date, y = value, colour = subsector)) +
  geom_line() +
  facet_wrap( ~ question, ncol = 2)


# Confidence by age ----

temp <- raw %>%
  filter(subsector %in% paste0("AG", 1:4))

ggplot(temp, aes(x = date, y = value, colour = subsector)) +
  geom_line() +
  facet_wrap( ~ question, ncol = 2)


# Confidence by sex ----

temp <- raw %>%
  filter(subsector %in% c("MAL", "FEM"))

ggplot(temp, aes(x = date, y = value, colour = subsector)) +
  geom_line() +
  facet_wrap( ~ question, ncol = 2)


## Not seasonally adjusted ----

raw <- open_dataset("data/silver/ec-business-and-consumer-surveys") %>%
  filter(sector == "CONS",
         sadj == FALSE,
         ctry == "AT") %>%
  collect() %>%
  mutate(question = factor(question, levels = question_levels, labels = question_labels))

## Overview ----

temp <- raw

ggplot(temp, aes(x = date, y = value, colour = subsector)) +
  geom_line() +
  facet_wrap( ~ question, ncol = 2)

# Confidence by occupational status ----

temp <- raw %>%
  filter(subsector %in% paste0("WO", 1:10))

ggplot(temp, aes(x = date, y = value, colour = subsector)) +
  geom_line() +
  facet_wrap( ~ question, ncol = 2)

# Confidence by work regime ----

temp <- raw %>%
  filter(subsector %in% c("WR1", "WR2"))

ggplot(temp, aes(x = date, y = value, colour = subsector)) +
  geom_line() +
  facet_wrap( ~ question, ncol = 2)


