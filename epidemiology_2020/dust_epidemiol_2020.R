###########################################################################################################################
###########################################################################################################################
### MODELLING DESERT DUST EXPOSURE IN EPIDEMIOLOGICAL SHORT-TERM HEALTH EFFECTS STUDIES
### Aurelio Tobías (aurelio.tobias@idaea.csic.es), Massimo Stafoggia (m.stafoggia@deplazio.it )
### 
### Last update: 17 Aug 2020
###########################################################################################################################
###########################################################################################################################

###########################################################################################################################
# Load libraries and define functions.
###########################################################################################################################

### Remove objects
rm(list=ls())

### Load libraries
library(foreign)
library(data.table)
library(dplyr)
library(MASS)
library(mgcv)
library(nlme)
library(splines)
library(dlnm)

### Function to get results of an exposure as last term in  the model
last.mod <- function(model)
{ mod <- model
  n   <- length(mod$coefficients)
  b   <- mod$coefficients[n]
  m   <- dim(summary(mod)$cov.scaled)[1]
  se  <- sqrt((summary(mod)$cov.scaled)[m,m])
  p   <- ""
  names(b)  <- NULL
  names(se) <- NULL
  names(p)  <- NULL
  betas     <- c(beta=b, se=se, p=p)
  betas     <- format(betas, digits=7)
}

### Function to get results of an exposure as one-but-last term in  the model
last2.mod <- function(model)
{ mod <- model
  n   <- length(mod$coefficients)
  b   <- mod$coefficients[n-1]
  m   <- dim(summary(mod)$cov.scaled)[1]
  se  <- sqrt(summary(mod)$cov.scaled[m-1,m-1])
  p   <- ""
  names(b)  <- NULL
  names(se) <- NULL
  names(p)  <- NULL
  betas     <- c(beta=b, se=se, p=p)
  betas     <- format(betas, digits=7)
}

### Function to get results of an exposure as two-but-last term in  the model
last3.mod <- function(model)
{ mod <- model
  n   <- length(mod$coefficients)
  b   <- mod$coefficients[n-2]
  m   <- dim(summary(mod)$cov.scaled)[1]
  se  <- sqrt(summary(mod)$cov.scaled[m-2,m-2])
  p   <- ""
  names(b)  <- NULL
  names(se) <- NULL
  names(p)  <- NULL
  betas     <- c(beta=b, se=se, p=p)
  betas     <- format(betas, digits=7)
}

### Function to get results as sum of one-but-last and last terms in the model, plus interaction term
last01.mod <- function(model)
{ mod <- model
  n   <- length(mod$coefficients)
  b   <- mod$coefficients[n-1]+mod$coefficients[n]
  m   <- dim(summary(mod)$cov.scaled)[1]
  se  <- sqrt(sum(summary(mod)$cov.scaled[c(m-1,m),c(m-1,m)]))
  z   <- mod$coefficients[n]/(sqrt(summary(mod)$cov.scaled[m,m]))
  p   <- 2*(1-pnorm(abs(z)))
  names(b)  <- NULL
  names(se) <- NULL
  names(p)  <- NULL
  betas     <- c(beta=b, se=se, p=p)
  betas     <- format(betas, digits=7)
}

###########################################################################################################################
# Data management.
###########################################################################################################################

### Import the dataset
data <- readRDS("RM_mortality_dust_daily.rds")

# Set the dataframe as a data.table
setDT(data)

# Sort it by date
setkey(data, date)

### Create lag terms (up to 6 days, and cumulative lags) for cold and hot temperatures adjustment
n <- dim(data)[1]
data$l1temp   <- c(NA,data$temp[1:(n-1)])
data$l2temp   <- c(NA,NA,data$temp[1:(n-2)])
data$l3temp   <- c(NA,NA,NA,data$temp[1:(n-3)])
data$l4temp   <- c(NA,NA,NA,NA,data$temp[1:(n-4)])
data$l5temp 	<- c(NA,NA,NA,NA,NA,data$temp[1:(n-5)])
data$l6temp 	<- c(NA,NA,NA,NA,NA,NA,data$temp[1:(n-6)])

