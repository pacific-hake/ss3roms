library(dplyr)
library(doParallel)
library(future)
library(r4ss)
library(ss3sim)
library(here)
source('R/add_fleet.R')

# to do:
# return to ss3sim instructions for new OM
# first try running this using the same sample sizes, F, etc. as cod
# then, possibly, try to mimic more realism
# explore forecast file.

# set ss3 executable location
if(Sys.info()['sysname'] == 'Linux'){
  exe_loc = system.file(file.path("bin", "Linux64", "ss3"), package = "ss3sim")
} else {
  exe_loc = system.file(file.path("bin", "Windows64", "ss3.exe"), package = "ss3sim")
}


# need to run model and use ss_new files so starting values match estimates
copy_SS_inputs('inst/extdata/models/petrale/production', 
               'inst/extdata/models/petrale/OM', 
               use_ss_new = TRUE, overwrite = TRUE)

mod <- SS_read('inst/extdata/models/petrale/OM')

# forecast modifications
mod$fore$Do_West_Coast_gfish_rebuilder_output <- 0

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
#   dplyr::filter(fleet == 4) |>
#   dplyr::select(Yr:Nsamp)

# start model in 1923, few catches before then
# Runs for 100 yrs (like cod)
mod$dat$styr <- 1923
mod$fore$Bmark_years[which(mod$fore$Bmark_years == 1876)] <- 1923

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
mod$dat$lencomp <- dplyr::filter(mod$dat$lencomp, fleet != 3)
# Triennial did not collect age structures for petrale

# add environmental index fleet
# don't want to use env sensitivity because other parameter estimates are somewhat different.
petrale.env <- add_fleet(datlist = mod$dat, ctllist = mod$ctl, 
                     data = data.frame(matrix(c(mod$dat$endyr, 7, 1, 0.1), nrow = 1, ncol = 4)), 
                     fleettype = 'CPUE', fleetname = 'env', units = 36)

petrale.env$datlist$fleetinfo1$env <- c(1,1,3)
petrale.env$datlist$fleetinfo2$env <- c(2,0)

petrale.env$ctllist$Q_options['env','extra_se'] <- 0
# Q for env index must be estimated, not float
petrale.env$ctllist$Q_options['env','float'] <- 0
petrale.env$ctllist$Q_parms <- petrale.env$ctllist$Q_parms[-grep('extraSD_env', rownames(petrale.env$ctllist$Q_parms)),]
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
mod$dat$lencomp$sex <- 0
mod$dat$lencomp <- select(mod$dat$lencomp, -(m12:m62))
mod$dat$agecomp <- filter(mod$dat$agecomp, sex != 2) |>
  mutate(sex = 0) |>
  select(-(m1:m17))

# prepare data file for sampling CAAL data
# agecomp <- mod$dat$agecomp
# 
# agecomp_long <- expand.grid(Yr = unique(agecomp$Yr[agecomp$Lbin_hi > 0]),
#             Lbin_hi = seq(12, 62, by = 2)) |> 
#   dplyr::mutate(fleet = 4, Part = 0, Ageerr = 2, Lbin_lo = Lbin_hi, Nsamp = 1,
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
# run('inst/extdata/models/petrale/EM', extras = '-nohess', # -maxfn 0',
#     show_in_console = TRUE,
#     exe = exe_loc, skipfinished = FALSE)
# beepr::beep()

# simulate OM and 1st EM scenario -----------------------------------------

# out <- SS_output('inst/extdata/models/petrale/production')
# out$exploitation |> 
#   with(plot(Yr, annual_F, type = 'l'))
# abline(h=0.2)
out <- SS_output('inst/extdata/models/petrale/production', printstats = FALSE, verbose = FALSE)
prod_mod <- SS_read('inst/extdata/models/petrale/production')
agecomp_simple <- prod_mod$dat$agecomp |>
  dplyr::group_by(fleet, year) |>
  dplyr::summarise(Nsamp = sum(Nsamp)) |>
  dplyr::filter(fleet > 0)

lencomp_simple <- prod_mod$dat$lencomp |>
  dplyr::group_by(fleet, year) |>
  dplyr::summarise(Nsamp = sum(Nsamp)) |>
  dplyr::filter(fleet > 0)

df <- setup_scenarios_defaults()
df$cf.years.1 <- '1923:2022'
df$cf.years.2 <- '1923:2022'
# lower fishing scenario
# df$cf.fvals.1 <- 'c(rep(0, 15), seq(0, 0.5, length.out = 40), rep(0.5, 30), rep(0.3, 15))'
# df$cf.fvals.2 <- 'c(rep(0, 20), rep(0.15, 80))'

