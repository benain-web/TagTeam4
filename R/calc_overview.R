library(dplyr)
library(lubridate)
library(readr)

OVERVIEW_METRICS <- c(
  "Average steps" = "avg_steps",
  "Average distance (km)" = "avg_distance",
  "Average active minutes" = "avg_active_minutes",
  "Average calories" = "avg_calories"
)

load_daily_activity <- function(data_dir) {
  read_csv(file.path(data_dir, "dailyActivity_merged.csv"),
           col_types = cols(Id = "c", ActivityDate = "c")) %>%
    mutate(Date = mdy(ActivityDate),
           ActiveMinutes = VeryActiveMinutes + FairlyActiveMinutes) %>%
    filter(Date < max(Date)) %>%  # last day is incomplete
    select(Id, Date, TotalSteps, TotalDistance, ActiveMinutes, Calories)
}

filter_daily <- function(df, members = NULL, dates = NULL) {
  if (!is.null(members)) df <- filter(df, Id %in% members)
  if (!is.null(dates)) df <- filter(df, between(Date, dates[1], dates[2]))
  df
}

# Zero-step days mean the tracker wasn't worn, so they're excluded
leaderboard <- function(df, sort_by = "avg_steps") {
  if (!sort_by %in% OVERVIEW_METRICS) stop("Unknown metric: ", sort_by)
  df %>%
    filter(TotalSteps > 0) %>%
    group_by(Id) %>%
    summarise(days = n(),
              avg_steps = round(mean(TotalSteps)),
              avg_distance = round(mean(TotalDistance), 2),
              avg_active_minutes = round(mean(ActiveMinutes), 1),
              avg_calories = round(mean(Calories))) %>%
    arrange(desc(.data[[sort_by]])) %>%
    mutate(rank = row_number(), .before = 1)
}

step_goal_progress <- function(df, goal = 10000) {
  df %>%
    filter(TotalSteps > 0) %>%
    group_by(Id) %>%
    summarise(days = n(),
              avg_steps = round(mean(TotalSteps)),
              days_met = sum(TotalSteps >= goal)) %>%
    mutate(goal_pct = round(avg_steps / goal * 100, 1)) %>%
    arrange(desc(goal_pct))
}

# Only complete Mon-Sun weeks are counted
weekly_target_summary <- function(df, target = 150) {
  df %>%
    group_by(Id, week = floor_date(Date, "week", week_start = 1)) %>%
    summarise(days = n(), minutes = sum(ActiveMinutes), .groups = "drop") %>%
    filter(days == 7) %>%
    group_by(Id) %>%
    summarise(weeks_tracked = n(), weeks_met = sum(minutes >= target)) %>%
    arrange(desc(weeks_met), desc(weeks_tracked))
}
