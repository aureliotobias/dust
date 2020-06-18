## Dust
**R** script files for modelling desert dust exposure in epidemiological studies for the short-term health effects.

---

### Workshop_ISEE2019 

Includes the files used for the pre-conference workshop **Modelling dessert dust exposure events for epidemiological short-term health effects studies** at the **31st Annual Conference of the International Society for Environmental Epidemiology**, Utrecht, The Netherlands.

* The file **01.allmodels.R** run all the modelling approaches simultaneously for desert dust exposures using binary and continuous metric.
* The file **00.prepdara.R** is an ancillary file to generate lagged variables for dust exposures and PM10 and the smooth terms to adjust for temperature.
    * In **Line 29** the dataset name must be replaced by the **Users**. Unfortunately, due to confidentiality issues with mortality data, we are not able to distribute the example dataset. However, we are working in a simulated dataset which will be uploaded shortly.
    * In **Lines 31-39** there is a description of the variable names. The **Users** must define the same names in their own dataset for **date** variable, dust exposures (**dust, pm10, pm10natural, pm10local**), and temperature (**temp**). 
    * In **Line 52** the **Users** must define the health outcome in their dataset. 
    * In **Lines 55-58** the **Users** must set the exposure lag of interest for their analysis. 
    * In **Line 70** the **Users** can change the parameters and variables for the adjustment of the baseline time-series regression model adjusted for time-trend and temperature.

* The file **dust_isee.R** includes the **R** code to replicate step-by-step the examples in the slides.

---

### Epidemiology_2020

Includes the files used for manuscript submitted to **Epidemiology** (currently under review).

* The file **dust_epidemiol.R** includes the **R** code to replicate step-by-step the examples in the manuscript. 

   * Unfortunately, due to confidentiality issues with mortality data, we are not able to distribute the example dataset. However, we are working in a simulated dataset which will be uploaded shortly.
   
