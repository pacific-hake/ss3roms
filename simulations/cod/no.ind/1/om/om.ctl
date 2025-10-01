#V3.30
#C file created using the SS_writectl function in the R package r4ss
#C file write time: 2024-09-26 13:54:40.731767
#
0 # 0 means do not read wtatage.ss; 1 means read and usewtatage.ss and also read and use growth parameters
1 #_N_Growth_Patterns
1 #_N_platoons_Within_GrowthPattern
2 # recr_dist_method for parameters
1 # not yet implemented; Future usage:Spawner-Recruitment; 1=global; 2=by area
1 # number of recruitment settlement assignments 
0 # unused option
# for each settlement assignment:
#_GPattern	month	area	age
1	1	1	0	#_recr_dist_pattern1
#
#_Cond 0 # N_movement_definitions goes here if N_areas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
0 #_Nblock_Patterns
#_Cond 0 #_blocks_per_pattern
# begin and end years of blocks
#
# controls for all timevary parameters 
1 #_env/block/dev_adjust_method for all time-vary parms (1=warn relative to base parm bounds; 3=no bound check)
#
# AUTOGEN
0 0 0 0 0 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen all time-varying parms; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
#
# setup for M, growth, maturity, fecundity, recruitment distibution, movement
#
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=Maunder_M;_6=Age-range_Lorenzen
#_no additional input for selected M option; read 1P per morph
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr;5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
1 #_Age(post-settlement)_for_L1;linear growth below this
999 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0 #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
0 #_First_Mature_Age
1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
#
#_growth_parms
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env_var&link	dev_link	dev_minyr	dev_maxyr	dev_PH	Block	Block_Fxn
 0.01	     1.8	    0.2	    0.1	0.8	0	 -3	0	0	0	0	0	0	0	#_NatM_p_1_Fem_GP_1  
    1	     100	     20	   30.8	0.2	0	  4	0	0	0	0	0	0	0	#_L_at_Amin_Fem_GP_1 
  6.6	     660	    132	  120.1	0.2	0	  4	0	0	0	0	0	0	0	#_L_at_Amax_Fem_GP_1 
0.001	       1	    0.2	   0.25	0.8	0	  4	0	0	0	0	0	0	0	#_VonBert_K_Fem_GP_1 
0.001	     0.5	    0.1	    0.1	0.8	0	  5	0	0	0	0	0	0	0	#_CV_young_Fem_GP_1  
0.001	     0.5	    0.1	    0.1	0.8	0	  5	0	0	0	0	0	0	0	#_CV_old_Fem_GP_1    
    0	       3	6.8e-06	6.8e-06	  0	0	 -3	0	0	0	0	0	0	0	#_Wtlen_1_Fem_GP_1   
  2.5	     3.5	  3.101	  3.101	0.2	0	 -3	0	0	0	0	0	0	0	#_Wtlen_2_Fem_GP_1   
   10	      50	  38.18	      0	  0	0	-99	0	0	0	0	0	0	0	#_Mat50%_Fem_GP_1    
   -2	       2	 -0.276	      0	  0	0	-99	0	0	0	0	0	0	0	#_Mat_slope_Fem_GP_1 
   -3	       3	      1	      0	  0	0	-99	0	0	0	0	0	0	0	#_Eggs_alpha_Fem_GP_1
   -3	       4	      0	      0	  0	0	-99	0	0	0	0	0	0	0	#_Eggs_beta_Fem_GP_1 
   -4	       4	      0	      0	  0	0	-99	0	0	0	0	0	0	0	#_RecrDist_GP_1      
   -4	       4	      0	      0	  0	0	-99	0	0	0	0	0	0	0	#_RecrDist_Area_1    
   -4	       4	      0	      0	  0	0	-99	0	0	0	0	0	0	0	#_RecrDist_month_1   
   -4	       4	      1	      0	  0	0	-99	0	0	0	0	0	0	0	#_CohortGrowDev      
