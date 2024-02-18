library(dplyr)
library(doParallel)
library(future)
library(r4ss)
library(ss3sim)
library(here)
source('R/add_fleet.R')

# set ss3 executable location
if(Sys.info()['sysname'] == 'Linux'){
  exe_loc = here('inst/extdata/bin/Linux64/ss3')
} else {
  exe_loc = here('inst/extdata/bin/Windows64/ss.exe')
}

# Adjust cod operating model ----------------------------------------------

cod.loc <- system.file(file.path("extdata", "models"), package = "ss3sim")

dir.create('inst/extdata/models/Cod')
file.copy(cod.loc, 'inst/extdata/models/Cod', recursive = TRUE)
file.rename(from = 'inst/extdata/models/Cod/models',
            to = 'inst/extdata/models/Cod/original')
cod <- SS_read('inst/extdata/models/Cod/original/cod-om')

# get rid of CPUE data from fishery. this is weird. and it breaks add_fleet function.
cod$ctl$Q_options <- cod$ctl$Q_options['Survey',]
cod$ctl$Q_parms <- cod$ctl$Q_parms[grep('Survey', rownames(cod$ctl$Q_parms)),]
cod$dat$CPUE <- filter(cod$dat$CPUE, index == which(cod$dat$fleetnames == 'Survey'))

# extend number of years (will be forecast in the EM)
cod$dat$endyr <- 112

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
# cod.env$ctllist$Q_options['env','float'] <- 0
cod.env$ctllist$Q_parms <- cod.env$ctllist$Q_parms[-grep('extraSD', rownames(cod.env$ctllist$Q_parms)),]

cod$dat <- cod.env$datlist
cod$ctl <- cod.env$ctllist
SS_write(cod, 'inst/extdata/models/Cod/OM', overwrite = TRUE)
ss3sim::create_em(dir_in = 'inst/extdata/models/Cod/OM', 
                  dir_out = 'inst/extdata/models/Cod/EM')
# run('inst/extdata/models/cod/OM', exe = here('inst/extdata/models/ss.exe'), extras = '-nohess', show_in_console = TRUE)


# simulate OM and 1st EM scenario -----------------------------------------

# try sample sizes from petrale?
df <- setup_scenarios_defaults()

# rec index
df$si.years.3 <- '70:100'
df$si.sds_obs.3 <- 0.1
df$si.seas.3 <- 1

# last 12 yrs of data are forecast
df$ce.forecast_num <- 12

# model location, etc.
df$om_dir <- 'inst/extdata/models/Cod/OM'
df$em_dir <- 'inst/extdata/models/Cod/EM'
df$bias_adjust <- FALSE

tictoc::tic()
ncore <- parallelly::availableCores()
cl <- makeCluster(ncore - 1)
registerDoParallel(cl)
nsim <- 50
sim_dir <- 'sims'
set.seed(52890)

scname <- run_ss3sim(iterations = 1:nsim, simdf = df, extras = '-nohess', 
                     parallel = TRUE, parallel_iterations = TRUE,
                     scenarios = file.path(sim_dir, df$si.sds_obs.3))
stopCluster(cl)

rec_flt_ind <- 3

# Run EM without index ----------------------------------------------------

dir.create(file.path(sim_dir, 'no_ind'))
plan(multisession, workers = ncore-1)

furrr::future_walk(1:nsim, \(iter) {
  # copy files, read in EM
  file.copy(from = file.path(sim_dir, df$si.sds_obs.3, iter),
            to = file.path(sim_dir, 'no_ind'), 
            recursive = TRUE, overwrite = TRUE)
  mod <- SS_read(file.path(sim_dir, 'no_ind', iter, 'em'))
  
  # remove index
  mod$dat$CPUE <- mod$dat$CPUE[mod$dat$CPUE$index != rec_flt_ind,]
  mod$ctl$Q_options <- mod$ctl$Q_options[-grep('env', rownames(mod$ctl$Q_options)),]
  mod$ctl$Q_parms <- mod$ctl$Q_parms[-grep('env', rownames(mod$ctl$Q_parms)),]
  
  # write model and run
  SS_write(mod, file.path(sim_dir, 'no_ind', iter, 'em'), overwrite = TRUE)
  run(dir = file.path(sim_dir, 'no_ind', iter, 'em'),
      exe = exe_loc,
      extras = '-nohess', skipfinished = FALSE)
})

# Run EM under different index SDs ----------------------------------------

# 0.1, 0.35, 0.7, 1.5, 10 seems like good range
sd_seq <- c(0.35, 0.7, 1.5, 10)
purrr::walk(sd_seq, \(sd) dir.create(file.path(sim_dir, sd)))

furrr::future_walk(1:nsim, \(iter) {
  mod <- SS_read(file.path(sim_dir, df$si.sds_obs.3, iter, 'em'))

  # First replace survey obs with expected values
  om_res <- r4ss::SS_output(file.path(sim_dir, df$si.sds_obs.3, iter, "om"),
                            forecast = FALSE, warn = FALSE, covar = FALSE,
                            readwt = FALSE, verbose = FALSE,
                            printstats = FALSE)
  rec_yrs <- mod$dat$CPUE$year[mod$dat$CPUE$index == rec_flt_ind]
  rec_devs <- dplyr::filter(om_res$recruit, Yr %in% rec_yrs) |>
    dplyr::pull(dev)
  mod$dat$CPUE$obs[mod$dat$CPUE$year %in% rec_yrs &
                     mod$dat$CPUE$index == rec_flt_ind] <- rec_devs
  
  # now sample survey index across new SDs
  purrr::walk(sd_seq, \(sd) {
    tmp_dat <- sample_index(mod$dat, fleets = rec_flt_ind, 
                            years = list(rec_yrs), 
                            sds_obs = list(sd))
    mod$dat$CPUE[mod$dat$CPUE$index == rec_flt_ind,] <- tmp_dat$CPUE
    
    # copy OM (and EM, but will overwrite), write model and run
    file.copy(from = file.path(sim_dir, df$si.sds_obs.3, iter),
              to = file.path(sim_dir, sd), 
              recursive = TRUE, overwrite = TRUE)
    SS_write(mod, file.path(sim_dir, sd, iter, 'em'), overwrite = TRUE)
    run(dir = file.path(sim_dir, sd, iter, 'em'),
        exe = exe_loc,
        extras = '-nohess', skipfinished = FALSE)
  })
}, .options = furrr::furrr_options(seed = 5890238))

sim_res <- get_results_all(directory = sim_dir,
                           overwrite_files = TRUE)

tictoc::toc()