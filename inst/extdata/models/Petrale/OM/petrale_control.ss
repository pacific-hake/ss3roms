#V3.30.21.00;_safe;_compile_date:_Feb 10 2023;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.1
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#C file created using the SS_writectl function in the R package r4ss
#C file write time: 2023-06-21 16:38:18
#_data_and_control_files: petrale_data.ss // petrale_control.ss
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
1  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS3)
1 #_N_platoons_Within_GrowthPattern 
#_Cond 1 #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)
#_Cond  1 #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)
#
4 # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity; 4=none (only when N_GP*Nsettle*pop==1)
1 # not yet implemented; Future usage: Spawner-Recruitment: 1=global; 2=by area
1 #  number of recruitment settlement assignments 
0 # unused option
#GPattern month  area  age (for each settlement assignment)
 1 1 1 0
#
#_Cond 0 # N_movement_definitions goes here if Nareas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
4 #_Nblock_Patterns
 6 4 2 1 #_blocks_per_pattern 
# begin and end years of blocks
 1973 1982 1983 1992 1993 2002 2003 2010 2011 2017 2018 2022
 2002 2002 2003 2008 2009 2010 2011 2022
 2010 2010 2011 2022
 1995 2004
#
# controls for all timevary parameters 
1 #_time-vary parm bound check (1=warn relative to base parm bounds; 3=no bound check); Also see env (3) and dev (5) options to constrain with base bounds
#
# AUTOGEN
 1 1 1 1 1 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen time-varying parms of this category; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
#
#_Available timevary codes
#_Block types: 0: P_block=P_base*exp(TVP); 1: P_block=P_base+TVP; 2: P_block=TVP; 3: P_block=P_block(-1) + TVP
#_Block_trends: -1: trend bounded by base parm min-max and parms in transformed units (beware); -2: endtrend and infl_year direct values; -3: end and infl as fraction of base range
#_EnvLinks:  1: P(y)=P_base*exp(TVP*env(y));  2: P(y)=P_base+TVP*env(y);  3: P(y)=f(TVP,env_Zscore) w/ logit to stay in min-max;  4: P(y)=2.0/(1.0+exp(-TVP1*env(y) - TVP2))
#_DevLinks:  1: P(y)*=exp(dev(y)*dev_se;  2: P(y)+=dev(y)*dev_se;  3: random walk;  4: zero-reverting random walk with rho;  5: like 4 with logit transform to stay in base min-max
#_DevLinks(more):  21-25 keep last dev for rest of years
#
#_Prior_codes:  0=none; 6=normal; 1=symmetric beta; 2=CASAL's beta; 3=lognormal; 4=lognormal with biascorr; 5=gamma
#
# setup for M, growth, wt-len, maturity, fecundity, (hermaphro), recr_distr, cohort_grow, (movement), (age error), (catch_mult), sex ratio 
#_NATMORT
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity;_6=Lorenzen_range
  #_no additional input for selected M option; read 1P per morph
#
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
1 #_Age(post-settlement)_for_L1;linear growth below this
17 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0  #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
2 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
#
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
3 #_First_Mature_Age
2 #_fecundity_at_length option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset**; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)
#_** in option 1, any male parameter with value = 0.0 and phase <0 is set equal to female parameter
#
#_growth_parms
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
# Sex: 1  BioPattern: 1  NatMort
 0.005 0.5 0.160786 -1.7793 0.31 3 2 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 5 45 8.95726 17.18 10 0 3 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 35 80 47.4921 54.2 10 0 3 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0.04 0.5 0.194857 0.157 99 0 3 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0.5 15 1.35129 3 99 0 3 0 0 0 0 0 0 0 # SD_young_Fem_GP_1
 0.5 15 4.90344 3 99 0 4 0 0 0 0 0 0 0 # SD_old_Fem_GP_1
# Sex: 1  BioPattern: 1  WtLen
 -3 3 2.035e-06 2.035e-06 99 0 -3 0 0 0 0 0 0 0 # Wtlen_1_Fem_GP_1
 1 5 3.478 3.478 99 0 -3 0 0 0 0 0 0 0 # Wtlen_2_Fem_GP_1
