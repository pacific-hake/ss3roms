library(dplyr)
library(doParallel)
library(future)
library(r4ss)
library(ss3sim)
library(here)

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

# simulate OM and 1st EM scenario -----------------------------------------

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

df <- setup_scenarios_defaults()

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
df$si.years.5 <- '2002:2022'
df$si.sds_obs.5 <- 0.1
df$si.seas.5 <- 1

#### clean up
df <- dplyr::select(df, -si.years.2, -si.sds_obs.2, -si.seas.2)

df$om_dir <- 'inst/extdata/models/Petrale/OM'
df$em_dir <- 'inst/extdata/models/Petrale/EM'
df$bias_adjust <- FALSE
rec_flt_ind <- 5


# Do OM runs, sample data -------------------------------------------------

nsim <- 2
sim_dir <- 'petrale'
set.seed(52890)

unlink('petrale', recursive = TRUE)

ncore <- parallelly::availableCores()
cl <- makeCluster(ncore - 1)
registerDoParallel(cl)

tictoc::tic()
scname <- run_ss3sim(iterations = 1:nsim, simdf = df, extras = '-nohess -maxfn 0', 
                     parallel = TRUE, parallel_iterations = TRUE,
                     scenarios = file.path(sim_dir, df[,paste0('si.sds_obs.', rec_flt_ind)]))

tictoc::toc()
stopCluster(cl)
beepr::beep()

file.copy(exe_loc, 'petrale/1/ss3.exe')
bad_out <- SS_output('petrale/0.1/1/em')
SS_plots(bad_out)



# Run EM w/out Env index --------------------------------------------------

dir.create(file.path(sim_dir, 'no_ind'))
plan(multisession, workers = ncore-1)

furrr::future_walk(1:nsim, \(iter) {
  # copy files, read in EM
  file.copy(from = file.path(sim_dir, df[,paste0('si.sds_obs.', rec_flt_ind)], iter),
            to = file.path(sim_dir, 'no_ind'), 
            recursive = TRUE, overwrite = TRUE)
  mod <- SS_read(file.path(sim_dir, 'no_ind', iter, 'em'))
  
  # remove index
  mod$dat$CPUE <- mod$dat$CPUE[mod$dat$CPUE$index != rec_flt_ind,]
  mod$ctl$Q_options <- mod$ctl$Q_options[-grep('env', rownames(mod$ctl$Q_options)),]
  mod$ctl$Q_parms <- mod$ctl$Q_parms[-grep('env', rownames(mod$ctl$Q_parms)),]
  
  # set forecast F to historic F
  om_dat <- SS_readdat(file.path(sim_dir, 'no_ind', iter, "om", 'data_expval.ss'), 
                       verbose = FALSE)
  mod$fore$ForeCatch <- filter(om_dat$catch, year > (om_dat$endyr-12)) |>
    rename(Year = year, Seas = seas, Fleet = fleet,
           `Catch or F` = catch) |>
    select(-catch_se)
  mod$fore$FirstYear_for_caps_and_allocations <- om_dat$endyr + 1
  
  # write model and run
  suppressWarnings(
    SS_write(mod, file.path(sim_dir, 'no_ind', iter, 'em'), overwrite = TRUE)
  ) # suppresses warnings about par file name.
  # run(dir = file.path(sim_dir, 'no_ind', iter, 'em'),
  #     exe = exe_loc, verbose = FALSE,
  #     # extras = '-nohess', # conducting bias adjustment
  #     skipfinished = FALSE)
  # bias <- ss3sim:::calculate_bias(
  #   dir = file.path(sim_dir, 'no_ind', iter, 'em'),
  #   ctl_file_in = "em.ctl"
  # )
  run(dir = file.path(sim_dir, 'no_ind', iter, 'em'),
      exe = exe_loc, verbose = FALSE,
      extras = '-nohess', 
      skipfinished = FALSE)
  
  # unlink(file.path(sim_dir, 'no_ind', iter, 'em', 'bias_00'), recursive = TRUE)
})

