# Overview page calculations (Person 1: REQ-19, REQ-20, REQ-21)
# Plain functions with no Shiny code so they can be unit tested.

library(dplyr)
library(lubridate)
library(readr)

# Leaderboard metrics: display label = column name
OVERVIEW_METRICS <- c(
  "Average steps"          = "avg_steps",
  "Average distance (km)"  = "avg_distance",
  "Average active minutes" = "avg_active_minutes",
  "Average calories"       = "avg_calories"
)

# Read and tidy dailyActivity_merged.csv
load_daily_activity <- function(data_dir) {
  path <- file.path(data_dir, "dailyActivity_merged.csv")
  if (!file.exists(path)) {
    stop("Could not find ", path, ". Set FITBIT_DATA_DIR to the Fitbit dataset folder.", call. = FALSE)
  }
  read_csv(
    path,
    col_types = cols(Id = col_character(), ActivityDate = col_character(), .default = col_double())
  ) %>%
    mutate(
      Date = mdy(ActivityDate),
      # Moderate-to-vigorous minutes (WHO definition)
      ActiveMinutes = VeryActiveMinutes + FairlyActiveMinutes
    ) %>%
    # The final day of the export is incomplete, so drop it
    filter(Date < max(Date)) %>%
    select(Id, Date, TotalSteps, TotalDistance, ActiveMinutes, Calories)
}

# Keep the selected members and dates (NULL = no filter)
filter_daily <- function(df, members = NULL, dates = NULL) {
  if (!is.null(members)) df <- filter(df, Id %in% members)
  if (!is.null(dates)) df <- filter(df, Date >= dates[1], Date <= dates[2])
  df
}

# REQ-19: one row per member, ranked by the chosen metric.
# Zero-step days are treated as the tracker not being worn and excluded.
leaderboard <- function(df, sort_by = "avg_steps") {
  if (!sort_by %in% OVERVIEW_METRICS) stop("Unknown metric: ", sort_by, call. = FALSE)
  df %>%
    filter(TotalSteps > 0) %>%
    group_by(Id) %>%
    summarise(
      days               = n(),
      avg_steps          = round(mean(TotalSteps)),
      avg_distance       = round(mean(TotalDistance), 2),
      avg_active_minutes = round(mean(ActiveMinutes), 1),
      avg_calories       = round(mean(Calories)),
      .groups = "drop"
    ) %>%
    arrange(desc(.data[[sort_by]])) %>%
    mutate(rank = row_number(), .before = 1)
}

# REQ-20: progress towards a daily step goal
step_goal_progress <- function(df, goal = 10000) {
  df %>%
    filter(TotalSteps > 0) %>%
    group_by(Id) %>%
    summarise(
      days      = n(),
      avg_steps = round(mean(TotalSteps)),
      days_met  = sum(TotalSteps >= goal),
      .groups = "drop"
    ) %>%
    mutate(
      goal_pct     = round(avg_steps / goal * 100, 1),
      pct_days_met = round(days_met / days * 100, 1)
    ) %>%
    arrange(desc(goal_pct))
}

# REQ-21: weeks (Mon-Sun) where a member reached the active-minutes target.
# Only complete weeks (7 recorded days) are counted so partial weeks are not unfairly failed.
weekly_active_minutes <- function(df, target = 150) {
  df %>%
    mutate(week = floor_date(Date, "week", week_start = 1)) %>%
    group_by(Id, week) %>%
    summarise(days = n(), active_minutes = sum(ActiveMinutes), .groups = "drop") %>%
    filter(days == 7) %>%
    mutate(met = active_minutes >= target)
}

weekly_target_summary <- function(df, target = 150) {
  weekly_active_minutes(df, target) %>%
    group_by(Id) %>%
    summarise(weeks_tracked = n(), weeks_met = sum(met), .groups = "drop") %>%
    arrange(desc(weeks_met), desc(weeks_tracked))
}