data$l16temp 	<- (data$l1temp + data$l2temp + data$l3temp + data$l4temp + data$l5temp + data$l6temp)/6
data$l16tempcold 	<- ((data$l16temp - median(data$l16temp,na.rm=T))*(data$l16temp <= median(data$l16temp,na.rm=T)))+median(data$l16temp,na.rm=T)

data$l01temp 	<- (data$temp + data$l1temp)/2
data$l01temphot  	<- ((data$l01temp - median(data$l01temp,na.rm=T))*(data$l01temp >= median(data$l01temp,na.rm=T)))+median(data$l01temp,na.rm=T)

### Create lag terms (up to 5 days) dust exposures

# Dust as binary exposure
data$l1dust   <- c(NA,data$dust[1:(n-1)])
data$l2dust   <- c(NA,NA,data$dust[1:(n-2)])
data$l3dust   <- c(NA,NA,NA,data$dust[1:(n-3)])
data$l4dust   <- c(NA,NA,NA,NA,data$dust[1:(n-4)])
data$l5dust 	<- c(NA,NA,NA,NA,NA,data$dust[1:(n-5)])

# PM10 concentrations
data$l1pm10 		<- c(NA,data$pm10[1:(n-1)])
data$l2pm10 		<- c(NA,NA,data$pm10[1:(n-2)])
data$l3pm10 		<- c(NA,NA,NA,data$pm10[1:(n-3)])
data$l4pm10 		<- c(NA,NA,NA,NA,data$pm10[1:(n-4)])
data$l5pm10 		<- c(NA,NA,NA,NA,NA,data$pm10[1:(n-5)])

# non-desert source to PM10
data$l1pm10local 	<- c(NA,data$pm10local[1:(n-1)])
data$l2pm10local 	<- c(NA,NA,data$pm10local[1:(n-2)])
data$l3pm10local 	<- c(NA,NA,NA,data$pm10local[1:(n-3)])
data$l4pm10local 	<- c(NA,NA,NA,NA,data$pm10local[1:(n-4)])
data$l5pm10local 	<- c(NA,NA,NA,NA,NA,data$pm10local[1:(n-5)])

# desert source to PM10
data$l1pm10natural	<- c(NA,data$pm10natural[1:(n-1)])
data$l2pm10natural 	<- c(NA,NA,data$pm10natural[1:(n-2)])
data$l3pm10natural 	<- c(NA,NA,NA,data$pm10natural[1:(n-3)])
data$l4pm10natural	<- c(NA,NA,NA,NA,data$pm10natural[1:(n-4)])
data$l5pm10natural 	<- c(NA,NA,NA,NA,NA,data$pm10natural[1:(n-5)])

### Varables ot adjust for temperature with separate terms for cold and hot temperatures:
#   1. Cold temperatures: defined on days with lag 1-6 temp < median, spline with one inner knot at 25th percentile
#   2. Hot temperatures: defined on days with lag 0-1 temp > median, spline with two inner knots at 75th and 90th percentile
#   See MED-PARTICLES paper for reference (Stafoggia et al. Environ Health Perspect. 2013;121(9):1026-33)

perc.hot		    <- c(75/100, 90/100)
perc.cold		    <- c(25/100)
ktemphot.lag01	<- as.vector(quantile(data$l01temphot, perc.hot, na.rm=T))
ktempcold.lag16	<- as.vector(quantile(data$l16tempcold,perc.cold,na.rm=T))

###########################################################################################################################
# Modelling approaches. 
###########################################################################################################################

### Adjusted (core) model
mod <- glm(allnat ~ ns(trend, df=4*11)+as.factor(dow)+ns(l01temphot,k=ktemphot.lag01)+ns(l16tempcold,k=ktempcold.lag16), data=data, family=quasipoisson, na=na.omit)

##############################
### DUST AS BINARY METRIC
##############################

