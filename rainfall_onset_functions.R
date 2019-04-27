#install.packages("magrittr"); #install.packages("zoo")

`%>%` = magrittr::`%>%`

CDD <- function(a)
  {      
  
  a <- as.numeric(a)
  a[a >= 1] <- 1
  a[a < 1] <- 0 
  CDD <- suppressWarnings(max((!a) * unlist(lapply(rle(a)$lengths, seq_len)), na.rm = T))
  if (CDD == -Inf){CDD <- NA}
  return(CDD)
  
  }

not_29 <- function(zoo_ts)
  {
  
  zoo_ts[format(time(zoo_ts), "%m-%d") == "02-29"] = NA
  zoo_ts[complete.cases(zoo_ts)]
  
  }

dClim <- function(zoo_ts)
  {
  
  zoo_ts[1:365] %>% time %>% format("%m-%d") %>%
    sapply(function(z) zoo_ts[format(time(zoo_ts), "%m-%d") %in% z] %>% mean )
  
  }

wSeason <- function(zoo_ts, wInd = 30)
  {
  
  zoo_ts <- not_29(zoo_ts)
  d_clim <- dClim(zoo_ts)
  R_ave <- mean(zoo_ts)
  d <- cumsum(d_clim - R_ave)
  i_wet <- zoo_ts[match(min(d), d)] %>% time() - wInd
  f_wet <- zoo_ts[match(max(d), d)] %>% time() + wInd + 365
  return(list(d = d, i_wet = i_wet, f_wet = f_wet, zoo_ts = zoo_ts, R_ave = R_ave))
  
  }

onSet <- function(zoo_ts, iY = "1981", fY = "2016")
  {
  
  parms <- wSeason(zoo_ts)
  zoo_ts <- parms$zoo_ts
  i_wet <- parms$i_wet
  f_wet <- parms$f_wet
  R_ave <- parms$R_ave
  sub_dates <- format(time(window(zoo_ts, 
                                 start = i_wet, 
                                 end = f_wet)), "%m-%d")

  zoo_ts <- window(zoo_ts, 
               start = paste(iY, format(i_wet, "%m-%d"), sep = "-"), 
               end = paste(fY, format(f_wet,"%m-%d"), sep = "-")) %>%
    .[format(time(.), "%m-%d") %in% sub_dates] %>%
    split(., ceiling(seq_along(.)/length(sub_dates)))
  
  p95 = quantile(unlist(zoo_ts), .95)
  
  lapply(zoo_ts, function(season){      
    
    Sacum = cumsum(season - R_ave)
    onset = time(Sacum[Sacum == min(Sacum)])
    cessation = time(Sacum[Sacum == max(Sacum)])
    
    oC = zoo::coredata(window(season, start = onset, end = cessation))
    
    rd = length(oC[oC >= 1])
    r = sum(oC[oC >= 1]) 
    sdii = rd/r
    r95sum = sum(oC[oC >= p95])*100/r 
    cdd = CDD(zoo::coredata(oC))
    
    data.frame(onset, cessation, rd, r, sdii, r95sum, cdd)
    
  }) %>% do.call(rbind, .) %>% return() 
  
  }
  