1e-06	0.999999	    0.5	    0.5	0.5	0	-99	0	0	0	0	0	0	0	#_FracFemale_GP_1    
#_no timevary MG parameters
#
#_seasonal_effects_on_biology_parms
0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
3 #_Spawner-Recruitment; 2=Ricker; 3=std_B-H; 4=SCAA;5=Hockey; 6=B-H_flattop; 7=survival_3Parm;8=Shepard_3Parm
0 # 0/1 to use steepness in initial equ recruitment calculation
0 # future feature: 0/1 to make realized sigmaR a function of SR curvature
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn # parm_name
  4	20	18.7	10.3	  10	0	  1	0	0	0	0	0	0	0	#_SR_LN(R0)  
0.2	 1	0.65	 0.7	0.05	0	 -3	0	0	0	0	0	0	0	#_SR_BH_steep
  0	 2	 0.4	 0.8	 0.8	0	-99	0	0	0	0	0	0	0	#_SR_sigmaR  
 -5	 5	   0	   0	   1	0	-99	0	0	0	0	0	0	0	#_SR_regime  
  0	 0	   0	   0	   0	0	 -6	0	0	0	0	0	0	0	#_SR_autocorr
#_no timevary SR parameters
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1 # first year of main recr_devs; early devs can preceed this era
100 # last year of main recr_devs; forecast devs start in following year
-2 #_recdev phase
1 # (0/1) to read 13 advanced options
0 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
-4 #_recdev_early_phase
0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
1 #_lambda for Fcast_recr_like occurring before endyr+1
1 #_last_yr_nobias_adj_in_MPD; begin of ramp
1 #_first_yr_fullbias_adj_in_MPD; begin of plateau
100 #_last_yr_fullbias_adj_in_MPD
100 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS sets bias_adj to 0.0 for fcast yrs)
0 #_max_bias_adj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)
0 #_period of cycles in recruitment (N parms read below)
-10 #min rec_dev
10 #max rec_dev
113 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
#_Year	recdev
  1	   0.229622	#_recdev_input1  
  2	   0.227402	#_recdev_input2  
  3	  -0.512473	#_recdev_input3  
  4	  -0.542136	#_recdev_input4  
  5	   0.020815	#_recdev_input5  
  6	   0.154919	#_recdev_input6  
  7	  -0.342745	#_recdev_input7  
  8	   0.202322	#_recdev_input8  
  9	 -0.0964152	#_recdev_input9  
 10	   -0.25655	#_recdev_input10 
 11	  -0.471352	#_recdev_input11 
 12	  -0.219541	#_recdev_input12 
 13	    0.28875	#_recdev_input13 
 14	  -0.284824	#_recdev_input14 
 15	  -0.701588	#_recdev_input15 
 16	  0.0121023	#_recdev_input16 
 17	  0.0745204	#_recdev_input17 
 18	   0.188476	#_recdev_input18 
 19	  -0.145422	#_recdev_input19 
 20	 -0.0723295	#_recdev_input20 
 21	    0.15027	#_recdev_input21 
 22	   0.337453	#_recdev_input22 
 23	    0.22374	#_recdev_input23 
 24	   0.321305	#_recdev_input24 
 25	  -0.433719	#_recdev_input25 
 26	 -0.0551646	#_recdev_input26 
 27	 -0.0564624	#_recdev_input27 
 28	   0.336218	#_recdev_input28 
 29	   0.221023	#_recdev_input29 
 30	  0.0441506	#_recdev_input30 
 31	  -0.286911	#_recdev_input31 
 32	   0.168463	#_recdev_input32 
 33	   0.195242	#_recdev_input33 
 34	 -0.0224826	#_recdev_input34 
 35	  -0.730319	#_recdev_input35 
 36	   0.329086	#_recdev_input36 
 37	  -0.667365	#_recdev_input37 
 38	    0.27484	#_recdev_input38 
 39	   -0.63453	#_recdev_input39 
 40	  -0.268896	#_recdev_input40 
 41	  -0.530449	#_recdev_input41 
 42	    0.78281	#_recdev_input42 
 43	   -1.23437	#_recdev_input43 
 44	  -0.855045	#_recdev_input44 
 45	    0.31323	#_recdev_input45 
 46	-0.00653502	#_recdev_input46 
 47	  -0.639898	#_recdev_input47 
 48	   -0.14345	#_recdev_input48 
 49	   0.161491	#_recdev_input49 
 50	  -0.690906	#_recdev_input50 
 51	  -0.142222	#_recdev_input51 
 52	  -0.223308	#_recdev_input52 
 53	  -0.397632	#_recdev_input53 
 54	   0.201299	#_recdev_input54 
 55	  0.0633371	#_recdev_input55 
 56	  -0.113998	#_recdev_input56 
 57	  -0.622586	#_recdev_input57 
 58	 -0.0918575	#_recdev_input58 
 59	   0.548266	#_recdev_input59 
 60	  -0.395573	#_recdev_input60 
 61	  -0.106251	#_recdev_input61 
 62	   0.036528	#_recdev_input62 
 63	 -0.0135152	#_recdev_input63 
 64	  -0.209806	#_recdev_input64 
 65	   0.139152	#_recdev_input65 
 66	  -0.237084	#_recdev_input66 
 67	 -0.0109651	#_recdev_input67 
 68	  -0.113468	#_recdev_input68 
 69	    0.18214	#_recdev_input69 
 70	  -0.310513	#_recdev_input70 
 71	   0.950216	#_recdev_input71 
 72	  -0.875865	#_recdev_input72 
 73	    0.54848	#_recdev_input73 
 74	  -0.213545	#_recdev_input74 
 75	  -0.658865	#_recdev_input75 
 76	   -0.26856	#_recdev_input76 
 77	   0.204752	#_recdev_input77 
 78	  -0.266597	#_recdev_input78 
 79	  -0.384859	#_recdev_input79 
 80	 -0.0591471	#_recdev_input80 
 81	   0.067037	#_recdev_input81 
 82	  -0.107678	#_recdev_input82 
 83	   0.521293	#_recdev_input83 
 84	  -0.237555	#_recdev_input84 
 85	  -0.397719	#_recdev_input85 
 86	   0.793647	#_recdev_input86 
 87	   0.697975	#_recdev_input87 
 88	 -0.0653337	#_recdev_input88 
 89	  -0.448698	#_recdev_input89 
 90	  -0.220747	#_recdev_input90 
 91	   0.242954	#_recdev_input91 
 92	  -0.109102	#_recdev_input92 
 93	  -0.222462	#_recdev_input93 
 94	   0.242876	#_recdev_input94 
 95	  -0.706325	#_recdev_input95 
 96	  0.0254052	#_recdev_input96 
 97	   0.551045	#_recdev_input97 
 98	   0.407012	#_recdev_input98 
 99	  -0.117017	#_recdev_input99 
