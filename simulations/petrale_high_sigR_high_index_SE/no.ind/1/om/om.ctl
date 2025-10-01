#V3.30
#C file created using the SS_writectl function in the R package r4ss
#C file write time: 2023-06-21 16:38:18
#
0 # 0 means do not read wtatage.ss; 1 means read and usewtatage.ss and also read and use growth parameters
1 #_N_Growth_Patterns
1 #_N_platoons_Within_GrowthPattern
4 # recr_dist_method for parameters
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
4 #_Nblock_Patterns
6 4 2 1 #_blocks_per_pattern
#_begin and end years of blocks
1973 1982 1983 1992 1993 2002 2003 2010 2011 2017 2018 2022
2002 2002 2003 2008 2009 2010 2011 2022
2010 2010 2011 2022
1995 2004
#
# controls for all timevary parameters 
1 #_env/block/dev_adjust_method for all time-vary parms (1=warn relative to base parm bounds; 3=no bound check)
#
# AUTOGEN
1 1 1 1 1 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen all time-varying parms; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
#
# setup for M, growth, maturity, fecundity, recruitment distibution, movement
#
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=Maunder_M;_6=Age-range_Lorenzen
#_no additional input for selected M option; read 1P per morph
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr;5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
1 #_Age(post-settlement)_for_L1;linear growth below this
17 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0 #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
2 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
3 #_First_Mature_Age
2 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
#
#_growth_parms
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env_var&link	dev_link	dev_minyr	dev_maxyr	dev_PH	Block	Block_Fxn
0.005	0.5	 0.141813	  -1.7793	0.31	3	 2	0	0	0	0	0	0	0	#_NatM_p_1_Fem_GP_1  
    5	 45	  8.84618	    17.18	  10	0	 3	0	0	0	0	0	0	0	#_L_at_Amin_Fem_GP_1 
   35	 80	  47.6931	     54.2	  10	0	 3	0	0	0	0	0	0	0	#_L_at_Amax_Fem_GP_1 
 0.04	0.5	 0.193447	    0.157	  99	0	 3	0	0	0	0	0	0	0	#_VonBert_K_Fem_GP_1 
  0.5	 15	  1.31684	        3	  99	0	 3	0	0	0	0	0	0	0	#_CV_young_Fem_GP_1  
  0.5	 15	  4.87428	        3	  99	0	 4	0	0	0	0	0	0	0	#_CV_old_Fem_GP_1    
   -3	  3	2.035e-06	2.035e-06	  99	0	-3	0	0	0	0	0	0	0	#_Wtlen_1_Fem_GP_1   
    1	  5	    3.478	    3.478	  99	0	-3	0	0	0	0	0	0	0	#_Wtlen_2_Fem_GP_1   
   10	 50	    35.45	    35.45	  99	0	-3	0	0	0	0	0	0	0	#_Mat50%_Fem_GP_1    
   -3	  3	 -0.48921	 -0.48921	  99	0	-3	0	0	0	0	0	0	0	#_Mat_slope_Fem_GP_1 
   -3	  1	  3.2e-11	        1	   1	0	-3	0	0	0	0	0	0	0	#_Eggs_alpha_Fem_GP_1
   -3	  5	     4.55	        0	   1	0	-3	0	0	0	0	0	0	0	#_Eggs_beta_Fem_GP_1 
    0	  1	        1	        1	   0	0	-4	0	0	0	0	0	0	0	#_CohortGrowDev      
  0.3	0.7	      0.5	      0.4	  99	0	-5	0	0	0	0	0	0	0	#_FracFemale_GP_1    
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
  5	20	9.63933	  9	  10	0	  1	0	0	0	0	0	0	0	#_SR_LN(R0)  
0.2	 1	    0.8	0.8	0.09	0	 -5	0	0	0	0	0	0	0	#_SR_BH_steep
  0	 2	      1	0.9	   5	0	-99	0	0	0	0	0	0	0	#_SR_sigmaR  
 -5	 5	      0	  0	 0.2	0	 -2	0	0	0	0	0	0	0	#_SR_regime  
  0	 0	      0	  0	   0	0	-99	0	0	0	0	0	0	0	#_SR_autocorr
