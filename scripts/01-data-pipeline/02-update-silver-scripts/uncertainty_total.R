

tfile <- tempfile(tmpdir = tdir <- tempdir())
file_name <- paste(dl_folder, "data", "bronze", "ec", paste0("uncertainty_total_nsa_nace2", ".zip"), sep = "/")
zipped_files <- unzip(file_name, exdir = tdir)

# excel_sheets(zipped_files)
temp <- NULL
for (i in c("BUILDING", "CONSUMER", "INDUSTRY", "RETAIL", "SERVICES")) {
  temp <- bind_rows(temp, read_excel(zipped_files, i, na = "NA"))
}
names(temp)[1] <- "date"

temp <- temp %>%
  pivot_longer(cols = -c("date")) %>%
  filter(!is.na(value)) %>%
  mutate(date = as.Date(date),
         sector = substring(name, 1, 4),
         subsector = "TOT",
         ctry = substring(name, 6, 7),
         question = "UNC",
         answer = "B",
         sadj = FALSE,
         freq = "M") %>%
  select(date, ctry, sector, subsector, question, answer, sadj, freq, value)

write_parquet(temp, "data/silver/uncertainty.parquet")

unlink(tdir)
rm(list = c("temp", "zipped_files", "tdir", "tfile", "file_name", "i"))