# Sex: 1  BioPattern: 1  Maturity&Fecundity
 10 50 35.45 35.45 99 0 -3 0 0 0 0 0 0 0 # Mat50%_Fem_GP_1
 -3 3 -0.48921 -0.48921 99 0 -3 0 0 0 0 0 0 0 # Mat_slope_Fem_GP_1
 -3 1 3.2e-11 1 1 0 -3 0 0 0 0 0 0 0 # Eggs_scalar_Fem_GP_1
 -3 5 4.55 0 1 0 -3 0 0 0 0 0 0 0 # Eggs_exp_len_Fem_GP_1
# Sex: 2  BioPattern: 1  NatMort
 0.005 0.6 0.177074 -1.6809 0.31 3 2 0 0 0 0 0 0 0 # NatM_uniform_Mal_GP_1
# Sex: 2  BioPattern: 1  Growth
 0 45 0 17.18 10 0 -3 0 0 0 0 0 0 0 # L_at_Amin_Mal_GP_1
 35 80 39.9778 41.1 10 0 3 0 0 0 0 0 0 0 # L_at_Amax_Mal_GP_1
 0.04 0.5 0.242625 0.247 99 0 3 0 0 0 0 0 0 0 # VonBert_K_Mal_GP_1
 0.5 15 1.40832 3 99 0 3 0 0 0 0 0 0 0 # SD_young_Mal_GP_1
 0.5 15 3.41234 3 99 0 4 0 0 0 0 0 0 0 # SD_old_Mal_GP_1
# Sex: 2  BioPattern: 1  WtLen
 -3 3 3.043e-06 3.043e-06 99 0 -3 0 0 0 0 0 0 0 # Wtlen_1_Mal_GP_1
 -3 5 3.359 3.359 99 0 -3 0 0 0 0 0 0 0 # Wtlen_2_Mal_GP_1
# Hermaphroditism
#  Recruitment Distribution 
#  Cohort growth dev base
 0 1 1 1 0 0 -4 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
#  Age Error from parameters
#  catch multiplier
#  fraction female, by GP
 0.3 0.7 0.5 0.4 99 0 -5 0 0 0 0 0 0 0 # FracFemale_GP_1
#  M2 parameter for each predator fleet
#
#_no timevary MG parameters
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
3 #_Spawner-Recruitment; Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm
0  # 0/1 to use steepness in initial equ recruitment calculation
0  #  future feature:  0/1 to make realized sigmaR a function of SR curvature
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name
             5            20       9.90964             9            10             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           0.2             1           0.8           0.8          0.09             0         -5          0          0          0          0          0          0          0 # SR_BH_steep
             0             2           0.5           0.9             5             0        -99          0          0          0          0          0          0          0 # SR_sigmaR
            -5             5             0             0           0.2             0         -2          0          0          0          0          0          0          0 # SR_regime
             0             0             0             0             0             0        -99          0          0          0          0          0          0          0 # SR_autocorr
#_no timevary SR parameters
2 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1959 # first year of main recr_devs; early devs can preceed this era
2020 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase 
1 # (0/1) to read 13 advanced options
 1845 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 3 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1935.3 #_last_yr_nobias_adj_in_MPD; begin of ramp
 2002 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2015.7 #_last_yr_fullbias_adj_in_MPD
 2021.8 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
 0.8405 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
 0 #_period of cycles in recruitment (N parms read below)
 -4 #min rec_dev
 4 #max rec_dev
 0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_Yr Input_value
