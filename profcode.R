write.csv(results_df, "10k_esg.csv", row.names=F)

write.csv(filterframe, "flight_data.csv", row.names = F)

esg<-results_df %>%
  mutate(company=str_remove(PARENT.COMPANIES, "test")) %>%
  rename(year=REPORTING.YEAR)

flight<-filterframe %>%
  rename(year=`REPORTING YEAR`, company=`PARENT COMPANIES`) %>%
  mutate(company=ifelse(str_detect(company, "PPG"), "PPG", company)) %>%
  mutate(company=ifelse(str_detect(company, "Exxon"), "Exxon Mobil", company))




dfRatio <- merge(NLPdata,Inputdata, by = c("year","company"))

dfFINAL <- merge(dfRatio, flight, by = c("year" , "company"))

dfFINAL2 <- dfFINAL %>%
  mutate(action = as.numeric(action)) %>%
  mutate(year = as.numeric(year)) %>%
  mutate(SentenceCount = as.numeric(SentenceCount)) %>%
  mutate(Ratio = action/SentenceCount) 



####################### OLDDDD
#df<-merge(esg, flight, by=c("year", "company"))
#table(df$company)

#write.csv(df, "final_6.csv", row.names=F)

your_data_frame <- read.csv("company_revenue_data.csv")


revenue <-your_data_frame %>%
  rename(year=`Year`, company=`Company.Name`) %>%
  mutate(company=ifelse(str_detect(company, "PPG"), "PPG", company)) %>%
  mutate(company=ifelse(str_detect(company, "Westlake"), "Westlake", company))


dfFINAL3<-merge(dfFINAL2, revenue, by=c("year", "company"))
      #%>% mutate(ESG_Score = ifelse(is.nan(ESG_Score), 0, ESG_Score))

  

#df <- subset(df, select = -PARENT.COMPANIES)
#write.csv(df, "final6rev.csv", row.names=F)

dfFINAL4 <- dfFINAL3 %>%
  mutate(`GHGadjusted` = `GHG QUANTITY (METRIC TONS CO2e)` / Revenue) %>%
  #old why 1000? mutate(`GHG QUANTITY (METRIC TONS CO2e)` = `GHG QUANTITY (METRIC TONS CO2e)` / Revenue * 1000) 
  filter(company =="Westlake")
  



my_plot_GHG <- ggplot(dfFINAL4, aes(x = year)) +
  geom_line(aes(y = `GHG QUANTITY (METRIC TONS CO2e)`), color = "blue") +
  geom_point(aes(y = `GHG QUANTITY (METRIC TONS CO2e)`), color = "blue") +
  
  geom_line(aes(y = Ratio*1000000000), color = "red") +  
  labs(x = "Year", title = "GHG vs ESG Index (Westlake Chemical)") +
  scale_y_continuous(
    name = "GHG Quantity (Blue)",
    sec.axis = sec_axis(~./10000000000, name = "ESG Index (Red)")
  ) + 
  scale_x_continuous(breaks = seq(min(dfFINAL4$year), max(dfFINAL4$year), by = 1)) 


my_plot_REV <- ggplot(dfFINAL4, aes(x = year)) +
  geom_line(aes(y = `GHGadjusted`), color = "blue") +
  geom_point(aes(y = `GHGadjusted`), color = "blue") +
  
  geom_line(aes(y = Ratio/10), color = "red") +  
  labs(x = "Year", title = "GHG/Revenue vs ESG Index (Westlake Chemical)") +
  scale_y_continuous(
    name = "GHG Quantity / Revenue (Blue)",
    sec.axis = sec_axis(~./1, name = "ESG Index (Red)")
  ) + 
  scale_x_continuous(breaks = seq(min(dfFINAL4$year), max(dfFINAL4$year), by = 1)) 



my_plot_GHG
my_plot_REV
ggsave("my_plot.png", plot = my_plot, width = 12, height = 6, units = "in", dpi = 300)


