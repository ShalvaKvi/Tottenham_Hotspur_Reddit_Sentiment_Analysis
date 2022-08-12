Hey!

## What is this?
Reddit has a special subrredit dedicated to the Tottenham Hotspur football club of the Premier League (https://www.reddit.com/r/coys/) that is comprised of 100K+ followers. Being a member of that community, and a huge fan of the club, I thought it would be cool and interesting to employ NLP techniques to explore the sentiment of the re-occuring match and post-match threads of the 2021-2022 season.

### *The following questions peaked my interest the most:*
 1. Can we identify different sentiment patterns for matches where the club won or lost?
 2. How does the sentiment differ in match threads as opposed to post-match threads?
 3. Does the match outcome has a lasting effect on the general sentiment of the subrredit? 

## How did I go about it?
I thought it would be cool to tackle these questions by building an interactive application that will allow the user to freely explore the data! These are the steps that I took:
 1. I web-scraped match results from the 2021-2022 season from the web (see: '/scripts/01_match_information.r').
 2. Then, I used Reddit's API to retrieve all the match\post-match\daily discussion threads that I could find (see: '/scripts/02_reddit_thread_data_retrieval.r').
 3. After getting everything together, I conducted the sentiment analysis with the excellent *sentimentr* library (see: '/scripts/03_sentiment_analysis.r').
 4. And Finally, I put everything together in an interactive dashboard that was built with *flexdashboard* and *plotly* (see: '/dashboard/dashboard.Rmd').

