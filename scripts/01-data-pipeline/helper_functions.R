

download_ec_raw_data <- function(dl_folder, suffix) {
  
  download_folder <- paste(dl_folder, "data", "bronze", "ec", sep = "/")
  download_file <- paste0(download_folder, "/", suffix, ".zip")
  
  # Try download for current month
  curr_date <- Sys.Date()
  curr_month <- lubridate::month(curr_date)
  curr_month <- ifelse(nchar(curr_month) == 1, paste0("0", curr_month), curr_month)
  curr_year <- substring(lubridate::year(curr_date), 3, 4)
  curr_month <- paste0(curr_year, curr_month)
  try(download.file(paste0("https://ec.europa.eu/economy_finance/db_indicators/surveys/documents/series/nace2_ecfin_", curr_month, "/", suffix, ".zip"),
                    destfile = download_file),
      silent = TRUE)
  sdmx_files <- unzip(download_file, exdir = download_folder)
  
  # Download failed try it with download of one month earlier
  if (length(sdmx_files) == 0) {
    curr_date <- lubridate::floor_date(Sys.Date(), "month") - 1
    curr_month <- lubridate::month(curr_date)
    curr_month <- ifelse(nchar(curr_month) == 1, paste0("0", curr_month), curr_month)
    curr_year <- substring(lubridate::year(curr_date), 3, 4)
    curr_month <- paste0(curr_year, curr_month)
    try(download.file(paste0("https://ec.europa.eu/economy_finance/db_indicators/surveys/documents/series/nace2_ecfin_", curr_month, "/", suffix, ".zip"),
                      destfile = download_file))
  } else {
    for (i in sdmx_files) {
      file.remove(i)
    }
  }
  
}