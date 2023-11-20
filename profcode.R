write.csv(results_df, "10k_esg.csv", row.names=F)

write.csv(filterframe, "flight_data.csv", row.names = F)

esg<-results_df %>%
  mutate(company=str_remove(PARENT.COMPANIES, "test")) %>%
  rename(year=REPORTING.YEAR)

flight<-filterframe %>%
  rename(year=`REPORTING YEAR`, company=`PARENT COMPANIES`) %>%
  mutate(company=ifelse(str_detect(company, "PPG"), "PPG", company)) %>%
  mutate(company=ifelse(str_detect(company, "Exxon"), "Exxon Mobil", company))

df<-merge(esg, flight, by=c("year", "company"))
table(df$company)

write.csv(df, "final_6.csv", row.names=F)


#my code for rev
#download.file("https://www.sec.gov/Archives/edgar/data/79879/000007987921000008/Financial_Report.xlsx","datastatement", mode = "wb")
#sheet_names2 <- excel_sheets("datastatement")
#dfexecl <- data.frame()
#xxxx<- read_excel("datastatement", sheet_names2[2], skip = 2)
#dfexecl <- bind_rows(dfexecl, xxxx)
#first_net_sales <- dfexecl[1,2] * 1000000


head(GetIncome("XOM", 2020))

ReportPeriod <- function(symbol, CIK, accession.no, accession.no.raw) {
  
  url <- paste0("https://www.sec.gov/Archives/edgar/data/", CIK, "/", 
                accession.no, "/", accession.no.raw, "-index.htm")
  search.result <- xml2::read_html(url)
  
  ##   Generic function to extract info
  ExtractInfo <- function(html.node) {
    info <-
      search.result %>%
      rvest::html_nodes(html.node) %>%
      rvest::html_text()
    return(info)
  }
  
  report.period <- ExtractInfo(".formGrouping+ .formGrouping .info:nth-child(2)")
  return(report.period)
}

GetAccessionNo <- function(symbol, year, foreign = FALSE) {
  
  ##   This is here to please R CMD check
  filing.year <- NULL
  filing.name <- NULL
  accession.no <- NULL
  
  year.char <- as.character(year)
  
  reports.df <- AnnualReports(symbol, foreign)
  reports.df <-
    mutate(reports.df, filing.year = substr(reports.df$filing.date,1,4) ) %>%
    filter(filing.year == year.char) %>%
    filter(filing.name == "10-K" | filing.name == "20-F")
  
  accession.no.raw <-
    select(reports.df, accession.no) %>%
    as.character()
  
  ##   Error message for function
  if(accession.no.raw == "character(0)") {
    stop("no filings available for given year")
  }
  
  return(accession.no.raw)
}

GetURL <- function(symbol, year) {
  
  lower.symbol <- tolower(symbol)
  
  accession.no.raw <- GetAccessionNo(symbol, year, foreign = FALSE)
  accession.no <- gsub("-", "" , accession.no.raw)
  
  CIK <- CompanyInfo(symbol)
  CIK <- as.numeric(CIK$CIK)
  
  report.period <- ReportPeriod(symbol, CIK, accession.no, accession.no.raw)
  report.period <- gsub("-", "" , report.period)
  
  inst.url <- paste0("https://www.sec.gov/Archives/edgar/data/", CIK, "/", 
                     accession.no, "/Financial_Report.xlsx")
  return(inst.url)
}

x <- GetURL("WLK", 2020)
download.file(x,"datastatement.xlsx", mode = "wb")
sheet_names2 <- excel_sheets("datastatement.xlsx")
patterns <- c("Consolidated Statements Of Oper", "Consolidated Statement Of Opera"
              ,"Consolidated Statement of Incom", "CONSOLIDATED STATEMENTS OF INCO")

pagecounter <- 1
boltest <- FALSE
for (sheet2 in sheet_names2) {
  if(any(str_detect(sheet2, regex(patterns, ignore_case = TRUE)))){
    boltest <- TRUE
    break
  }
  pagecounter <- pagecounter + 1
}
if(boltest){ 
  
  dfexecl <- data.frame()
  xxxx<- read_excel("datastatement.xlsx", sheet_names2[pagecounter], skip = 2)
  dfexecl <- bind_rows(dfexecl, xxxx)
  
  first_net_sales <- dfexecl[1,2] 
  if (is.numeric(first_net_sales)) {
    
  } else if (is.character(first_net_sales)) {
    first_net_sales <- dfexecl[1,3] 
  } else {
    first_net_sales <- dfexecl[1,3] 
  }
  
  first_net_sales <- first_net_sales *1000000
} else {
  print("excel page not found")
}

