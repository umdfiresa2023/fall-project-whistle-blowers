# Uncovering Greenwashing: A Review of Large Public Companies
Anant Agrawal, Tyler Jones, Ishaan Kalra

# <u>**Research Question**</u>

Do changes in corporate environmental action statements correlate with
their GHG emissions?

![](1.png)

# <u>**Data Querying**</u>

## A. Treatment variable:

Our treatment variable is the environmental sentiment score from a
companies annual report. To get this variable we need to first get all
the annual reports from <https://www.sec.gov/edgar/search/>, the SEC
compiles all submitted data for all public companies into this database.

### Querying for 10K Filings

### **1. Prerequisites**

1.Node.js

2.NPM (Node Packet Manager)

### **2. Import Required Modules**

``` javascript
import fs from "fs";
import sanitize from "sanitize-filename";
import puppeteer from "puppeteer-extra";
import StealthPlugin from "puppeteer-extra-plugin-stealth";
import { stripHtml } from "string-strip-html";
import { executablePath } from "puppeteer";
```

### **3. Set up Web Scraping Module**

``` javascript
puppeteer.use(StealthPlugin());
```

### **4. Setting up the Array of Companies to be scraped**

``` javascript
const companyNames = {
  // Albemarle: "ALB",
  // Mosaic: "MOS",
  // "3M": "MMM",
  // Westlake: "WLK",
  // "Air Products": "APD",
  PPG: "PPG",
  // "Exxon Mobil": "XOM",
  // Huntsman: "HUN",
  // Celanese: "CE", 
  // Honeywell: "HON",
};
```

### 5. Function to Run the Scraping Algorithm

``` javascript
async function scrapeSECWebsite() {
  const browser = await puppeteer.launch({
    headless: true,
    executablePath: executablePath(),
  });

  for (const companyName in companyNames) {
    const entityName = companyNames[companyName];
    let url = `https://www.sec.gov/edgar/search/#/q=${companyName}&dateRange=custom&category=form-cat1&entityName=${entityName.toUpperCase()}&startdt=2010-12-31&enddt=2021-12-31&filter_forms=10-K`;
    const page = await browser.newPage();
    try {
      let pageNum = 1;
      const maxPages = 3;
      while (pageNum <= maxPages) {

      url = url + '&page='+pageNum;
      await page.goto(url);
      await page.waitForTimeout(2000);

      await page.keyboard.press("Enter");

      await page.waitForTimeout(1000);

        const result = await page.evaluate(() => {
          const tableElement = document.querySelector("div#hits table.table");
          if (tableElement) {
            const tbody = tableElement.querySelector("tbody");
            if (tbody) {
              const links = Array.from(tbody.querySelectorAll("a"));
              return links.map((link) => ({
                href: link.href,
                text: link.textContent,
              }));
            } else {
              return "Tbody element not found inside the table";
            }
          } else {
            return "Table element not found";
          }
        });

        const filteredLinks = [];

        result.forEach((linkInfo) => {
          filteredLinks.push(linkInfo.href);
        });

        const yearArray = [];
        for (const href of filteredLinks) {
          if (href.includes("ex")) {
            console.log(href);
          } else {
            if (href.includes("#")) {
              const yearPattern = /\d{4}(?!10K)/;
              const matches = href.match(yearPattern);
              if (matches) {
                const year = matches[0];
                if (year != 1231 && yearArray.includes(year)) {
                  console.log(year);
                  console.log(href);
                  break;
                } else if (yearArray.length <= 12) {
                  const parts = href.split("#");
                  const selector = `a[href="#${parts[1]}"]`;
                  yearArray.push(year);
                  await page.click(selector);

                  const openFileLink = await page.$eval("a#open-file", (link) =>
                    link.getAttribute("href")
                  );
                  await page.waitForTimeout(300);

                  console.log("\n");
                  console.log("The actual link is: " + openFileLink);
                  await scrapeTextAndSaveToFile(openFileLink, year, companyName);
                  console.log("\n");

                  await page.waitForTimeout(100);
                  await page.click("button#close-modal");
                } else {
                  break;
                }
              }
            }
          }

          await page.waitForTimeout(100);
        }

        pageNum++;
      }
    } catch (error) {
      console.error("Error:", error);
    }
  }

  await browser.close();
}
```

### **6. Function to save the 10K Filings locally with a definite format**

``` javascript
async function scrapeTextAndSaveToFile(url, year, companyName) {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  try {
    const folderName =
      "/Users/ishaankalra/Documents/GitHub/fall-project-whistle-blowers/WebScraper/test" +
      companyName;

    if (!fs.existsSync(folderName)) {
      fs.mkdirSync(folderName);
    }

    await page.goto(url, { waitUntil: "networkidle2" });

    const textContent = await page.evaluate(() => {
      return document.body.textContent;
    });

    
    const sanitizedYear = sanitize(year);
    // const strippedResult = textContent.replace(/(<([^>]+)>)/gi, '');
    const strippedResult = stripHtml(textContent.toLowerCase());
    const strippedString = strippedResult.result;

    // Find and extract the fiscal year information
    const fiscalYearKeywords = ["fiscal year ended", "fiscal year"];
    let fiscalYear = null;

    for (const keyword of fiscalYearKeywords) {
      const startIndex = strippedString.indexOf(keyword);
      if (startIndex !== -1) {
        const yearMatch = strippedString
          .substr(startIndex + keyword.length)
          .match(/[0-9]{4}/);
        if (yearMatch) {
          fiscalYear = yearMatch[0];
          if (fiscalYear != null && fiscalYear === sanitizedYear) {
            fiscalYear = sanitizedYear;
          }
          break;
        }
      }
    }

    let fileName;
    if (fiscalYear) {
      fileName = `${folderName}/${fiscalYear}.txt`;
      fs.writeFileSync(fileName, strippedString, "utf-8");
      console.log(`Text content scraped and saved to ${fileName}`);
    } else if(fiscalYear === sanitizedYear){
      fileName = `${folderName}/${sanitizedYear}.txt`;
      console.log("Year same, no change need. \n");
    } else {
      console.log("Fiscal year information not found in the text.");
    }
  } catch (error) {
    console.error(`Error scraping and saving text: ${error}`);
  } finally {
    await browser.close();
  }
}
```

### **7. Run scraping function**

``` javascript
scrapeSECWebsite();
```

## B. Outcome variable:

Our outcome variable is greenhouse gas emissions from each target
chemical company.

This data is obtained from
“https://ghgdata.epa.gov/ghgp/main.do?site_preference=normal” which
reports greenhouse gases for every facility in the U.S for each year.

We transformed yearly facility emissions into total company emissions,
as shown in the R language code below.

### Querying for FLIGHT DATA 📉

### **1. Loading Required Libraries**

``` r
library(readxl)
library(finreportr)
library(R.utils)
library(tidyverse)
library(httr)
library(XBRL)
```

### **2. Function to retrieve annual GHG FLIGHT Data**

``` r
# Import FLIGHT data as excel file
dir.create("exceldata", showWarnings = FALSE)
folder <- paste0("exceldata", "/", "data")