### Dust as risk factor
# without PM10 adjustment
mod.1.lag0 <- update(mod, .~. + dust)
mod.1.lag1 <- update(mod, .~. + l1dust)
mod.1.lag2 <- update(mod, .~. + l2dust)
mod.1.lag3 <- update(mod, .~. + l3dust)
mod.1.lag4 <- update(mod, .~. + l4dust)
mod.1.lag5 <- update(mod, .~. + l5dust)

res.mod.1.lag0 <- last.mod(mod.1.lag0)
res.mod.1.lag1 <- last.mod(mod.1.lag1)
res.mod.1.lag2 <- last.mod(mod.1.lag2)
res.mod.1.lag3 <- last.mod(mod.1.lag3)
res.mod.1.lag4 <- last.mod(mod.1.lag4)
res.mod.1.lag5 <- last.mod(mod.1.lag5)

# without PM10 adjustment
mod.1b.lag0 <- update(mod, .~. + pm10 + dust)
mod.1b.lag1 <- update(mod, .~. + l1pm10 + l1dust)
mod.1b.lag2 <- update(mod, .~. + l2pm10 + l2dust)
mod.1b.lag3 <- update(mod, .~. + l3pm10 + l3dust)
mod.1b.lag4 <- update(mod, .~. + l4pm10 + l4dust)
mod.1b.lag5 <- update(mod, .~. + l5pm10 + l5dust)

res.mod.1b.lag0 <- last.mod(mod.1b.lag0)
res.mod.1b.lag1 <- last.mod(mod.1b.lag1)
res.mod.1b.lag2 <- last.mod(mod.1b.lag2)
res.mod.1b.lag3 <- last.mod(mod.1b.lag3)
res.mod.1b.lag4 <- last.mod(mod.1b.lag4)
res.mod.1b.lag5 <- last.mod(mod.1b.lag5)

### PM10 as risk factor
# Without dust adjustment
mod.2.lag0 <- update(mod, .~. + pm10)
mod.2.lag1 <- update(mod, .~. + l1pm10)
mod.2.lag2 <- update(mod, .~. + l2pm10)
mod.2.lag3 <- update(mod, .~. + l3pm10)
mod.2.lag4 <- update(mod, .~. + l4pm10)
mod.2.lag5 <- update(mod, .~. + l5pm10)

res.mod.2.lag0 <- last.mod(mod.2.lag0)
res.mod.2.lag1 <- last.mod(mod.2.lag1)
res.mod.2.lag2 <- last.mod(mod.2.lag2)
res.mod.2.lag3 <- last.mod(mod.2.lag3)
res.mod.2.lag4 <- last.mod(mod.2.lag4)
res.mod.2.lag5 <- last.mod(mod.2.lag5)

# With dust adjustment (.e., Dust as confounder)
mod.2b.lag0 <- update(mod, .~. + dust + pm10)
mod.2b.lag1 <- update(mod, .~. + l1dust + l1pm10)
mod.2b.lag2 <- update(mod, .~. + l2dust + l2pm10)
mod.2b.lag3 <- update(mod, .~. + l3dust + l3pm10)
mod.2b.lag4 <- update(mod, .~. + l4dust + l4pm10)
mod.2b.lag5 <- update(mod, .~. + l5dust + l5pm10)

res.mod.2b.lag0 <- last.mod(mod.2b.lag0)
res.mod.2b.lag1 <- last.mod(mod.2b.lag1)
res.mod.2b.lag2 <- last.mod(mod.2b.lag2)
res.mod.2b.lag3 <- last.mod(mod.2b.lag3)
res.mod.2b.lag4 <- last.mod(mod.2b.lag4)
res.mod.2b.lag5 <- last.mod(mod.2b.lag5)

