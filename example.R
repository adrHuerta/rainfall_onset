rm(list = ls())
source('rainfall_onset_functions.R')

pr_data <- zoo::read.zoo("./data/example_zoo.csv", 
                        header = T, 
                        format = "%Y-%m-%d", 
                        sep = ",")
est <- pr_data[, 3]

## daily climatologies
clim_days <- dClim(est)
plot(clim_days)

## wet season: climatological cumulative daily rainfall anomaly
wet_season <- wSeason(est)
plot(wet_season$d)
wet_season$i_wet
wet_season$f_wet

## rainfall onset-cessation and extreme indices (https://doi.org/10.5194/bg-15-319-2018)
est_ext <- onSet(est, iY = "1981", fY = "2016")
head(est_ext)

#amount of precipitation (r) by onset-cessation season
plot(est_ext$r, type = "l")

#setting onset-cessation dates to numeric values, counting since June 1st
est_ext$onset <- (est_ext$onset %>% format("%m-%d") %>% match(., names(clim_days))) - 151
est_ext$cessation <- (est_ext$cessation %>% format("%m-%d") %>% match(., names(clim_days))) + 151
          
plot(est_ext$onset, type = "l")
plot(est_ext$cessation, type = "l")
