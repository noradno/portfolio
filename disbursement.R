# PTA disbursement level report

# Three dataframes are prodused: 1) agreement_info, and 2) agreement_disbursemet and agreement_total
# The agreement_disbursement level report is supplemented by frame agreement info and disbursement form from PTA report Agreement totals
# The agreement_total is a separate table to include the expected agreement total.

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

# Include only Norad cost centers by filtering on cost center names starting with two uppercase letters
df <- df |> 
  filter(str_detect(cost_center_name, "^[A-ZÆØÅ]{2}"))

# Create column parent_agreement_no - to create frame agreement numbers from sub frame agreement numbers
df <- df |> 
  mutate(parent_agreement_no = str_sub(agreement_no, end = 11)) |> 
  relocate(parent_agreement_no, .after = agreement_no)

# Create column agreement_type to separeate sub units from other agreements
# Please double check later that the NA values are treated correctly
df <- df |>
  mutate(agreement_type = if_else(disb_code %in% c("S", "SD", "SM"), "Subunit", "Standard", missing = "Standard"))

# Remove rejected agreements (agreement phase E)
df <- df |> 
  filter(agr_phase != "E")

# Remove chapter 5309 - Repayments, as this is not relevant in this context
df <- df |> 
  filter(chapter != "5309")

# Exlude years higher than 2040 to remove misspelled years (like year 2125)
df <- df |> 
  filter(year < 2040)

# A vector storing unique frame agreement numbers
vec_frameagreements <- df |> 
  filter(disb_code == "S") |> 
  select(parent_agreement_no) |> 
  unique() |> 
  pull()


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

# Remove column expected agreement totals
df_frameagreement_totals <- df_frameagreement_totals |> 
  select(-expected_agreement_total)

# Create column parent_agreement_no - here a duplicate of agreement_no
df_frameagreement_info <- df_frameagreement_totals |> 
  mutate(parent_agreement_no = agreement_no, .after = agreement_no)

# Create column agreement phase from the subframes to the frame agreement (all sub-units are the same phase)
df_frameagreement_phase <- df |>
  filter(agreement_type == "Subunit") |>
  group_by(
    parent_agreement_no,
    agr_phase
  ) |>
  summarise(n = n()) |> 
  ungroup() |> 
  select(-n)

df_frameagreement_info <- df_frameagreement_info |> 
  left_join(df_frameagreement_phase, by = "parent_agreement_no")


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

# Replace NA with N/A
df_agreement_info <- df_agreement_info |> 
  mutate(
    across(where(is.character), ~replace_na(.x, "N/A"))
  )

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
    status_of_payment,
    chapter_post,
    cost_center_name,
    programme_officer_name,
    year
  ) |>
  summarise(amount = sum(amount)) |> 
  ungroup()

# Calculate the grouped sums of the subunits to find the frame agreement sums
df_frameagreement_disbursement <- df |>
  filter(agreement_type == "Subunit") |>
  group_by(
    parent_agreement_no,
    status_of_payment,
    chapter_post,
    cost_center_name,
    programme_officer_name,
    year
  ) |>
  summarise(amount = sum(amount)) |> 
  ungroup()

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

# Replace NA with N/A
df_agreement_disbursement <- df_agreement_disbursement |> 
  mutate(
    across(where(is.character), ~replace_na(.x, "N/A"))
  )

# Remove subunits without a parent agreement
# If there are subunits without a corresponding frameagreement, the subunits should be excluded from the df_agreement_info and df_agreement_disbursement datasets
# These are A frame agreements with to little information to be included in PTA Agreement total reports
# NB: This code can be improved: instead of finding subunits not present in agreements_total, we can find subunits without a parent_agreement_no in df_agreement_no

# Find values in  vec_frameagreements that are not present in df_agreement_total
missing_frameagreements <- vec_frameagreements[!vec_frameagreements %in% df_agreement_totals$agreement_no]

# Filter the data frames to exclude these subunit orphans
df_agreement_info <- df_agreement_info |> 
  filter(!str_detect(agreement_no, str_c(missing_frameagreements, collapse = "|")))

df_agreement_disbursement <- df_agreement_disbursement |> 
  filter(!str_detect(agreement_no, str_c(missing_frameagreements, collapse = "|")))



# Dataframe expected_agreement_total (expected agreement total) -----------
# Include column agreement_no and expected_agreement_total. Include only agreements present in df_agreement_info.
# Exclude na rows, typically A phase agreements without registered total amounts
df_agreement_total <- df_agreement_totals |> 
  select(agreement_no, expected_agreement_total) |> 
  filter(!is.na(expected_agreement_total)) |> 
  filter(agreement_no %in% df_agreement_info$agreement_no)

# Save dataframes ---------------------------------------------------------

# Save datasets to prod folder
path <- "C:/Users/u14339/UD Office 365 AD/Norad-Avd-Kunnskap - General/06. Porteføljestyring/P-Dash/prod/data/"

readr::write_csv2(df_agreement_info,
                  paste0(path, "agreement_info.csv"))

readr::write_csv2(df_agreement_disbursement,
                  paste0(path, "agreement_disbursement.csv"))

readr::write_csv2(df_agreement_total,
                  paste0(path, "agreement_total.csv"))
