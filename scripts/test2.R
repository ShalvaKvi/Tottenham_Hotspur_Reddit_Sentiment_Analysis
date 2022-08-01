pacman::p_load(
  tidyverse,
  tidytext, tokenizers, stopwords
)

# READ
results <- read.csv("results.csv")
comments <- read.csv("comments.csv")
threads <- read.csv('threads.csv')
#

# tokenize
tokens <- comments |>
  select("text" = comment, gameid, "commentid" = comment_id) |> 
  unnest_tokens(output = word, input = text, token = "words")

# clean stop-words
tokens <- tokens |> 
  anti_join(by = "word", get_stopwords(source = "stopwords-iso"))

