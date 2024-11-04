om <- SS_read('inst/extdata/models/sardine/om')
em <- SS_read('inst/extdata/models/sardine/em')

### minor changes to OM for ss3sim
om$start$last_estimation_phase <- 0
om$start$N_bootstraps <- 3
om$start$F_report_basis <- 0
om$start$datfile <- 'om.dat'
om$start$ctlfile <- 'om.ctl'
em$start$datfile <- 'ss3.dat'
em$start$ctlfile <- 'em.ctl'


# om$ctl$recdev_early_start <- 0 # is -6 right now. see if this works
om$ctl$max_bias_adj <- 0
om$ctl$F_Method <- 2
om$ctl$lambdas <- NULL #om$ctl$lambdas[-(1:nrow(om$ctl$lambdas)),]
om$ctl$N_lambdas <- 0
om$ctl$F_setup <- c(0.2, 1, 1) |>
  `names<-`(paste0('F_setup_', 1:3))
om$ctl$F_setup2 <- data.frame(fleet = 1,
                              yr = om$dat$styr,
                              seas = 1, 
                              Fvalue = 0.00005, #is the ok?
                              se = 0.00001, #is this ok? 
                              phase = -1)
om$ctl$F_iter <- NULL

### add a PNW_S2 fleet
# data file
om$dat$Nfleets <- em$dat$Nfleets <- 7
om$dat$Nfleet <- em$dat$Nfleet <- 4
om$dat$fleetnames[7] <- em$dat$fleetnames[7] <- 'PNW_S2'
om$dat$fleetinfo[7,] <- em$dat$fleetinfo[7,] <- data.frame(1, -1, 1, 1, 0, 'PNW_S2')
om$dat$surveytiming <- em$dat$surveytiming <- om$dat$fleetinfo$surveytiming
om$dat$CPUEinfo[7,] <- em$dat$CPUEinfo[7,] <- data.frame(7, 1, 0, 0, row.names = 'PNW_S2')
om$dat$len_info[7,] <- em$dat$len_info[7,] <- om$dat$len_info[6,]
rownames(om$dat$len_info)[7] <- rownames(em$dat$len_info)[7] <- 'PNW_S2'
om$dat$age_info[7,] <- em$dat$age_info[7,] <- om$dat$age_info[6,]
rownames(om$dat$age_info)[7] <- rownames(em$dat$age_info)[7] <- 'PNW_S2'
om$dat$fleetinfo1$PNW_S2 <- em$dat$fleetinfo1$PNW_S2 <- om$dat$fleetinfo1$PNW
om$dat$fleetinfo2$PNW_2 <- em$dat$fleetinfo2$PNW_2 <- om$dat$fleetinfo2$PNW

# control file
om$ctl$size_selex_types[7,] <- em$ctl$size_selex_types[7,] <- data.frame(15, 0, 0, 1, row.names = 'PNW_S2')
om$ctl$age_selex_types[7,] <- em$ctl$age_selex_types[7,] <- data.frame(15, 0, 0, 3, row.names = 'PNW_S2')

# move season 2 landings to new fleet
om$dat$catch[om$dat$catch$fleet == 3 & om$dat$catch$seas == 2, 'fleet'] <- 7
em$dat$catch[em$dat$catch$fleet == 3 & em$dat$catch$seas == 2, 'fleet'] <- 7
# 
# ### add env fleet
# sardine.env <- add_fleet(datlist = om$dat, ctllist = om$ctl, 
#                          data = data.frame(matrix(c(om$dat$endyr, 7, 1, 0.1), nrow = 1, ncol = 4)), 
#                          fleettype = 'CPUE', fleetname = 'env', units = 36)
# 
# sardine.env$datlist$fleetinfo1$env <- c(1,1,3)
# sardine.env$datlist$fleetinfo2$env <- c(2,0)
# 
# sardine.env$ctllist$Q_options['env','extra_se'] <- 0
# sardine.env$ctllist$Q_parms <- sardine.env$ctllist$Q_parms[-grep('extraSD_env', rownames(sardine.env$ctllist$Q_parms)),]
# # Q for env index must be estimated, not float
# sardine.env$ctllist$Q_options['env','float'] <- 0
# # Q is actually on a linear scale, not log scale, despite parameter name
# sardine.env$ctllist$Q_parms['LnQ_base_env(5)', 'LO'] <- 0.001 # this is actually q for index type 36, and must be >0
# sardine.env$ctllist$Q_parms['LnQ_base_env(5)', 'INIT'] <- 1