# Run EM under different index SDs ----------------------------------------

# based on earlier simulations, > 0.5 all look the same
# want more contrast at lower values.
file.rename(from = file.path(sim_dir, '0.1'),
            to = file.path(sim_dir, 'base'))
sd_seq <- c(0.05, 0.1, 0.2, 0.3, 0.5)
purrr::walk(sd_seq, \(sd) dir.create(file.path(sim_dir, sd)))

furrr::future_walk(1:nsim, \(iter) {
  mod <- SS_read(file.path(sim_dir, 'base', iter, 'em'))
  rec_yrs <- mod$dat$CPUE$year[mod$dat$CPUE$index == rec_flt_ind]
  
  # First replace survey obs with expected values if needed.
  if(any(is.nan(mod$dat$CPUE$obs))) {
    warning('replacing NaNs in index with rec dev. SS3 may not behave as expected.')
    om_res <- r4ss::SS_output(file.path(sim_dir, 'base', iter, "om"),
                              forecast = FALSE, warn = FALSE, covar = FALSE,
                              readwt = FALSE, verbose = FALSE,
                              printstats = FALSE)
    rec_devs <- dplyr::filter(om_res$recruit, Yr %in% rec_yrs) |>
      dplyr::pull(dev)
    mod$dat$CPUE$obs[mod$dat$CPUE$year %in% rec_yrs &
                       mod$dat$CPUE$index == rec_flt_ind] <- rec_devs
  }
  
  # set forecast F to historic F
  om_dat <- SS_readdat(file.path(sim_dir, 'base', iter, "om", 'data_expval.ss'), 
                       verbose = FALSE)
  mod$fore$ForeCatch <- filter(om_dat$catch, year > (om_dat$endyr-12)) |>
    rename(Year = year, Seas = seas, Fleet = fleet,
           `Catch or F` = catch) |>
    select(-catch_se)
  mod$fore$FirstYear_for_caps_and_allocations <- om_dat$endyr + 1
  
  seed <- sample(100000000, 1)
  # now sample survey index across new SDs
  purrr::walk(sd_seq, \(s.d) {
    # ensure same seed for all SEs per iteration
    set.seed(seed)
    tmp_dat <- sample_index(mod$dat, fleets = rec_flt_ind, 
                            years = list(rec_yrs), 
                            sds_obs = list(s.d))
    mod$dat$CPUE[mod$dat$CPUE$index == rec_flt_ind,] <- tmp_dat$CPUE
    
    # copy OM, write model and run
    dir.create(file.path(sim_dir, s.d, iter))
    file.copy(from = file.path(sim_dir, 'base', iter, 'om'),
              to = file.path(sim_dir, s.d, iter), 
              recursive = TRUE, overwrite = TRUE)
    suppressWarnings(
      SS_write(mod, file.path(sim_dir, s.d, iter, 'em'), overwrite = TRUE)
    ) # suppresses parfile warnings
    # run(dir = file.path(sim_dir, s.d, iter, 'em'),
    #     exe = exe_loc, verbose = FALSE,
    #     # extras = '-nohess', 
    #     skipfinished = FALSE)
    # bias <- ss3sim:::calculate_bias(
    #   dir = file.path(sim_dir, s.d, iter, 'em'),
    #   ctl_file_in = "em.ctl"
    # )
    run(dir = file.path(sim_dir, s.d, iter, 'em'),
        exe = exe_loc, verbose = FALSE,
        extras = '-nohess', 
        skipfinished = FALSE)
    # unlink(file.path(sim_dir, s.d, iter, 'em', 'bias_00'), recursive = TRUE)
  })
}, .options = furrr::furrr_options(seed = 5890238))


tictoc::tic()
plan(sequential)
sim_res <- get_results_all(directory = sim_dir, 
                           user_scenarios = c(0.05, 0.1, 0.2, 0.3, 0.5, 'no_ind'),
                           overwrite_files = TRUE)
tictoc::toc()

beepr::beep()