### Dust as effect modiffier
mod.3.lag0 <- update(mod, .~. + dust*pm10)
mod.3.lag1 <- update(mod, .~. + l1dust*l1pm10)
mod.3.lag2 <- update(mod, .~. + l2dust*l2pm10)
mod.3.lag3 <- update(mod, .~. + l3dust*l3pm10)
mod.3.lag4 <- update(mod, .~. + l4dust*l4pm10)
mod.3.lag5 <- update(mod, .~. + l5dust*l5pm10)

res.mod.3.lag0.dust0 <- last2.mod(mod.3.lag0)
res.mod.3.lag0.dust1 <- last01.mod(mod.3.lag0)

res.mod.3.lag1.dust0 <- last2.mod(mod.3.lag1)
res.mod.3.lag1.dust1 <- last01.mod(mod.3.lag1)

res.mod.3.lag2.dust0 <- last2.mod(mod.3.lag2)
res.mod.3.lag2.dust1 <- last01.mod(mod.3.lag2)

res.mod.3.lag3.dust0 <- last2.mod(mod.3.lag3)
res.mod.3.lag3.dust1 <- last01.mod(mod.3.lag3)

res.mod.3.lag4.dust0 <- last2.mod(mod.3.lag4)
res.mod.3.lag4.dust1 <- last01.mod(mod.3.lag4)

res.mod.3.lag5.dust0 <- last2.mod(mod.3.lag5)
res.mod.3.lag5.dust1 <- last01.mod(mod.3.lag5)

### Two-sources model
mod.4.lag0 <- update(mod,.~. + pm10natural + pm10local)
mod.4.lag1 <- update(mod,.~. + l1pm10natural + l1pm10local)
mod.4.lag2 <- update(mod,.~. + l2pm10natural + l2pm10local)
mod.4.lag3 <- update(mod,.~. + l3pm10natural + l3pm10local)
mod.4.lag4 <- update(mod,.~. + l4pm10natural + l4pm10local)
mod.4.lag5 <- update(mod,.~. + l5pm10natural + l5pm10local)

res.mod.4.lag0.nat <- last2.mod(mod.4.lag0)
res.mod.4.lag0.loc <- last.mod(mod.4.lag0)

res.mod.4.lag1.nat <- last2.mod(mod.4.lag1)
res.mod.4.lag1.loc <- last.mod(mod.4.lag1)

res.mod.4.lag2.nat <- last2.mod(mod.4.lag2)
res.mod.4.lag2.loc <- last.mod(mod.4.lag2)

res.mod.4.lag3.nat <- last2.mod(mod.4.lag3)
res.mod.4.lag3.loc <- last.mod(mod.4.lag3)

res.mod.4.lag4.nat <- last2.mod(mod.4.lag4)
res.mod.4.lag4.loc <- last.mod(mod.4.lag4)

res.mod.4.lag5.nat <- last2.mod(mod.4.lag5)
res.mod.4.lag5.loc <- last.mod(mod.4.lag5)

### Three-sources model
mod.5.lag0 <- update(mod,.~. + dust + pm10natural + pm10local + dust:pm10local)
mod.5.lag1 <- update(mod,.~. + l1dust + l1pm10natural + l1pm10local + l1dust:l1pm10local)
mod.5.lag2 <- update(mod,.~. + l2dust + l2pm10natural + l2pm10local + l2dust:pm10local)
mod.5.lag3 <- update(mod,.~. + l3dust + l3pm10natural + l3pm10local + l3dust:pm10local)
mod.5.lag4 <- update(mod,.~. + l4dust + l4pm10natural + l4pm10local + l4dust:pm10local)
mod.5.lag5 <- update(mod,.~. + l5dust + l5pm10natural + l5pm10local + l5dust:pm10local)

res.mod.5.lag0.nat       <- last3.mod(mod.5.lag0)
res.mod.5.lag0.loc.dust0 <- last2.mod(mod.5.lag0)
res.mod.5.lag0.loc.dust1 <- last01.mod(mod.5.lag0)

res.mod.5.lag1.nat       <- last3.mod(mod.5.lag1)
res.mod.5.lag1.loc.dust0 <- last2.mod(mod.5.lag1)
res.mod.5.lag1.loc.dust1 <- last01.mod(mod.5.lag1)

