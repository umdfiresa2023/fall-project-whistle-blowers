install.packages("R.utils")
install.packages("edgar")
install.packages("finreportr")
install.packages("edgarWebR")

install.packages("tidyverse")
install.packages("httr")
install.packages("XBRL")
install.packages("stringr")

library(stringr)
library(finreportr)
library(R.utils)
library(edgar)
library(edgarWebR)

library(tidyverse)
library(httr)
library(XBRL)


options(HTTPUserAgent = "tjones77@terpmail.umd")
info.df <- AnnualReports("GOOG")
#lsf.str("package:finreportr")



#edgar_agent <- Sys.getenv("EDGARWEBR_USER_AGENT",
#                          unset = "monkeyiran22@gmail.com"
#)
#ua <- httr::user_agent(edgar_agent)
#options(HTTPUserAgent=ua$options$useragent)
#company_filings("AAPL", type = "10-K", count = 1)

#useragent <- Sys.getenv("useragent", unset = "monkeyiran22@gmail.com")
#ua <- httr::user_agent(useragent)
#options(HTTPUserAgent=ua$options$useragent)
#output <- getFilings("AAPL", c('10-K','10-Q'), 2020, quarter = c(1, 2, 3), downl.permit = "n", useragent)




AnnualReportsTYLERFORK <- function(symbol, foreign = FALSE, save_files = TRUE) {
  
  options(stringsAsFactors = FALSE)
  
  if(foreign == FALSE) {
    url <- paste0("http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=", 
                  symbol, "&type=10-k&dateb=&owner=exclude&count=100")
  } else {
    url <- paste0("http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=", 
                  symbol, "&type=20-f&dateb=&owner=exclude&count=100")
  }
  
  filings <- xml2::read_html(url)
  
  ##   Generic function to extract info
  ExtractInfo <- function(html.node) {
    info <-
      filings %>%
      rvest::html_nodes(html.node) %>%
      rvest::html_text()
    return(info)
  }
  
  ##   Acquire filing name
  filing.name <- ExtractInfo("#seriesDiv td:nth-child(1)")
  
  ##   Error message for function
  if(length(filing.name) == 0) {
    stop("invalid company symbol or foreign logical")
  }
  
  ##   Acquire filing date
  filing.date <- ExtractInfo(".small+ td")
  
  ##   Acquire accession number
  accession.no.raw <- ExtractInfo(".small")
  
  accession.no <-
    gsub("^.*Acc-no: ", "", accession.no.raw) %>%
    substr(1, 20)
  
  ##   Create dataframe
  info.df <- data.frame(filing.name = filing.name, filing.date = filing.date, 
                        accession.no = accession.no)
  #/Archives/edgar/data/1652044/000165204423000016/0001652044-23-000016-xbrl.zip
  
  if (save_files) {
    # Create a directory to store the annual reports
    dir_name <- paste0(symbol, "_AnnualReports")
    dir.create(dir_name, showWarnings = FALSE)
    
    # Download and save each annual report as a text file
    for (i in 1:length(info.df$filing.name)) {
      if(trimws(info.df$filing.name[i]) == "10-K/A") {
        next
      }
      path <- paste0("tr:nth-child(", i + 1 , ") td:nth-child(2) a")
      
      urlToZipPath  <- filings %>%
        rvest::html_node(path) %>%
        rvest::html_attr("href")
      
      converted_string <- sub("\\index.htm$", "xbrl.zip", urlToZipPath)
     
      # should work if first one didnt
      if(str_sub(converted_string, start = tail(unlist(gregexpr('\\.', converted_string)), n=1)+1) == "html"){
        converted_string = sub("\\-index.html$", ".txt", urlToZipPath)
      }
      
      report_url <- paste0("https://www.sec.gov", converted_string)
      #response <- httr::HEAD(report_url)
      #print(response)
      file_name <- str_sub(converted_string, start = tail(unlist(gregexpr('/', converted_string)), n=1)+1)
      dest <- paste0(dir_name,"/",file_name)
      tryCatch(
        expr = {
          download.file(report_url, dest, mode = "wb")
         
        },
        error = function(e){
          message('Caught an error!')
          print(e)
        },
        warning = function(w){
          file_size <- file.info(dest)$size
          if (file_size == 0) {
            file.remove(dest)
          }
          converted_string2 <- sub("\\-xbrl.zip$", ".txt", report_url)
          file_name2 <- str_sub(converted_string2, start = tail(unlist(gregexpr('/', converted_string2)), n=1)+1)
          dest <- paste0(dir_name,"/",file_name2)
          download.file(converted_string2, dest, mode = "wb")
        },
        finally = {
          message('FILE DOWNLOAD COMPLETE\n')
        }
      )    
      
    }
    cat("Annual reports saved in directory:", dir_name, "\n")
  }
  return(info.df)
}

info.df <- AnnualReportsTYLERFORK("KO")

