
#Sleep metrics used by the leaderboard dropdown
SLEEP_METRICS <- c(
  "Average sleep (hours)" = "avg_sleep_hours",
  "Average time in bed (hours)" = "avg_time_in_bed",
  "Sleep efficiency (%)" = "avg_efficiency"
)


#Prepare sleep data
prepare_sleep <- function(sleep) {
  
  sleep %>%
    mutate(
      Id = as.character(Id),
      
      SleepDay = if (inherits(SleepDay, "Date")) {
        as.Date(SleepDay)
      } else if (inherits(SleepDay, "POSIXt")) {
        as.Date(SleepDay)
      } else {
        as.Date(
          lubridate::parse_date_time(
            as.character(SleepDay),
            orders = c(
              "mdy IMS p",
              "mdy HM",
              "mdy HMS",
              "mdy"
            ),
            quiet = TRUE
          )
        )
      },
      
      sleep_hours = TotalMinutesAsleep / 60,
      time_in_bed_hours = TotalTimeInBed / 60,
      
      sleep_efficiency = ifelse(
        TotalTimeInBed > 0,
        TotalMinutesAsleep / TotalTimeInBed * 100,
        NA_real_
      )
    )
}




#Filter sleep data by selected members and dates
filter_sleep <- function(sleep, members, dates) {
  sleep %>%
    filter(
      Id %in% members,
      between(SleepDay, dates[1], dates[2])
    )
}

#Calculate leaderboard
sleep_leaderboard <- function(sleep, sort_by = "avg_sleep_hours") {
  
  out <- sleep %>%
    group_by(Id) %>%
    summarise(
      nights_tracked = n(),
      avg_sleep_hours = mean(sleep_hours, na.rm = TRUE),
      avg_time_in_bed = mean(time_in_bed_hours, na.rm = TRUE),
      avg_efficiency = mean(sleep_efficiency, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(.data[[sort_by]])) %>%
    mutate(Rank = row_number()) %>%
    select(
      Rank,
      Id,
      nights_tracked,
      avg_sleep_hours,
      avg_time_in_bed,
      avg_efficiency
    )
  
  out
}


#Calculate progress towards 8 hours of sleep
sleep_goal_progress <- function(sleep) {
  
  sleep %>%
    group_by(Id) %>%
    summarise(
      nights = n(),
      nights_met = sum(sleep_hours >= 8, na.rm = TRUE),
      goal_pct = nights_met / nights * 100,
      avg_sleep = mean(sleep_hours, na.rm = TRUE),
      .groups = "drop"
    )
}


#Calculate weekly sleep patterns
weekly_sleep_summary <- function(sleep) {
  
  sleep %>%
    mutate(
      week = lubridate::floor_date(
        SleepDay,
        unit = "week",
        week_start = 1
      )
    ) %>%
    group_by(Id, week) %>%
    summarise(
      avg_sleep = mean(sleep_hours, na.rm = TRUE),
      .groups = "drop"
    )
}