#
# all recruitment deviations
#  1845E 1846E 1847E 1848E 1849E 1850E 1851E 1852E 1853E 1854E 1855E 1856E 1857E 1858E 1859E 1860E 1861E 1862E 1863E 1864E 1865E 1866E 1867E 1868E 1869E 1870E 1871E 1872E 1873E 1874E 1875E 1876E 1877E 1878E 1879E 1880E 1881E 1882E 1883E 1884E 1885E 1886E 1887E 1888E 1889E 1890E 1891E 1892E 1893E 1894E 1895E 1896E 1897E 1898E 1899E 1900E 1901E 1902E 1903E 1904E 1905E 1906E 1907E 1908E 1909E 1910E 1911E 1912E 1913E 1914E 1915E 1916E 1917E 1918E 1919E 1920E 1921E 1922E 1923E 1924E 1925E 1926E 1927E 1928E 1929E 1930E 1931E 1932E 1933E 1934E 1935E 1936E 1937E 1938E 1939E 1940E 1941E 1942E 1943E 1944E 1945E 1946E 1947E 1948E 1949E 1950E 1951E 1952E 1953E 1954E 1955E 1956E 1957E 1958E 1959R 1960R 1961R 1962R 1963R 1964R 1965R 1966R 1967R 1968R 1969R 1970R 1971R 1972R 1973R 1974R 1975R 1976R 1977R 1978R 1979R 1980R 1981R 1982R 1983R 1984R 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017R 2018R 2019R 2020R 2021F 2022F 2023F 2024F 2025F 2026F 2027F 2028F 2029F 2030F 2031F 2032F 2033F 2034F
#  2.44917e-07 2.87697e-07 3.37924e-07 3.96885e-07 4.66081e-07 5.47267e-07 6.42489e-07 7.54126e-07 8.84943e-07 1.03814e-06 1.21742e-06 1.42703e-06 1.67185e-06 1.9574e-06 2.28997e-06 2.67649e-06 3.1247e-06 3.64304e-06 4.24059e-06 4.92688e-06 5.71167e-06 6.60458e-06 7.61465e-06 8.74994e-06 1.00179e-05 1.14281e-05 1.30009e-05 1.47722e-05 1.67804e-05 1.90594e-05 2.1645e-05 2.45849e-05 2.79127e-05 3.16872e-05 3.59681e-05 4.08226e-05 4.63261e-05 5.25642e-05 5.96338e-05 6.76444e-05 7.67198e-05 8.69999e-05 9.86428e-05 0.000111827 0.000126754 0.000143652 0.000162778 0.000184422 0.000208913 0.000236621 0.000267962 0.00030341 0.000343495 0.000388819 0.000440059 0.000497981 0.00056345 0.000637444 0.000721061 0.000815551 0.000922332 0.001043 0.00117938 0.00133353 0.00150773 0.00170489 0.00192789 0.00218019 0.00246548 0.00278751 0.00314978 0.0035561 0.0040118 0.00452256 0.00509851 0.00574849 0.00648267 0.00731092 0.00824641 0.00930899 0.0105196 0.0119086 0.0135161 0.0154001 0.0176544 0.0203926 0.0237483 0.0278692 0.0328769 0.0386111 0.0441209 0.0472995 0.0442209 0.0289263 -0.004813 -0.0591589 -0.126609 -0.188038 -0.217213 -0.193817 -0.14109 -0.131616 -0.153523 -0.173321 -0.17514 -0.157554 -0.13868 -0.144864 -0.166155 -0.182662 -0.213099 -0.258813 -0.263366 -0.141976 0.157411 0.350882 0.017175 -0.153233 -0.0597801 -0.0445642 1.01083 0.423994 -0.415559 -0.667539 -0.661541 -0.503384 -0.389364 -0.516829 -0.584531 -0.431542 -0.190642 0.00963278 -0.382013 -0.730063 -0.379263 -0.189536 -0.308273 -0.240239 0.314225 0.384489 -0.0556014 -0.462896 -0.0471907 0.247552 0.267121 0.164734 -0.134824 0.103347 0.154828 -0.134688 -0.100071 -0.157102 -0.0284102 0.668255 0.200201 -0.178939 -0.156787 0.10949 -0.193095 -0.0856845 -0.0768912 0.97892 0.934829 0.907241 0.289672 0.0638039 0.074357 0.455578 -0.0378338 -0.191128 0.088455 -0.0383193 -0.0916903 -0.234193 -0.114412 0.123743 -0.0357465 0 0 0 0 0 0 0 0 0 0 0 0 0
#
#Fishing Mortality info 
0.3 # F ballpark value in units of annual_F
-2001 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
4 # max F (methods 2-4) or harvest fraction (method 1)
5  # N iterations for tuning in hybrid mode; recommend 3 (faster) to 5 (more precise if many fleets)
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 0
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
#
# F rates by fleet x season
# Yr:  1876 1877 1878 1879 1880 1881 1882 1883 1884 1885 1886 1887 1888 1889 1890 1891 1892 1893 1894 1895 1896 1897 1898 1899 1900 1901 1902 1903 1904 1905 1906 1907 1908 1909 1910 1911 1912 1913 1914 1915 1916 1917 1918 1919 1920 1921 1922 1923 1924 1925 1926 1927 1928 1929 1930 1931 1932 1933 1934 1935 1936 1937 1938 1939 1940 1941 1942 1943 1944 1945 1946 1947 1948 1949 1950 1951 1952 1953 1954 1955 1956 1957 1958 1959 1960 1961 1962 1963 1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# North 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1.77758e-05 1.46018e-05 1.14107e-05 1.11318e-05 1.08554e-05 1.05776e-05 1.02985e-05 1.00142e-05 9.73212e-06 9.44845e-06 9.15945e-06 8.87249e-06 8.58382e-06 8.28967e-06 7.99746e-06 7.70344e-06 7.40757e-06 7.10602e-06 6.80634e-06 6.50472e-06 6.19686e-06 5.90153e-06 5.60445e-06 5.28691e-06 4.94848e-06 4.611e-06 4.28665e-06 3.96537e-06 3.65147e-06 3.33937e-06 3.01852e-06 2.83478e-06 4.02332e-08 0.000126408 0.000101131 0.00142678 0.00348241 0.00454658 0.00581737 0.00744423 0.00996142 0.0172193 0.0118616 0.0336591 0.0554032 0.0720353 0.185333 0.197313 0.115636 0.102662 0.17459 0.102171 0.249369 0.11727 0.236038 0.190499 0.160623 0.0799225 0.127906 0.139107 0.125731 0.241494 0.216651 0.171852 0.264739 0.271574 0.380246 0.380857 0.308331 0.299083 0.310341 0.287173 0.242997 0.272554 0.325395 0.352521 0.338805 0.339224 0.450498 0.502438 0.418171 0.437948 0.792295 0.953724 1.05234 1.07859 1.8417 1.18879 0.956899 0.893086 1.00391 1.49366 1.55037 1.44269 1.12141 1.22908 1.06981 0.66137 0.454532 0.518543 0.465415 0.507606 0.433797 0.380948 0.503995 0.519099 0.558778 0.851385 0.674849 0.865282 0.863001 0.654361 0.662356 0.684637 0.283462 0.272333 0.229954 0.346392 0.289955 0.304371 0.313891 0.319919 0.371819 0.345728 0.258838 0.35881 0.378626 0.276108 0.276108 0.255451 0.253986 0.252817 0.251617 0.250081 0.24884 0.247593 0.246038 0.244795 0.243556
# South 3.35851e-05 3.35859e-05 3.35866e-05 3.35872e-05 0.000387989 0.000742675 0.00109789 0.00145384 0.00181073 0.00216872 0.00252794 0.00288852 0.00325057 0.00361416 0.00397937 0.00434626 0.00471489 0.00508564 0.00545786 0.00583194 0.00620793 0.00658583 0.00696566 0.00734743 0.00773118 0.00811691 0.00850464 0.00889438 0.00928615 0.00967996 0.0100758 0.0104737 0.0108737 0.0112757 0.0116798 0.012086 0.0124942 0.0129045 0.0133169 0.0137312 0.0139682 0.0191074 0.0154505 0.0121703 0.00839948 0.010682 0.0154535 0.0155812 0.0194948 0.0194218 0.0192483 0.0234365 0.0231266 0.0264962 0.0248756 0.0236632 0.0211732 0.0161394 0.0425809 0.0347984 0.0199518 0.0320583 0.0391689 0.0467039 0.029245 0.0167336 0.0116856 0.0181851 0.0227844 0.0242237 0.056878 0.0662927 0.124918 0.13521 0.131052 0.0882248 0.0972006 0.115055 0.148847 0.134869 0.107392 0.137765 0.129431 0.110629 0.106089 0.151701 0.144665 0.166598 0.136199 0.129193 0.136846 0.126392 0.128358 0.121915 0.13525 0.129932 0.132081 0.0879867 0.118383 0.133269 0.142608 0.120119 0.168022 0.236606 0.207197 0.165366 0.180743 0.181889 0.203675 0.312346 0.278502 0.328085 0.311708 0.317946 0.256245 0.288804 0.209094 0.239021 0.244583 0.233457 0.306934 0.3099 0.168731 0.188778 0.210464 0.192592 0.15585 0.123113 0.133577 0.202942 0.21372 0.275842 0.289012 0.16707 0.0623006 0.0321799 0.0289219 0.0492763 0.0566404 0.0493302 0.0395548 0.0517771 0.0580996 0.0525772 0.0537103 0.0783344 0.103044 0.343496 0.343496 0.318094 0.316283 0.314829 0.313339 0.311435 0.309899 0.308359 0.306441 0.304909 0.303382
#
#_Q_setup for fleets with cpue or survey data
#_1:  fleet number
#_2:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm; 4=mirror with offset, 2 parm)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
         3         1         0         1         0         1  #  Triennial
         4         1         0         0         0         1  #  WCGBTS
         5         1         0         0         0         1  #  Env_index
