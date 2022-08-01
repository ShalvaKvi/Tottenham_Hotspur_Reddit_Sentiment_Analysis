library(tidyverse)
library(tidylog)
library(sentimentr)

daily_threads_info <- read_csv('./data/daily_threads_info.csv')
results <- read_csv("./data/results.csv")

# Read threads, then bind them into a nested dataframe using 'purrr::map_dfr'
threads <- fs::dir_ls(path = './data/threads', glob = '*rds') |> 
  purrr::map_dfr(read_rds)

comments <- threads$comments
threads <- threads$threads

# Remove deleted or removed comments
comments <- comments |> 
  filter(!str_detect(comment, pattern = '\\[removed\\]')) |> 
  filter(!str_detect(comment, pattern = '\\[deleted\\]'))