download.file("https://ghgdata.epa.gov/ghgp/service/export?q=&tr=current&ds=E&ryr=2022&cyr=2022&lowE=-20000&highE=23000000&st=&fc=&mc=&rs=ALL&sc=0&is=11&et=&tl=&pn=undefined&ol=0&sl=0&bs=&g1=1&g2=1&g3=1&g4=1&g5=1&g6=0&g7=1&g8=1&g9=1&g10=1&g11=1&g12=1&s1=0&s2=0&s3=0&s4=0&s5=0&s6=0&s7=1&s8=0&s9=0&s10=0&s201=0&s202=0&s203=0&s204=0&s301=0&s302=0&s303=0&s304=0&s305=0&s306=0&s307=0&s401=0&s402=0&s403=0&s404=0&s405=0&s601=0&s602=0&s701=1&s702=1&s703=1&s704=1&s705=1&s706=1&s707=1&s708=1&s709=1&s710=1&s711=1&s801=0&s802=0&s803=0&s804=0&s805=0&s806=0&s807=0&s808=0&s809=0&s810=0&s901=0&s902=0&s903=0&s904=0&s905=0&s906=0&s907=0&s908=0&s909=0&s910=0&s911=0&sf=11001100&allReportingYears=yes&listExport=false", folder, mode = "wb")

excel_file_path <- "exceldata/data"
```

``` r
# Array of each sheet name
sheet_names <- excel_sheets(excel_file_path)

#Skip rows with irrelevant data
rows_to_skip <- 6  

#Filter to only the columns of data we are analyzing
columns_to_select <- c("REPORTING YEAR", "PARENT COMPANIES", "GHG QUANTITY (METRIC TONS CO2e)")  

#The excel file has a sheet for each year so we need to loop through each to get all the data and put the data into a dataframe
for (sheet in sheet_names) {
  sheet_data <- read_excel(excel_file_path, sheet = sheet, skip = rows_to_skip)
  combined_df <- bind_rows(combined_df, sheet_data)
}

# re-organized data to be emissions per year per parent company
your_dataframe <- combined_df %>%
  select(columns_to_select) %>%
  select("PARENT COMPANIES", everything()) 

# Define the target companies
search_terms <- c("PPG Industries")

