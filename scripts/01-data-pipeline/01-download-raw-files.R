

ds <- c("main_indicators_sa_nace2",
        "uncertainty_total_nsa_nace2",
        "labourhoarding_total_sa_nace2",
        "labourhoarding_total_nsa_nace2",
        "industry_total_sa_nace2",
        "industry_total_nsa_nace2",
        "industry_mig_sa_nace2",
        "industry_inve_nace2",
        "industry_subsectors_sa_nace2",
        "industry_subsectors_nsa_nace2",
        "services_total_sa_nace2",
        "services_total_nsa_nace2",
        "services_inve_nace2",
        "services_subsectors_sa_nace2",
        "services_subsectors_nsa_nace2",
        "consumer_total_sa_nace2",
        "consumer_total_nsa_nace2",
        "consumer_subsectors_nace2",
        "consumer_inflation_nace2",
        "retail_total_sa_nace2",
        "retail_total_nsa_nace2",
        "retail_subsectors_sa_nace2",
        "retail_subsectors_nsa_nace2",
        "building_total_sa_nace2",
        "building_total_nsa_nace2",
        "building_subsectors_sa_nace2",
        "building_subsectors_nsa_nace2")

for (i in ds) {
  download_ec_raw_data(dl_folder, i)
}

