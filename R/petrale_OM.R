library(dplyr)
library(doParallel)
library(future)
library(r4ss)
library(ss3sim)
library(here)
source('R/functions.R')

# set ss3 executable location
if(Sys.info()['sysname'] == 'Linux'){
  exe_loc = system.file(file.path("bin", "Linux64", "ss3"), package = "ss3sim")
} else {
  exe_loc = system.file(file.path("bin", "Windows64", "ss3.exe"), package = "ss3sim")
}

# set up simulation -----------------------------------------

out <- SS_output('inst/extdata/models/petrale/production', printstats = FALSE, verbose = FALSE)
prod_mod <- SS_read('inst/extdata/models/petrale/production')
agecomp_simple <- prod_mod$dat$agecomp |>
  dplyr::group_by(FltSvy, Yr) |>
  dplyr::summarise(Nsamp = sum(Nsamp)) |>
  dplyr::filter(FltSvy > 0)

lencomp_simple <- prod_mod$dat$lencomp |>
  dplyr::group_by(FltSvy, Yr) |>
  dplyr::summarise(Nsamp = sum(Nsamp)) |>
  dplyr::filter(FltSvy > 0)

df <- setup_scenarios_defaults(nscenarios = 1)

#### landings
df$ce.forecast_num <- 12
df$cf.years.1 <- '1923:2034'
df$cf.years.2 <- '1923:2034'
# df$cf.fvals.1 <- 'c(rep(0, 15), seq(0, 0.5, length.out = 40), rep(0.5, 30), rep(0.3, 15))'
# df$cf.fvals.2 <- 'c(rep(0, 20), rep(0.15, 80))'
df$cf.fvals.1 <- c('c(NULL', out$exploitation$North[out$exploitation$Yr %in% 1923:2022], rep(0.3, 12), ')') |> 
  stringr::str_flatten_comma(last = '')
df$cf.fvals.2 <- c('c(NULL', out$exploitation$South[out$exploitation$Yr %in% 1923:2022], rep(0.05, 12), ')') |> 
  stringr::str_flatten_comma(last = '')

#### fishery dependent lengths
df$sl.years.1 <- c('c(NULL', lencomp_simple$Yr[lencomp_simple$FltSvy == 1], ')') |>
  stringr::str_flatten_comma(last = '')
df$sl.Nsamp.1 <- { lencomp_simple$Nsamp[lencomp_simple$FltSvy == 1] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 1, Data_type == 4)[,'Value']
  } |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')
df$sl.years.2 <- c('c(NULL', lencomp_simple$Yr[lencomp_simple$FltSvy == 2], ')') |>
  stringr::str_flatten_comma(last = '')
df$sl.Nsamp.2 <- { lencomp_simple$Nsamp[lencomp_simple$FltSvy == 2] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 2, Data_type == 4)[,'Value']
} |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')

#### fishery dependent ages
df$sa.years.1 <- c('c(NULL', agecomp_simple$Yr[agecomp_simple$FltSvy == 1], ')') |>
  stringr::str_flatten_comma(last = '')
df$sa.Nsamp.1 <- { agecomp_simple$Nsamp[agecomp_simple$FltSvy == 1] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 1, Data_type == 5)[,'Value']
} |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')
df$sa.years.2 <- c('c(NULL', agecomp_simple$Yr[agecomp_simple$FltSvy == 2], ')') |>
  stringr::str_flatten_comma(last = '')
df$sa.Nsamp.2 <- { agecomp_simple$Nsamp[agecomp_simple$FltSvy == 2] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 2, Data_type == 5)[,'Value']
} |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')

#### survey index
df$si.years.4 <- c('c(NULL', unique(prod_mod$dat$CPUE$year), ')') |>
  stringr::str_flatten_comma(last = '')
df$si.sds_obs.4 <- 0.075
df$si.seas.4 <- 1

#### lengths from triennial (assign to WCGBTS for simplicity)
df$sl.years.4 <- c('c(NULL', lencomp_simple$Yr[lencomp_simple$FltSvy == 3 & lencomp_simple$Yr != 2004], ')') |>
  stringr::str_flatten_comma(last = '')
df$sl.Nsamp.4 <- { lencomp_simple$Nsamp[lencomp_simple$FltSvy == 3 & lencomp_simple$Yr != 2004] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 3, Data_type == 4)[,'Value']
} |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')

#### CAAL from WCGBTS  
df$sc.years.4 <- c('c(NULL', agecomp_simple$Yr[agecomp_simple$FltSvy == 4], ')') |>
  stringr::str_flatten_comma(last = '')