100	  -0.459598	#_recdev_input100
101	  0.0966594	#_recdev_input101
102	   0.242804	#_recdev_input102
103	   0.375751	#_recdev_input103
104	   0.491215	#_recdev_input104
105	  -0.120216	#_recdev_input105
106	   0.419397	#_recdev_input106
107	    -0.3094	#_recdev_input107
108	  -0.308365	#_recdev_input108
109	  -0.338268	#_recdev_input109
110	  -0.495422	#_recdev_input110
111	  0.0328953	#_recdev_input111
112	  -0.570223	#_recdev_input112
113	  -0.544238	#_recdev_input113
#
#Fishing Mortality info
0.3 # F ballpark
-2001 # F ballpark year (neg value to disable)
2 # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
4 # max F or harvest rate, depends on F_Method
#_overall start F value; overall phase; N detailed inputs to read
0 1 87 #_F_setup
#_Fleet	Yr	Seas	F_value	se	phase
1	 26	1	0.1052	0.005	1	#_1 
1	 27	1	0.1052	0.005	1	#_2 
1	 28	1	0.1052	0.005	1	#_3 
1	 29	1	0.1052	0.005	1	#_4 
1	 30	1	0.1052	0.005	1	#_5 
1	 31	1	0.1052	0.005	1	#_6 
1	 32	1	0.1052	0.005	1	#_7 
1	 33	1	0.1052	0.005	1	#_8 
1	 34	1	0.1052	0.005	1	#_9 
1	 35	1	0.1052	0.005	1	#_10
1	 36	1	0.1052	0.005	1	#_11
1	 37	1	0.1052	0.005	1	#_12
1	 38	1	0.1052	0.005	1	#_13
1	 39	1	0.1052	0.005	1	#_14
1	 40	1	0.1052	0.005	1	#_15
1	 41	1	0.1052	0.005	1	#_16
1	 42	1	0.1052	0.005	1	#_17
1	 43	1	0.1052	0.005	1	#_18
1	 44	1	0.1052	0.005	1	#_19
1	 45	1	0.1052	0.005	1	#_20
1	 46	1	0.1052	0.005	1	#_21
1	 47	1	0.1052	0.005	1	#_22
1	 48	1	0.1052	0.005	1	#_23
1	 49	1	0.1052	0.005	1	#_24
1	 50	1	0.1052	0.005	1	#_25
1	 51	1	0.1052	0.005	1	#_26
1	 52	1	0.1052	0.005	1	#_27
1	 53	1	0.1052	0.005	1	#_28
1	 54	1	0.1052	0.005	1	#_29
1	 55	1	0.1052	0.005	1	#_30
1	 56	1	0.1052	0.005	1	#_31
1	 57	1	0.1052	0.005	1	#_32
1	 58	1	0.1052	0.005	1	#_33
1	 59	1	0.1052	0.005	1	#_34
1	 60	1	0.1052	0.005	1	#_35
1	 61	1	0.1052	0.005	1	#_36
1	 62	1	0.1052	0.005	1	#_37
1	 63	1	0.1052	0.005	1	#_38
1	 64	1	0.1052	0.005	1	#_39
1	 65	1	0.1052	0.005	1	#_40
1	 66	1	0.1052	0.005	1	#_41
1	 67	1	0.1052	0.005	1	#_42
1	 68	1	0.1052	0.005	1	#_43
1	 69	1	0.1052	0.005	1	#_44
1	 70	1	0.1052	0.005	1	#_45
1	 71	1	0.1052	0.005	1	#_46
1	 72	1	0.1052	0.005	1	#_47
1	 73	1	0.1052	0.005	1	#_48
1	 74	1	0.1052	0.005	1	#_49
1	 75	1	0.1052	0.005	1	#_50
1	 76	1	0.1052	0.005	1	#_51
1	 77	1	0.1052	0.005	1	#_52
1	 78	1	0.1052	0.005	1	#_53
1	 79	1	0.1052	0.005	1	#_54
1	 80	1	0.1052	0.005	1	#_55
1	 81	1	0.1052	0.005	1	#_56
1	 82	1	0.1052	0.005	1	#_57
1	 83	1	0.1052	0.005	1	#_58
1	 84	1	0.1052	0.005	1	#_59
1	 85	1	0.1052	0.005	1	#_60
1	 86	1	0.1052	0.005	1	#_61
1	 87	1	0.1052	0.005	1	#_62
1	 88	1	0.1052	0.005	1	#_63
1	 89	1	0.1052	0.005	1	#_64
1	 90	1	0.1052	0.005	1	#_65
1	 91	1	0.1052	0.005	1	#_66
1	 92	1	0.1052	0.005	1	#_67
1	 93	1	0.1052	0.005	1	#_68
1	 94	1	0.1052	0.005	1	#_69
1	 95	1	0.1052	0.005	1	#_70
1	 96	1	0.1052	0.005	1	#_71
1	 97	1	0.1052	0.005	1	#_72
1	 98	1	0.1052	0.005	1	#_73
1	 99	1	0.1052	0.005	1	#_74
1	100	1	0.1052	0.005	1	#_75
1	101	1	0.1052	0.005	1	#_76
1	102	1	0.1052	0.005	1	#_77
1	103	1	0.1052	0.005	1	#_78
1	104	1	0.1052	0.005	1	#_79
1	105	1	0.1052	0.005	1	#_80
1	106	1	0.1052	0.005	1	#_81
1	107	1	0.1052	0.005	1	#_82
1	108	1	0.1052	0.005	1	#_83
1	109	1	0.1052	0.005	1	#_84
1	110	1	0.1052	0.005	1	#_85
1	111	1	0.1052	0.005	1	#_86
1	112	1	0.1052	0.005	1	#_87
#
#_initial_F_parms; count = 0
#
#_Q_setup for fleets with cpue or survey data
#_fleet	link	link_info	extra_se	biasadj	float  #  fleetname
    2	1	0	0	0	0	#_Survey    
    3	1	0	0	0	0	#_env       
