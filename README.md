## Dust
R script files for modelling desert dust exposure in epidemiological studies for the short-term health effects.

---

#### Workshop_ISEE2019 

Includes the files used for the pre-conference workshop **Modelling dessert dust exposure events for epidemiological short-term health effects studies** at the **31st Annual Conference of the International Society for Environmental Epidemiology**, Utrecht, The Netherlands.

* The file **01.allmodels.R** runs simultaneously all the modelling aproaches for desert dust exposures using binary and continuous metric. While the file **00.prepdara.R** is an anchilary file to generate lagged variables for dustt exposures and PM10 and the smooth terms to adjust for temperature.
    * In **Line 29** the dataset name must be replaced by the Users. Unfortunately, due to confidentiality isuse with mortality data we are not able to distribute the example dataset. However, we are working in a simulated dataset which will be uploades shortly.
    * In **Lines 31-39** there is description of the variable names. The Users must use the same names in their own dataset for the **date**, the dust exposures (variables **dust, pm10, pm10natural, pm10local**), and the temperature (variable **temp**). 
    * In **Line 52** the Users must define tthe health outcome in their dataset and in **Lines 55-58** the Users must define the exposure lags of interest for their analysis. 
    * In **Line 70** the Users can change the parameters and variables for the adjustmend of the base line time-series regression model adjusted for time-trend and temperature.

* The file **dust_isee.R** includes de code to replicate step-by-step the examples in the slides.

---

#### Epidemiology_2020

Includes the files used for manuscript submited to **Epidemiology** (currently under review).

* The file **dust_epidemiol.R** includes de code to replicate step-by-step the examples in the manuscript.

