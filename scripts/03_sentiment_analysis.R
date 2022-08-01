library(tidyverse)
library(tidylog)
library(sentimentr)

# Getting everything ready ----

## Read threads, then bind them into a nested dataframe using 'purrr::map_dfr'
threads <- fs::dir_ls(path = './data/threads', glob = '*rds') |> 
  purrr::map_dfr(read_rds)

## Split the nested dataframe
comments <- threads$comments
threads <- threads$threads |> distinct(date, .keep_all = TRUE)


# Analysis ----

## Remove deleted or removed comments
comments <- comments |> 
  filter(!str_detect(comment, pattern = '\\[removed\\]')) |> 
  filter(!str_detect(comment, pattern = '\\[deleted\\]'))

## Convert to a "get_sentences" object from "sentimentr"
sentences <- sentimentr::get_sentences(comments$comment)
# write_rds(sentences, file = './data/sentences.rds') # intermediate save

## Compute the sentiment via the "sentiment" function
sentiment_sentence <- sentimentr::sentiment(text.var = sentences)
# write_rds(sentiment_sentence, file = './data/sentiment_sentence.rds') # intermediate save

# Aggregate sentiment on the comment and thread levels
## Comment level
sentiment_comment <- sentiment |> 
  group_by(element_id) |> 
  summarise(mean_sentiment = mean(sentiment, na.rm = TRUE),
            mean_words = mean(word_count, na.rm = TRUE))

comments <- comments |> 
bind_cols(sentiment_comment)  
  
## Thread level
sentiment_thread <- comments |> 
  group_by(url) |> 
  summarise(polarity = sd(mean_sentiment, na.rm = TRUE),
            mean_sentiment = mean(mean_sentiment, na.rm = TRUE),
            mean_words = mean(mean_words, na.rm = TRUE))

threads <- threads |> 
  left_join(sentiment_thread, by = c('url'))

## Write files 
write_csv(comments, './data/comments.csv')
write_csv(threads, './data/threads.csv')
