write.csv(filterframe, "flight_data.csv", row.names = F)

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


your_data_frame <- read.csv("company_revenue_data.csv")


revenue <-your_data_frame %>%
  rename(year=`Year`, company=`Company.Name`) %>%
  mutate(company=ifelse(str_detect(company, "PPG"), "PPG", company)) %>%
  mutate(company=ifelse(str_detect(company, "Westlake"), "Westlake", company))


dfFINAL3<-merge(dfFINAL2, revenue, by=c("year", "company"))
     

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
  scale_x_continuous(breaks = seq(min(dfFINAL5$year), max(dfFINAL5$year), by = 1)) +
  facet_wrap( ~ company, scales = "free_y",  ncol = 2)+
  theme_bw(base_size=10)


my_plot_REV2 
ggsave("my_plot_REV2 .png", plot = my_plot_REV2 , width = 12, height = 6, units = "in", dpi = 900)


my_plot_REVscatter <- ggplot(dfFINAL6, aes(x = Ratio,y = `GHGadjusted`)) +
  geom_point(aes(y = `GHGadjusted`, color = company), size=5) +
  labs(x = "Action Ratio", y= "GHG/Revenue" ,title = "GHG/Revenue vs Action Ratio") +
  ylim(0,0.0008) +
  geom_smooth(method="lm")+
  theme_bw(base_size=28)

my_plot_REVscatter 

ggsave("my_plot_REVscatter.png", my_plot_REVscatter,width = 16, height = 12, units = "in", dpi = 900)