#_no timevary SR parameters
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1876 # first year of main recr_devs; early devs can preceed this era
2034 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase
1 # (0/1) to read 13 advanced options
0 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
3 #_recdev_early_phase
0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
1 #_lambda for Fcast_recr_like occurring before endyr+1
1935.3 #_last_yr_nobias_adj_in_MPD; begin of ramp
2002 #_first_yr_fullbias_adj_in_MPD; begin of plateau
2015.7 #_last_yr_fullbias_adj_in_MPD
2021.8 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS sets bias_adj to 0.0 for fcast yrs)
0 #_max_bias_adj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)
0 #_period of cycles in recruitment (N parms read below)
-4 #min rec_dev
4 #max rec_dev
124 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
#_Year	recdev
1923	  0.274055	#_recdev_input1  
1924	  0.268504	#_recdev_input2  
1925	  -1.58118	#_recdev_input3  
1926	  -1.65534	#_recdev_input4  
1927	 -0.247963	#_recdev_input5  
1928	 0.0872973	#_recdev_input6  
1929	  -1.15686	#_recdev_input7  
1930	  0.205806	#_recdev_input8  
1931	 -0.541038	#_recdev_input9  
1932	 -0.941375	#_recdev_input10 
1933	  -1.47838	#_recdev_input11 
1934	 -0.848853	#_recdev_input12 
1935	  0.421874	#_recdev_input13 
1936	  -1.01206	#_recdev_input14 
1937	  -2.05397	#_recdev_input15 
1938	 -0.269744	#_recdev_input16 
1939	 -0.113699	#_recdev_input17 
1940	  0.171191	#_recdev_input18 
1941	 -0.663554	#_recdev_input19 
1942	 -0.480824	#_recdev_input20 
1943	 0.0756744	#_recdev_input21 
1944	  0.543632	#_recdev_input22 
1945	  0.259351	#_recdev_input23 
1946	  0.503262	#_recdev_input24 
1947	   -1.3843	#_recdev_input25 
1948	 -0.437911	#_recdev_input26 
1949	 -0.441156	#_recdev_input27 
1950	  0.540544	#_recdev_input28 
1951	  0.252558	#_recdev_input29 
1952	 -0.189624	#_recdev_input30 
1953	  -1.01728	#_recdev_input31 
1954	  0.121158	#_recdev_input32 
1955	  0.188105	#_recdev_input33 
1956	 -0.356207	#_recdev_input34 
1957	   -2.1258	#_recdev_input35 
1958	  0.522714	#_recdev_input36 
1959	  -1.96841	#_recdev_input37 
1960	  0.387099	#_recdev_input38 
1961	  -1.88633	#_recdev_input39 
1962	 -0.972241	#_recdev_input40 
1963	  -1.62612	#_recdev_input41 
1964	   1.65702	#_recdev_input42 
1965	  -3.38593	#_recdev_input43 
1966	  -2.43761	#_recdev_input44 
1967	  0.483076	#_recdev_input45 
1968	 -0.316338	#_recdev_input46 
1969	  -1.89975	#_recdev_input47 
1970	 -0.658626	#_recdev_input48 
1971	  0.103728	#_recdev_input49 
1972	  -2.02727	#_recdev_input50 
1973	 -0.655555	#_recdev_input51 
1974	 -0.858269	#_recdev_input52 
1975	  -1.29408	#_recdev_input53 
1976	  0.203247	#_recdev_input54 
1977	 -0.141657	#_recdev_input55 
1978	 -0.584994	#_recdev_input56 
1979	  -1.85646	#_recdev_input57 
1980	 -0.529644	#_recdev_input58 
1981	   1.07066	#_recdev_input59 
1982	  -1.28893	#_recdev_input60 
1983	 -0.565628	#_recdev_input61 
1984	  -0.20868	#_recdev_input62 
1985	 -0.333788	#_recdev_input63 
1986	 -0.824514	#_recdev_input64 
1987	 0.0478804	#_recdev_input65 
1988	 -0.892709	#_recdev_input66 
1989	 -0.327413	#_recdev_input67 
1990	 -0.583671	#_recdev_input68 
1991	   0.15535	#_recdev_input69 
1992	  -1.07628	#_recdev_input70 
1993	   2.07554	#_recdev_input71 
1994	  -2.48966	#_recdev_input72 
1995	    1.0712	#_recdev_input73 
1996	 -0.833863	#_recdev_input74 
1997	  -1.94716	#_recdev_input75 
1998	   -0.9714	#_recdev_input76 
1999	   0.21188	#_recdev_input77 
2000	 -0.966494	#_recdev_input78 
2001	  -1.26215	#_recdev_input79 
2002	 -0.447868	#_recdev_input80 
2003	 -0.132408	#_recdev_input81 
2004	 -0.569194	#_recdev_input82 
2005	   1.00323	#_recdev_input83 
2006	 -0.893889	#_recdev_input84 
2007	   -1.2943	#_recdev_input85 
2008	   1.68412	#_recdev_input86 
2009	   1.44494	#_recdev_input87 
2010	 -0.463334	#_recdev_input88 
2011	  -1.42174	#_recdev_input89 
2012	 -0.851866	#_recdev_input90 
2013	  0.307384	#_recdev_input91 
2014	 -0.572755	#_recdev_input92 
2015	 -0.856155	#_recdev_input93 
2016	  0.307191	#_recdev_input94 
2017	  -2.06581	#_recdev_input95 
2018	 -0.236487	#_recdev_input96 
2019	   1.07761	#_recdev_input97 
2020	   0.71753	#_recdev_input98 
2021	 -0.592542	#_recdev_input99 
2022	  -1.44899	#_recdev_input100
2023	-0.0583514	#_recdev_input101
2024	  0.307009	#_recdev_input102
2025	  0.639376	#_recdev_input103
2026	  0.928038	#_recdev_input104
2027	  -0.60054	#_recdev_input105
2028	  0.748492	#_recdev_input106
2029	   -1.0735	#_recdev_input107
2030	  -1.07091	#_recdev_input108
2031	  -1.14567	#_recdev_input109
2032	  -1.53855	#_recdev_input110
2033	 -0.217762	#_recdev_input111
2034	  -1.72556	#_recdev_input112
2035	   -1.6606	#_recdev_input113
2036	   1.89457	#_recdev_input114
2037	  -1.57395	#_recdev_input115
2038	 -0.946238	#_recdev_input116
2039	  0.411652	#_recdev_input117
2040	 -0.527357	#_recdev_input118
2041	   1.25721	#_recdev_input119
2042	   1.89484	#_recdev_input120
2043	 -0.519387	#_recdev_input121
2044	  0.288703	#_recdev_input122
2045	   1.24637	#_recdev_input123
2046	   -2.5421	#_recdev_input124
#
#Fishing Mortality info
0.3 # F ballpark
-2001 # F ballpark year (neg value to disable)
2 # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
4 # max F or harvest rate, depends on F_Method
#_overall start F value; overall phase; N detailed inputs to read
0 1 224 #_F_setup
#_Fleet	Yr	Seas	F_value	se	phase
1	1923	1	3.65189e-06	0.005	1	#_1  
1	1924	1	3.36398e-06	0.005	1	#_2  
1	1925	1	3.07754e-06	0.005	1	#_3  
1	1926	1	2.78295e-06	0.005	1	#_4  
1	1927	1	2.61469e-06	0.005	1	#_5  
1	1928	1	3.71277e-08	0.005	1	#_6  
1	1929	1	0.000116717	0.005	1	#_7  
1	1930	1	9.34396e-05	0.005	1	#_8  
1	1931	1	 0.00131926	0.005	1	#_9  
1	1932	1	 0.00322268	0.005	1	#_10 
1	1933	1	 0.00421132	0.005	1	#_11 
1	1934	1	 0.00539372	0.005	1	#_12 
1	1935	1	 0.00690969	0.005	1	#_13 
1	1936	1	 0.00925777	0.005	1	#_14 
1	1937	1	  0.0160254	0.005	1	#_15 
1	1938	1	  0.0110572	0.005	1	#_16 
1	1939	1	  0.0314367	0.005	1	#_17 
1	1940	1	  0.0518588	0.005	1	#_18 
1	1941	1	   0.067594	0.005	1	#_19 
1	1942	1	     0.1744	0.005	1	#_20 
1	1943	1	   0.186348	0.005	1	#_21 
1	1944	1	    0.10968	0.005	1	#_22 
1	1945	1	  0.0977796	0.005	1	#_23 
1	1946	1	   0.166987	0.005	1	#_24 
1	1947	1	  0.0981117	0.005	1	#_25 
1	1948	1	   0.240514	0.005	1	#_26 
1	1949	1	   0.113682	0.005	1	#_27 
1	1950	1	   0.230043	0.005	1	#_28 
1	1951	1	   0.186714	0.005	1	#_29 
1	1952	1	   0.158265	0.005	1	#_30 
1	1953	1	   0.079169	0.005	1	#_31 
1	1954	1	   0.127479	0.005	1	#_32 
1	1955	1	   0.139593	0.005	1	#_33 
1	1956	1	   0.126819	0.005	1	#_34 
1	1957	1	   0.244919	0.005	1	#_35 
1	1958	1	   0.221145	0.005	1	#_36 
1	1959	1	   0.176167	0.005	1	#_37 
1	1960	1	   0.272294	0.005	1	#_38 
1	1961	1	   0.280741	0.005	1	#_39 
1	1962	1	   0.396068	0.005	1	#_40 
1	1963	1	   0.400578	0.005	1	#_41 
1	1964	1	   0.326981	0.005	1	#_42 
1	1965	1	   0.318398	0.005	1	#_43 
1	1966	1	   0.330728	0.005	1	#_44 
1	1967	1	   0.305648	0.005	1	#_45 
1	1968	1	   0.257824	0.005	1	#_46 
1	1969	1	   0.288143	0.005	1	#_47 
1	1970	1	   0.342564	0.005	1	#_48 
1	1971	1	   0.368684	0.005	1	#_49 
1	1972	1	   0.351281	0.005	1	#_50 
1	1973	1	   0.346835	0.005	1	#_51 
1	1974	1	   0.458017	0.005	1	#_52 
1	1975	1	   0.509065	0.005	1	#_53 
1	1976	1	   0.421954	0.005	1	#_54 
1	1977	1	   0.439074	0.005	1	#_55 
1	1978	1	   0.789905	0.005	1	#_56 
1	1979	1	   0.949393	0.005	1	#_57 
1	1980	1	    1.04849	0.005	1	#_58 
1	1981	1	    1.07404	0.005	1	#_59 
1	1982	1	    1.83478	0.005	1	#_60 
1	1983	1	    1.23073	0.005	1	#_61 
1	1984	1	   0.994613	0.005	1	#_62 
1	1985	1	   0.930128	0.005	1	#_63 
1	1986	1	    1.04871	0.005	1	#_64 
1	1987	1	    1.57887	0.005	1	#_65 
1	1988	1	    1.67363	0.005	1	#_66 
1	1989	1	    1.59452	0.005	1	#_67 
1	1990	1	    1.27337	0.005	1	#_68 
1	1991	1	    1.45758	0.005	1	#_69 
1	1992	1	    1.34338	0.005	1	#_70 
1	1993	1	   0.900783	0.005	1	#_71 
1	1994	1	   0.618921	0.005	1	#_72 
1	1995	1	   0.693104	0.005	1	#_73 
1	1996	1	   0.619007	0.005	1	#_74 
1	1997	1	   0.683392	0.005	1	#_75 
1	1998	1	   0.570356	0.005	1	#_76 
1	1999	1	   0.469045	0.005	1	#_77 
1	2000	1	   0.579309	0.005	1	#_78 
1	2001	1	    0.56705	0.005	1	#_79 
1	2002	1	   0.587505	0.005	1	#_80 
1	2003	1	   0.827796	0.005	1	#_81 
1	2004	1	   0.655903	0.005	1	#_82 
1	2005	1	   0.841272	0.005	1	#_83 
1	2006	1	    0.84347	0.005	1	#_84 
1	2007	1	   0.654542	0.005	1	#_85 
1	2008	1	   0.687015	0.005	1	#_86 
1	2009	1	   0.728303	0.005	1	#_87 
1	2010	1	   0.296398	0.005	1	#_88 
1	2011	1	   0.267806	0.005	1	#_89 
1	2012	1	   0.223078	0.005	1	#_90 
1	2013	1	   0.333986	0.005	1	#_91 
1	2014	1	   0.278695	0.005	1	#_92 
1	2015	1	   0.292191	0.005	1	#_93 
1	2016	1	   0.301444	0.005	1	#_94 
1	2017	1	   0.307935	0.005	1	#_95 
1	2018	1	   0.344869	0.005	1	#_96 
1	2019	1	   0.322432	0.005	1	#_97 
1	2020	1	   0.242416	0.005	1	#_98 
1	2021	1	   0.339191	0.005	1	#_99 
1	2022	1	   0.366862	0.005	1	#_100
1	2023	1	        0.3	0.005	1	#_101
1	2024	1	        0.3	0.005	1	#_102
1	2025	1	        0.3	0.005	1	#_103
1	2026	1	        0.3	0.005	1	#_104
1	2027	1	        0.3	0.005	1	#_105
1	2028	1	        0.3	0.005	1	#_106
1	2029	1	        0.3	0.005	1	#_107
1	2030	1	        0.3	0.005	1	#_108
1	2031	1	        0.3	0.005	1	#_109
1	2032	1	        0.3	0.005	1	#_110
1	2033	1	        0.3	0.005	1	#_111
1	2034	1	        0.3	0.005	1	#_112
2	1923	1	  0.0149816	0.005	1	#_113
2	1924	1	  0.0187514	0.005	1	#_114
2	1925	1	  0.0186889	0.005	1	#_115
2	1926	1	  0.0185304	0.005	1	#_116
2	1927	1	  0.0225741	0.005	1	#_117
2	1928	1	   0.022289	0.005	1	#_118
2	1929	1	  0.0255541	0.005	1	#_119
2	1930	1	  0.0240098	0.005	1	#_120
2	1931	1	  0.0228593	0.005	1	#_121
2	1932	1	  0.0204728	0.005	1	#_122
2	1933	1	  0.0156206	0.005	1	#_123
2	1934	1	  0.0412579	0.005	1	#_124
2	1935	1	  0.0337627	0.005	1	#_125
2	1936	1	  0.0193857	0.005	1	#_126
2	1937	1	  0.0311981	0.005	1	#_127
2	1938	1	  0.0381905	0.005	1	#_128
2	1939	1	  0.0456428	0.005	1	#_129
2	1940	1	  0.0286575	0.005	1	#_130
2	1941	1	  0.0164442	0.005	1	#_131
2	1942	1	  0.0115211	0.005	1	#_132
2	1943	1	  0.0180002	0.005	1	#_133
2	1944	1	  0.0226361	0.005	1	#_134
2	1945	1	  0.0241275	0.005	1	#_135
2	1946	1	  0.0567786	0.005	1	#_136
2	1947	1	  0.0662996	0.005	1	#_137
2	1948	1	    0.12526	0.005	1	#_138
2	1949	1	   0.136126	0.005	1	#_139
2	1950	1	   0.132581	0.005	1	#_140
2	1951	1	  0.0897326	0.005	1	#_141
2	1952	1	  0.0992995	0.005	1	#_142
2	1953	1	   0.117988	0.005	1	#_143
2	1954	1	   0.153276	0.005	1	#_144
2	1955	1	   0.139516	0.005	1	#_145
2	1956	1	    0.11141	0.005	1	#_146
2	1957	1	   0.143392	0.005	1	#_147
2	1958	1	   0.135295	0.005	1	#_148
2	1959	1	   0.115914	0.005	1	#_149
2	1960	1	   0.111337	0.005	1	#_150
2	1961	1	   0.159747	0.005	1	#_151
2	1962	1	   0.153224	0.005	1	#_152
2	1963	1	   0.177738	0.005	1	#_153
2	1964	1	   0.145935	0.005	1	#_154
2	1965	1	   0.138377	0.005	1	#_155
2	1966	1	   0.146347	0.005	1	#_156
2	1967	1	   0.134918	0.005	1	#_157
2	1968	1	   0.136721	0.005	1	#_158
2	1969	1	   0.129244	0.005	1	#_159
2	1970	1	   0.142283	0.005	1	#_160
2	1971	1	   0.135666	0.005	1	#_161
2	1972	1	   0.137015	0.005	1	#_162
2	1973	1	  0.0920306	0.005	1	#_163
2	1974	1	   0.123202	0.005	1	#_164
2	1975	1	   0.138174	0.005	1	#_165
2	1976	1	   0.147188	0.005	1	#_166
2	1977	1	   0.123243	0.005	1	#_167
2	1978	1	   0.171684	0.005	1	#_168
2	1979	1	   0.241818	0.005	1	#_169
2	1980	1	    0.21191	0.005	1	#_170
2	1981	1	   0.168794	0.005	1	#_171
2	1982	1	   0.184619	0.005	1	#_172
2	1983	1	    0.18713	0.005	1	#_173
2	1984	1	   0.209916	0.005	1	#_174
2	1985	1	   0.322029	0.005	1	#_175
2	1986	1	   0.288116	0.005	1	#_176
2	1987	1	    0.34315	0.005	1	#_177
2	1988	1	    0.33171	0.005	1	#_178
2	1989	1	   0.345727	0.005	1	#_179
2	1990	1	   0.286197	0.005	1	#_180
2	1991	1	   0.336167	0.005	1	#_181
2	1992	1	   0.254511	0.005	1	#_182
2	1993	1	   0.266844	0.005	1	#_183
2	1994	1	   0.273325	0.005	1	#_184
2	1995	1	   0.258128	0.005	1	#_185
2	1996	1	   0.341265	0.005	1	#_186
2	1997	1	   0.349988	0.005	1	#_187
2	1998	1	   0.184688	0.005	1	#_188
2	1999	1	   0.194078	0.005	1	#_189
2	2000	1	   0.203647	0.005	1	#_190
2	2001	1	   0.178266	0.005	1	#_191
2	2002	1	   0.140213	0.005	1	#_192
2	2003	1	   0.118607	0.005	1	#_193
2	2004	1	   0.128908	0.005	1	#_194
2	2005	1	   0.195848	0.005	1	#_195
2	2006	1	   0.207991	0.005	1	#_196
2	2007	1	   0.276155	0.005	1	#_197
2	2008	1	   0.298747	0.005	1	#_198
2	2009	1	   0.173628	0.005	1	#_199
2	2010	1	  0.0635126	0.005	1	#_200
2	2011	1	   0.031792	0.005	1	#_201
2	2012	1	  0.0284097	0.005	1	#_202
2	2013	1	  0.0481857	0.005	1	#_203
2	2014	1	  0.0553042	0.005	1	#_204
2	2015	1	   0.048191	0.005	1	#_205
2	2016	1	  0.0386927	0.005	1	#_206
2	2017	1	  0.0508354	0.005	1	#_207
2	2018	1	  0.0560329	0.005	1	#_208
2	2019	1	  0.0509142	0.005	1	#_209
2	2020	1	  0.0522162	0.005	1	#_210
2	2021	1	  0.0772868	0.005	1	#_211
2	2022	1	   0.104973	0.005	1	#_212
2	2023	1	       0.05	0.005	1	#_213
2	2024	1	       0.05	0.005	1	#_214
2	2025	1	       0.05	0.005	1	#_215
2	2026	1	       0.05	0.005	1	#_216
2	2027	1	       0.05	0.005	1	#_217
2	2028	1	       0.05	0.005	1	#_218
2	2029	1	       0.05	0.005	1	#_219
2	2030	1	       0.05	0.005	1	#_220
2	2031	1	       0.05	0.005	1	#_221
2	2032	1	       0.05	0.005	1	#_222
2	2033	1	       0.05	0.005	1	#_223
2	2034	1	       0.05	0.005	1	#_224
#
#_initial_F_parms; count = 0
#
#_Q_setup for fleets with cpue or survey data
#_fleet	link	link_info	extra_se	biasadj	float  #  fleetname
    4	1	0	0	0	1	#_WCGBTS    
    5	1	0	0	0	0	#_env       
