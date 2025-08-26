library(dplyr)
library(doParallel)
library(future)
library(r4ss)
library(ss3sim)
library(here)
source('R/add_fleet.R')

# set ss3 executable location
if(Sys.info()['sysname'] == 'Linux'){
  exe_loc = system.file(file.path("bin", "Linux64", "ss3"), package = "ss3sim")
} else {
  exe_loc = system.file(file.path("bin", "Windows64", "ss3.exe"), package = "ss3sim")
}


# simulate OM and 1st EM scenario -----------------------------------------

df <- setup_scenarios_defaults()

# decrease comp sample sizes
# df$sl.Nsamp.1 <- 25
# df$sl.Nsamp.2 <- 50
# df$sa.Nsamp.1 <- 25
# df$sa.Nsamp.2 <- 50
  
# rec index
df$si.years.3 <- '71:100'
df$si.sds_obs.3 <- 0.1
df$si.seas.3 <- 1

# last 12 yrs of data are forecast
df$ce.forecast_num <- 12
df$cf.years.1 <- '26:112'
df$cf.fvals.1 <- 'rep(0.1052, 87)'

# model location, etc.
df$om_dir <- 'inst/extdata/models/Cod/OM'
df$em_dir <- 'inst/extdata/models/Cod/EM'
df$bias_adjust <- FALSE
rec_flt_ind <- 3


# Do OM simulations, sample data ------------------------------------------

nsim <- 100
sim_dir <- file.path('simulations', 'cod')
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
df2$co.par_int <- 0.8
df2$ce.par_name <- 'SR_sigmaR'
df2$ce.par_int <- 0.8
df2$ce.par_phase <- -99

sim_dir <- file.path('simulations', 'cod_high_sigR')
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


