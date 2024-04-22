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
results_df  <- data.frame()
results_df <- data.frame(`REPORTING YEAR` = numeric(), `ESG_Score` = numeric(), `PARENT COMPANIES` = character())
#missing Celanese, Honeywell
for(folder in c("test3M", "testAlbemarle","testExxon Mobil", "testHuntsman", "testPPG", "testWestlake")) {               
  for (file in c("/2011.txt","/2012.txt", "/2013.txt", "/2014.txt", "/2015.txt","/2016.txt", "/2017.txt", "/2018.txt", "/2019.txt", "/2020.txt")){
    
    PATH <- paste0(folder, file)
    test_data <- readLines(PATH)
    
    df <- tibble(text = test_data)
    
    test_data_sentences <- df %>%
      unnest_tokens(output = "sentence",
                    token = "sentences",
                    input = text) 
    
    #the total score of emotions
    total_score <- 0
    year <- as.numeric(substr(file, 2, 5))
    
    
    count <- 0
    #for loop because words used separately as environment/environmental/environmentally
    for(term in c("environment","environmental","environmentally")) {
      
      
      #considering the environment related sentences
      env_sentences <- test_data_sentences[grepl(term, test_data_sentences$sentence), ]
      
      
      
      # Further Tokenize the text by word
      env_tokens <- env_sentences %>%
        unnest_tokens(output = "word", token = "words", input = sentence) %>%
        anti_join(stop_words)
      
      afinnframe<-get_sentiments("afinn")
      # Use afinn to find the overall sentiment score
      affin_score <- env_tokens %>% 
        inner_join(afinnframe, by = c("word" = "word")) 
      
      if(nrow(affin_score)>0){ 
        count = count + 1
      } else {
        print("no affin scores for this word")
        next
      }
      
      if(nrow(affin_score) == 0){
        affin_score_rows <- 1
      } else {
        affin_score_rows <- nrow(affin_score)
      }
      total_score = total_score + sum(affin_score$value)/affin_score_rows
    }
    #company_name <- substring(folder, first = 5)
    total_score = total_score / count
    results_df <- rbind(results_df, 
                        data.frame(`REPORTING YEAR` = year, 
                                   `ESG_Score` = total_score,
                                   `PARENT COMPANIES`= folder))
  }
  
}



test_data <- readLines("envTestbad")
df <- tibble(text = test_data)

test_data_sentences <- df %>%
  unnest_tokens(output = "sentence",
                token = "sentences",
                input = text) 

#the total score of emotions
total_score <- 0
year <- "2011"
count <- 0
for(term in c("environment","environmental","environmentally")) {
  
  #considering the environment related sentences
  env_sentences <- test_data_sentences[grepl(term, test_data_sentences$sentence), ]
  
  

  # Further Tokenize the text by word
  env_tokens <- env_sentences %>%
    unnest_tokens(output = "word", token = "words", input = sentence) %>%
    anti_join(stop_words)
  
  afinnframe<-get_sentiments("afinn")
  # Use afinn to find the overall sentiment score
  affin_score <- env_tokens %>% 
    inner_join(afinnframe, by = c("word" = "word")) 
  
  if(nrow(affin_score)>0){ 
    count = count + 1
  } else {
    print("no affin scores for this word")
    next
  }
    
  if(nrow(affin_score) == 0){
    affin_score_rows <- 1
  } else {
    affin_score_rows <- nrow(affin_score)
  }
  total_score = total_score + sum(affin_score$value)/affin_score_rows
}
total_score = total_score / count
results_df <- rbind(results_df, 
                    data.frame(`REPORTING YEAR` = year, 
                               `ESG_Score` = total_score,
                               `PARENT COMPANIES`=folder))
#install.packages("tm")
#install.packages("NLP")
#install.packages("openNLP")

#library(tm)
#library(NLP)
#library(openNLP)
#chunk_into_sentences <- function(text) {
#  break_points <- c(1, as.numeric(gregexpr('[[:alnum:] ][.!?]', text)[[1]]) + 1)
#  sentences <- NULL
# for(i in 1:length(break_points)) {
#    res <- substr(text, break_points[i], break_points[i+1]) 
#    if(i>1) { sentences[i] <- sub('. ', '', res) } else { sentences[i] <- res }
#  }
#  sentences <- sentences[sentences=!is.na(sentences)]
#  return(sentences)
#}




#install.packages("tokenizers")
#library(tokenizers)
install.packages("qdap")
library(qdap)

# Loop through each folder and file
for (folder in c("test3M", "testAlbemarle","testExxon Mobil", "testHuntsman", "testPPG", "testWestlake")) {
  dir_name <- paste0(folder, "_for_NLP")
  dir.create(dir_name, showWarnings = FALSE)
  for (file in c("/2011.txt","/2012.txt", "/2013.txt","/2012.txt", "/2013.txt", "/2014.txt", "/2015.txt","/2016.txt", "/2017.txt", "/2018.txt", "/2019.txt", "/2020.txt")) {
    
    # Construct the file path
    PATH <- paste0(folder, file)
    
    # Read the content of the file
    test_data2 <- readLines(PATH, warn = FALSE, n = -1)
    test_data2 <- paste(test_data2, collapse = " ")
    test_data2 <- sent_detect(test_data2)
    
    t<-as.data.frame(test_data2)
    
    t2<- t |>
      mutate(nchar=str_length(test_data2))
    
    tshort<-t2 |>
      filter(nchar<512)
    
    tlong<-t2 |>
      filter(nchar>=512)
    
    tlong1<-tlong |>
      mutate(test_data2=substr(test_data2, 1, 512)) |>
      mutate(nchar=str_length(test_data2))
    
    tlong2<-tlong |>
      mutate(test_data2=substr(test_data2, 512+1, 512*2)) |>
      mutate(nchar=str_length(test_data2))
    
    tall<-rbind(tshort, tlong1, tlong2)
    
    tcsv<-tall$test_data2
    
    output_file <- paste(folder,gsub(".txt", "sentences.csv", file))
    output_file <- gsub("/", "", output_file)
    dest <- paste0(dir_name,"/",output_file)
    
    write.csv(tcsv, dest, row.names=F)
  }
}
#dir_name <- paste0(folder, "_for_NLP")
#dir.create(dir_name, showWarnings = FALSE)
#dest <- paste0(dir_name,"/",file_name)
sentenceDF <- data.frame(SENTENCES = sentences)
view(test_data2)

folder<-"test3M"
file<-"/2011.txt"

library("tidyverse")

t<-as.data.frame(test_data2)

t2<- t |>
  mutate(nchar=str_length(test_data2))

tshort<-t2 |>
  filter(nchar<514)

tlong<-t2 |>
  filter(nchar>=514)

tlong1<-tlong |>
  mutate(test_data2=substr(test_data2, 1, 514)) |>
  mutate(nchar=str_length(test_data2))

tlong2<-tlong |>
  mutate(test_data2=substr(test_data2, 514+1, 514*2)) |>
  mutate(nchar=str_length(test_data2))

tall<-rbind(tshort, tlong1, tlong2)

tcsv<-tall$test_data2
write.csv(tcsv, "splittest.csv", row.names=F)
