# PTA Agreement totals report to get frame agreement data on title, partner and period.
# In addition to get expected agreement total column for all frame and standard agreements.
# Selections in Agreement totals report: In PTA, select Signed after 01.01.2000, Agreement Phase A,B,C,D, Programme area 3,12, Tick off Responsible unit, Flexi column Agreement period

library(dplyr)
library(tidyr)
library(stringr)
library(janitor)
library(readr)

# Load
path <- "C:/Users/aaw262/Norad/Norad-Avd-Kunnskap - General/06. Portef\u00F8ljestyring/P-Dash/data_raw/pta_reports/Agreement totals.csv"


# Return error if file does not exist
if (!file.exists(path)) {
  stop("File Agreement totals.csv does not exist")
}

# Read and clean data
df <-
  read_csv2(path,
            skip = 13,
            name_repair = janitor::make_clean_names,
            locale = readr::locale(decimal_mark = ",", grouping_mark = " ", encoding = "UTF-8")
  ) |> 
  select(-starts_with("x")) |> 
  head(-2)

# Select relevant columns
df <- df |>
  select(agreement_no,
         agreement_title,
         agreement_partner,
         agr_period,
         expected_agreement_total)

# The expected_agreement_total is in 1000NOK, must make it to NOK
df <- df |> 
  mutate(expected_agreement_total = expected_agreement_total * 1000)

# Create agreement from and two, and rename agr_period and relocate columns
df <- df |>
  mutate(
    agreement_period_from = str_sub(agr_period, end = 4),
    agreement_period_to = str_sub(agr_period, start = -4)
  ) |>
  rename(agreement_period = agr_period) |> 
  relocate(expected_agreement_total, .after = last_col())

# Save to output folder
readr::write_csv2(df, "output/agreement_totals.csv")
