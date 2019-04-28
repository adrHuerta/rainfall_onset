#install.packages("magrittr"); #install.packages("zoo")

`%>%` = magrittr::`%>%`

CDD <- function(a)
  {      
  
  a <- as.numeric(a)
  a[a >= 1] <- 1
  a[a < 1] <- 0 
  CDD <- suppressWarnings(max((!a) * unlist(lapply(rle(a)$lengths, seq_len)), na.rm = T))
  if (CDD == -Inf){CDD <- NA}
  CDD
  
  }

not_29 <- function(zoo_ts)
  {
  
  zoo_ts[format(time(zoo_ts), "%m-%d") == "02-29"] = NA
  zoo_ts[complete.cases(zoo_ts)]
  
  }

dClim <- function(zoo_ts)
  {
  
  zoo_ts <- not_29(zoo_ts)
  #zoo_ts %>% time %>% .[c(182:365,1:181)] %>% format("%m-%d") %>% #Year since July 1st
  zoo_ts %>% time %>% .[c(213:365,1:212)] %>% format("%m-%d") %>% #Year since August 1st
      sapply(function(z) zoo_ts[format(time(zoo_ts), "%m-%d") %in% z] %>% mean )
  
  }

wSeason <- function(zoo_ts)
  {
  
  zoo_ts <- not_29(zoo_ts)
  d_clim <- dClim(zoo_ts)
  R_ave <- mean(zoo_ts)
  d <- cumsum(d_clim - R_ave)
  f_wet <- zoo_ts[match(min(d), d)] %>% time()
  i_wet <- zoo_ts[match(max(d), d)] %>% time()
  
  list(d = d, i_wet = i_wet, f_wet = f_wet, zoo_ts = zoo_ts, R_ave = R_ave)
  
  }

onSet <- function(zoo_ts, iY = "1981", fY = "2016", wInd = 45)
  {
  
  parms <- wSeason(zoo_ts)
  zoo_ts <- parms$zoo_ts
  i_wet <- parms$i_wet - wInd
  f_wet <- parms$f_wet + wInd + 365
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
    
    D <- cumsum(season - R_ave)
    onset = time(D[D == min(D)])
    cessation = time(D[D == max(D)])
    
    oC = zoo::coredata(window(season, start = onset, end = cessation))
    
    rd = length(oC[oC >= 1])
    r = sum(oC[oC >= 1]) 
    sdii = rd/r
    r95sum = sum(oC[oC >= p95])*100/r 
    cdd = CDD(zoo::coredata(oC))
    
    data.frame(onset, cessation, rd, r, sdii, r95sum, cdd)
    
  }) %>% do.call(rbind, .) -> ext_ind 
  
  lapply(zoo_ts, function(season){      
    
    D <- cumsum(season - R_ave)
    zoo::coredata(D)
  }) %>% do.call(cbind, .) -> D_season
  
  list(ext_ind = ext_ind,
       D_season = D_season,
       wseason_wInd = c(i_wet, f_wet) %>% format("%m-%d"))
  
  }
  
