# Dust
Modelling desert dust exposure in epidemiological studies for the short-term health effects.

## Scripts
The script files are divided in three diferent folders

* **Workshop_ISEE2019** includes the files used for the pre-conference workshop *Modelling dessert dust exposure events for epidemiological short-term health effects studies* at the 31st Annual Conference of the International Society for Environmental Epidemiology, Utrecht, The Netherlands.

The file **01.models.R** runs all the modelling aproaches for desert dust exposures using binary and continuous metric. While the **00.prepdara.R** is an anchilary file to generate lagged variables for dustt exposures and PM10 and the smooth terms to adjust for temperature.

In **Line 29** the dataset name must be replaced by the User's. In the Uer's dataset the exposure variables must be named as **dust** for the binary exposure, **pm10** for the daily PM10 concentrations, **pm10local** for the local or anthropogenic (non-dust) contruibution to daily PM10 concentrations, **pm10natural** for the natural (dust) contruibution to daily PM10 concentrations, and **temp** for daily average temperature.

In **Line 44** the User must define the health outcome in their dataset and in **Lines 47-50** the User must define the exposure lags.  
