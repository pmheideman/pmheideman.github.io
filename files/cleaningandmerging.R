rm(list=ls()) #clears the workspace of all objects

library(tidyverse) #always
library(devtools) #because we need to install a package from github

install_github("jamesmartherus/anesr") #Install a package from github
#Note: you only ever need to install a package once. So in the future if you run this code, you can delete this line, and the call to load devtools as well, since the only reason to do that is to install the package from github.


library(anesr)


#Getting the CSPP data
df.cspp <- read.csv("https://ippsr.msu.edu/sites/default/files/correlatesofstatepolicyprojectv2_2.csv") %>%
  as_tibble()

#Loading the ANES data

data(timeseries_cum) #Load the cumulative (1948-2016) ANES dataset


#Processing data for merging


#The ANES uses totally non-descriptive variable names, so I'm going to select the ones I want and rename them.

timeseries_cum %>%
  select(year = VCF0004,
         state = VCF0901b,
         big.bus = VCF0209) -> df.anes.processed

#write.csv(df.anes.processed, file = "~/Downloads/anes2merge.csv")
#The above line of code is commented out, so it won't run. But it's what I used to make the .csv file.



#Also going to select only the data I want from df.cspp

df.cspp %>%
  select(year,
         state = st,
         right2work) %>% #In CSPP, state abbreviations are in the variable st. I'm going to rename it state so it has the same variable name as my other dataset.
  mutate(right2work = case_when(is.na(right2work)==TRUE ~ 0, #I have to recode right2work because the morons who put this dataset together for LIS gave us a variable in which RTW states are coded 1, and non-RTW states are coded NA! MADNESS!!! If you spend any time working with data, you WILL run into this kind of insanity that you will then have to figure out how to fix.
                         TRUE ~ 1)) -> df.cspp.processed 

#write.csv(df.cspp.processed, file="~/Downloads/cspp2merge.csv")

#Now I'm ready to join them.

inner_join(df.cspp.processed, df.anes.processed, by=c("state", "year")) %>%
  filter(is.na(big.bus)==FALSE)-> df.pref #I dropped all observations missing data for big.bus

# Now I have a dataset with about 58,000 observations. Each observation represents a survey respondent.
# For each respondent, I have their state, the year of the survey, their feeling thermometer about big business, and whether their state is right to work.

#Making the Pivot Table

df.pref %>%
  group_by(year, right2work) %>%
  summarise(avg.therm = mean(big.bus)) -> my.pivot.table
