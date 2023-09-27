# Create data files for the portfolio dashboard

Create PTA csv files for P-dash and save to sharepoint.

## Step 0: Backup files

1.  Go to folder: Norad-Avd-Kunnskap - General\\06. Porteføljestyring\\P-Dash\\prod\\data\\

2.  There you find two csv files: agreement_info.csv and agreement_disbursement.csv

3.  Copy the two files to folder Norad-Avd-Kunnskap - General\\06. Porteføljestyring\\P-Dash\\backup\\data\\

## Step 1: Download raw data reports from PTA

Two PTA reports are used as input files.

### PTA report Agreement totals

Purpose: The report is used for frame agreement information on title, partner and period. We include all agreements signed after the year 2000 to include all agreements with disbursement this current year and onwards, as the year criteria in Agreement reports is not filtered on disbursement.

1.  Open PTA
2.  Select Reports -\> Agreement totals
3.  Pane Basic criteria: leave all selections empty
4.  Pane Advanced criteria
    -   Agreement phase: A;B;C;D
    -   Signed after: 01.01.2000
    -   Programme area: 03;12
    -   Leave the other selections empty
5.  Pane Change layout:
    -   Show totals for
        -   Resonsible unit: Remove selection
    -   Other layout options
        -   Flexi column: Agreement period
        -   For public use: Remove selection
6.  Click the excel icon to generate excel report
7.  Save report
    -   File name: *Agreement totals*
    -   Select file format *CSV UTF-8 (Comma delimited) (\*.csv)*
    -   Save to folder: Norad-Avd-Kunnskap - General\\06. Porteføljestyring\\P-Dash\\data_raw\\pta_reports\\

### PTA report Disbursement level

Purpose: The report is used for disbursements and agreement information for agreements with disbursements current year and onwards.

1.  Open PTA
2.  Select Reports -\> Disbursement level
3.  Pane Basic criteria: leave all selections empty
4.  Pane Advanced criteria
    -   Date after: 01.01.2023 (current year)
    -   Cost center group: Norad
    -   Programme area: 03;12
    -   Leave other selections empty
5.  Pane Change layout:
    -   Show columns for
        -   Statistics: Yes
        -   Agreement description: Yes
    -   Show totals for: no selection
    -   Other layout options: leave all selections empty
6.  Click the excel icon to generate excel report
7.  File name: *Disbursement level*
8.  Select file format *CSV UTF-8 (Comma delimited) (\*.csv)*
9.  Save to folder: Norad-Avd-Kunnskap - General\\06. Porteføljestyring\\P-Dash\\data_raw\\pta_reports\\

## Step 2: Run R-script agreement_totals.R

Purpose: This report takes the Agreement totals.csv file produced in Step 1 as input and and saves a tidy versjon as agreement_totals.csv in the output/ folder of this prosject directory.

1.  Run script agreement_totals.R

## Step 3: Run R-script disbursement.R

Purpose: This report takes the Disbursement level.csv file produced in Step 1 and the agreement_totals.csv prodused in Step 2 as input and saves to separate datasets in sharepoint prod folder.

1.  Run script disbursement_totals.R

## Step 4: Run R-script agreement_title.R

Purpose: This report takes the Agreement totals.csv file produced in Step 1 as input and and saves the agreement number and agreement title in an xlsx file in sharepoint prod folder.

1.  Run script agreement_title.R

## That's it!

The dashboard will be updated daily from the agreement_info.csv and agreement_disbursement.csv, and the power apps will be updated using the agreement_title.xlsx.
