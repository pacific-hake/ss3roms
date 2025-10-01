#C forecast file written by R function SS_writeforecast
#C rerun model to get more complete formatting in forecast.ss_new
#C should work with SS version: 3.3
#C file write time: 2025-08-20 17:07:33.709921
#
1 #_benchmarks
2 #_MSY
0.3 #_SPRtarget
0.25 #_Btarget
#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF,  beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)
-1 -1 -1 -1 -1 -1 -999 0 -999 0
2 #_Bmark_relF_Basis
2 #_Forecast
12 #_Nforecastyrs
1 #_F_scalar
#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF, beg_recruits, end_recruits (enter actual year, or values of 0 or -integer to be rel. endyr)
0 0 -10 0 -999 0
0 #_Fcast_selex
3 #_ControlRuleMethod
0.25 #_BforconstantF
0.05 #_BfornoF
-1 #_Flimitfraction
 #_Year Fraction
   2023    1.000
   2024    1.000
   2025    0.935
   2026    0.930
   2027    0.926
   2028    0.922
   2029    0.917
   2030    0.913
   2031    0.909
   2032    0.904
   2033    0.900
   2034    0.896
-9999 0
3 #_N_forecast_loops
3 #_First_forecast_loop_with_stochastic_recruitment
0 #_fcast_rec_option
1 #_fcast_rec_val
0 #_Fcast_loop_control_5
2035 #_FirstYear_for_caps_and_allocations
0 #_stddev_of_log_catch_ratio
0 #_Do_West_Coast_gfish_rebuilder_output
2013 #_Ydecl
2015 #_Yinit
2 #_fleet_relative_F
# Note that fleet allocation is used directly as average F if Do_Forecast=4 
2 #_basis_for_fcast_catch_tuning
#_vals_fleet_relative_f
 #_Season Fleet Relative F
        1     1    0.44562
        1     2    0.55438
-9999 0 0
# enter list of fleet number and max for fleets with max annual catch; terminate with fleet=-9999
-9999 -1
# enter list of area ID and max annual catch; terminate with area=-9999
-9999 -1
# enter list of fleet number and allocation group assignment, if any; terminate with fleet=-9999
-9999 -1
2 #_InputBasis
 #_Year Seas Fleet Catch or F
   2023    1     1   1590.470
   2024    1     1   1605.180
   2025    1     1   1645.130
   2026    1     1   1710.710
   2027    1     1   1787.120
   2028    1     1   1855.550
   2029    1     1   1907.900
   2030    1     1   1950.870
   2031    1     1   1997.570
   2032    1     1   2055.240
   2033    1     1   2119.860
   2034    1     1   2178.090
   2023    1     2    785.796
   2024    1     2    816.174
   2025    1     2    853.021
   2026    1     2    886.745
   2027    1     2    912.608
   2028    1     2    933.271
   2029    1     2    955.167
   2030    1     2    982.314
   2031    1     2   1013.540
   2032    1     2   1043.010
   2033    1     2   1062.320
   2034    1     2   1064.160
-9999 0 0 0
#
999 # verify end of input 
