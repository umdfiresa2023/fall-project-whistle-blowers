install.packages("edgar")
library("edgar")

useragent<-"ruangmas@umd.edu"

output <- getFilings(cik.no = c(0001666700), 
                     c('10-K'),
                     2019, 
                     quarter = c(1), 
                     downl.permit = "y", 
                     useragent)

install.packages("R.utils")
library(R.utils)
gunzip("Master Indexes/2019QTR1master.gz", remove=FALSE)
