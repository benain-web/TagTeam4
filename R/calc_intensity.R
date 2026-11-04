# Column -> label shown on the page, ordered least to most active
INTENSITY_LEVELS <- c(
  "SedentaryMinutes" = "Sedentary",
  "LightlyActiveMinutes" = "Light",
  "FairlyActiveMinutes" = "Fair",
  "VeryActiveMinutes" = "Very active"
)

load_intensity <- function(data_dir) {
  read_csv(file.path(data_dir, "dailyActivity_merged.csv"),
           col_types = cols(Id = "c", ActivityDate = "c")) %>%
    mutate(Date = mdy(ActivityDate)) %>%
    filter(Date < max(Date)) %>% # last day is incomplete
    select(Id, Date, TotalSteps, all_of(names(INTENSITY_LEVELS)))
}

# Average minutes per day at each intensity level for each member (REQ-23).
# Zero-step days mean the tracker wasn't worn, so they're excluded (REQ-15).
intensity_breakdown <- function(df) {
  df %>%
    filter(TotalSteps > 0) %>%
    tidyr::pivot_longer(all_of(names(INTENSITY_LEVELS)),
                        names_to = "level", values_to = "minutes") %>%
    group_by(Id, level) %>%
    summarise(days = n(), avg_minutes = mean(minutes), .groups = "drop") %>%
    group_by(Id) %>%
    mutate(share = avg_minutes / sum(avg_minutes) * 100) %>%
    ungroup() %>%
    mutate(level = factor(INTENSITY_LEVELS[level], levels = INTENSITY_LEVELS)) %>%
    arrange(Id, level)
}
