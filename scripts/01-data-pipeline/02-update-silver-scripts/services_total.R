
# Not seasonally adjusted ----

tfile <- tempfile(tmpdir = tdir <- tempdir())
file_name <- paste(dl_folder, "data", "bronze", "ec", paste0("services_total_nsa_nace2", ".zip"), sep = "/")
zipped_files <- unzip(file_name, exdir = tdir)

# excel_sheets(zipped_files)
monthly_data <- read_excel(zipped_files, "SERVICES MONTHLY", na = "NA")
names(monthly_data)[1] <- "date"

quarterly_data <- read_excel(zipped_files, "SERVICES QUARTERLY", na = "NA")
names(quarterly_data)[1] <- "date"
quarterly_data <- quarterly_data %>%
  mutate(date = as.Date(as.yearqtr(date, "%Y-Q%q")),
         date = ceiling_date(date, "quarter") - 1)

nsa <- bind_rows(monthly_data,
                 quarterly_data) %>%
  pivot_longer(cols = -c("date")) %>%
  filter(!is.na(value)) %>%
  mutate(date = as.Date(date),
         sector = substring(name, 1, 4),
         ctry = substring(name, 6, 7),
         subsector = substring(name, 9, 11),
         name = substring(name, 13, nchar(name)),
         sadj = FALSE,
         question = regmatches(name, regexpr("[^.]*", name)),
         answer = regmatches(name, regexpr("(?<=\\.)[^.]*(?=\\.)", name, perl = TRUE)),
         freq = substring(name, nchar(name), nchar(name))) %>%
  select(date, ctry, sector, subsector, question, answer, sadj, freq, value)

unlink(tdir)
rm(list = c("monthly_data", "quarterly_data", "file_name", "zipped_files", "tdir", "tfile"))


# Seasonally adjusted ----

tfile <- tempfile(tmpdir = tdir <- tempdir())
file_name <- paste(dl_folder, "data", "bronze", "ec", paste0("services_total_sa_nace2", ".zip"), sep = "/")
zipped_files <- unzip(file_name, exdir = tdir)

# excel_sheets(zipped_files)
monthly_data <- read_excel(zipped_files, "SERVICES MONTHLY", na = "NA")
names(monthly_data)[1] <- "date"

quarterly_data <- read_excel(zipped_files, "SERVICES QUARTERLY", na = "NA")
names(quarterly_data)[1] <- "date"
quarterly_data <- quarterly_data %>%
  mutate(date = as.Date(as.yearqtr(date, "%Y-Q%q")),
         date = ceiling_date(date, "quarter") - 1)

sa <- bind_rows(monthly_data,
                quarterly_data) %>%
  pivot_longer(cols = -c("date")) %>%
  filter(!is.na(value)) %>%
  mutate(date = as.Date(date),
         sector = substring(name, 1, 4),
         ctry = substring(name, 6, 7),
         subsector = substring(name, 9, 11),
         name = substring(name, 13, nchar(name)),
         sadj = TRUE,
         question = regmatches(name, regexpr("[^.]*", name)),
         answer = regmatches(name, regexpr("(?<=\\.)[^.]*(?=\\.)", name, perl = TRUE)),
         freq = substring(name, nchar(name), nchar(name))) %>%
  select(date, ctry, sector, subsector, question, answer, sadj, freq, value)

unlink(tdir)
rm(list = c("monthly_data", "quarterly_data", "file_name", "zipped_files", "tdir", "tfile"))


bind_rows(nsa, sa) %>%
  group_by(sector, subsector, question, sadj) %>%
  write_dataset("data/silver/ec-business-and-consumer-surveys")

rm(list = c("sa", "nsa"))
