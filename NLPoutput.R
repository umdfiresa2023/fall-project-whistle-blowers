

library(textdata)
library(tidyverse)
library(dplyr)
library(tidytext)
library(SnowballC)




NLPdata<-c()
for(folder in c("NLP Output/3M", "NLP Output/PPG","NLP Output/Huntsman", "NLP Output/Albemarle", "NLP Output/Exxon Mobil", "NLP Output/Westlake")) {
  files<-dir(folder)
  for (file in files){
    outputPath <- paste0(folder,"/",file)
    dfNLP <-read.csv(outputPath)
    
    dfNLP2 <- dfNLP %>%
      filter(nchar(text) >= 30) %>%
      filter(action == "action")
    
    cleanyear <- as.numeric(sub(".*([0-9]{4})[^0-9]*$", "\\1", file))
    
    NLPMerge<-data.frame(cbind(action = nrow(dfNLP2),
                               year = cleanyear,
                               company = sub(".*/", "", folder)))
    
    NLPdata<-rbind(NLPdata, NLPMerge)
    
  }
}


Inputdata <- c()
for(folder in c("DataForNLP/test3M_for_NLP", "DataForNLP/testAlbemarle_for_NLP",
                "DataForNLP/testExxon Mobil_for_NLP","DataForNLP/testHuntsman_for_NLP", "DataForNLP/testPPG_for_NLP",
                "DataForNLP/testWestlake_for_NLP")) {
  files<-dir(folder)
  for (file in files){
    outputPath <- paste0(folder,"/",file)
    dfcount <-read.csv(outputPath)
    
    
    cleanyear <- as.numeric(sub(".*([0-9]{4})[^0-9]*$", "\\1", file))
    text_between_slash_and_underscore <- sub(".*/([^_]*)_.*", "\\1", folder)
    cleaned_string <- sub("test", "", text_between_slash_and_underscore)
    
    
    InputMerge<-data.frame(cbind(SentenceCount = nrow(dfcount),
                               year = cleanyear,
                               company = cleaned_string))
    
    Inputdata<-rbind(Inputdata, InputMerge)
    
  }
}