-9999	0	0	0	0	0	#_terminator
#_Q_parms(if_any);Qunits_are_ln(q)
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn  #  parm_name
  -15	15	1.39191	0	 1	0	-1	0	0	0	0	0	0	0	#_LnQ_base_WCGBTS(4)
0.001	20	      1	0	99	0	-1	0	0	0	0	0	0	0	#_LnQ_base_env(5)   
#_no timevary Q parameters
#
#_size_selex_patterns
#_Pattern	Discard	Male	Special
24	0	0	0	#_1 North    
24	0	0	0	#_2 South    
 0	0	0	0	#_3 Triennial
24	0	0	0	#_4 WCGBTS   
 0	0	0	0	#_5 env      
#
#_age_selex_patterns
#_Pattern	Discard	Male	Special
10	0	0	0	#_1 North    
10	0	0	0	#_2 South    
10	0	0	0	#_3 Triennial
10	0	0	0	#_4 WCGBTS   
 0	0	0	0	#_5 env      
#
#_SizeSelex
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn  #  parm_name
  15	75	61.2108	43.1	99	0	 2	0	0	0	0	0	0	0	#_SizeSel_P_1_North(1) 
 -15	 4	    -15	 -15	99	0	-3	0	0	0	0	0	0	0	#_SizeSel_P_2_North(1) 
  -4	12	  5.261	3.42	99	0	 3	0	0	0	0	0	0	0	#_SizeSel_P_3_North(1) 
  -2	20	     20	0.21	99	0	-3	0	0	0	0	0	0	0	#_SizeSel_P_4_North(1) 
