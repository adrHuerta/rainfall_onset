# rainy season for northern hemisphere (April to September)

rm(list = ls())
source('rainfall_onset_functions2.R')

pr_data <- zoo::read.zoo("./data/test_devisdevis.csv", 
                         header = T, 
                         format = "%d/%m/%Y", 
                         sep = ",")
# time serie
plot(pr_data)

## daily climatologies
clim_days <- dClim(pr_data)
plot(clim_days, xlab = "Days since January 1st")


## wet season: climatological cumulative daily rainfall anomaly
wet_season <- wSeason(pr_data)
plot(wet_season$d, xlab = "Days since January 1st")
wet_season$i_wet 
wet_season$f_wet

## rainfall onset-cessation and extreme indices (https://doi.org/10.5194/bg-15-319-2018)
est_ext <- onSet(pr_data, iY = "1981", fY = "2000")$ext_ind
est_ext

#amount of precipitation (r) by onset-cessation season
plot(est_ext$r, type = "l")

#setting onset-cessation dates to numeric values, counting since January 1st
est_ext$onset <- est_ext$onset %>% format("%m-%d") %>% match(., names(clim_days)) 
est_ext$cessation <- est_ext$cessation %>% format("%m-%d") %>% match(., names(clim_days))

plot(est_ext$onset, type = "l")
plot(est_ext$cessation, type = "l")

# rainy season for northern hemisphere (April to September)
