###########################################################################################################################
###########################################################################################################################
#####  Workshop "Modelling desert dust exposure events for epidemiological short-term health effects studies".        #####
#####  Massimo Stafoggia (m.stafoggia@deplazio.it) and Aurelio Tobías (aurelio.tobias@idaea.csic.es)                  #####
#####                                                                                                                 #####
#####  31st Annual Conference of the International Society of Environmental Epidemiology.                             ##### 
#####  Utrecht, The Netherlands, 24th August 2019.                                                                    #####  
#####                                                                                                                 #####
#####  01.models.R  - Time-series regression models for dust exposures.                                               #####
#####  LAST UPDATE: 20/08/2019                                                                                        #####
###########################################################################################################################
###########################################################################################################################


###########################################################################################################################
## Remove objects, install packages (if necessary) and load packages.
###########################################################################################################################

rm(list=ls())
#install.packages(c("splines"))
library(splines)


###########################################################################################################################
### Load dataset 
### NOTE: Date and exposure variables MUST be named as: date, dust, pm10, pm10local, pm10natural, temp.
###########################################################################################################################

data <- readRDS("data_isee2019dust.rds")


###########################################################################################################################
### Prepare data for the analysis generating lags for temperature, dust and pm variables.
###########################################################################################################################

source("00.prepdata.R")


###########################################################################################################################
### Define variables for dust and pm (use same lags for both)
###########################################################################################################################

### Define outcome variable
Y     <- data$allnat

### Define lagged dust and pm exposures
PM    <- data$l0pm10
PMLOC <- data$l0pm10local   
PMNAT <- data$l0pm10natural
DUST  <- data$l0dust

###
DUST  <- factor(DUST,ordered = is.ordered(DUST))
DUST1 <- ifelse(DUST==0, 1, ifelse(DUST==1, 0, NA))


###########################################################################################################################
### Base time-series regression model adjusted for time-trend and temperature
###########################################################################################################################

### Set model parameters
NDF <- 4
NYEARS <- round(length(data$date)/365.25)

### Fit base model
basemodel <- glm(Y ~ ns(date, df=NDF*NYEARS)+as.factor(dow)+ns(l01temphot,k=ktemphot.lag01)+ns(l16tempcold,k=ktempcold.lag16), data=data, family=quasipoisson, na=na.omit)


###########################################################################################################################
### Time-series regression models for dust exposures
###########################################################################################################################


### Dust as binary metric (yes/no) 
##################################

### Model 1. Dust as main exposure
model1.dust   <- update(basemodel, .~. +DUST)
model1.dustpm <- update(basemodel, .~. +DUST+PM)

### Model 2. Dust as confounder
model2.pm      <- update(basemodel, .~. +PM)
#model2.pmdust <- update(basemodel, .~. +PM+DUST) is same model as model1.dustpm 

### Model 3. Dust as effect modifier
model3.pm.dust0 <- update(basemodel, .~. +DUST+PM+DUST:PM)
model3.pm.dust1 <- update(basemodel, .~. +DUST1+PM+DUST1:PM)


### Dust as continuous exposure
##################################

### Model 4. Two-sources model
model4.pm.2sources <- update(basemodel, .~. +PMLOC+PMNAT)

### Model 5. Three-sources model
model5.pm.3sources.dust0 <- update(basemodel, .~. +PMLOC+PMNAT+DUST+DUST:PMLOC)
model5.pm.3sources.dust1 <- update(basemodel, .~. +PMLOC+PMNAT+DUST1+DUST1:PMLOC)


###########################################################################################################################
### Table of results with dust and PM10 estimates from all models
###########################################################################################################################


### Generate empty data frame
##################################
results.est <- data.frame(exposure="", b=NA, se=NA, pint=NA)
ncoef <- length(basemodel$coefficients)

### Model 1. Dust as main exposure
e  <- "Dust (yes/no) - crude"
b  <- summary(model1.dust)$coefficients[ncoef+1,1]
se <- summary(model1.dust)$coefficients[ncoef+1,2]
est <- data.frame(exposure=e,b=b,se=se,pint=NA)
results.est <- rbind(results.est,est)

e <- "Dust (yes/no) - adjusted"
b  <- summary(model1.dustpm)$coefficients[ncoef+1,1]
se <- summary(model1.dustpm)$coefficients[ncoef+1,2]
est <- data.frame(exposure=e,b=b,se=se,pint=NA)
results.est <- rbind(results.est,est)

