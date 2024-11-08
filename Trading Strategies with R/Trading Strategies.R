#Trading Strategies
#Using EMA
ema_fx <- function(symbol, n1, n2){
  library(quantmod)
  library(fPortfolio)
  library(PerformanceAnalytics)
  library(dplyr)
  
  stock <- getSymbols(symbol,from = "2020-01-04",auto.assign = FALSE)
  stock <- na.locf(stock)
  
  ema_n1 <- EMA(Ad(stock),n1)
  ema_n2 <- EMA(Ad(stock),n2)
  
  ema_trading_signal <- lag(ifelse(ema_n1>ema_n2 & lag(ema_n1)<lag(ema_n2),1,ifelse(ema_n1<ema_n2 & lag(ema_n1)>lag(ema_n2),-1,0)))
  ema_trading_signal[is.na(ema_trading_signal)] <- 0
  ema_trading_position <- 0L
  changeover <- 0L
  for (i in 1:nrow(stock)) {
    if (ema_trading_signal[i]==1){
      ema_trading_position[i] <- 1
      changeover=1
    }else if(ema_trading_signal[i]==-1){
      ema_trading_position[i] <- 0
      changeover=0
    }else{ema_trading_position[i]=changeover}
    
  }
  daily_return <- Return.calculate(Ad(stock),method = "discrete")
  daily_return[is.na(daily_return)] <- 0
  strategy_return <- ema_trading_position*daily_return
  cum_daily_return <- cumprod(1+daily_return)-1
  cum_strategy_ret <- cumprod(1+strategy_return)-1
#to display final cumulative returns here 
  cat("The cumulative daily return: ",tail(cum_daily_return,1),"\n")
  cat("EMA cumulative strategy return: ", tail(cum_strategy_ret,1),"\n")


}



#Using MACD
macd_fx <- function(symbol){
  library(quantmod)
  library(fPortfolio)
  library(PerformanceAnalytics)
  library(dplyr)
  
  stock <- getSymbols(symbol,from = "2020-01-04",auto.assign = FALSE)
  stock <- na.locf(stock)
  
  fx <- MACD(Ad(stock),nFast = 12,nSlow = 26,nSig = 9,percent = FALSE )
  macd <- fx[,1]
  signal <- fx[,2]
  
  macd_trading_signal <- lag(ifelse(macd>signal & lag(macd)<lag(signal),1,ifelse(macd<signal & lag(macd)>lag(signal),-1,0)))
  macd_trading_signal[is.na(macd_trading_signal)] <- 0
  macd_trading_position <- 0L
  changeover <- 0L
  for (i in 1:nrow(stock)) {
    if (macd_trading_signal[i]==1){
      macd_trading_position[i] <- 1
      changeover=1
    }else if(macd_trading_signal[i]==-1){
      macd_trading_position[i] <- 0
      changeover=0
    }else{macd_trading_position[i]=changeover}
    
  }
  daily_return <- Return.calculate(Ad(stock),method = "discrete")
  daily_return[is.na(daily_return)] <- 0
  strategy_return <- macd_trading_position*daily_return
  cum_daily_return <- cumprod(1+daily_return)-1
  cum_strategy_ret <- cumprod(1+strategy_return)-1
  #to display final cumulative returns here 
  cat("The cumulative daily return: ",tail(cum_daily_return,1),"\n")
  cat("MACD cumulative strategy return: ", tail(cum_strategy_ret,1),"\n")
  
  
  
}


#Using SMI

smi_fx <- function(symbol){
  library(quantmod)
  library(fPortfolio)
  library(PerformanceAnalytics)
  library(dplyr)
  
  stock <- getSymbols(symbol,from = "2020-01-04",auto.assign = FALSE)
  stock <- na.locf(stock)
  hlc <- HLC(stock)
  fx <- SMI(hlc,13,2,25,9)
  smi <- fx[,1]
  signal <- fx[,2]
  
  smi_trading_signal <- lag(ifelse(smi>signal & lag(smi)<lag(signal),1,ifelse(smi<signal & lag(smi)>lag(signal),-1,0)))
  smi_trading_signal[is.na(smi_trading_signal)] <- 0
  smi_trading_position <- 0L
  changeover <- 0L
  for (i in 1:nrow(stock)) {
    if (smi_trading_signal[i]==1){
      smi_trading_position[i] <- 1
      changeover=1
    }else if(smi_trading_signal[i]==-1){
      smi_trading_position[i] <- 0
      changeover=0
    }else{smi_trading_position[i]=changeover}
    
  }
  daily_return <- Return.calculate(Ad(stock),method = "discrete")
  daily_return[is.na(daily_return)] <- 0
  strategy_return <- smi_trading_position*daily_return
  cum_daily_return <- cumprod(1+daily_return)-1
  cum_strategy_ret <- cumprod(1+strategy_return)-1
  #to display final cumulative returns here 
  cat("The cumulative daily return: ",tail(cum_daily_return,1),"\n")
  cat("Smi cumulative strategy return: ", tail(cum_strategy_ret,1),"\n")
  
  
  
}


#Using RSI

rsi_fx <- function(symbol){
  library(quantmod)
  library(fPortfolio)
  library(PerformanceAnalytics)
  library(dplyr)
  
  stock <- getSymbols(symbol,from = "2020-01-04",auto.assign = FALSE)
  stock <- na.locf(stock)
  rsi <- RSI(Ad(stock),14)
  rsi[is.na(rsi)] <- 0
  
  rsi_trading_signal <- lag(ifelse(rsi<30,1,ifelse((rsi>70),-1,0)))
  rsi_trading_signal[1:15] <- 0
  rsi_trading_signal[is.na(rsi_trading_signal)] <- 0
  rsi_trading_position <- 0L
  changeover <- 0L
  for (i in 1:nrow(stock)) {
    if (rsi_trading_signal[i]==1){
      rsi_trading_position[i] <- 1
      changeover=1
    }else if(rsi_trading_signal[i]==-1){
      rsi_trading_position[i] <- 0
      changeover=0
    }else{rsi_trading_position[i]=changeover}
    
  }
  daily_return <- Return.calculate(Ad(stock),method = "discrete")
  daily_return[is.na(daily_return)] <- 0
  strategy_return <- rsi_trading_position*daily_return
  cum_daily_return <- cumprod(1+daily_return)-1
  cum_strategy_ret <- cumprod(1+strategy_return)-1
  #to display final cumulative returns here 
  cat("The cumulative daily return: ",tail(cum_daily_return,1),"\n")
  cat("Rsi cumulative strategy return: ", tail(cum_strategy_ret,1),"\n")
  
}



#Using the switch 
Result <- function(indic_choice){
  The_result <- switch (as.character(indic_choice),
      "1"={ema_fx(symbol,5,21)},
      "2"={macd_fx(symbol)},
      "3"={smi_fx(symbol)},
      "4"={rsi_fx(symbol)},
      stop("Invalid indicator choice"))
  return(The_result)
}


for (i in 1) {
  print("Please enter the Stock name as in Yahoo finance")
  symbol <- scan(what ="" )
  print("Enter indicator choice")
  print("1 as EMA strategy with shorter period as 5 and longer period as 21") 
  print("2 as MACD strategy")
  print("3 as SMI strategy")
  print("4 as RSI strategy")
  strategy = scan(what = double())
  Result(strategy)
  
}




