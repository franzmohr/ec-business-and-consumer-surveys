

tfile <- tempfile(tmpdir = tdir <- tempdir())
file_name <- paste(dl_folder, "data", "bronze", "ec", paste0("main_indicators_sa_nace2", ".zip"), sep = "/")
zipped_files <- unzip(file_name, exdir = tdir)

# excel_sheets(zipped_files)
temp <- read_excel(zipped_files[1], "MONTHLY", na = "NA")
names(temp)[1] <- "date"

temp <- temp %>%
  pivot_longer(cols = -c("date")) %>%
  filter(!is.na(value)) %>%
  mutate(date = as.Date(date),
         ctry = substring(name, 1, 2),
         sector = substring(name, 4, nchar(name)),
         sadj = TRUE,
         freq = "M") %>%
  select(date, ctry, sector, sadj, freq, value)

write_parquet(temp, "data/silver/main.parquet")

unlink(tdir)
rm(list = c("temp", "zipped_files", "tdir", "tfile", "file_name"))

