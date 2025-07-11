
# Not seasonally adjusted ----

tfile <- tempfile(tmpdir = tdir <- tempdir())
file_name <- paste(dl_folder, "data", "bronze", "ec", paste0("retail_subsectors_nsa_nace2", ".zip"), sep = "/")
zipped_files <- unzip(file_name, exdir = tdir)

## Monthly data ----
file_name <- zipped_files[which(grepl("nsa_m_nace2", zipped_files))]
sheets <- excel_sheets(file_name)
sheets <- sheets[!sheets %in% c("Index", "INFO")]

m_nsa <- NULL
for (i in sheets) {
  temp <- read_excel(file_name, sheet = i, na = "NA")
  names(temp)[1] <- "date"
  temp <- temp %>%
    pivot_longer(cols = -c("date")) %>%
    filter(!is.na(value))
  m_nsa[[i]] <- temp
}
m_nsa <- bind_rows(m_nsa)

nsa <- m_nsa %>%
  mutate(date = as.Date(date),
         sector = substring(name, 1, 4),
         ctry = substring(name, 6, 7),
         name = substring(name, 9, nchar(name)),
         subsector = regmatches(name, regexpr("[^.]*", name)),
         name = substring(name, nchar(subsector) + 2, nchar(name)),
         sadj = FALSE,
         question = regmatches(name, regexpr("[^.]*", name)),
         answer = regmatches(name, regexpr("(?<=\\.)[^.]*(?=\\.)", name, perl = TRUE)),
         freq = substring(name, nchar(name), nchar(name))) %>%
  select(date, ctry, sector, subsector, question, answer, sadj, freq, value)

unlink(tdir)
rm(list = c("i", "m_nsa", "temp", "sheets", "file_name", "zipped_files", "tdir", "tfile"))

# Seasonally adjusted ----

tfile <- tempfile(tmpdir = tdir <- tempdir())
file_name <- paste(dl_folder, "data", "bronze", "ec", paste0("retail_subsectors_sa_nace2", ".zip"), sep = "/")
zipped_files <- unzip(file_name, exdir = tdir)

## Monthly data ----
file_name <- zipped_files[which(grepl("sa_m_nace2", zipped_files))]
sheets <- excel_sheets(file_name)
sheets <- sheets[!sheets %in% c("Index", "INFO")]

m_sa <- NULL
for (i in sheets) {
  temp <- read_excel(file_name, sheet = i, na = "NA")
  names(temp)[1] <- "date"
  temp <- temp %>%
    pivot_longer(cols = -c("date")) %>%
    filter(!is.na(value))
  m_sa[[i]] <- temp
}
m_sa <- bind_rows(m_sa)


sa <- m_sa %>%
  mutate(date = as.Date(date),
         sector = substring(name, 1, 4),
         ctry = substring(name, 6, 7),
         name = substring(name, 9, nchar(name)),
         subsector = regmatches(name, regexpr("[^.]*", name)),
         name = substring(name, nchar(subsector) + 2, nchar(name)),
         sadj = TRUE,
         question = regmatches(name, regexpr("[^.]*", name)),
         answer = regmatches(name, regexpr("(?<=\\.)[^.]*(?=\\.)", name, perl = TRUE)),
         freq = substring(name, nchar(name), nchar(name))) %>%
  select(date, ctry, sector, subsector, question, answer, sadj, freq, value)

unlink(tdir)
rm(list = c("i", "m_sa", "temp", "sheets", "file_name", "zipped_files", "tdir", "tfile"))

# Save data ----

bind_rows(nsa, sa) %>%
  group_by(sector, subsector, question, sadj) %>%
  write_dataset("data/silver/ec-business-and-consumer-surveys")

rm(list = c("sa", "nsa"))
