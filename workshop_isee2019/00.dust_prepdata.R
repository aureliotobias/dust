###########################################################################################################################
###########################################################################################################################
#####  Workshop "Modelling desert dust exposure events for epidemiological short-term health effects studies".        #####
#####  Massimo Stafoggia (m.stafoggia@deplazio.it) and Aurelio Tobías (aurelio.tobias@idaea.csic.es)                  #####
#####                                                                                                                 #####
#####  31st Annual Conference of the International Society of Environmental Epidemiology.                             ##### 
#####  Utrecht, The Netherlands, 24th August 2019.                                                                    #####  
#####                                                                                                                 #####
#####  01.dust_prepdata.R - Prepare necessary variables and lags for the analysis.                                    #####
#####  LAST UPDATE: 20/08/2019                                                                                        #####
###########################################################################################################################
###########################################################################################################################


###########################################################################################################################
### Generate trend and calendar variables.
###########################################################################################################################

### Time-trend.
n<-dim(data)[1]
data$trend <- seq(from=1, to=n, 1)

### Date.
data$date <- as.Date(data$date, format="%d/%m/%Y")

### Calendar variables.
data$year <- as.numeric(format(data$date,"%Y"))
data$month <- as.numeric(format(data$date,"%m"))
data$day <- as.numeric(format(data$date,"%d"))
data$yday <- as.numeric(format(data$date,"%j"))
data$dow <- factor(weekdays(data$date,abbr=T))


###########################################################################################################################
### Generate lagged temperature variables for adjustment following the MedParticles protocol.
### (Described in: Stafoggia et al. 2013, 2016).
###########################################################################################################################

### Lags
data$l1temp   <- c(NA,data$temp[1:(n-1)])
data$l2temp   <- c(NA,NA,data$temp[1:(n-2)])
data$l3temp   <- c(NA,NA,NA,data$temp[1:(n-3)])
data$l4temp   <- c(NA,NA,NA,NA,data$temp[1:(n-4)])
data$l5temp 	<- c(NA,NA,NA,NA,NA,data$temp[1:(n-5)])
data$l6temp 	<- c(NA,NA,NA,NA,NA,NA,data$temp[1:(n-6)])

### Averaged lags
data$l16temp 	<- (data$l1temp + data$l2temp + data$l3temp + data$l4temp + data$l5temp + data$l6temp)/6
data$l16tempcold 	<- ((data$l16temp - median(data$l16temp,na.rm=T))*(data$l16temp <= median(data$l16temp,na.rm=T)))+median(data$l16temp,na.rm=T)
data$l01temp 	<- (data$temp + data$l1temp)/2
data$l01temphot  	<- ((data$l01temp - median(data$l01temp,na.rm=T))*(data$l01temp >= median(data$l01temp,na.rm=T)))+median(data$l01temp,na.rm=T)

### Percentiles of temperature for model adjustment.
perc.hot		    <- c(75/100, 90/100)
perc.cold		    <- c(25/100)
ktemphot.lag01	<- as.vector(quantile(data$l01temphot, perc.hot, na.rm=T))
ktempcold.lag16	<- as.vector(quantile(data$l16tempcold,perc.cold,na.rm=T))


###########################################################################################################################
### Generate lagged dust and pm variables 
###########################################################################################################################

### Lags for for dust (yes/no) variable.
data$l0dust <- data$dust
data$l1dust <- c(NA,data$dust[1:(n-1)])
data$l2dust <- c(NA,NA,data$dust[1:(n-2)])
data$l3dust <- c(NA,NA,NA,data$dust[1:(n-3)])
data$l4dust <- c(NA,NA,NA,NA,data$dust[1:(n-4)])
data$l5dust	<- c(NA,NA,NA,NA,NA,data$dust[1:(n-5)])

### Lags for pm variables.
data$l0pm10 <- data$pm10
data$l1pm10 <- c(NA,data$pm10[1:(n-1)])
data$l2pm10 <- c(NA,NA,data$pm10[1:(n-2)])
data$l3pm10 <- c(NA,NA,NA,data$pm10[1:(n-3)])
data$l4pm10 <- c(NA,NA,NA,NA,data$pm10[1:(n-4)])
data$l5pm10 <- c(NA,NA,NA,NA,NA,data$pm10[1:(n-5)])

data$l0pm10local <- data$pm10local
data$l1pm10local <- c(NA,data$pm10local[1:(n-1)])
data$l2pm10local <- c(NA,NA,data$pm10local[1:(n-2)])
data$l3pm10local <- c(NA,NA,NA,data$pm10local[1:(n-3)])
data$l4pm10local <- c(NA,NA,NA,NA,data$pm10local[1:(n-4)])
data$l5pm10local <- c(NA,NA,NA,NA,NA,data$pm10local[1:(n-5)])

data$l0pm10natural <- data$pm10natural
data$l1pm10natural <- c(NA,data$pm10natural[1:(n-1)])
data$l2pm10natural <- c(NA,NA,data$pm10natural[1:(n-2)])
data$l3pm10natural <- c(NA,NA,NA,data$pm10natural[1:(n-3)])
data$l4pm10natural <- c(NA,NA,NA,NA,data$pm10natural[1:(n-4)])
data$l5pm10natural <- c(NA,NA,NA,NA,NA,data$pm10natural[1:(n-5)])


###########################################################################################################################
###########################################################################################################################
#####                                                                                                                 #####
#####                                             END OF SCRIPT                                                       #####
#####                                                                                                                 #####
###########################################################################################################################
###########################################################################################################################


