pacman::p_load(
  tidyverse, tidylog, 
  wordcloud2, RedditExtractoR, tidytext, SnowballC,
  ggthemes, extrafont, ggraph, igraph)

# READ
results <- read.csv("results.csv")
comments <- read.csv("comments.csv")
threads <- read.csv('threads.csv')
#

# Pre-processing (Stop-words, stemming)

tokens <- comments |> 
  select("text" = comment, gameid, "commentid" = comment_id) |>
  unnest_tokens(word, text)
  
tokens <- tokens |> 
  anti_join(get_stopwords(source = "snowball"))

tokens <- tokens |> 
  mutate(stem = wordStem(word))

  
  
# Word embeddings

df <- comments |> 
  select("text" = comment, gameid, "commentid" = comment_id) |>
  unnest_tokens(word, text) |> 
  add_count(word) |> 
  filter(n >= 50) |> 
  select(-n)
  

nested_words <- df %>%
  nest(words = c(word))


### SENTIMENT PLOT
df <- comments |>
  select("text" = comment, gameid, comment_id) 

df <- df |> 
  unnest_tokens(word, text, token = "words", drop = FALSE) |> 
  select(!text) |> 
  anti_join(get_stopwords(language = "en", source = "snowball"))

df <- df |> 
  inner_join(get_sentiments("afinn")) |> 
  group_by(gameid, comment_id) |> 
  summarise(sentiment = mean(value)) |> 
  group_by(gameid) |> 
  summarise(sentiment = mean(sentiment))




results <- results |> 
  left_join(df, by = c("gameid" = "gameid")) |> 
  mutate(win_text = factor(case_when(win == 1 ~ "Win",
                                     win == 0.5 ~ "Draw", 
                                     win == 0 ~ "Lose"),
                           levels = c("Win","Lose","Draw")))
                            

plt <-
  ggplot(data = results, aes(
    x = gameid,
    y = sentiment,
    label = paste(opponent, score)
  )) +
  geom_hline(yintercept = 0) +
  geom_segment(aes(color = win_text, yend = 0, xend = gameid),
               lineend = "round",
               size = 2) +
  geom_point(aes(color = win_text, y = 0), size = 4) +
  geom_segment(aes(yend = 0, xend = gameid)) +
  geom_text(
    aes(
      color = win_text,
      y = ifelse(sentiment > 0, 0.05, -0.05),
      hjust = ifelse(sentiment > 0, 0, 1)
    ),
    vjust = -0.5,
    size = 2.5,
    angle = 90
  ) +
  scale_x_reverse() +
  scale_color_manual(values = c("#0072B5", "#BC3C29", "#20854E")) +
  labs(
    title = "r/coys Post-Match Threads Average Sentiment",
    y = "Average sentiment",
    color = "Game outcome:",
    caption = "Computed with AFINN sentiment lexicon. Finn Årup Nielsen. (2011)."
  ) +
  theme_hc(base_size = 16) +
  theme(
    text = element_text(family = "Candara"),
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  )

plt








# # 
# names <- c(
#   "conte antonio",
#   "lloris hugo",
#   "gollini pierluigi",
#   "doherty matt",
#   "reguilon sergio regi",
#   "sanchez davinson",
#   "rodon joe",
#   "tanganga japhet",
#   "davies ben",
#   "dier eric",
#   "romero cristian cuti",
#   "royal emerson",
#   "hojbjerg pierre emile",
#   "winks winksy",
#   "sessegnon ryan sess",
#   "skipp oliver skippy oli olli",
#   "bentancur rodrigo",
#   "kulusevski dejan kulu deki",
#   "bergwijn steven berg stevie",
#   "moura lucas",
#   "kane harry",
#   "son heung min sonny"
# )

# ### LINK PLOT
# 
# df <- comments |> 
#   select("text" = comment, gameid) |> 
#   unnest_tokens(bigram, text, token = "ngrams", n = 2)
# 
# 
# df_separated <- df %>%
#   separate(bigram, c("word1", "word2"), sep = " ")
# 
# df_filtered <- df_separated %>%
#   filter(!word1 %in% stop_words$word) %>%
#   filter(!word2 %in% stop_words$word)
# 
# # new bigram counts:
# df_counts <- df_filtered %>% 
#   count(word1, word2, sort = TRUE)
# 
# bigram_graph <- df_counts |> 
#   filter(n > 20) |> 
#   graph_from_data_frame()
# 
# 
# ggraph(bigram_graph, layout = "fr") +
#   geom_edge_link() +
#   geom_node_point() +
#   geom_node_text(aes(label = name), vjust = 1, hjust = 1)