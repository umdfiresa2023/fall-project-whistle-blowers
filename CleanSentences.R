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