df$sc.Nsamp_lengths.4 <- df$sc.Nsamp_ages.4 <- { lencomp_simple$Nsamp[lencomp_simple$FltSvy == 4] * 
    dplyr::filter(prod_mod$ctl$Variance_adjustment_list, Fleet == 4, Data_type == 4)[,'Value']
} |> 
  round() %>%
  c('c(NULL', ., ')') |>
  stringr::str_flatten_comma(last = '')

#### recruitment index
df$si.years.5 <- '1993:2022'
df$si.sds_obs.5 <- 0.1
df$si.seas.5 <- 1

#### clean up
df <- dplyr::select(df, -si.years.2, -si.sds_obs.2, -si.seas.2)

df$om_dir <- 'inst/extdata/models/Petrale/OM'
df$em_dir <- 'inst/extdata/models/Petrale/EM'
# df$scenarios <- c('sigR_0.5', 'sigR_1')

rec_flt_ind <- 5


# Do OM runs, sample data -------------------------------------------------

nsim <- 100
sim_dir <- file.path('simulations', 'petrale')
set.seed(52890)
df$bias_adjust <- FALSE

# unlink(sim_dir, recursive = TRUE)

ncore <- parallelly::availableCores()
cl <- makeCluster(ncore - 1)
registerDoParallel(cl)

tictoc::tic()
scname <- run_ss3sim(iterations = 1:nsim, simdf = df, extras = '-stopph 0 -nohess', 
                     parallel = TRUE, parallel_iterations = TRUE,
                     # parallel = FALSE, parallel_iterations = FALSE,
                     scenarios = file.path(sim_dir, 'base'))

tictoc::toc()
stopCluster(cl)
beepr::beep()


# Do the actual EM runs ---------------------------------------------------

plan(multisession, workers = ncore-1)
sd_seq <- c(0.05, 0.1, 0.2, 0.3, 0.5)
rec_ind_len <- c(10, 30)
# based on earlier simulations, > 0.5 all look the same
# want more contrast at lower values.

# plan(sequential, split = TRUE)
run_no_index_sims(sim_dir = sim_dir, 
                  rec_flt_ind = rec_flt_ind, 
                  nsim = nsim, 
                  do_bias = TRUE)

run_index_sims(sim_dir = sim_dir,
               rec_flt_ind = rec_flt_ind, 
               nsim = nsim, 
               do_bias = TRUE, 
               sd_seq = sd_seq,
               rec_ind_len = rec_ind_len)

beepr::beep()


# Summarize results -------------------------------------------------------

tictoc::tic()
plan(sequential, split = TRUE)

scenario_names <- expand.grid(sd_seq, rec_ind_len) |> apply(1, paste, collapse = "_")

sim_res <- get_results_all(directory = sim_dir, 
                           user_scenarios = c(scenario_names, 'no.ind'),
                           overwrite_files = TRUE)
tictoc::toc()


# Now increase sigma R ----------------------------------------------------

df2 <- df
df2$co.par_name <- 'SR_sigmaR'
df2$co.par_int <- 1
df2$ce.par_name <- 'SR_sigmaR'
df2$ce.par_int <- 1
df2$ce.par_phase <- -99

sim_dir <- file.path('simulations', 'petrale_high_sigR')
set.seed(52890)

cl <- makeCluster(ncore - 1)
registerDoParallel(cl)

tictoc::tic()
scname <- run_ss3sim(iterations = 1:nsim, simdf = df2, extras = '-stopph 0 -nohess', 
                     parallel = TRUE, parallel_iterations = TRUE,
                     # parallel = FALSE, parallel_iterations = FALSE,
                     scenarios = file.path(sim_dir, 'base'))

tictoc::toc()
stopCluster(cl)

plan(multisession, workers = ncore-1)

run_no_index_sims(sim_dir = sim_dir, 
                  rec_flt_ind = rec_flt_ind, 
                  nsim = nsim, 
                  do_bias = TRUE)

run_index_sims(sim_dir = sim_dir,
               rec_flt_ind = rec_flt_ind, 
               nsim = nsim, 
               do_bias = TRUE, 
               sd_seq = sd_seq,
               rec_ind_len = rec_ind_len)

tictoc::tic()
plan(sequential, split = TRUE)

scenario_names <- expand.grid(sd_seq, rec_ind_len) |> apply(1, paste, collapse = "_")

sim_res <- get_results_all(directory = sim_dir, 
                           user_scenarios = c(scenario_names, 'no.ind'),
                           overwrite_files = TRUE)
tictoc::toc()

source('R/cod_OM.R')