dfFINAL5 <- dfFINAL3 %>%
  mutate(`GHGadjusted` = `GHG QUANTITY (METRIC TONS CO2e)` / Revenue) %>%
  mutate(GHGadjusted = ifelse(company %in% c("Exxon Mobil"),GHGadjusted*50,GHGadjusted))  %>%
  mutate(Ratio = ifelse(company %in% c("Westlake"),Ratio*10,Ratio)) 

dfFINAL6 <- dfFINAL3 %>%
  mutate(`GHGadjusted` = `GHG QUANTITY (METRIC TONS CO2e)` / Revenue) 

  
my_plot_REV2 <- ggplot(dfFINAL5, aes(x = year)) +
  geom_line(aes(y = `GHGadjusted`, color = "GHG/Revenue")) +
  geom_point(aes(y = `GHGadjusted`, color = "GHG/Revenue")) +
  
  geom_line(aes(y = Ratio/100, color = "Action Ratio")) + 
  geom_point(aes(y = Ratio/100, color = "Action Ratio")) + 
  labs(x = "Year", title = "GHG/Revenue vs Action Ratio per Year per Company") +
  scale_y_continuous(
    name = "GHG Quantity / Revenue (Blue)",
    label = scales::scientific,
    sec.axis = sec_axis(~./1, name = "Action Ratio (Red)", label = scales::scientific) )+ 
  scale_x_continuous(breaks = seq(min(dfFINAL4$year), max(dfFINAL4$year), by = 1)) +
  facet_wrap( ~ company, scales = "free_y",  ncol = 2)+
  theme_bw(base_size=10)


my_plot_REV2 
ggsave("my_plot_REV2 .png", plot = my_plot_REV2 , width = 12, height = 6, units = "in", dpi = 900)


my_plot_GHG2 <- ggplot(dfFINAL7, aes(x = year)) +
  geom_line(aes(y = `GHG QUANTITY (METRIC TONS CO2e)`), color = "blue") +
  geom_point(aes(y = `GHG QUANTITY (METRIC TONS CO2e)`), color = "blue") +
  
  geom_line(aes(y = Ratio*1000000000), color = "red") +  
  labs(x = "Year", title = "GHG/Revenue vs ESG Index") +
  scale_y_continuous(
    name = "GHG Quantity / Revenue (Blue)",
    sec.axis = sec_axis(~./10000000000, name = "ESG Index (Red)")
  ) + 
  scale_x_continuous(breaks = seq(min(dfFINAL4$year), max(dfFINAL4$year), by = 1)) +
  facet_wrap( ~ company, scales = "free_y",  ncol = 2)


my_plot_GHG2 


my_plot_REVscatter <- ggplot(dfFINAL6, aes(x = Ratio,y = `GHGadjusted`)) +
  geom_point(aes(y = `GHGadjusted`, color = company), size=5) +
  labs(x = "Action Ratio", y= "GHG/Revenue" ,title = "GHG/Revenue vs Action Ratio") +
  ylim(0,0.0008) +
  geom_smooth(method="lm")+
  theme_bw(base_size=28)

my_plot_REVscatter 

summary(m1<-lm(GHGadjusted ~ Ratio + as.factor(company) + year, data=dfFINAL6))
  


my_plot_REVscatter 
ggsave("my_plot_REVscatter.png", my_plot_REVscatter,width = 16, height = 12, units = "in", dpi = 900)
















##########################################
######################################
my_plot <- ggplot(dfFINAL4, aes(x = year)) +
  # First y-axis: GHG QUANTITY
  geom_line(aes(y = `GHG QUANTITY (METRIC TONS CO2e)`), color = "blue") +
  geom_point(aes(y = `GHG QUANTITY (METRIC TONS CO2e)`), color = "blue") +
  
  labs(y = "GHG Quantity  / Revenue", x = "Year") +
  
  #Second y-axis: ESG_Score   geom_line(aes(y = `ESG_Score` * 10000000), color = "red") +
  
  geom_line(aes(y = Ratio), color = "red") +
  
  labs(y = "ESG Index",  title = "GHG/Revenue vs ESG Index (Westlake Chemical)") +
  
  scale_y_continuous(
    name = "GHG Quantity / Revenue (BLUE)",
    
    sec.axis = sec_axis(~./ 10, name = "ESG Index (RED)")
  ) 


