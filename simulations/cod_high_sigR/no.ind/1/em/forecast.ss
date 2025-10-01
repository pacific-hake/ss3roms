#C forecast file written by R function SS_writeforecast
#C rerun model to get more complete formatting in forecast.ss_new
#C should work with SS version: 3.3
#C file write time: 2025-08-22 16:04:22.882127
#
1 #_benchmarks
2 #_MSY
0.4 #_SPRtarget
0.4 #_Btarget
#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF,  beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)
0 0 0 0 0 0 -999 0 -999 0
1 #_Bmark_relF_Basis
2 #_Forecast
12 #_Nforecastyrs
0 #_F_scalar
#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF, beg_recruits, end_recruits (enter actual year, or values of 0 or -integer to be rel. endyr)
0 0 0 0 -999 0
0 #_Fcast_selex
2 #_ControlRuleMethod
0.4 #_BforconstantF
0.01 #_BfornoF
1 #_Flimitfraction
3 #_N_forecast_loops
3 #_First_forecast_loop_with_stochastic_recruitment
0 #_fcast_rec_option
1 #_fcast_rec_val
0 #_Fcast_loop_control_5
113 #_FirstYear_for_caps_and_allocations
0 #_stddev_of_log_catch_ratio
0 #_Do_West_Coast_gfish_rebuilder_output
100 #_Ydecl
100 #_Yinit
1 #_fleet_relative_F
# Note that fleet allocation is used directly as average F if Do_Forecast=4 
2 #_basis_for_fcast_catch_tuning
# enter list of fleet number and max for fleets with max annual catch; terminate with fleet=-9999
-9999 -1
# enter list of area ID and max annual catch; terminate with area=-9999
-9999 -1
# enter list of fleet number and allocation group assignment, if any; terminate with fleet=-9999
-9999 -1
2 #_InputBasis
 #_Year Seas Fleet Catch or F
    101    1     1  194270000
    102    1     1  210379000
    103    1     1  232718000
    104    1     1  238773000
    105    1     1  228592000
    106    1     1  218292000
    107    1     1  218283000
    108    1     1  231241000
    109    1     1  250058000
    110    1     1  260380000
    111    1     1  264906000
    112    1     1  257113000
-9999 0 0 0
#
999 # verify end of input 
