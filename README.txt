README: The effect of oviposition site selection on offspring survival in a glassfrog

Description of the data:
This data was collected for a clutch translocation experiment. The location of the laid clutches was manipulated and the objective was to compare their level of hydration, hatching time, and mortality rate to control clutches

Files and variables
File: Data_oviposition_location.xlsx
Description: Data base with all the variables measured and processed to use in subsequent analyses

Variables

d_s_o: days since oviposition
d_on_e: days on experiment
d_u_h: days until the first tadpole hatched
d_t_s: days passed until reaching Gosner's developmental stage 19 
post_hatch: days since first tadpole hatched until last tadpole hatched
Num_eggs_full: Complete number of eggs per clutch
number_eggs: Number of eggs disregarding of embryos collected for DNA analyses (different study)
thickness: height of the clutch from mase to highest point in mm
area: area covered by the clutch's jelly
stand_dev: standard deviation of area
perimeter: perimeter of the jelly 
length_leaf: length from the tip  of the leaf to the base (where petiole starts) in cm
width_leaf: measured at the thickest point of the leaf, in cm. 
meanT: mean temperature of the day
meanH: mean humidity of the day
per_mort_end: percentage of mortaity of the entire clutch by the last day of experimentation
THI_day: daily measure of Temperature and Humidity Index (THI) with the formula THI = 0.8*T + RH*(T-14.4) + 46.4, following Mader et al 2006
eggs*perarea: number*eggs/area
THI_on_e: mean Temperature and Humidity Index of the days the clutch was under experimentation
mort_day: mortality per day
thickness_on_e: mean thickness of the clutch during experimentation
eggs_per_area_on_e: mean *number*eggs/area during experimentation
Missing values are blank
File: Data_survival.xlsx
Description: Data base with all the variables measured and processed to use in survival COX analyses

Variables:

clutch: Clutch ID
condition: Experiment/control
d_s_o: days since oviposition
status_cl: censoring status (1 being event of death and 2 censored clutches - clutches with at least one embryo hatched, successfully hatched clutches, and clutches that did not hatch until end of experiment but were still alive)
File: Analyses_oviposition_location.R
Description: Code used in RStudio for analyzing the data
Code/software
Software used: R

All packages are mentioned within the code