### Model 2 - Dust as confounder
e  <- "PM10 - crude"
b  <- summary(model2.pm)$coefficients[ncoef+1,1]
se <- summary(model2.pm)$coefficients[ncoef+1,2]
est <- data.frame(exposure=e,b=b,se=se,pint=NA)
results.est <- rbind(results.est,est)

e <- "PM10 - adjusted"
b  <- summary(model1.dustpm)$coefficients[ncoef+2,1]
se <- summary(model1.dustpm)$coefficients[ncoef+2,2]
est <- data.frame(exposure=e,b=b,se=se,pint=NA)
results.est <- rbind(results.est,est)

### Model 3 - Dust as effect modiffier 
e <- "PM10, non-dust days"
b  <- summary(model3.pm.dust0)$coefficients[ncoef+2,1]
se <- summary(model3.pm.dust0)$coefficients[ncoef+2,2]
pint <- summary(model3.pm.dust0)$coefficients[ncoef+3,4]
est <- data.frame(exposure=e,b=b,se=se,pint=pint)
results.est <- rbind(results.est,est)

e <- "PM10, dust days"
b  <- summary(model3.pm.dust1)$coefficients[ncoef+2,1]
se <- summary(model3.pm.dust1)$coefficients[ncoef+2,2]
est <- data.frame(exposure=e,b=b,se=se,pint=NA)
results.est <- rbind(results.est,est)

### Model 4 - Two-sources models
e <- "PM10 local"
b  <- summary(model4.pm.2sources)$coefficients[ncoef+1,1]
se <- summary(model4.pm.2sources)$coefficients[ncoef+1,2]
est <- data.frame(exposure=e,b=b,se=se,pint=NA)
results.est <- rbind(results.est,est)

e <- "PM10 natural"
b  <- summary(model4.pm.2sources)$coefficients[ncoef+2,1]
se <- summary(model4.pm.2sources)$coefficients[ncoef+2,2]
est <- data.frame(exposure=e,b=b,se=se,pint=NA)
results.est <- rbind(results.est,est)

### Model 5 - Three-sources model
e <- "PM10 local, non-dust days"
b  <- summary(model5.pm.3sources.dust0)$coefficients[ncoef+1,1]
se <- summary(model5.pm.3sources.dust0)$coefficients[ncoef+1,2]
pint <- summary(model5.pm.3sources.dust0)$coefficients[ncoef+4,4]
est <- data.frame(exposure=e,b=b,se=se,pint=pint)
results.est <- rbind(results.est,est)

e <- "PM10 local, dust days"
b  <- summary(model5.pm.3sources.dust1)$coefficients[ncoef+1,1]
se <- summary(model5.pm.3sources.dust1)$coefficients[ncoef+1,2]
est <- data.frame(exposure=e,b=b,se=se,pint=NA)
results.est <- rbind(results.est,est)

e <- "PM10 natural"
b  <- summary(model5.pm.3sources.dust0)$coefficients[ncoef+2,1]
se <- summary(model5.pm.3sources.dust0)$coefficients[ncoef+2,2]
est <- data.frame(exposure=e,b=b,se=se,pint=NA)
results.est <- rbind(results.est,est)


### Clean up results as %IR
###################################
results.est <- results.est[-1,] 
results.est$upp <- results.est$low <- results.est$irr <- NA

### %IR for dust (yes/no)
UG <- 1
results.est$irr[1:2] <- round((exp(results.est$b[1:2]*UG)-1)*100, 1)
results.est$low[1:2] <- round((exp((results.est$b[1:2]-1.96*results.est$se[1:2])*UG)-1)*100, 1)
results.est$upp[1:2] <- round((exp((results.est$b[1:2]+1.96*results.est$se[1:2])*UG)-1)*100, 1)

### %IR per 10 ug/m3 of pm increase
UG <- 10
results.est$irr[3:11] <- round((exp(results.est$b[3:11]*UG)-1)*100, 1)
results.est$low[3:11] <- round((exp((results.est$b[3:11]-1.96*results.est$se[3:11])*UG)-1)*100, 1)
results.est$upp[3:11] <- round((exp((results.est$b[3:11]+1.96*results.est$se[3:11])*UG)-1)*100, 1)


### List estimates from all models
###################################
results.irr <- cbind(results.est[,-2:-4], results.est[,4])
names(results.irr)[5] = "pint"
results.irr


###########################################################################################################################
###########################################################################################################################
#####                                                                                                                 #####
#####                                             END OF SCRIPT                                                       #####
#####                                                                                                                 #####
###########################################################################################################################
###########################################################################################################################
