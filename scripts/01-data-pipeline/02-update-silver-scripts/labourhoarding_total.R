
# Not seasonally adjusted ----

tfile <- tempfile(tmpdir = tdir <- tempdir())
file_name <- paste(dl_folder, "data", "bronze", "ec", paste0("labourhoarding_total_nsa_nace2", ".zip"), sep = "/")
zipped_files <- unzip(file_name, exdir = tdir)

# excel_sheets(zipped_files)
temp <- NULL
for (i in c("BUILDING", "INDUSTRY", "RETAIL", "SERVICES")) {
  temp <- bind_rows(temp, read_excel(zipped_files, i, na = "NA"))
}
names(temp)[1] <- "date"

nsa <- temp %>%
  pivot_longer(cols = -c("date")) %>%
  filter(!is.na(value)) %>%
  mutate(date = as.Date(date),
         sector = substring(name, 1, 4),
         subsector = "TOT",
         ctry = substring(name, 6, 7),
         sadj = FALSE,
         question = "LH",
         answer = "QP",
         freq = "M") %>%
  select(date, ctry, sector, subsector, question, answer, sadj, freq, value)

unlink(tdir)
rm(list = c("temp", "zipped_files", "tdir", "tfile", "file_name", "i"))

# Not seasonally adjusted ----

tfile <- tempfile(tmpdir = tdir <- tempdir())
file_name <- paste(dl_folder, "data", "bronze", "ec", paste0("labourhoarding_total_sa_nace2", ".zip"), sep = "/")
zipped_files <- unzip(file_name, exdir = tdir)

# excel_sheets(zipped_files)
temp <- NULL
for (i in c("AGGREGATE", "BUILDING", "INDUSTRY", "RETAIL", "SERVICES")) {
  temp <- bind_rows(temp, read_excel(zipped_files, i, na = "NA"))
}
names(temp)[1] <- "date"

sa <- temp %>%
  pivot_longer(cols = -c("date")) %>%
  filter(!is.na(value)) %>%
  mutate(date = as.Date(date),
         sector = substring(name, 1, 4),
         subsector = "TOT",
         ctry = substring(name, 6, 7),
         sadj = TRUE,
         question = "LH",
         answer = "QP",
         freq = "M") %>%
  select(date, ctry, sector, subsector, question, answer, sadj, freq, value)

unlink(tdir)
rm(list = c("temp", "zipped_files", "tdir", "tfile", "file_name", "i"))


temp <- bind_rows(nsa, sa)
write_parquet(temp, "data/silver/labourhoarding.parquet")

rm(list = c("temp", "sa", "nsa"))