-9999 0 0 0 0 0
#
#_Q_parms(if_any);Qunits_are_ln(q)
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
           -15            15     -0.801653             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_Triennial(3)
         0.001             2      0.273713          0.22            -1             0          5          0          0          0          0          0          0          0  #  Q_extraSD_Triennial(3)
           -15            15       1.42776             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_WCGBTS(4)
           -15            15     0.0103803             0             1             0         -1          0          0          0          0          0          0          0  #  Q_base_Env_index(5)
#_no timevary Q parameters
#
#_size_selex_patterns
#Pattern:_0;  parm=0; selex=1.0 for all sizes
#Pattern:_1;  parm=2; logistic; with 95% width specification
#Pattern:_5;  parm=2; mirror another size selex; PARMS pick the min-max bin to mirror
#Pattern:_11; parm=2; selex=1.0  for specified min-max population length bin range
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_6;  parm=2+special; non-parm len selex
#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (average over bin range)
#Pattern:_8;  parm=8; double_logistic with smooth transitions and constant above Linf option
#Pattern:_9;  parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset
#Pattern:_21; parm=2+special; non-parm len selex, read as pairs of size, then selex
#Pattern:_22; parm=4; double_normal as in CASAL
#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0
#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners
#Pattern:_2;  parm=6; double_normal with sel(minL) and sel(maxL), using joiners, back compatibile version of 24 with 3.30.18 and older
#Pattern:_25; parm=3; exponential-logistic in length
#Pattern:_27; parm=special+3; cubic spline in length; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=special+3+2; cubic spline; like 27, with 2 additional param for scaling (average over bin range)
#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention
#_Pattern Discard Male Special
 24 1 3 0 # 1 North
 24 1 3 0 # 2 South
 24 0 3 0 # 3 Triennial
 24 0 3 0 # 4 WCGBTS
 0 0 0 0 # 5 Env_index