-999	 9	   -999	-8.9	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_North(1) 
-999	 9	   -999	0.15	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_6_North(1) 
  15	75	54.2777	43.1	99	0	 2	0	0	0	0	0	0	0	#_SizeSel_P_1_South(2) 
 -15	 4	    -15	 -15	99	0	-3	0	0	0	0	0	0	0	#_SizeSel_P_2_South(2) 
  -4	12	5.96648	3.42	99	0	 3	0	0	0	0	0	0	0	#_SizeSel_P_3_South(2) 
  -2	20	     20	0.21	99	0	-3	0	0	0	0	0	0	0	#_SizeSel_P_4_South(2) 
-999	 9	   -999	-8.9	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_South(2) 
-999	 9	   -999	0.15	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_6_South(2) 
  15	61	50.4841	43.1	99	0	 2	0	0	0	0	0	0	0	#_SizeSel_P_1_WCGBTS(4)
 -15	 4	    -15	  -1	99	0	-2	0	0	0	0	0	0	0	#_SizeSel_P_2_WCGBTS(4)
  -4	12	5.65368	3.42	99	0	 2	0	0	0	0	0	0	0	#_SizeSel_P_3_WCGBTS(4)
  -2	20	     20	0.21	99	0	-2	0	0	0	0	0	0	0	#_SizeSel_P_4_WCGBTS(4)
-999	 9	   -999	-8.9	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_5_WCGBTS(4)
-999	 9	   -999	0.15	99	0	-4	0	0	0	0	0	0	0	#_SizeSel_P_6_WCGBTS(4)
#_AgeSelex
#_No age_selex_parm
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
15 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 0 changes to default Lambdas (default value is 1.0)
-9999 0 0 0 0 # terminator
#
0 # 0/1 read specs for more stddev reporting
#
999
