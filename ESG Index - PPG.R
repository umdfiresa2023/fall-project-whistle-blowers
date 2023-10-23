install.packages("tidyverse")
install.packages("lubridate")
install.packages("lfe")
install.packages("tidytext")
install.packages("SnowballC")


library(tidyverse)
library(dplyr)
library(tidytext)
library(SnowballC)

# reading the text file 
test_data <- read.table("2011.txt", sep = ".", header = TRUE, row.names = NULL)

# #tokenization and removing stop words
# test_data_tokenize <- test_data %>%
#   unnest_tokens(output = "word",
#                 token = "words",
#                 input = X10.K) %>%
#   anti_join(stop_words) %>%
#   count(word, sort = TRUE)
# 
# 
# #Stemming 
# stemmed_test_data <- test_data_tokenize %>%
#   mutate(word = wordStem(word))%>%
#   count(word, sort = TRUE)

#sentence tokenization
test_data_sentences <- test_data %>%
  unnest_tokens(output = "sentence",
                token = "sentences",
                input = X10.K) 

#the total score of emotions
total_score <- 0

#for loop because words used separately as environment/environmental/environmentally
for(term in c("environment", "environmental", "environmentally")) {
 
  #considering the environment related sentences
  env_sentences <- test_data_sentences[grepl(term, test_data_sentences$sentence), ]
  
  # Further Tokenize the text by word
  env_tokens <- env_sentences %>%
    unnest_tokens(output = "word", token = "words", input = sentence) %>%
    anti_join(stop_words)
  
  # Use afinn to find the overall sentiment score
  affin_score <- env_tokens %>% 
    inner_join(get_sentiments("afinn")) %>%
    summarise(sentiment = sum(score))
  
  total_score = total_score + affin_score
}