#
#_age_selex_patterns
#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage
#Pattern:_10; parm=0; selex=1.0 for ages 1 to maxage
#Pattern:_11; parm=2; selex=1.0  for specified min-max age
#Pattern:_12; parm=2; age logistic
#Pattern:_13; parm=8; age double logistic. Recommend using pattern 18 instead.
#Pattern:_14; parm=nages+1; age empirical
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_16; parm=2; Coleraine - Gaussian
#Pattern:_17; parm=nages+1; empirical as random walk  N parameters to read can be overridden by setting special to non-zero
#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (average over bin range)
#Pattern:_18; parm=8; double logistic - smooth transition
#Pattern:_19; parm=6; simple 4-parm double logistic with starting age
#Pattern:_20; parm=6; double_normal,using joiners
#Pattern:_26; parm=3; exponential-logistic in age
#Pattern:_27; parm=3+special; cubic spline in age; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=2+special+3; // cubic spline; with 2 additional param for scaling (average over bin range)
#Age patterns entered with value >100 create Min_selage from first digit and pattern from remainder
#_Pattern Discard Male Special
 10 0 0 0 # 1 North
 10 0 0 0 # 2 South
 10 0 0 0 # 3 Triennial
 10 0 0 0 # 4 WCGBTS
 0 0 0 0 # 5 Env_index
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   North LenSelex
            15            75        61.146          43.1            99             0          2          0          0          0          0          0          1          2  #  Size_DblN_peak_North(1)
           -15             4           -15           -15            99             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_North(1)
            -4            12       5.23664          3.42            99             0          3          0          0          0          0          0          1          2  #  Size_DblN_ascend_se_North(1)
            -2            20            20          0.21            99             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_North(1)
          -999             9          -999          -8.9            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_North(1)
          -999             9          -999          0.15            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_end_logit_North(1)
            10            40       28.4154            15            99             0          2          0          0          0          0          0          2          2  #  Retain_L_infl_North(1)
           0.1            10       1.35794             3            99             0          4          0          0          0          0          0          2          2  #  Retain_L_width_North(1)
           -10            10       9.65385            10            99             0          4          0          0          0          0          0          2          2  #  Retain_L_asymptote_logit_North(1)
           -10            10             0             0            99             0         -2          0          0          0          0          0          0          0  #  Retain_L_maleoffset_North(1)
           -25            15      -17.5975             0            99             0          4          0          0          0          0          0          0          0  #  SzSel_Male_Peak_North(1)
           -15            15      -1.68962             0            99             0          4          0          0          0          0          0          0          0  #  SzSel_Male_Ascend_North(1)
           -15            15             0             0            99             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Descend_North(1)
           -15            15             0             0            99             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Final_North(1)
           -15            15             1             0            99             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Scale_North(1)
