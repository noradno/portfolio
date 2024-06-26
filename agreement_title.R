# PTA Agreement totals report to lookup agreement titles in the power apps
# Selections in Agreement totals report: In PTA, select Signed after 01.01.2000, Agreement Phase A,B,C,D, Programme area 3,12, Tick off Responsible unit, Flexi column Agreement period

library(dplyr)
library(tidyr)
library(stringr)
library(janitor)
library(readr)
library(openxlsx2)

# Load
path <- "C:/Users/aaw262/Norad/Norad-Avd-Kunnskap - General/06. Portef\u00F8ljestyring/P-Dash/data_raw/pta_reports/Agreement totals.csv"

# Return error if file does not exist
if (!file.exists(path)) {
  stop("File Agreement totals.csv does not exist")
}

# Read and clean data
df_title <-
  read_csv2(path,
            skip = 13,
            name_repair = janitor::make_clean_names,
            locale = readr::locale(decimal_mark = ",", grouping_mark = " ", encoding = "UTF-8")
  ) |> 
  select(agreement_no, agreement_title) |> 
  head(-2)

# Include subunits and create parent_agreement_no.Import subunits from file produced by disbursement.R
# There are many missing values, as there are many old agreements in df_title not present in the disbursements dataset
df_subunit <- readr::read_csv2("C:/Users/aaw262/Norad/Norad-Avd-Kunnskap - General/06. Portef\u00F8ljestyring/P-Dash/prod/data/agreement_info.csv") |> 
  filter(agreement_type == "Subunit") |> 
  select(agreement_no, agreement_title)

df_title <- bind_rows(df_title, df_subunit)

df_title <- df_title |> 
  mutate(agreement_no = str_squish(agreement_no)) |> 
  mutate(parent_agreement_no = str_sub(agreement_no, 1, 11)) |> 
  mutate(subunit = str_length(agreement_no) > 11) |> 
  relocate(agreement_no, parent_agreement_no, agreement_title)

# Save data ---------------------------------------------------------

# Save data as xlsx in table format to prod folder
path <- "C:/Users/aaw262/Norad/Norad-Avd-Kunnskap - General/06. Portef\u00F8ljestyring/P-Dash/prod/data/"

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
