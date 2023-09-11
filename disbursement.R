# PTA disbursement level report
# Two dataframes: 1) Agreement info, and 2) Disbursement info
# The disbursement level report is supplemented by frame agreement info and disbursement

library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(janitor)
library(tibble)

# Path to PTA agreement totals report (csv)
path <- "C:/Users/u14339/UD Office 365 AD/Norad-Avd-Kunnskap - General/06. Porteføljestyring/P-Dash/data_raw/pta_reports/Disbursement level.csv"

# Return error if file does not exist
if (!file.exists(path)) {
  stop("File Disbursement level.csv does not exist")
}

# Read PTA csv data
df <-
  read_csv2(
    path,
    skip = 7,
    name_repair = janitor::make_clean_names,
    col_types = cols(case_no = col_character(),
                     agreement_period_from = col_character(),
                     agreement_period_to = col_character()),
    locale = readr::locale(decimal_mark = ",", grouping_mark = " ")
  ) |> 
  head(-2)

# Create column parent_agreement_no - to create frame agreement numbers from sub frame agreement numbers
df <- df |> 
  mutate(parent_agreement_no = str_sub(agreement_no, end = 11)) |> 
  relocate(parent_agreement_no, .after = agreement_no)

# Create column agreement_type to separeate sub units from other agreements
# Please double check later that the NA values are treated correctly
df <- df |>
  mutate(agreement_type = if_else(disb_code == "S", "Subunit", "Standard", missing = "Standard"))

# A vector storing unique frame agreement numbers
vec_frameagreements <- df |> 
  filter(disb_code == "S") |> 
  select(parent_agreement_no) |> 
  unique() |> 
  pull()

# Remove chapter 5309 - Repayments, as this is not relevant in this context
df <- df |> 
  filter(chapter != "5309")

# Include current year and the next 3 years
df <- df |> 
  filter(year %in% c(min(year):(min(year)+3))) 


# Keep only distinct rows (remove duplicate rows)
# There are three duplicates, check what this is.
#df_distinct <- df |> distinct()

# Data frame agreement_info --------------------------------------------------
# This dataset should contain only unique agreement numbers and static agreement info columns

# Select agreement_no and static columns
df_agreement_info <- df |> 
  select(agreement_no,
         parent_agreement_no,
         agreement_type,
         agreement_title,
         agr_phase,
         agreement_period_from,
         agreement_period_to,
         agreement_partner,
         agreement_partner_group,
         impl_institution,
         recipient_country,
         type_of_assistance,
         form_of_assistance,
         sector,
         main_sector_description,
         sub_sector_description,
         agreement_description,
         gender_equality,
         bio_diversity,
         climate_change_mitigation,
         climate_change_adaptation
         )

# Keep only distinct rows
df_agreement_info <- distinct(df_agreement_info)

# Check if there are any duplicate agreement numbers
df_agreement_info |> 
  count(agreement_no) |> 
  filter(n > 1)

# Create column agreement_period
df_agreement_info <-
  df_agreement_info |> unite(
    agreement_period,
    agreement_period_from,
    agreement_period_to,
    sep = "-" ,
    remove = FALSE
  )



# Include frame agreement info in agreement_info
df_agreement_totals <-
  read_csv2(
    "output/agreement_totals.csv",
    col_types = cols(
      agreement_period_from = col_character(),
      agreement_period_to = col_character()
    )
  )

# Agreement totals of frame agreements only
df_frameagreement_totals <- df_agreement_totals |>
  filter(agreement_no %in% vec_frameagreements)

# Create column parent_agreement_no - here a duplicate of agreement_no
df_frameagreement_info <- df_frameagreement_totals |> 
  mutate(parent_agreement_no = agreement_no, .after = agreement_no)

# Create column agreement_type - specify as frame agreements

df_frameagreement_info <- df_frameagreement_info |> 
  add_column(agreement_type = "Frame")

# Add the frame agreements to the bottom of the df_agreement_info dataset.
# By using the bind_rows any unmatched column names gives value NA

df_agreement_info <- bind_rows(df_agreement_info, df_frameagreement_info)

# Check to make sure there ar no duplicate agreement numbers
df_agreement_info |> 
  count(agreement_no) |> 
  filter(n > 1)

# THe agreement_no column is unique, and is therefor fit for showing disbursement data.
# The parent_agreement_no column is not unique and is fit to have a relation to portfolio objective
# Perhaps it will be useful to include a agreement_type column (like a agreement type, or S,A,M column) but that is at least more important in the agreement_disbursement dataset

# Dataframe agreement_disbursement ----------------------------------------------------
# This dataset should contain each agreements disbursement info including other non-static info
# In this dataset an agreement number can have multiple records (across these non-static info)

# Select columns and create grouped amount summaries across columns
df_agreement_disbursement <- df |>
  group_by(
    agreement_no,
    year,
    status_of_payment,
    chapter_post,
    cost_center_name,
    programme_officer_name
  ) |>
  summarise(amount = sum(amount)) |> 
  ungroup()

# Calculate the grouped sums of the subunits to find the frame agreement sums
df_frameagreement_disbursement <- df |>
  filter(agreement_type == "Subunit") |>
  group_by(
    parent_agreement_no,
    year
  ) |>
  summarise(amount = sum(amount)) |> 
  ungroup()

# Add agreement phase from the subframes to the frame agreement (all sub-units are the same phase)
df_frameagreement_phase <- df |>
  filter(agreement_type == "Subunit") |>
  group_by(
    parent_agreement_no,
    agr_phase
  ) |>
  summarise(n = n()) |> 
  ungroup() |> 
  select(-n)

df_frameagreement_disbursement <- df_frameagreement_disbursement |> 
  left_join(df_frameagreement_phase, by ="parent_agreement_no")



# Checks: one frameagreement is not present in the disbursement datset. Perhaps there are nothing disbursed.
vec_test <- unique(df_frameagreement_disbursement$parent_agreement_no)

df_agreement_disbursement |> 
  filter(agreement_no %in% vec_frameagreements)

# Create column parent_agreement_no - a duplicate column of agreement_no
df_frameagreement_disbursement <- df_frameagreement_disbursement |> 
  mutate(agreement_no = parent_agreement_no, .before = parent_agreement_no) |> 
  select(-parent_agreement_no)


# Add the frame agreements to the bottom of the df_agreement_disbursement dataset.
# By using the bind_rows any unmatched column names gives value NA

df_agreement_disbursement <- bind_rows(df_agreement_disbursement, df_frameagreement_disbursement)


# Save dataframes ---------------------------------------------------------

# Save datasets to prod folder
path <- "C:/Users/u14339/UD Office 365 AD/Norad-Avd-Kunnskap - General/06. Porteføljestyring/P-Dash/prod/data/"

readr::write_csv2(df_agreement_info,
                  paste0(path, "agreement_info.csv"))

readr::write_csv2(df_agreement_disbursement,
                  paste0(path, "agreement_disbursement.csv"))