#Filter the data so that it only contains the search term (target company)
#Filters out all companies were the search term substring is not found
filterframe <- your_dataframe %>%
  filter(sapply(search_terms, function(term) str_detect(`PARENT COMPANIES`, regex(term, ignore_case = TRUE))) %>% rowSums > 0) 

#Rename all the parent companies for each facility to the search term 
for (term in search_terms) {
  filterframe <- filterframe %>%
    mutate(`PARENT COMPANIES` = ifelse(
      str_detect(`PARENT COMPANIES`, regex(term, ignore_case = TRUE)),
      term,
      `PARENT COMPANIES`
    ))
}

#Combine each companies' facilities emissions together for each year
filterframe <- filterframe %>%
  group_by(`PARENT COMPANIES`, `REPORTING YEAR`) %>%
  summarize(`GHG QUANTITY (METRIC TONS CO2e)` = sum(`GHG QUANTITY (METRIC TONS CO2e)`))
```

# <u>**Data Wrangling**</u>

1.  An existing NLP model, EnvironmentalBERT-action (Schimanski et
    al. 2024) is used to classify sentences as environmental action from
    each annual report.

2.  The base NLP model output looks like {‘label’: ‘none’, ‘score’:
    0.9966304898262024}, with the label being ‘none’ or ‘environmental’
    and ‘score’ being the model’s confidence

3.  After a sentence is classified as ‘environmental’ it is then run
    through the action model to classify each environmental sentence as
    ‘action’ or ‘none’

``` python
# import standard libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline # for using the models

import spacy # for sentence extraction
from tika import parser # for the report extraction
```

``` python
#Get the path for each file to import
paths = []
for subdir, dir, files in os.walk('/content/drive/My Drive/rstudio-export'):
  for file in files:
    paths.append(os.path.join(subdir,file))
    
#Sort the array with the paths to be in alphebetical order 
paths.sort()

#Read each annual report into an array
reportsbyyear = []
for path in paths:
  reportsbyyear.append(pd.read_csv(path))
```

``` python
#Load the models

# Environmental model.
name = "ESGBERT/EnvironmentalBERT-environmental" # path to download from HuggingFace
# In simple words, the tokenizer prepares the text for the model and the model classifies the text-
tokenizer = AutoTokenizer.from_pretrained(name)
model = AutoModelForSequenceClassification.from_pretrained(name)
# The pipeline combines tokenizer and model to one process.
pipe_env = pipeline("text-classification", model=model, tokenizer=tokenizer, device=0) # set device=0 to use GPU

# Action model.
name = "ESGBERT/EnvironmentalBERT-action"
tokenizer = AutoTokenizer.from_pretrained(name)
model = AutoModelForSequenceClassification.from_pretrained(name)
pipe_act = pipeline("text-classification", model=model, tokenizer=tokenizer, device=0) # 
```

``` python
# Function that takes a report and then classifies first "environmental", then "action" on the "environmental" sentences.
def classify2(sentences, pipe_env, pipe_act):
  # Batch size helps to handle the texts in parallel. If there are "out of memory" erros, decrease the batch size.
  classifications = pipe_env(sentences, padding=True, truncation=True, batch_size=16)
  # We only want the labels, so we take the first entry of the outputed dicts.
  labels_only = [x["label"] for x in classifications]
  # Create Dataframe with sentence and label
  df = pd.DataFrame({"text": sentences, "environmental": labels_only})

  # Take only environmental sentences and classify them.
  df_env = df.loc[df["environmental"] == "environmental"].copy()
  # Batch size helps to handle the texts in parallel. If there are "out of memory" erros, decrease the batch size.
  classifications_act = pipe_act(df_env.text.to_list(), padding=True, truncation=True, batch_size=16)
  df_env["action"] = [x["label"] for x in classifications_act]

  # Combine action with all data.
  # Only take the "action" column of df_env to not have "text" and "environmental" duplicated.
  df_all = df.join(df_env[["action"]])

  return df_all
```

``` python
#Loop through each report to classify sentences and export the data to a csv file
for i in range(len(reportsbyyear)):
    dftest = classify2([x for x in reportsbyyear[i]['x'].tolist() if isinstance(x, str)         and x != "nan"],  pipe_env, pipe_act)
    dfout = pd.DataFrame(dftest[dftest["environmental"] == "environmental"])
    dfout.to_csv("Env-Action-" + paths[i].split('/')[-1].replace(' ', ''))
    print(i)
```

Some example of environmental action sentences in an annual report is:

“PPG has, and will continue to, annually report our global GHG emissions
to the voluntary Carbon Disclosure project.”

“While PPG fell short of its goal of reducing GHG emissions by 10
percent, the Company continues to work toward this long-term goal.”

“At Barberton, PPG has completed a Facility Investigation and Corrective
Measure Study under USEPA’s Resource Conservation and Recycling Act
Corrective Action Program.”

# <u>**Cleaning Data**</u>

``` r
#Create a data frame with the total sentence count per company per year

