library(dplyr)
library(r4ss)
library(ss3sim)
library(here)
source('R/add_fleet.R')

# need to run model and use ss_new files so starting values match estimates
copy_SS_inputs('inst/extdata/models/petrale/production', 
               'inst/extdata/models/petrale/OM', 
               use_ss_new = TRUE, overwrite = TRUE)

mod <- SS_read('inst/extdata/models/petrale/OM')

# forecast modifications
mod$fore$Do_West_Coast_gfish_rebuilder_output <- 0
mod$dat$endyr <- 2034 # run OM through end of forecast

# starter modifications
mod$start$last_estimation_phase <- 0
mod$start$N_bootstraps <- 3
mod$start$F_age_range <- NULL
mod$start$ctlfile <- 'petrale.ctl'

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
mod$ctl$Variance_adjustment_list <- mod$ctl$Variance_adjustment_list[-(1:nrow(mod$ctl$Variance_adjustment_list)),]

# append all length bins to CAAL data
# they are input as sex = 1 and sex = 2, not sex = 3.
# caal_dat <- matrix(0, nrow = 1, ncol = ncol(mod$dat$agecomp))
# # data bins: 12-62 cm, 2004-2022, minus 2020
# full_caal <- expand.grid(lbin = seq(12, 62, 2), yr = c(2004:2019, 2021:2022)) 
# obs_caal <- mod$dat$agecomp |>
#   dplyr::filter(FltSvy == 4) |>
#   dplyr::select(Yr:Nsamp)

# start model in 1923, few catches before then
# Runs for 100 yrs (like cod)
mod$dat$styr <- 1923
mod$fore$Bmark_years[which(mod$fore$Bmark_years == 1876)] <- -999 # -999 = start year
mod$fore$Bmark_years[which(mod$fore$Bmark_years == 2022)] <- 0 # 0 = end year

# get rid of discards, they are low
mod$ctl$size_selex_types$Discard <- 0
mod$ctl$size_selex_parms <- mod$ctl$size_selex_parms[-grep('Ret', rownames(mod$ctl$size_selex_parms)),]
mod$ctl$size_selex_parms_tv <- mod$ctl$size_selex_parms_tv[-grep('Ret', rownames(mod$ctl$size_selex_parms_tv)),]
mod$dat$use_meanbodywt <- 0
mod$dat$meanbodywt <- NULL
mod$dat$DF_for_meanbodywt <- NULL
mod$dat$N_discard_fleets <- 0
mod$dat$discard_fleet_info <- NULL
mod$dat$discard_data <- NULL
mod$dat$lencomp <- dplyr::filter(mod$dat$lencomp, Part != 1)

# get rid of triennial, just simulate one long fishery-independent index
mod$dat$Nsurveys <- 1
mod$ctl$size_selex_types['Triennial', c('Pattern', 'Male')] <- 0
mod$ctl$size_selex_parms <- mod$ctl$size_selex_parms[-grep('Triennial', rownames(mod$ctl$size_selex_parms)),]
mod$ctl$Q_options <- mod$ctl$Q_options[rownames(mod$ctl$Q_options) != 'Triennial',]
mod$ctl$Q_parms <- mod$ctl$Q_parms[-grep('Triennial', rownames(mod$ctl$Q_parms)),]
mod$dat$CPUE <- dplyr::filter(mod$dat$CPUE, index != 3)
mod$dat$lencomp <- dplyr::filter(mod$dat$lencomp, FltSvy != 3)
# Triennial did not collect age structures for petrale

# get rid of selectivity time blocks
mod$ctl$size_selex_parms$Block <- 0
mod$ctl$size_selex_parms$Block_Fxn <- 0
mod$ctl$size_selex_parms_tv <- NULL

# add environmental index fleet
# don't want to use env sensitivity because other parameter estimates are somewhat different.
petrale.env <- add_fleet(datlist = mod$dat, ctllist = mod$ctl, 
                         data = data.frame(matrix(c(mod$dat$endyr, 7, 1, 0.1), nrow = 1, ncol = 4)), 
                         fleettype = 'CPUE', fleetname = 'env', units = 36)

petrale.env$datlist$fleetinfo1$env <- c(1,1,3)
petrale.env$datlist$fleetinfo2$env <- c(2,0)

petrale.env$ctllist$Q_options['env','extra_se'] <- 0
petrale.env$ctllist$Q_parms <- petrale.env$ctllist$Q_parms[-grep('extraSD_env', rownames(petrale.env$ctllist$Q_parms)),]
# Q for env index must be estimated, not float
petrale.env$ctllist$Q_options['env','float'] <- 0
# Q is actually on a linear scale, not log scale, despite parameter name
petrale.env$ctllist$Q_parms['LnQ_base_env(5)', 'LO'] <- 0.001 # this is actually q for index type 36, and must be >0
petrale.env$ctllist$Q_parms['LnQ_base_env(5)', 'INIT'] <- 1
# Ideally Q is estimated not fixed
# But cannot estimate Q in cases where there is no index
# petrale.env$ctllist$Q_parms['LnQ_base_env(5)', 'PHASE'] <- 5

mod$dat <- petrale.env$datlist
mod$ctl <- petrale.env$ctllist
# mod$dat$agecomp <- dplyr::filter(mod$dat$agecomp, Lbin_lo < 0)

# 1 sex model
mod$ctl$Nsexes <- 1
mod$ctl$size_selex_types$Male <- 0
mod$ctl$MG_parms <- mod$ctl$MG_parms[-grep('Mal', rownames(mod$ctl$MG_parms)),]
mod$ctl$size_selex_parms <- mod$ctl$size_selex_parms[-grep('MalOff', rownames(mod$ctl$size_selex_parms)),]
mod$dat$Nsexes <- 1
mod$dat$lencomp$Gender <- 0
mod$dat$lencomp <- select(mod$dat$lencomp, -(m12:m62))
mod$dat$agecomp <- filter(mod$dat$agecomp, Gender != 2) |>
  mutate(Gender = 0) |>
  select(-(m1:m17))

# prepare data file for sampling CAAL data
# agecomp <- mod$dat$agecomp
# 
# agecomp_long <- expand.grid(Yr = unique(agecomp$Yr[agecomp$Lbin_hi > 0]),
#             Lbin_hi = seq(12, 62, by = 2)) |> 
#   dplyr::mutate(FltSvy = 4, Part = 0, Ageerr = 2, Lbin_lo = Lbin_hi, Nsamp = 1,
#                 Gender = 0, f1 = 1) |>
#   dplyr::arrange(Yr) |> 
#   full_join(agecomp) |> 
#   purrr::map(tidyr::replace_na, replace = 0) |> 
#   as_tibble()
# 
# mod$dat$agecomp <- agecomp_long[,names(agecomp)] |> as.data.frame() 

SS_write(mod, 'inst/extdata/models/petrale/OM', overwrite = TRUE)

ss3sim::create_em(dir_in = 'inst/extdata/models/petrale/OM', 
                  dir_out = 'inst/extdata/models/petrale/EM')
file.copy(from = 'inst/extdata/models/petrale/OM/petrale_data.ss', 
          to = 'inst/extdata/models/petrale/EM/ss3.dat', 
          overwrite = TRUE)
em <- SS_read('inst/extdata/models/petrale/EM')
# create_em hard codes start year of 0 for rec devs
em$ctl$MainRdevYrFirst <- 1959
em$ctl$recdev_early_start <- 1905
SS_write(em, 'inst/extdata/models/petrale/EM', overwrite = TRUE)
