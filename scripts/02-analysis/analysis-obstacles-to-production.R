rm(list = ls())

library(arrow)
library(dplyr)
library(tidyr)
library(ggplot2)

sector_names <- read.csv("data/silver/sector-names.csv")

mapping_factors <- read.csv("data/silver/mapping_limiting_factors.csv") %>%
  mutate(sector = substring(name, 1, 4),
         name = substring(name, 10, nchar(name)),
         question = substring(name, 1, 1),
         answer = substring(name, 3, 4)) %>%
  select(sector, question, answer, name_en)

raw <- open_dataset("data/silver/ec-business-and-consumer-surveys")

# Overview ----

temp <- raw %>%
  filter(date >= "2020-01-01",
         ctry %in% "AT",
         subsector %in% c("41", "43", "68", "TOT"),
         sadj == "false",
         !is.na(subsector)) %>%
  mutate(name = paste(sector, subsector, question, answer, freq, sep = ".")) %>%
  left_join(mapping_factors, by = c("sector", "question", "answer")) %>%
  filter(!is.na(name_en)) %>%
  collect() %>%
  group_by(subsector, answer) %>%
  filter(n() > 1) %>%
  ungroup() %>%
  left_join(sector_names, by = c("subsector" = "sector"))
  
ggplot(temp, aes(x = date, y = value, colour = name_en)) +
  geom_line(alpha = .4) +
  facet_wrap( ~ sector_name)
#+  geom_smooth(se = FALSE, method = "loess", span = .1)

# Funding ----
temp <- raw %>%
  #filter(ctry %in% c("AT", "DE", "EA")) %>%
  filter(!s_adj) %>%
  filter(grepl("BUIL.TOT.2", name) | grepl("INDU.TOT.8", name) | grepl("SERV.TOT.7", name)) %>%
  mutate(sector = substring(name, 1, 8)) %>%
  left_join(mapping_factors, by = "name") %>%
  filter(name_en == "Financial") %>%
  group_by(date, sector) %>%
  summarise(ymin = min(value),
            ymax = max(value),
            .groups = "drop")

ggplot(temp, aes(x = date, ymin = ymin, ymax = ymax)) +
  #geom_point() +
  geom_errorbar() +
  facet_wrap(~sector)