# 2   South LenSelex
            15            75        54.672          43.1            99             0          2          0          0          0          0          0          1          2  #  Size_DblN_peak_South(2)
           -15             4           -15           -15            99             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_South(2)
            -4            12       5.95836          3.42            99             0          3          0          0          0          0          0          1          2  #  Size_DblN_ascend_se_South(2)
            -2            20            20          0.21            99             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_South(2)
          -999             9          -999          -8.9            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_South(2)
          -999             9          -999          0.15            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_end_logit_South(2)
            10            40       28.2588            15            99             0          2          0          0          0          0          0          3          2  #  Retain_L_infl_South(2)
           0.1            10       1.15743             3            99             0          3          0          0          0          0          0          3          2  #  Retain_L_width_South(2)
           -10            10       6.66553            10            99             0          4          0          0          0          0          0          3          2  #  Retain_L_asymptote_logit_South(2)
           -10            10             0             0            99             0         -2          0          0          0          0          0          0          0  #  Retain_L_maleoffset_South(2)
           -25            15      -16.0981             0            99             0          4          0          0          0          0          0          0          0  #  SzSel_Male_Peak_South(2)
           -15            15      -1.98501             0            99             0          4          0          0          0          0          0          0          0  #  SzSel_Male_Ascend_South(2)
           -15            15             0             0            99             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Descend_South(2)
           -15            15             0             0            99             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Final_South(2)
           -15            15             1             0            99             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Scale_South(2)
# 3   Triennial LenSelex
            15            61       35.4369          43.1            99             0          2          0          0          0          0          0          0          0  #  Size_DblN_peak_Triennial(3)
           -15             4           -15            -1            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_top_logit_Triennial(3)
            -4            12        4.4431          3.42            99             0          2          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_Triennial(3)
            -2            20            20          0.21            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_descend_se_Triennial(3)
          -999             9          -999          -8.9            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_Triennial(3)
          -999             9          -999          0.15            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_end_logit_Triennial(3)
           -15            15      -3.28244             0            99             0          3          0          0          0          0          0          0          0  #  SzSel_Male_Peak_Triennial(3)
           -15            15     -0.228495             0            99             0          3          0          0          0          0          0          0          0  #  SzSel_Male_Ascend_Triennial(3)
           -15            15             0             0            99             0         -3          0          0          0          0          0          0          0  #  SzSel_Male_Descend_Triennial(3)
           -15            15             0             0            99             0         -3          0          0          0          0          0          0          0  #  SzSel_Male_Final_Triennial(3)
           -15            15             1             0            99             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Scale_Triennial(3)
# 4   WCGBTS LenSelex
            15            61       51.7926          43.1            99             0          2          0          0          0          0          0          0          0  #  Size_DblN_peak_WCGBTS(4)
           -15             4           -15            -1            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_top_logit_WCGBTS(4)
            -4            12       5.67419          3.42            99             0          2          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_WCGBTS(4)
            -2            20            20          0.21            99             0         -2          0          0          0          0          0          0          0  #  Size_DblN_descend_se_WCGBTS(4)
          -999             9          -999          -8.9            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_WCGBTS(4)
          -999             9          -999          0.15            99             0         -4          0          0          0          0          0          0          0  #  Size_DblN_end_logit_WCGBTS(4)
           -15            15      -11.2519             0            99             0          3          0          0          0          0          0          0          0  #  SzSel_Male_Peak_WCGBTS(4)
           -15            15     -0.847369             0            99             0          3          0          0          0          0          0          0          0  #  SzSel_Male_Ascend_WCGBTS(4)
           -15            15             0             0            99             0         -3          0          0          0          0          0          0          0  #  SzSel_Male_Descend_WCGBTS(4)
           -15            15             0             0            99             0         -3          0          0          0          0          0          0          0  #  SzSel_Male_Final_WCGBTS(4)
           -15            15             1             0            99             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Scale_WCGBTS(4)