my_plot

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

count <- 0
downfail <- 0
rev_df  <- data.frame()
rev_df <- data.frame(`REPORTING YEAR` = numeric(), `ESG_Score` = numeric(), `PARENT COMPANIES`= character())
rev_year <- c(2017,2018,2019,2020, 2021)

#removed "DOW" 2012,2013, 2014,2015,2016,
tiks <- c( "WLK", "OXY","MOS","ALB", "APD", "PPG", "XOM","HUN","CE", "HON")
real_names <- c("Westlake", "Occidental Petroleum","Mosaic","Albemarle", "Air Products", "PPG Industries", "Exxon","Huntsman","Celanese", "Honeywell")

for (ticker in tiks) {
  count <- count + 1
  for (year in rev_year) {
    
    downfail <- 0
    x <- GetURL(ticker, year)
    #download.file(x,"datastatement.xlsx", mode = "wb")
    
    tryCatch(
      expr = {
        download.file(x,"datastatement.xlsx", mode = "wb")
        
      },
      error = function(e){
        message('Caught an error!')
        print(e)
      },
      warning = function(w){
        file_size <- file.info("datastatement.xlsx")$size
        if (file_size == 0) {
          file.remove("datastatement.xlsx")
        }
        x <- str_sub(x, end = -2)
        downfail <<- 1
        download.file(x,"datastatement.xls", mode = "wb")
        
      },
      finally = {
        message('FILE DOWNLOAD COMPLETE\n')
      }
    )    
    
    if(downfail == 0) {
      sheet_names2 <- excel_sheets("datastatement.xlsx")
    } else {
      print("namefailed")
      workbook <- loadWorkbook("datastatement.xls")
      sheet_names2 <- getSheets(workbook)
    }
    
    patterns <- c("Consolidated Statements Of Oper", "Consolidated Statement Of Opera"
                  ,"Consolidated Statement of Incom", "CONSOLIDATED STATEMENTS OF INCO",
                  "Consolidated_Statements_Of_Oper", "Consolidated_Statement_Of_Opera"
                  ,"Consolidated_Statement_of_Incom", "CONSOLIDATED_STATEMENTS_OF_INCO")
    
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
      if(downfail == 0) {
        xxxx<- read_excel("datastatement.xlsx", sheet_names2[pagecounter], skip = 2)
      } else {
        print("dffailed")
        xxxx <- readWorksheet(workbook, sheet_names2[pagecounter], 3)
        
      }
      dfexecl <- bind_rows(dfexecl, xxxx)
      
      first_net_sales <- dfexecl[1,2] 
      
      if (!is.numeric(first_net_sales)) {
        first_net_sales <- dfexecl[1,3] 
      }
      
      first_net_sales <- first_net_sales *1000000
    } else {
      print("excel page not found")
    }
    
    rev_df <- rbind(rev_df, data.frame(`REPORTING YEAR` = year - 1, `Revenue` = first_net_sales,
                                       `PARENT COMPANIES`= real_names[count]))
  }
}


y <- GetURL("GOOG", 2017)
print(y)



################
#real_names <- c("Westlake", "Occidental Petroleum","Mosaic","Albemarle", "Air Products", "PPG Industries", "Exxon","Huntsman","Celanese", "Honeywell")
website_names <- c("Westlake", "Occidental Petroleum","Mosaic","Albemarle", "Air Products", "PPG Industries", "Exxon","Huntsman","Celanese", "Honeywell")

filings <- xml2::read_html("https://companiesmarketcap.com/walmart/revenue/")