-9999	0	0	0	0	0	#_terminator
#_Q_parms(if_any);Qunits_are_ln(q)
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn  #  parm_name
  -20	20	0	0	99	0	-5	0	0	0	0	0	0	0	#_LnQ_base_Survey(2)
0.001	20	1	0	99	0	-1	0	0	0	0	0	0	0	#_LnQ_base_env(3)   
#_no timevary Q parameters
#
#_size_selex_patterns
#_Pattern	Discard	Male	Special
24	0	0	0	#_1 Fishery
24	0	0	0	#_2 Survey 
 0	0	0	0	#_3 env    
#
#_age_selex_patterns
#_Pattern	Discard	Male	Special
11	0	0	0	#_1 Fishery
11	0	0	0	#_2 Survey 
 0	0	0	0	#_3 env    
#
#_SizeSelex
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn  #  parm_name
  20	 150	 100	50.8	0.05	0	  2	0	0	0	0	0.5	0	0	#_SizeSel_P_1_Fishery(1)
  -5	   3	  -3	  -3	0.05	0	-99	0	0	0	0	0.5	0	0	#_SizeSel_P_2_Fishery(1)
   0	  26	 5.1	 5.1	0.05	0	  3	0	0	0	0	0.5	0	0	#_SizeSel_P_3_Fishery(1)
  -2	  16	  15	  15	0.05	0	-99	0	0	0	0	0.5	0	0	#_SizeSel_P_4_Fishery(1)
 -15	   5	-999	-999	0.05	0	-99	0	0	0	0	0.5	0	0	#_SizeSel_P_5_Fishery(1)
  -5	1000	 999	 999	0.05	0	-99	0	0	0	0	0.5	0	0	#_SizeSel_P_6_Fishery(1)
  20	 150	  75	41.8	0.05	0	  2	0	0	0	0	0.5	0	0	#_SizeSel_P_1_Survey(2) 
  -5	   3	  -4	  -4	0.05	0	-99	0	0	0	0	0.5	0	0	#_SizeSel_P_2_Survey(2) 
  -4	  26	 5.2	 5.2	0.05	0	  3	0	0	0	0	0.5	0	0	#_SizeSel_P_3_Survey(2) 
  -2	  16	  14	  14	0.05	0	-99	0	0	0	0	0.5	0	0	#_SizeSel_P_4_Survey(2) 