# 5   Env_index LenSelex
# 1   North AgeSelex
# 2   South AgeSelex
# 3   Triennial AgeSelex
# 4   WCGBTS AgeSelex
# 5   Env_index AgeSelex
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
            15            75       61.4695          43.1            99             0      5  # Size_DblN_peak_North(1)_BLK1repl_1973
            15            75        58.001          43.1            99             0      5  # Size_DblN_peak_North(1)_BLK1repl_1983
            15            75       56.6823          43.1            99             0      5  # Size_DblN_peak_North(1)_BLK1repl_1993
            15            75       58.0286          43.1            99             0      5  # Size_DblN_peak_North(1)_BLK1repl_2003
            15            75       58.2884          43.1            99             0      5  # Size_DblN_peak_North(1)_BLK1repl_2011
            15            75       58.6386          43.1            99             0      5  # Size_DblN_peak_North(1)_BLK1repl_2018
            -4            12       5.48218          3.42            99             0      6  # Size_DblN_ascend_se_North(1)_BLK1repl_1973
            -4            12       5.36986          3.42            99             0      6  # Size_DblN_ascend_se_North(1)_BLK1repl_1983
            -4            12       5.59219          3.42            99             0      6  # Size_DblN_ascend_se_North(1)_BLK1repl_1993
            -4            12       5.45769          3.42            99             0      6  # Size_DblN_ascend_se_North(1)_BLK1repl_2003
            -4            12       5.36818          3.42            99             0      6  # Size_DblN_ascend_se_North(1)_BLK1repl_2011
            -4            12       5.22549          3.42            99             0      6  # Size_DblN_ascend_se_North(1)_BLK1repl_2018
            10            40       31.2994            15            99             0      5  # Retain_L_infl_North(1)_BLK2repl_2002
            10            40       29.9752            15            99             0      5  # Retain_L_infl_North(1)_BLK2repl_2003
            10            40       31.5581            15            99             0      5  # Retain_L_infl_North(1)_BLK2repl_2009
            10            40        27.048            15            99             0      5  # Retain_L_infl_North(1)_BLK2repl_2011
           0.1            10      0.874991             3            99             0      5  # Retain_L_width_North(1)_BLK2repl_2002
           0.1            10       1.35282             3            99             0      5  # Retain_L_width_North(1)_BLK2repl_2003
           0.1            10       1.69822             3            99             0      5  # Retain_L_width_North(1)_BLK2repl_2009
           0.1            10       1.67478             3            99             0      5  # Retain_L_width_North(1)_BLK2repl_2011
           -10            10       9.74543             0            99             0      5  # Retain_L_asymptote_logit_North(1)_BLK2repl_2002
           -10            10       6.22644             0            99             0      5  # Retain_L_asymptote_logit_North(1)_BLK2repl_2003
           -10            10       3.67483             0            99             0      5  # Retain_L_asymptote_logit_North(1)_BLK2repl_2009
           -10            10       7.55173             0            99             0      5  # Retain_L_asymptote_logit_North(1)_BLK2repl_2011
            15            75       51.2317          43.1            99             0      5  # Size_DblN_peak_South(2)_BLK1repl_1973
            15            75        49.041          43.1            99             0      5  # Size_DblN_peak_South(2)_BLK1repl_1983
            15            75       50.8457          43.1            99             0      5  # Size_DblN_peak_South(2)_BLK1repl_1993
            15            75       51.3077          43.1            99             0      5  # Size_DblN_peak_South(2)_BLK1repl_2003
            15            75       51.0185          43.1            99             0      5  # Size_DblN_peak_South(2)_BLK1repl_2011
            15            75       51.9028          43.1            99             0      5  # Size_DblN_peak_South(2)_BLK1repl_2018
            -4            12       6.27068          3.42            99             0      6  # Size_DblN_ascend_se_South(2)_BLK1repl_1973
            -4            12       5.24535          3.42            99             0      6  # Size_DblN_ascend_se_South(2)_BLK1repl_1983
            -4            12       4.90668          3.42            99             0      6  # Size_DblN_ascend_se_South(2)_BLK1repl_1993
            -4            12       4.99167          3.42            99             0      6  # Size_DblN_ascend_se_South(2)_BLK1repl_2003
            -4            12       4.97212          3.42            99             0      6  # Size_DblN_ascend_se_South(2)_BLK1repl_2011
            -4            12       4.90264          3.42            99             0      6  # Size_DblN_ascend_se_South(2)_BLK1repl_2018
            10            40       30.8191            15            99             0      5  # Retain_L_infl_South(2)_BLK3repl_2010
            10            40       25.0665            15            99             0      5  # Retain_L_infl_South(2)_BLK3repl_2011
           0.1            10       1.87159             3            99             0      5  # Retain_L_width_South(2)_BLK3repl_2010
           0.1            10       1.62782             3            99             0      5  # Retain_L_width_South(2)_BLK3repl_2011
           -10            10       9.34935             0            99             0      5  # Retain_L_asymptote_logit_South(2)_BLK3repl_2010
           -10            10       8.12084             0            99             0      5  # Retain_L_asymptote_logit_South(2)_BLK3repl_2011
