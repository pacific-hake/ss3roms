# Adjust cod operating model ----------------------------------------------

# cod.loc <- system.file(file.path("extdata", "models"), package = "ss3sim")
# 
# dir.create('inst/extdata/models/Cod')
# file.copy(cod.loc, 'inst/extdata/models/Cod', recursive = TRUE)
# file.rename(from = 'inst/extdata/models/Cod/models',
#             to = 'inst/extdata/models/Cod/original')

cod <- SS_read('inst/extdata/models/Cod/original/cod-om')

# get rid of CPUE data from fishery. this is weird. and it breaks add_fleet function.
cod$ctl$Q_options <- cod$ctl$Q_options['Survey',]
cod$ctl$Q_parms <- cod$ctl$Q_parms[grep('Survey', rownames(cod$ctl$Q_parms)),]
cod$dat$CPUE <- filter(cod$dat$CPUE, index == which(cod$dat$fleetnames == 'Survey'))

# extend number of years (will be forecast in the EM)
cod$dat$endyr <- 112

# remove recdev sum to zero constraint
cod$ctl$do_recdev <- 2

# change forecast buffer so fish are actually caught!
cod$fore$Flimitfraction <- 1

# move selectivity curve right to give index a shot
cod$ctl$size_selex_parms$INIT[grep('1_Fishery', rownames(cod$ctl$size_selex_parms))] <- 100
cod$ctl$size_selex_parms$INIT[grep('1_Survey', rownames(cod$ctl$size_selex_parms))] <- 75
cod$ctl$size_selex_parms$HI[grep('P_1', rownames(cod$ctl$size_selex_parms))] <- 150
cod$ctl$size_selex_parms$LO[grep('P_1', rownames(cod$ctl$size_selex_parms))] <- 20

# considered decreasing steepness, but popn is not depleted so doesn't matter

cod.env <- add_fleet(datlist = cod$dat, ctllist = cod$ctl, 
                     data = data.frame(matrix(1, nrow = 1, ncol = 4)), 
                     fleettype = 'CPUE', fleetname = 'env', units = 36)
cod.env$ctllist$Q_options['env','extra_se'] <- 0
cod.env$ctllist$Q_options['env','float'] <- 0
cod.env$ctllist$Q_parms <- cod.env$ctllist$Q_parms[-grep('extraSD', rownames(cod.env$ctllist$Q_parms)),]
cod.env$ctllist$Q_parms['LnQ_base_env(3)', 'LO'] <- 0.001 # this is actually q for index type 36, and must be >0
cod.env$ctllist$Q_parms['LnQ_base_env(3)', 'INIT'] <- 1

cod$dat <- cod.env$datlist
cod$ctl <- cod.env$ctllist

SS_write(cod, 'inst/extdata/models/Cod/OM', overwrite = TRUE)
ss3sim::create_em(dir_in = 'inst/extdata/models/Cod/OM', 
                  dir_out = 'inst/extdata/models/Cod/EM')
# run('inst/extdata/models/cod/OM', exe = here('inst/extdata/models/ss.exe'), extras = '-nohess', show_in_console = TRUE)