-100	 100	 -99	 -99	0.05	0	-99	0	0	0	0	0.5	0	0	#_SizeSel_P_5_Survey(2) 
-100	 100	  99	  99	0.05	0	-99	0	0	0	0	0.5	0	0	#_SizeSel_P_6_Survey(2) 
#_AgeSelex
0	  1	 0	0.1	99	0	-99	0	0	0	0	0.5	0	0	#_AgeSel_P_1_Fishery(1)
0	101	25	100	99	0	-99	0	0	0	0	0.5	0	0	#_AgeSel_P_2_Fishery(1)
0	  1	 0	0.1	99	0	-99	0	0	0	0	0.5	0	0	#_AgeSel_P_1_Survey(2) 
0	101	25	100	99	0	-99	0	0	0	0	0.5	0	0	#_AgeSel_P_2_Survey(2) 
#_no timevary selex parameters
#
0 #  use 2D_AR1 selectivity(0/1):  experimental feature
#_no 2D_AR1 selex offset used
# Tag loss and Tag reporting parameters go next
0 # TG_custom:  0=no read; 1=read if tags exist
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# Input variance adjustments factors: 
#_Data_type Fleet Value
-9999 1 0 # terminator
#
4 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 0 changes to default Lambdas (default value is 1.0)
-9999 0 0 0 0 # terminator
#
0 # 0/1 read specs for more stddev reporting
#
999
