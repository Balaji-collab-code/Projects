
library(readxl)

library(fPortfolio)
library("quantmod")
library("PerformanceAnalytics")
library("ggplot2")
library(zoo)
library(timeSeries)

library(writexl)
library(tidyverse)
library(dplyr)


setwd("D:/MBA 2nd Year/Advanced Financial Analytics")

#### Extracting from Excel File

tensec <- read_excel("AFA-1.xlsx")
tensec_prices <- read_excel("AFA-1.xlsx",sheet=1,range="b3:l742")
head(tensec_prices)
class(tensec_prices)


sec_prices <- as.data.frame(tensec_prices)
head(sec_prices)
class(sec_prices)
sec_prices$Date

head(sec_prices)
class(sec_prices)

row.names(sec_prices) <- sec_prices$Date
head(sec_prices)
sec_prices[1:11]


sec_prices1 <- sec_prices[c(2:11)]
sec_prices2 <- as.zoo(sec_prices1)
sec_prices3 <- as.timeSeries(sec_prices2)
head(sec_prices3)
class(sec_prices3)



portfolio1 <- Return.calculate(sec_prices3,method = 'discrete')
head(portfolio1)

portfolio1<- na.omit(portfolio1)




efficient_frontier <- portfolioFrontier(portfolio1, `setRiskFreeRate<-`(portfolioSpec(),.07/252),constraints = "LongOnly")
plot(efficient_frontier,c(1,2,3,4,5,8))

cov((portfolio1))

mean(portfolio1)

min_var_portfolio <- minvariancePortfolio(portfolio1, portfolioSpec(),constraints = "longonly")
wts_min_var_portfolio <- getWeights(min_var_portfolio)

optimum_portfolio <- tangencyPortfolio(portfolio1, `setRiskFreeRate<-`(portfolioSpec(),.07/252), constraints = "longonly")
wts_optimal_portfolio <- getWeights(optimum_portfolio)

### Single Stock Loading

ultracem <- getSymbols("ULTRACEMCO.NS",from = "2021-07-31", to = "2024-07-31",auto.assign = FALSE)
divislab <- getSymbols("DIVISLAB.NS",from = "2021-07-31", to = "2024-07-31",auto.assign = FALSE)
jswsteel <- getSymbols("JSWSTEEL.NS",from = "2021-07-31", to = "2024-07-31",auto.assign = FALSE)
hdfclife <- getSymbols("HDFCLIFE.NS",from = "2021-07-31", to = "2024-07-31",auto.assign = FALSE)
techm <- getSymbols("TECHM.NS",from = "2021-07-31", to = "2024-07-31",auto.assign = FALSE)
tcs <- getSymbols("TCS.NS",from = "2021-07-31", to = "2024-07-31",auto.assign = FALSE)
eichermot <- getSymbols("EICHERMOT.NS",from = "2021-07-31", to = "2024-07-31",auto.assign = FALSE)
britannia <- getSymbols("BRITANNIA.NS",from = "2021-07-31", to = "2024-07-31",auto.assign = FALSE)
adaniports <- getSymbols("ADANIPORTS.NS",from = "2021-07-31", to = "2024-07-31",auto.assign = FALSE)
grasim <- getSymbols("GRASIM.NS",from = "2021-07-31", to = "2024-07-31",auto.assign = FALSE)


ultracem <- Ad(ultracem)
divislab <- Ad(divislab)
jswsteel <- Ad(jswsteel)
hdfclife <- Ad(hdfclife)
techm <- Ad(techm)
tcs <- Ad(tcs)
eichermot <- Ad(eichermot)
britannia <- Ad(britannia)
adaniports <- Ad(adaniports)
grasim <- Ad(grasim)

ultracem <- na.locf(ultracem)
divislab <- na.locf(divislab)
jswsteel <- na.locf(jswsteel)
hdfclife <- na.locf(hdfclife)
techm <- na.locf(techm)
tcs <- na.locf(tcs)
eichermot <- na.locf(eichermot)
britannia <- na.locf(britannia)
adaniports <- na.locf(adaniports)
grasim <- na.locf(grasim)

ten_stks <- merge.xts(ultracem,divislab,jswsteel,hdfclife,techm,tcs,eichermot,britannia,adaniports,grasim)
head(ten_stks)
class(ten_stks)
ten_stks_df <- as.data.frame(ten_stks)

write_xlsx(ten_stks_df,"ten_stocks.xlsx")
ten_stks_df$Date <- row.names(ten_stks_df)
head(ten_stks_df)
row.names(ten_stks_df)
ten_stks_df <- relocate(ten_stks_df,Date,.before = "ULTRACEMCO.NS.Adjusted")
write_xlsx(ten_stks_df,"ten_stocks.xlsx")

ten_stk_return <- Return.calculate(ten_stks,method='discrete')

ten_stk_return <- na.omit(ten_stk_return)
class(ten_stk_return)
ten_stk_return <- as.timeSeries(ten_stk_return)
class(ten_stk_return)
ten_stk_return_pf <- Return.portfolio(ten_stk_return, weights = c(.1,.1,.1,.1,.1,.1,.1,.1,.1,.1),geometric = FALSE)
view(ten_stk_return_pf)

mean(ten_stk_return_pf)
var_cov <- cov(ten_stk_return)
sd(ten_stk_return_pf)

efficient_frontier1 <- portfolioFrontier(ten_stk_return, `setRiskFreeRate<-`(portfolioSpec(),.07/252),constraints = "longonly")
plot(efficient_frontier1,c(1,2,3,4,5,8))

### Bulk Loading

symbols = c("ULTRACEMCO.NS","DIVISLAB.NS","JSWSTEEL.NS","HDFCLIFE.NS","TECHM.NS","TCS.NS","EICHERMOT.NS","BRITANNIA.NS","ADANIPORTS.NS","GRASIM.NS")
portfolio_stk <- lapply(symbols,function(X){
  getSymbols(X,from = "2021-07-31",to = "2024-07-31",auto.assign = FALSE)
})
head(portfolio_stk)
class(portfolio_stk)

portfolio_stk_df <- as.data.frame(portfolio_stk)

class(portfolio_stk_df)

portfolio_stk_df <- Ad(portfolio_stk_df)
head(portfolio_stk_df)

portfolio_stk_df <- as.timeSeries(portfolio_stk_df)
class(portfolio_stk_df)
portfolio_stk_ret <- Return.calculate(portfolio_stk_df)
head(portfolio_stk_ret)
portfolio_stk_ret <- na.omit(portfolio_stk_ret)
portfolio_stk_ret_pf <- Return.portfolio(portfolio_stk_ret,c(.1,.1,.1,.1,.1,.1,.1,.1,.1,.1),geometric = FALSE)
head(portfolio_stk_ret_pf)
mean(portfolio_stk_ret_pf)
var_cov1 <- cov(portfolio_stk_ret)
sd(portfolio_stk_ret_pf)
efficient_frontier2 <- portfolioFrontier(portfolio_stk_ret, `setRiskFreeRate<-`(portfolioSpec(),.07/252),constraints = "longonly")
plot(efficient_frontier2,c(1,2,3,4,5,7,8))