# empirical fishing scenario
df$cf.fvals.1 <- c('c(NULL', out$exploitation$North[out$exploitation$Yr %in% 1923:2022], ')') |> 
  stringr::str_flatten_comma(last = '')
df$cf.fvals.2 <- c('c(NULL', out$exploitation$South[out$exploitation$Yr %in% 1923:2022], ')') |> 
  stringr::str_flatten_comma(last = '')

# fishery dependent lengths
# some of these are sexed and some are not.
# production model contains sex = 0 and sex = 3 for same fleet in some years
# lengths of these vectors do not match!
df$sl.years.1 <- c('c(NULL', lencomp_simple$year[lencomp_simple$fleet == 1], ')') |>
  stringr::str_flatten_comma(last = '')
df$sl.Nsamp.1 <- { lencomp_simple$Nsamp[lencomp_simple$fleet == 1] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 1, Data_type == 4)[,'Value']
  } |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')
df$sl.years.2 <- c('c(NULL', lencomp_simple$year[lencomp_simple$fleet == 2], ')') |>
  stringr::str_flatten_comma(last = '')
df$sl.Nsamp.2 <- { lencomp_simple$Nsamp[lencomp_simple$fleet == 2] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 2, Data_type == 4)[,'Value']
} |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')

# fishery dependent ages
df$sa.years.1 <- c('c(NULL', agecomp_simple$year[agecomp_simple$fleet == 1], ')') |>
  stringr::str_flatten_comma(last = '')
df$sa.Nsamp.1 <- { agecomp_simple$Nsamp[agecomp_simple$fleet == 1] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 1, Data_type == 5)[,'Value']
} |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')
df$sa.years.2 <- c('c(NULL', agecomp_simple$year[agecomp_simple$fleet == 2], ')') |>
  stringr::str_flatten_comma(last = '')
df$sa.Nsamp.2 <- { agecomp_simple$Nsamp[agecomp_simple$fleet == 2] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 2, Data_type == 5)[,'Value']
} |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')

# wcgbts samples
df$si.years.4 <- c('c(NULL', unique(prod_mod$dat$CPUE$year), ')') |>
  stringr::str_flatten_comma(last = '')
df$si.sds_obs.4 <- 0.075
df$si.seas.4 <- 1

# lengths from triennial (assign to WCGBTS for simplicity)
df$sl.years.4 <- c('c(NULL', lencomp_simple$year[lencomp_simple$fleet == 3 & lencomp_simple$year != 2004], ')') |>
  stringr::str_flatten_comma(last = '')
df$sl.Nsamp.4 <- { lencomp_simple$Nsamp[lencomp_simple$fleet == 3 & lencomp_simple$year != 2004] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 3, Data_type == 4)[,'Value']
} |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')

# CAAL from WCGBTS  
df$sc.years.4 <- c('c(NULL', agecomp_simple$year[agecomp_simple$fleet == 4], ')') |>
  stringr::str_flatten_comma(last = '')
df$sc.Nsamp_lengths.4 <- df$sc.Nsamp_ages.4 <- { lencomp_simple$Nsamp[lencomp_simple$fleet == 4] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 4, Data_type == 4)[,'Value']
} |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')

# recruitment index
df$si.years.5 <- 'c(2018:2022)'
df$si.seas.5 <- 1
df$si.sds_obs.5 <- 0.1

df <- dplyr::select(df, -si.years.2, -si.sds_obs.2, -si.seas.2)

df$om_dir <- 'inst/extdata/models/Petrale/OM'
df$em_dir <- 'inst/extdata/models/Petrale/EM'
df$bias_adjust <- FALSE

nsim <- 1
sim_dir <- 'petrale'
ncore <- parallelly::availableCores()
# cl <- makeCluster(ncore - 1)
# registerDoParallel(cl)
set.seed(52890)

unlink('petrale', recursive = TRUE)
tictoc::tic()
scname <- run_ss3sim(iterations = 1:nsim, simdf = df, extras = '-nohess', 
                     # parallel = TRUE, parallel_iterations = TRUE,
                     parallel = FALSE, parallel_iterations = FALSE,
                     scenarios = file.path(sim_dir))

tictoc::toc()
beepr::beep()
stopCluster(cl)

file.copy(exe_loc, 'petrale/1/ss3.exe')

rec_flt_ind <- 5

# Comp data
# If I use existing EM data weights, I think I can just use multinomial distribution.
# Maybe use multinomial distribution with n = data weight * input n? and no data weighting in EM?

# Ian: what is up with seas of both 1 and 7 in the petrale length comps?
simdf[,grep('^sl\\.', colnames(simdf))]

# How many years to do this for?

# Meeting notes
# dat file for OM is meaningless but needs to be there
# christine has petrale ss3sim, claudio has hake ss3sim without empirical weight at age. If I want to sample weight at age I need to review and likely revise the function.

