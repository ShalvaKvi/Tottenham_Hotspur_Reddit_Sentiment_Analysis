library(tidyverse)
library(tidylog)
library(RedditExtractoR)

# Retreive Reddit Daily Discussion URL's ----

# Extract thread information
daily_thread_search <- RedditExtractoR::find_thread_urls(keywords = "Daily Discussion Thread",
                                                         sort_by = "new", 
                                                         subreddit = "coys",
                                                         period = "all")


# Extract some more thread information from last year
daily_thread_search_21 <- RedditExtractoR::find_thread_urls(keywords = "Daily Discussion Thread (2021)",
                                                         sort_by = "new", 
                                                         subreddit = "coys",
                                                         period = "all")


# Bind dataframes together
daily_threads_info <- daily_thread_search |> 
  bind_rows(daily_thread_search_21)

daily_threads_info <- daily_threads_info |> 
  filter(date_utc > min(results$date) - 3 & date_utc < max(results$date) + 3) |> 
  filter(str_extract(string = title, pattern = 'Daily Discussion Thread') == 'Daily Discussion Thread') |> 
  distinct(title, .keep_all = TRUE) 
  arrange(date_utc)

# Save
write_csv(daily_threads_info, "./data/daily_threads_info.csv")


# Download Daily Threads Content ----

# Read CSVs
daily_threads_info <- read_csv("./data/daily_threads_info.csv")
results <- read_csv("./data/results.csv")


# Run a loop that extract the thread content via Reddit API and save the rds file, also track progression
for (i in 1:length(daily_threads_info$url)) {
  
thread <- RedditExtractoR::get_thread_content(daily_threads_info$url[i])
file_name <- glue::glue('./data/threads/{filename}.rds', 
                        filename = daily_threads_info$title[i])

write_rds(thread, file = file_name)

print(paste('progress:', i, '/', length(daily_threads_info$url)))

}
