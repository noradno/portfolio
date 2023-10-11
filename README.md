# Update PTA data files for P-dash

[P-dash](https://teams.microsoft.com/l/channel/19%3aLKJoSQmxd38wdsg8wxcE-Er4yZAohLQbMnpyCITY5EM1%40thread.tacv2/Generelt?groupId=e07641f9-014c-4a89-b46f-fc3572a6be38&tenantId=bb0f0b4e-4525-4e4b-ba50-1e7775a8fd2e) (Portfolio dashboard and apps) is connected to the data files listed below, and looks for changes in the files 6 times each day. P-dash is automatically updated when these files are updated.

Follow the procedure outlined below to updated these files.

-   agreement_info.csv

-   agreement_disbursement.csv

-   agreement_total.csv

-   agreement_title.xlsx

When? As for now, we do this procedure every weekday before 9 am, to keep P-dash updated daily.

## Step 0: Backup existing files

Take a copy of the existing data files in case the update procedure fails.

1.  Go to folder: Norad-Avd-Kunnskap - General\\06. Porteføljestyring\\P-Dash\\prod\\data\\

2.  Copy all files and save by replacing the existing files in folder Norad-Avd-Kunnskap - General\\06. Porteføljestyring\\P-Dash\\backup\\data\\

## Step 1: Download raw data reports from PTA

Two PTA reports are used as input files.

### PTA report Agreement totals

Purpose: The report is used for frame agreement information on title, partner and period. We include all agreements signed after the year 2000 to include all agreements with disbursement this current year and onward, as the year criteria in Agreement reports is not filtered on disbursement.

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
7.  Save file by replacing the existing file
    -   Don't do any changes in the PTA report before saving
    -   Select File -\> Save as
    -   Select the following folder: Norad-Avd-Kunnskap - General\\06. Porteføljestyring\\P-Dash\\data_raw\\pta_reports\\
    -   Select file format *CSV UTF-8 (Comma delimited) (\*.csv)*
    -   Select the file to overwrite: File name: *Agreement totals*
    -   Save and accept to replace the existing *Agreemen totals.csv* file

### PTA report Disbursement level

Purpose: The report is used for disbursements and agreement information for agreements with disbursements current year -2 and onward.

1.  Open PTA
2.  Select Reports -\> Disbursement level
3.  Pane Basic criteria: leave all selections empty
4.  Pane Advanced criteria
    -   Date after: 01.01.2021 (current year - 2)
    -   Cost center group: Norad
    -   Agreement phase: A;B;C;D
    -   Programme area: 03;12
    -   Leave other selections empty
5.  Pane Change layout:
    -   Show columns for
        -   Statistics: Yes
        -   Agreement description: Yes
    -   Show totals for: no selection
    -   Other layout options: leave all selections empty
6.  Click the excel icon to generate excel report
7.  Save file by replacing the existing file
    -   Don't do any changes in the PTA report before saving
    -   Select File -\> Save as
    -   Select the following folder: Norad-Avd-Kunnskap - General\\06. Porteføljestyring\\P-Dash\\data_raw\\pta_reports\\
    -   Select file format *CSV UTF-8 (Comma delimited) (\*.csv)*
    -   File name: *Disbursement level*
    -   Select the file to overwrite: File name: *Disbursement level*
    -   Save and accept to replace the existing *Disbursement level.csv* file

## Step 2: Run R-script agreement_totals.R

Purpose: This report takes the Agreement totals.csv file produced in Step 1 as input and and saves a tidy versjon as agreement_totals.csv in the output/ folder of this prosject directory.

1.  Run script agreement_totals.R
2.  Restart R to clear Environment: On the top banner i R-Studio click Session -\> Restart R

## Step 3: Run R-script disbursement.R

Purpose: This report takes the Disbursement level.csv file produced in Step 1 and the agreement_totals.csv prodused in Step 2 as input and saves to separate datasets in sharepoint prod folder.

1.  Run script disbursement.R
2.  Restart R to clear Environment: On the top banner i R-Studio click Session -\> Restart R

## Step 4: Run R-script agreement_title.R

Purpose: This report takes the Agreement totals.csv file produced in Step 1 as input and and saves the agreement number and agreement title in an xlsx file in sharepoint prod folder.

1.  Run script agreement_title.R
2.  Close R-Studio

## That's it!

P-dash (dashboard and apps) looks for changes in the data files 6 times a day.
