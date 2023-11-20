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


# reading the text file , "/New foldder/,"2012.txt", "2013.txt", "2014.txt", "2015.txt","2016.txt", "2017.txt", "2018.txt", "2019.txt", "2020.txt",
results_df <- data.frame(`REPORTING YEAR` = numeric(), `ESG_Score` = numeric())
results_df  <- data.frame()

for (file in c("2011.txt","2012.txt", "2013.txt", "2014.txt", "2015.txt","2016.txt", "2017.txt", "2018.txt", "2019.txt", "2020.txt")){

# reading the text file 

for (file in c("2011.txt", "2012.txt", "2013.txt", "2014.txt", "2015.txt",
               "2016.txt", "2017.txt", "2018.txt", "2019.txt", "2020.txt",)){

  test_data <- readLines(file)
  
  df <- tibble(text = test_data)
  
  test_data_sentences <- df %>%
    unnest_tokens(output = "sentence",
                  token = "sentences",
                  input = text) 
  
  #the total score of emotions
  total_score <- 0
<<<<<<< HEAD
  year <- as.numeric(sub("\\.txt$", "", file))
  
  
  count <- 0
  #for loop because words used separately as environment/environmental/environmentally
  for(term in c("environment","environmental","environmentally")) {
=======
  
  #for loop because words used separately as environment/environmental/environmentally
  for(term in c("environment", "environmental", "environmentally")) {
>>>>>>> 9d596cc81eb8b9c566a33df82f538aa431694841
    
    #considering the environment related sentences
    env_sentences <- test_data_sentences[grepl(term, test_data_sentences$sentence), ]
    
<<<<<<< HEAD
   #cat(nrow(env_sentences) , "num of sent")
    if(nrow(env_sentences)>0){ 
      count = count + 1
    } else {
      print("no text for this word")
      next
    }
    
    #for(i in env_sentences) { 
    #  for (j in i){
     #   count <- count + 1
    #  }
    #}
=======
    count <- 0
    for(i in env_sentences) { 
      for (j in i){
        count <- count + 1
      }
    }
>>>>>>> 9d596cc81eb8b9c566a33df82f538aa431694841
    # Further Tokenize the text by word
    env_tokens <- env_sentences %>%
      unnest_tokens(output = "word", token = "words", input = sentence) %>%
      anti_join(stop_words)
    
    afinnframe<-get_sentiments("afinn")
    # Use afinn to find the overall sentiment score
    affin_score <- env_tokens %>% 
<<<<<<< HEAD
      inner_join(afinnframe, by = c("word" = "word")) #%>%
      #summarise(sentiment = sum(value)/ nrow(affin_score))
    cat(nrow(affin_score), "affin rows")

    total_score = total_score + sum(affin_score$value)/nrow(affin_score)
  }
  total_score = total_score / count
  results_df <- rbind(results_df, data.frame(`REPORTING YEAR` = year, `ESG_Score` = total_score))
=======
      inner_join(afinnframe, by = c("word" = "word")) %>%
      summarise(sentiment = sum(value))
    
    total_score = total_score + affin_score
  }
  
  total_score = total_score / count
>>>>>>> 9d596cc81eb8b9c566a33df82f538aa431694841
}


