install.packages("tidyverse")
install.packages("lubridate")
install.packages("lfe")
install.packages("tidytext")
install.packages("SnowballC")
install.packages("textdata")

library(textdata)
library(tidyverse)
library(dplyr)
library(tidytext)
library(SnowballC)

# reading the text file 
test_data <- readLines("2011.txt")



df <- tibble(text = test_data)

test_data_sentences <- df %>%
  unnest_tokens(output = "sentence",
                token = "sentences",
                input = text) 

#the total score of emotions
total_score <- 0

#for loop because words used separately as environment/environmental/environmentally
for(term in c("profits")) {
 
  #considering the environment related sentences
  env_sentences <- test_data_sentences[grepl(term, test_data_sentences$sentence), ]
  
  # Further Tokenize the text by word
  env_tokens <- env_sentences %>%
    unnest_tokens(output = "word", token = "words", input = sentence) %>%
    anti_join(stop_words)
  
  afinnframe<-get_sentiments("afinn")
  # Use afinn to find the overall sentiment score
  affin_score <- env_tokens %>% 
    inner_join(afinnframe, by = c("word" = "word")) %>%
    summarise(sentiment = sum(value))
  
  total_score = total_score + affin_score
}

