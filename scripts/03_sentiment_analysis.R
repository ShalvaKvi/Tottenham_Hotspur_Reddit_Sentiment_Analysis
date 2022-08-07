library(tidyverse)
library(tidylog)
library(sentimentr)


# Getting everything ready ----
## Read Results
results <- read_csv('./data/results.csv')
## Read thread information
daily_threads_info <- read_csv("./data/thread_search_results/daily_threads_info.csv")
pre_match_info <- read_csv("./data/thread_search_results/pre_match_threads_info.csv")
match_info <- read_csv("./data/thread_search_results/match_threads_info.csv")
post_match_info <- read_csv("./data/thread_search_results/post_match_threads_info.csv")


## Read threads, then bind them into a nested dataframe using 'purrr::map_dfr'
thread_urls <- c("./data/threads/daily/", "./data/threads/match/", "./data/threads/pre_match/", "./data/threads/post_match/")
threads <- fs::dir_ls(path = thread_urls , glob = '*rds') |> 
  purrr::map_dfr(read_rds) |> 
  bind_cols()

## Split the nested dataframe
comments <- threads$comments
thread_info <- threads$threads |> distinct(title, .keep_all = TRUE)


# Analysis ----

## Remove deleted or removed comments
comments <- comments |> 
  filter(!str_detect(comment, pattern = '\\[removed\\]')) |> 
  filter(!str_detect(comment, pattern = '\\[deleted\\]'))

## Convert to a "get_sentences" object from "sentimentr"
sentences <- sentimentr::get_sentences(comments$comment)

# write_rds(sentences, file = './data/sentences.rds') # intermediate save

## Compute the sentiment via the "sentiment" function
sentiment_sentence <- sentimentr::sentiment(text.var = sentences) |> 
  as_tibble() |> 
  mutate(category = case_when(
    sentiment < 0 ~ -1, 
    sentiment == 0 ~ 0, 
    sentiment > 0 ~ 1)
  )
# write_rds(sentiment_sentence, file = './data/sentiment_sentence.rds') # intermediate save

# Aggregate sentiment on the comment and thread levels
## Comment level -
sentiment_comment <- sentiment_sentence |> 
  group_by(element_id) |> 
  summarise(mean_sentiment = mean(category, na.rm = TRUE),
            mean_words = mean(word_count, na.rm = TRUE))

### Bind the sentiment score the the comment dataframe
comments <- comments |> 
bind_cols(sentiment_comment)  
  
## Thread level - 
sentiment_thread <- comments |> 
  group_by(url) |> 
  summarise(polarity = sd(mean_sentiment, na.rm = TRUE),
            mean_sentiment = mean(mean_sentiment, na.rm = TRUE),
            mean_words = mean(mean_words, na.rm = TRUE))

### Join the thread sentiment score to the thread_info dataframe
thread_info <- thread_info |> 
  left_join(sentiment_thread, by = c('url'))

### Create a column that indicates the thread type by matching the url for the search results
thread_info <- thread_info |> 
  mutate(thread_type = case_when(
    url %in% pre_match_info$url ~ "pre_match",
    url %in% match_info$url ~ "match",
    url %in% post_match_info$url ~ "post_match",
    url %in% daily_threads_info$url ~ "daily",
  ))


# Combine Results and Thread Info for the dashboard
combined_data <- thread_info |> 
  mutate(date = lubridate::as_date(date)) |> 
  arrange(date) |> 
  left_join(results, by = 'date') |> 
  mutate(matchday = factor(ifelse(is.na(opponent), yes = 0, no = 1))) |> 
  fill(win)

combined_data <- combined_data |> 
  mutate(win = factor(win, levels = c(1, 0.5, 0), labels = c("Win", "Draw", "Lose")),
         score_label = paste('Tottenham Hotspur', score.y, opponent),
         mean_sentiment = round(mean_sentiment, digits = 5),
         polarity = round(polarity, digits = 5))


## Write files -
write_rds(combined_data, './dashboard/combined_data.rds')
write_rds(comments, './dashboard/comments.rds')
