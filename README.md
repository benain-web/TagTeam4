# Fitbit Group Dashboard (TagTeam4)

An interactive R Shiny dashboard built by Team 4 for the DATA2007 group project. It uses the
Fitbit Fitness Tracker dataset (33 users, 12 April to 12 May 2016) to let a group compare their
activity, sleep and heart rate in one place.

## Features

- **Secure login** with hashed passwords and automatic logout after 15 minutes idle (shinymanager)
- **Overview**: leaderboard sortable by steps, distance, active minutes or calories, progress
  towards a 10,000 daily step goal, and weeks meeting 150 active minutes
- **Heart rate**: average heart rate per member and over time
- **Sleep**: sleep leaderboard (duration, time in bed, efficiency), 8 hour goal progress and
  weekly sleep patterns
- **On every page**: member and date filters, full screen charts, PNG download, and a raw data
  table you can filter, sort and export as CSV

## Running the app

1. Install R (4.5 or later) and open `TagTeam4.Rproj` in RStudio.
2. Restore the packages with `renv::restore()`.
3. Copy these files from the Fitbit dataset into `data-raw/`:
   - `dailyActivity_merged.csv`
   - `sleepDay_merged.csv`
   - `heartrate_seconds_merged.csv`
4. Run `shiny::runApp()`.

The raw data isn't stored in this repo. To keep it elsewhere, set the `FITBIT_DATA_DIR`
environment variable to that folder.

Login details are shared within the team and are not published here.

## Project structure

| Path | Purpose |
|---|---|
| `app.R` | Main app: login, navbar and page modules |
| `R/mod_*.R` | One Shiny module per dashboard page |
| `R/calc_*.R` | Data loading and calculations, kept separate so they can be tested |
| `R/ui_helpers.R` | Shared chart cards, filters and data tables |
| `R/mod_template.R` | Starting template for a new page |
| `tests/testthat/` | Unit tests |
| `www/credentials.sqlite` | Login database (passwords stored hashed) |

## Data notes

- Days with zero steps are treated as the tracker not being worn and are left out of activity
  averages.
- The last day (12 May) is only partly recorded and is excluded from activity summaries.
- Coverage varies: activity data exists for all 33 users, sleep for 24 and heart rate for 14.
  Pages show a "no data available" message when a selected member has no data.

## Running tests

From the `tests/testthat` folder, run `testthat::test_dir(".")`.

## Team workflow

Each member works on their own feature branch and opens a pull request into `dev`. `dev` is
merged into `main` once reviewed.

## Team

Team 4, DATA2007.
