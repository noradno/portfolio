# PTA Agreement totals report to lookup agreement titles in the power apps
# Selections in Agreement totals report: In PTA, select Signed after 01.01.2000, Agreement Phase A,B,C,D, Programme area 3,12, Tick off Responsible unit, Flexi column Agreement period

library(dplyr)
library(tidyr)
library(stringr)
library(janitor)
library(readr)
library(openxlsx2)

# Load
path <- "C:/Users/u14339/UD Office 365 AD/Norad-Avd-Kunnskap - General/06. Porteføljestyring/P-Dash/data_raw/pta_reports/Agreement totals.csv"

# Return error if file does not exist
if (!file.exists(path)) {
  stop("File Agreement totals.csv does not exist")
}

# Read and clean data
df_title <-
  read_csv2(path,
            skip = 13,
            name_repair = janitor::make_clean_names,
            locale = readr::locale(decimal_mark = ",", grouping_mark = " ")
  ) |> 
  select(agreement_no, agreement_title) |> 
  head(-2)

# Save data ---------------------------------------------------------

# Save data as xlsx in table format to prod folder
path <- "C:/Users/u14339/UD Office 365 AD/Norad-Avd-Kunnskap - General/06. Porteføljestyring/P-Dash/prod/data/"

## Create Workbook, specify table name (name to refer to in Power apps etc) and save
wb <- wb_workbook()
wb$add_worksheet("Sheet1")
write_datatable(
  wb = wb,
  sheet = "Sheet1",
  x = df_title,
  table_name = "table_agreement_title"
)
wb_save(wb,
        file = paste0(path, "agreement_title.xlsx"),
        overwrite = TRUE)
