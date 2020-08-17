## Dust
**R** script files for modelling desert dust exposure in epidemiological studies for the short-term health effects.

---

#### workshop_isee2019 

Includes the files used for the pre-conference workshop **Modelling dessert dust exposure events for epidemiological short-term health effects studies** at the **31st Annual Conference of the International Society for Environmental Epidemiology**, Utrecht, The Netherlands.

* The file **01.dust_models.R** run all the modelling approaches simultaneously for desert dust exposures using binary and continuous metric.
    * In **Line 29** the dataset name must be replaced by the **Users**. 
    * In **Lines 31-39** there is a description of the variable names. The **Users** must define the same names in their own dataset for **date** variable, dust exposures (**dust, pm10, pm10natural, pm10local**), and temperature (**temp**). 
    * In **Line 52** the **Users** must define the health outcome in their dataset. 
    * In **Lines 55-58** the **Users** must set the exposure lag of interest for their analysis. 
    * In **Line 70** the **Users** can change the parameters and variables for the adjustment of the baseline time-series regression model adjusted for time-trend and temperature.
    
* The file **00.dust_prepdata.R** is an ancillary file used by **01.allmodels.R** to generate the lagged variables for dust exposures and PM10 and the smooth terms to adjust for temperature.

* Unfortunately, due to confidentiality issues with mortality data, we are not able to distribute the example dataset. However, we are working in a simulated dataset which will be uploaded shortly.

---

#### epidemiology_2020

Includes the files used in: **Tobias A, Stafoggia M. Modelling desert dust exposure in epidemiological short-term health effects studies. Epidemiology 2020, In Press.**

* The file **dust_epidemiol_2020.R** includes the **R** code to replicate step-by-step the examples in the manuscript. It uses the ancillary file **00.prepdara.R** is to generate lagged variables and the smooth terms to adjust for temperature.

* Unfortunately, due to confidentiality issues with mortality data, we are not able to distribute the example dataset. However, we are working in a simulated dataset which will be uploaded shortly.
   
