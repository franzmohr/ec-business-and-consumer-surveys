
# Not seasonally adjusted ----

tfile <- tempfile(tmpdir = tdir <- tempdir())
file_name <- paste(dl_folder, "data", "bronze", "ec", paste0("industry_subsectors_nsa_nace2", ".zip"), sep = "/")
zipped_files <- unzip(file_name, exdir = tdir)

## Monthly data ----
file_name <- zipped_files[which(grepl("nsa_m_nace2", zipped_files))]
sheets <- excel_sheets(file_name)
sheets <- sheets[!sheets %in% c("Index", "INFO")]

industry_m_nsa <- NULL
for (i in sheets) {
  temp <- read_excel(file_name, sheet = i, na = "NA")
  names(temp)[1] <- "date"
  temp <- temp %>%
    pivot_longer(cols = -c("date")) %>%
    filter(!is.na(value))
  industry_m_nsa[[i]] <- temp
}
industry_m_nsa <- bind_rows(industry_m_nsa)

## Quarterly data ----

file_name <- zipped_files[which(grepl("nsa_q_nace2", zipped_files))]
sheets <- excel_sheets(file_name)
sheets <- sheets[!sheets %in% c("Index", "INFO")]

industry_q_nsa <- NULL
for (i in sheets) {
  temp <- read_excel(file_name, sheet = i, na = "NA")
  names(temp)[1] <- "date"
  temp <- temp %>%
    pivot_longer(cols = -c("date")) %>%
    filter(!is.na(value))
  industry_q_nsa[[i]] <- temp
}
industry_q_nsa <- bind_rows(industry_q_nsa)

industry_q_nsa <- industry_q_nsa %>%
  mutate(date = as.Date(as.yearqtr(date, "%Y-Q%q")),
         date = ceiling_date(date, "quarter") - 1)

## Quarterly 8 data ----

file_name <- zipped_files[which(grepl("nsa_q8_nace2", zipped_files))]
sheets <- excel_sheets(file_name)
sheets <- sheets[!sheets %in% c("Index", "INFO")]

industry_q8_nsa <- NULL
for (i in sheets) {
  temp <- read_excel(file_name, sheet = i, na = "NA")
  names(temp)[1] <- "date"
  temp <- temp %>%
    pivot_longer(cols = -c("date")) %>%
    filter(!is.na(value))
  industry_q8_nsa[[i]] <- temp
}
industry_q8_nsa <- bind_rows(industry_q8_nsa)

industry_q8_nsa <- industry_q8_nsa %>%
  mutate(date = as.Date(as.yearqtr(date, "%Y-Q%q")),
         date = ceiling_date(date, "quarter") - 1)

nsa <- bind_rows(industry_m_nsa,
                 industry_q_nsa,
                 industry_q8_nsa) %>%
  mutate(date = as.Date(date),
         sector = substring(name, 1, 4),
         ctry = substring(name, 6, 7),
         subsector = substring(name, 9, 10),
         name = substring(name, 12, nchar(name)),
         sadj = FALSE,
         question = regmatches(name, regexpr("[^.]*", name)),
         answer = regmatches(name, regexpr("(?<=\\.)[^.]*(?=\\.)", name, perl = TRUE)),
         freq = substring(name, nchar(name), nchar(name))) %>%
  select(date, ctry, sector, subsector, question, answer, sadj, freq, value)

# Seasonally adjusted ----

tfile <- tempfile(tmpdir = tdir <- tempdir())
file_name <- paste(dl_folder, "data", "bronze", "ec", paste0("industry_subsectors_sa_nace2", ".zip"), sep = "/")
zipped_files <- unzip(file_name, exdir = tdir)

## Monthly data ----
file_name <- zipped_files[which(grepl("sa_m_nace2", zipped_files))]
sheets <- excel_sheets(file_name)
sheets <- sheets[!sheets %in% c("Index", "INFO")]

industry_m_sa <- NULL
for (i in sheets) {
  temp <- read_excel(file_name, sheet = i, na = "NA")
  names(temp)[1] <- "date"
  temp <- temp %>%
    pivot_longer(cols = -c("date")) %>%
    filter(!is.na(value))
  industry_m_sa[[i]] <- temp
}
industry_m_sa <- bind_rows(industry_m_sa)

## Quarterly data ----

file_name <- zipped_files[which(grepl("sa_q_nace2", zipped_files))]
sheets <- excel_sheets(file_name)
sheets <- sheets[!sheets %in% c("Index", "INFO")]

industry_q_sa <- NULL
for (i in sheets) {
  temp <- read_excel(file_name, sheet = i, na = "NA")
  names(temp)[1] <- "date"
  temp <- temp %>%
    pivot_longer(cols = -c("date")) %>%
    filter(!is.na(value))
  industry_q_sa[[i]] <- temp
}
industry_q_sa <- bind_rows(industry_q_sa)

industry_q_sa <- industry_q_sa %>%
  mutate(date = as.Date(as.yearqtr(date, "%Y-Q%q")),
         date = ceiling_date(date, "quarter") - 1)

## Quarterly 8 data ----

file_name <- zipped_files[which(grepl("sa_q8_nace2", zipped_files))]
sheets <- excel_sheets(file_name)
sheets <- sheets[!sheets %in% c("Index", "INFO")]

industry_q8_sa <- NULL
for (i in sheets) {
  temp <- read_excel(file_name, sheet = i, na = "NA")
  names(temp)[1] <- "date"
  temp <- temp %>%
    pivot_longer(cols = -c("date")) %>%
    filter(!is.na(value))
  industry_q8_sa[[i]] <- temp
}
industry_q8_sa <- bind_rows(industry_q8_sa)

industry_q8_sa <- industry_q8_sa %>%
  mutate(date = as.Date(as.yearqtr(date, "%Y-Q%q")),
         date = ceiling_date(date, "quarter") - 1)


sa <- bind_rows(industry_m_sa,
                industry_q_sa,
                industry_q8_sa) %>%
  mutate(date = as.Date(date),
         sector = substring(name, 1, 4),
         ctry = substring(name, 6, 7),
         subsector = substring(name, 9, 10),
         name = substring(name, 12, nchar(name)),
         sadj = TRUE,
         question = regmatches(name, regexpr("[^.]*", name)),
         answer = regmatches(name, regexpr("(?<=\\.)[^.]*(?=\\.)", name, perl = TRUE)),
         freq = substring(name, nchar(name), nchar(name))) %>%
  select(date, ctry, sector, subsector, question, answer, sadj, freq, value)

unlink(tdir)
rm(list = c("industry_m_nsa", "industry_q_nsa", "industry_q8_nsa",
            "industry_m_sa", "industry_q_sa", "industry_q8_sa",
            "temp", "sheets", "file_name", "zipped_files", "tdir", "tfile"))

bind_rows(nsa, sa) %>%
  group_by(sector, subsector, question, sadj) %>%
  write_dataset("data/silver/ec-business-and-consumer-surveys")

rm(list = c("sa", "nsa"))
