library(r4ss)
library(here)

get_ss3_exe(dir = 'C:/Program Files/R/R-4.3.2/library/ss3sim/bin/Windows64')
# manually copy it and rename it to ss.exe

# need to run model and use ss_new files so starting values match estimates
copy_SS_inputs('inst/extdata/models/petrale/production_env_ind', 
               'inst/extdata/models/petrale/OM', 
               use_ss_new = TRUE, overwrite = TRUE)

mod <- SS_read('inst/extdata/models/petrale/OM')

# forecast modifications
mod$fore$Do_West_Coast_gfish_rebuilder_output <- 0

SS_writeforecast(mod$fore, dir = 'inst/extdata/models/petrale/OM', overwrite = TRUE)

# starter modifications
mod$start$last_estimation_phase <- 0
mod$start$N_bootstraps <- 3
mod$start$F_age_range <- NULL
# How to do this, cannot find # F_report_basis in starter file: 
# Implement catches using instantaneous fishing mortality by changing # F_report_basis to 0. 

# control modifications
mod$ctl$do_recdev <- 1
mod$ctl$MainRdevYrFirst <- mod$dat$styr
mod$ctl$MainRdevYrLast <- mod$dat$endyr
mod$ctl$recdev_early_start <- 0
mod$ctl$max_bias_adj <- 0
mod$ctl$F_Method <- 2
# deleted stuff I should not have!
mod$ctl$F_setup <- c(0.2, 1, 1) |>
  `names<-`(paste0('F_setup_', 1:3))
mod$ctl$F_setup2 <- data.frame(fleet = 1,
                               yr = mod$dat$styr,
                               seas = 1, 
                               Fvalue = 0.00005, #is the ok?
                               se = 0.00001, #is this ok? 
                               phase = -1)
mod$ctl$F_iter <- NULL
mod$ctl$Variance_adjustment_list$Value <- 0

# data modifications
mod$dat$use_meanbodywt <- 0
mod$dat$meanbodywt <- NULL
mod$dat$DF_for_meanbodywt <- NULL

# get rid of discards, they are low, speed up model
mod$dat$discard_data <- NULL
mod$dat$discard_fleet_info <- NULL
mod$dat$N_discard_fleets <- 0

SS_write(mod, 'inst/extdata/models/petrale/OM', overwrite = TRUE)
SS_read(here('inst/extdata/models/petrale/OM'))


copy_SS_inputs('inst/extdata/models/petrale/production', 
               'inst/extdata/models/petrale/EM', 
               use_ss_new = TRUE, overwrite = TRUE)

mod <- SS_read('inst/extdata/models/petrale/EM')

ss3sim::create_em(dir_in = 'inst/extdata/models/petrale/OM', 
                  dir_out = 'inst/extdata/models/petrale/EM')
# now manually adjust start year in ctl file and dat file name in starter file
run('inst/extdata/models/petrale/EM', extras = '-nohess -maxfn 0', show_in_console = TRUE)

mod.res <- SS_output('inst/extdata/models/petrale/production_env_ind')


simdf <- setup_scenarios_defaults(nscenarios = 1)

# Define fishing mortality. Input as F/F_MSY I *THINK*???
simdf[, grep("^cf\\.", colnames(simdf))] <- c(paste0(mod$dat$styr, ':', mod$dat$endyr), # year range
                                              paste0('c(', stringr::str_flatten(mod.res$Kobe$F.Fmsy, collapse = ','), ')') # F/F_MSY 
                                              ) 

# Comp data
# If I use existing EM data weights, I think I can just use multinomial distribution.
# Maybe use multinomial distribution with n = data weight * input n? and no data weighting in EM?

# Is this for the simulation or the estimation? I am confused. 
# The directions in the vignette edit this data frame. It feels very restrictive.
# The directions in ss3sim::sample_lcomp are quite different, and do make sense to me.

# Ian: what is up with seas of both 1 and 7 in the petrale length comps?
simdf[,grep('^sl\\.', colnames(simdf))]

# Visualizing the results: iterations, are these years, simulated populations, simulated samples from the population?

# Big question: What if I took the example OM and used petrale MG table, recr cv, steepness, selectivity. Would that be easier? It would probably run faster because of fewer bells and whistles?

# How many years to do this for?

# Meeting notes
# dat file for OM is meaningless but needs to be there
# petrale cut off the triennial
# christine has petrale ss3sim, claudio has hake ss3sim without empirical weight at age. If I want to sample weight at age I need to review and likely revise the function.













# minor changes to EM
mod$fore$Do_West_Coast_gfish_rebuilder_output <- 0

# get rid of discards, they are low, speed up model
# cannot simulate mean body weight data anyway
mod$dat$use_meanbodywt <- 0
mod$dat$meanbodywt <- NULL
mod$dat$DF_for_meanbodywt <- NULL
mod$dat$discard_data <- NULL
mod$dat$discard_fleet_info <- NULL
mod$dat$N_discard_fleets <- 0

SS_write(mod, 'inst/extdata/models/petrale/EM', overwrite = TRUE)