SS_write(em, dir = 'inst/extdata/models/sardine/em_modified', overwrite = TRUE)
SS_write(om, dir = 'inst/extdata/models/sardine/om_modified', overwrite = TRUE)

run('inst/extdata/models/sardine/em_modified', exe = exe_loc, extras = '-nohess', skipfinished = FALSE)

em <- SS_read('inst/extdata/models/sardine/em_modified')
out <- SS_output('inst/extdata/models/sardine/em_modified')

df <- data.frame(ce.forecast_num = 1,
                 om_dir = 'inst/extdata/models/sardine/OM_modified',
                 em_dir = 'inst/extdata/models/sardine/EM_modified',
                 bias_adjust = FALSE)
#### landings
df$cf.years.1 <- df$cf.years.2 <- df$cf.years.3 <- df$cf.years.7 <- '2005:2019'
df$cf.seasons.1 <- df$cf.seasons.3 <- 1
df$cf.seasons.2 <- df$cf.seasons.7 <- 2

df$cf.fvals.1 <- c('c(NULL', out$exploitation$MexCal_S1[out$exploitation$Seas == 1 & 
                                                          out$exploitation$Yr <= om$dat$endyr], ')') |> 
  stringr::str_flatten_comma(last = '')
df$cf.fvals.2 <- c('c(NULL', out$exploitation$MexCal_S2[out$exploitation$Seas == 2 & 
                                                          out$exploitation$Yr <= om$dat$endyr], ')') |> 
  stringr::str_flatten_comma(last = '')
df$cf.fvals.3 <- c('c(NULL', out$exploitation$PNW[out$exploitation$Seas == 1 & 
                                                    out$exploitation$Yr <= om$dat$endyr], ')') |> 
  stringr::str_flatten_comma(last = '')
df$cf.fvals.7 <- c('c(NULL', out$exploitation$PNW_S2[out$exploitation$Seas == 2 & 
                                                       out$exploitation$Yr <= om$dat$endyr], ')') |> 
  stringr::str_flatten_comma(last = '')

#### lengths
for(flt in unique(abs(em$dat$lencomp$FltSvy))) {
  df[1, paste0('sl.years.', flt)] <- c('c(NULL', em$dat$lencomp$Yr[em$dat$lencomp$FltSvy == flt], ')') |>
    stringr::str_flatten_comma(last = '')
  df[1, paste0('sl.Nsamp.', flt)] <- c('c(NULL', round(em$dat$lencomp$Nsamp[em$dat$lencomp$FltSvy == flt]), ')') |>
    stringr::str_flatten_comma(last = '')
  df[1, paste0('sl.Seas.', flt)] <- em$dat$lencomp$Seas[em$dat$lencomp$FltSvy == flt][1]
}

#### ages
for(flt in unique(em$dat$agecomp$FltSvy)) {
  df[1, paste0('sa.years.', flt)] <- c('c(NULL', em$dat$agecomp$Yr[em$dat$agecomp$FltSvy == flt], ')') |>
    stringr::str_flatten_comma(last = '')
  df[1, paste0('sa.Nsamp.', flt)] <- c('c(NULL', em$dat$agecomp$Nsamp[em$dat$agecomp$FltSvy == flt], ')') |>
    stringr::str_flatten_comma(last = '')
  df[1, paste0('sa.Seas.', flt)] <- em$dat$agecomp$Seas[em$dat$agecomp$FltSvy == flt][1]
}

### index
for(flt in unique(em$dat$CPUE$index)) {
  df[1, paste0('si.years.', flt)] <- c('c(NULL', unique(em$dat$CPUE$year[em$dat$CPUE$index == flt]), ')') |>
    stringr::str_flatten_comma(last = '')
  df[1, paste0('si.sds_obs.', flt)] <- mean(em$dat$CPUE$se_log[em$dat$CPUE$index == flt])
  if(flt != 4) {
    df[1, paste0('si.seas.', flt)] <- em$dat$CPUE$seas[em$dat$CPUE$index == flt][1]
  }
}
df[1, 'si.seas.4'] <- 1

nsim <- 1
sim_dir <- 'sardine'
unlink(sim_dir, recursive = TRUE)
scname <- run_ss3sim(iterations = 1:nsim, simdf = df, extras = '-nohess', 
                     parallel = FALSE, parallel_iterations = TRUE, scenarios = sim_dir)
                     # scenarios = file.path(sim_dir, df[,paste0('si.sds_obs.', rec_flt_ind)]))