#Do this by looping through each annual report broken down into sentences and getting the number of rows and using text functions to extract the company and year

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
```

``` r
#Create a dataframe with the total action sentences per year per company

#Do this by looping through the NLP output and getting the number of 'action' rows and using text functions to extract the company and year
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
```

# <u>**Merging Data**</u>

``` r
#store the EPA FLIGHT data and fix naming convensions
flight<-filterframe %>%
  rename(year=`REPORTING YEAR`, company=`PARENT COMPANIES`) %>%
  mutate(company=ifelse(str_detect(company, "PPG"), "PPG", company)) %>%
  mutate(company=ifelse(str_detect(company, "Exxon"), "Exxon Mobil", company))

#Combine the NLP output that has number of 'action' sentences per company per year with the Input data which has the total number of sentences per company per year
dfRatio <- merge(NLPdata,Inputdata, by = c("year","company"))

#Combine flight data with sentence data
dfFINAL <- merge(dfRatio, flight, by = c("year" , "company"))

#Convert fields to numerical values and Create a field that is the ratio of action sentences divided by total sentences
dfFINAL2 <- dfFINAL %>%
  mutate(action = as.numeric(action)) %>%
  mutate(year = as.numeric(year)) %>%
  mutate(SentenceCount = as.numeric(SentenceCount)) %>%
  mutate(Ratio = action/SentenceCount) 

#Get revenue data and fix naming convensions
your_data_frame <- read.csv("company_revenue_data.csv")
revenue <-your_data_frame %>%
  rename(year=`Year`, company=`Company.Name`) %>%
  mutate(company=ifelse(str_detect(company, "PPG"), "PPG", company)) %>%
  mutate(company=ifelse(str_detect(company, "Westlake"), "Westlake", company))

#Combine revenue data with previous dataframe
dfFINAL3<-merge(dfFINAL2, revenue, by=c("year", "company"))

#These create a field that adjusts GHG emissions for company revenue 
dfFINAL5 <- dfFINAL3 %>%
  mutate(`GHGadjusted` = `GHG QUANTITY (METRIC TONS CO2e)` / Revenue) %>%
  mutate(GHGadjusted = ifelse(company %in% c("Exxon Mobil"),GHGadjusted*50,GHGadjusted))  %>%
  mutate(Ratio = ifelse(company %in% c("Westlake"),Ratio*10,Ratio)) 

dfFINAL6 <- dfFINAL3 %>%
  mutate(`GHGadjusted` = `GHG QUANTITY (METRIC TONS CO2e)` / Revenue) 
```

# <u>**Preliminary Results**</u>

Upon consolidating all the data, we can uncover the subtle nuances in
how a company, has changed over the years in terms of its sentiment
towards the environment. This provides a window into the company’s
commitment to sustainable practices by comparing changes in
environmental action claim prevalence to emissions adjusted for revenue
over the years.

The provided code creates a visual analysis for each company, comparing
greenhouse gas (GHG) emissions per revenue with the company’s
environmental action ratio. This approach offers a nuanced view of each
company’s environmental impact and sustainability commitment.

``` r
#Create a line plot of Action ratio vs GHG/Revenue per year
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
  scale_x_continuous(breaks = seq(min(dfFINAL5$year), max(dfFINAL5$year), by = 1)) +
  facet_wrap( ~ company, scales = "free_y",  ncol = 2)+
  theme_bw(base_size=10)

#Create a scatter plot showing Action Ration vs GHG/Revenue
my_plot_REVscatter <- ggplot(dfFINAL6, aes(x = Ratio,y = `GHGadjusted`)) +
  geom_point(aes(y = `GHGadjusted`, color = company), size=5) +
  labs(x = "Action Ratio", y= "GHG/Revenue" ,title = "GHG/Revenue vs Action Ratio") +
  ylim(0,0.0008) +
  geom_smooth(method="lm")+
  theme_bw(base_size=28)
```

![![](my_plot_REVscatter.png)](my_plot_REV2%20.png)

There is no direct correlation between GHG/revenue and environmental
action ratio that can be observed in our data. A regression with a year
trend and company fixed effects, showed a weak positive correlation
between GHG/revenue and environmental action ratio. Given the weak
correlation there is no conclusive evidence given the data that we have.
However, this research question is important to policymakers,
shareholders, and the general public because the answer would inform
them which companies deserve praise for their efforts in lowering their
negative impacts and which companies are capitalizing on the movement
without doing anything
