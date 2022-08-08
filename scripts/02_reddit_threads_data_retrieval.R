library(tidyverse)
library(tidylog)
library(glue)
library(RedditExtractoR)

results <- read_csv("./data/results.csv")

# Retrieve Reddit r/coys Thread Information via the API----

## Daily Discussions ----
## Extract thread information
daily_thread_search <- find_thread_urls(keywords = "Daily Discussion Thread",
                                                         subreddit = "coys",
                                                         sort_by = "new",
                                                         period = "year")


## Extract some more thread information from last year
daily_thread_search_21 <- find_thread_urls(keywords = "Daily Discussion Thread (2021)",
                                                         subreddit = "coys",
                                                         sort_by = "new",
                                                         period = "year")

## Bind dataframes together
daily_threads_info <- daily_thread_search |> 
  bind_rows(daily_thread_search_21)

## Filter out irrelevant results
daily_threads_info <- daily_threads_info |> 
  filter(date_utc > min(results$date) - lubridate::days(3) & date_utc < max(results$date) + lubridate::days(3)) |> 
  filter(str_extract(string = title, pattern = 'Daily Discussion Thread') == 'Daily Discussion Thread') |> 
  mutate(title = str_replace_all(title, pattern = "[:punct:]", replacement = "_")) |> 
  distinct(title, .keep_all = TRUE) |> 
  arrange(date_utc)

## Save
write_csv(daily_threads_info, "./data/thread_search_results/daily_threads_info.csv")


## Pre-Match Threads ----
pre_match_search <-  find_thread_urls(keywords = "Pre-Match Thread", 
                                      subreddit = "coys", 
                                      sort_by = "new",
                                      period = "year")


pre_match_info <- pre_match_search |> 
  mutate(date_utc = as.POSIXct(date_utc, tz = "utc")) |> 
  arrange(date_utc) |> 
  filter(date_utc %in% (results$date - lubridate::days(1)) | date_utc %in% (results$date)) |> 
  mutate(title = str_replace_all(title, pattern = "[:punct:]", replacement = "_"))

write_csv(pre_match_info, "./data/thread_search_results/pre_match_threads_info.csv")

## Match Threads ----
match_search <-  find_thread_urls(keywords = "[Match Thread]", 
                                  subreddit = "coys", 
                                  sort_by = "new",
                                  period = "all")


match_info <- match_search |> 
  mutate(date_utc = as.POSIXct(date_utc, tz = "utc")) |> 
  filter(str_extract(string = title, pattern = '\\[Match Thread\\]') == '[Match Thread]') |> 
  arrange(date_utc) |> 
  filter(date_utc %in% (results$date)) |> 
  mutate(title = str_replace_all(title, pattern = "[:punct:]", replacement = "_"))



write_csv(match_info, "./data/thread_search_results/match_threads_info.csv")
## Post-Match Threads ----
post_match_search <-  find_thread_urls(keywords = "Post-Match Thread", 
                                       subreddit = "coys", 
                                       sort_by = "new",
                                       period = "year")


post_match_info <- post_match_search |> 
  mutate(date_utc = as.POSIXct(date_utc, tz = "utc")) |> 
  arrange(date_utc) |> 
  filter(date_utc  %in% (results$date)) |> 
  mutate(title = str_replace_all(title, pattern = "[:punct:]", replacement = "_"))

write_csv(post_match_info, "./data/thread_search_results/post_match_threads_info.csv")


# Download Daily Threads Content ----

# Read CSVs
daily_threads_info <- read_csv("./data/thread_search_results/daily_threads_info.csv")
pre_match_info <- read_csv("./data/thread_search_results/pre_match_threads_info.csv")
match_info <- read_csv("./data/thread_search_results/match_threads_info.csv")
post_match_info <- read_csv("./data/thread_search_results/post_match_threads_info.csv")


# Run a loop that extract the thread content via Reddit API and save the rds file, also track progression

# for daily threads
for (i in 1:length(daily_threads_info$url)) {
  
thread <- RedditExtractoR::get_thread_content(daily_threads_info$url[i])
file_name <- glue::glue('./data/threads/daily/{filename}.rds', 
                        filename = daily_threads_info$title[i])

write_rds(thread, file = file_name)

print(paste('progress:', i, '/', length(daily_threads_info$url)))

}

# for pre match threads
for (i in 1:length(pre_match_info$url)) {
  
  thread <- RedditExtractoR::get_thread_content(pre_match_info$url[i])
  file_name <- glue::glue('./data/threads/pre_match/{filename}.rds', 
                          filename = pre_match_info$title[i])
  
  write_rds(thread, file = file_name)
  
  print(paste('progress:', i, '/', length(pre_match_info$url)))
  
}

# for match threads
for (i in 1:length(match_info$url)) {
  
  thread <- RedditExtractoR::get_thread_content(match_info$url[i])
  file_name <- glue::glue('./data/threads/match/{filename}.rds', 
                          filename = match_info$title[i])
  
  write_rds(thread, file = file_name)
  
  print(paste('progress:', i, '/', length(match_info$url)))
  
}

# for post match threads
for (i in 1:length(post_match_info$url)) {
  
  thread <- RedditExtractoR::get_thread_content(post_match_info$url[i])
  file_name <- glue::glue('./data/threads/post_match/{filename}.rds', 
                          filename = post_match_info$title[i])
  
  write_rds(thread, file = file_name)
  
  print(paste('progress:', i, '/', length(post_match_info$url)))
  
}