res.mod.5.lag2.nat       <- last3.mod(mod.5.lag2)
res.mod.5.lag2.loc.dust0 <- last2.mod(mod.5.lag2)
res.mod.5.lag2.loc.dust1 <- last01.mod(mod.5.lag2)

res.mod.5.lag3.nat       <- last3.mod(mod.5.lag3)
res.mod.5.lag3.loc.dust0 <- last2.mod(mod.5.lag3)
res.mod.5.lag3.loc.dust1 <- last01.mod(mod.5.lag3)

res.mod.5.lag4.nat       <- last3.mod(mod.5.lag4)
res.mod.5.lag4.loc.dust0 <- last2.mod(mod.5.lag4)
res.mod.5.lag4.loc.dust1 <- last01.mod(mod.5.lag4)

res.mod.5.lag5.nat       <- last3.mod(mod.5.lag5)
res.mod.5.lag5.loc.dust0 <- last2.mod(mod.5.lag5)
res.mod.5.lag5.loc.dust1 <- last01.mod(mod.5.lag5)

###########################################################################################################################
### Collect and save dust risk estimates. 
###########################################################################################################################

### Colect all model estimates
results <- rbind( res.mod.1.lag0,  res.mod.1.lag1,  res.mod.1.lag2,  res.mod.1.lag3,  res.mod.1.lag4,  res.mod.1.lag5, 
                  res.mod.1b.lag0, res.mod.1b.lag1, res.mod.1b.lag2, res.mod.1b.lag3, res.mod.1b.lag4, res.mod.1b.lag5, 

                  res.mod.2.lag0,  res.mod.2.lag1,  res.mod.2.lag2,  res.mod.2.lag3,  res.mod.2.lag4,  res.mod.2.lag5, 
                  res.mod.2b.lag0, res.mod.2b.lag1, res.mod.2b.lag2, res.mod.2b.lag3, res.mod.2b.lag4, res.mod.2b.lag5, 

                  res.mod.3.lag0.dust0, res.mod.3.lag1.dust0, res.mod.3.lag2.dust0, res.mod.3.lag3.dust0, res.mod.3.lag4.dust0, res.mod.3.lag5.dust0,
                  res.mod.3.lag0.dust1, res.mod.3.lag1.dust1, res.mod.3.lag2.dust1, res.mod.3.lag3.dust1, res.mod.3.lag4.dust1, res.mod.3.lag5.dust1,
                  
                  res.mod.4.lag0.nat, res.mod.4.lag1.nat, res.mod.4.lag2.nat, res.mod.4.lag3.nat, res.mod.4.lag4.nat, res.mod.4.lag5.nat,
                  res.mod.4.lag0.loc, res.mod.4.lag1.loc, res.mod.4.lag2.loc, res.mod.4.lag3.loc, res.mod.4.lag4.loc, res.mod.4.lag5.loc,
                  
                  res.mod.5.lag0.nat,       res.mod.5.lag1.nat,       res.mod.5.lag2.nat,       res.mod.5.lag3.nat,       res.mod.5.lag4.nat,       res.mod.5.lag5.nat ,
                  res.mod.5.lag0.loc.dust0, res.mod.5.lag1.loc.dust0, res.mod.5.lag2.loc.dust0, res.mod.5.lag3.loc.dust0, res.mod.5.lag4.loc.dust0, res.mod.5.lag5.loc.dust0, 
                  res.mod.5.lag0.loc.dust1, res.mod.5.lag1.loc.dust1, res.mod.5.lag2.loc.dust1, res.mod.5.lag3.loc.dust1, res.mod.5.lag4.loc.dust1, res.mod.5.lag5.loc.dust1)
 
### Save estimates as a text file
results <- as.data.frame(results)
write.table(results, "results_paper_extended.txt")

###########################################################################################################################
###########################################################################################################################
### END OF SCRIPT
###########################################################################################################################
###########################################################################################################################