# info on dev vectors created for selex parms are reported with other devs after tag parameter section 
#
0   #  use 2D_AR1 selectivity(0/1)
#_no 2D_AR1 selex offset used
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read and autogen if tag data exist; 1=read
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# deviation vectors for timevary parameters
#  base   base first block   block  env  env   dev   dev   dev   dev   dev
#  type  index  parm trend pattern link  var  vectr link _mnyr  mxyr phase  dev_vector
#      5     1     1     1     2     0     0     0     0     0     0     0
#      5     3     7     1     2     0     0     0     0     0     0     0
#      5     7    13     2     2     0     0     0     0     0     0     0
#      5     8    17     2     2     0     0     0     0     0     0     0
#      5     9    21     2     2     0     0     0     0     0     0     0
#      5    16    25     1     2     0     0     0     0     0     0     0
#      5    18    31     1     2     0     0     0     0     0     0     0
#      5    22    37     3     2     0     0     0     0     0     0     0
#      5    23    39     3     2     0     0     0     0     0     0     0
#      5    24    41     3     2     0     0     0     0     0     0     0
     #
# Input variance adjustments factors: 
 #_1=add_to_survey_CV
 #_2=add_to_discard_stddev
 #_3=add_to_bodywt_CV
 #_4=mult_by_lencomp_N
 #_5=mult_by_agecomp_N
 #_6=mult_by_size-at-age_N
 #_7=mult_by_generalized_sizecomp
#_Factor  Fleet  Value
      4      1  0.277766
      4      2  0.135516
      4      3  0.289957
      4      4  0.101749
      5      1  0.279775
      5      2  0.081769
      5      4  0.040054
 -9999   1    0  # terminator
#
15 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 0 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
-9999  1  1  1  1  #  terminator
#
# lambdas (for info only; columns are phases)
#  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 #_CPUE/survey:_1
#  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 #_CPUE/survey:_2
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_CPUE/survey:_3
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_CPUE/survey:_4
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_CPUE/survey:_5
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_discard:_1
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_discard:_2
#  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 #_discard:_3
#  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 #_discard:_4
#  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 #_discard:_5
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_meanbodywt:1
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_meanbodywt:2
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_meanbodywt:3
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_meanbodywt:4
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_meanbodywt:5
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_lencomp:_1
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_lencomp:_2
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_lencomp:_3
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_lencomp:_4
#  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 #_lencomp:_5
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_agecomp:_1
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_agecomp:_2
#  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 #_agecomp:_3
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_agecomp:_4
#  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 #_agecomp:_5
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_init_equ_catch1
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_init_equ_catch2
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_init_equ_catch3
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_init_equ_catch4
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_init_equ_catch5
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_recruitments
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_parameter-priors
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_parameter-dev-vectors
#  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 #_crashPenLambda
#  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 # F_ballpark_lambda
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999
