run_iter <- function(iter, sim_dir, s.d, rec_yrs, mod, tmp_dat,
                     do_bias = TRUE) {
  
  mod$dat$CPUE <- mod$dat$CPUE |> 
    filter(index != rec_flt_ind) |>
    bind_rows(
      filter(tmp_dat$CPUE, index == rec_flt_ind, year %in% rec_yrs)
    )
   
  # copy OM
  iter_dir <- file.path(sim_dir, paste(s.d, length(rec_yrs), sep = '_'), iter) 
  dir.create(iter_dir)
  file.copy(from = file.path(sim_dir, 'base', iter, 'om'),
            to = iter_dir, 
            recursive = TRUE, overwrite = TRUE)
  
  # write EM
  suppressWarnings(
    SS_write(mod, file.path(iter_dir, 'em'), overwrite = TRUE)
  ) # suppresses parfile warnings
  if(do_bias) {
    r4ss::run(dir = file.path(iter_dir, 'em'),
              exe = exe_loc, verbose = FALSE,
              skipfinished = FALSE)
    bias <- ss3sim:::calculate_bias(
      dir = file.path(iter_dir, 'em'),
      ctl_file_in = "em.ctl"
    )
  }
  r4ss::run(dir = file.path(iter_dir, 'em'),
            exe = exe_loc, verbose = FALSE,
            extras = '-nohess', 
            skipfinished = FALSE)
}


# Run EM w/out index ------------------------------------------------------

run_no_index_sims <- function(sim_dir, rec_flt_ind, nsim, do_bias) {
  
  dir.create(file.path(sim_dir, 'no.ind'))
  
  furrr::future_walk(1:nsim, \(iter) {
    # copy OM files
    dir.create(file.path(sim_dir, 'no.ind', iter))
    file.copy(from = file.path(sim_dir, 'base', iter, 'om'),
              to = file.path(sim_dir, 'no.ind', iter), 
              recursive = TRUE, overwrite = TRUE)
    
    # read EM
    mod <- SS_read(file.path(sim_dir, 'base', iter, 'em'))
    
    # remove index
    mod$dat$CPUE <- mod$dat$CPUE[mod$dat$CPUE$index != rec_flt_ind,]
    mod$ctl$Q_options <- mod$ctl$Q_options[-grep('env', rownames(mod$ctl$Q_options)),]
    mod$ctl$Q_parms <- mod$ctl$Q_parms[-grep('env', rownames(mod$ctl$Q_parms)),]
    
    # set forecast F to historic F
    om_dat <- SS_readdat(file.path(sim_dir, 'no.ind', iter, "om", 'data_expval.ss'), 
                         verbose = FALSE)
    mod$fore$ForeCatch <- filter(om_dat$catch, year > (om_dat$endyr-12)) |>
      rename(Year = year, Seas = seas, Fleet = fleet,
             `Catch or F` = catch) |>
      select(-catch_se)
    mod$fore$FirstYear_for_caps_and_allocations <- om_dat$endyr + 1
    
    # write model and run
    suppressWarnings(
      SS_write(mod, file.path(sim_dir, 'no.ind', iter, 'em'))
    ) # suppresses warnings about par file name.
    if(do_bias) {
      r4ss::run(dir = file.path(sim_dir, 'no.ind', iter, 'em'),
                exe = exe_loc, verbose = FALSE,
                # extras = '-nohess', # conducting bias adjustment
                skipfinished = FALSE)
      bias <- ss3sim:::calculate_bias(
        dir = file.path(sim_dir, 'no.ind', iter, 'em'),
        ctl_file_in = "em.ctl"
      )
    }
    r4ss::run(dir = file.path(sim_dir, 'no.ind', iter, 'em'),
              exe = exe_loc, verbose = FALSE,
              extras = '-nohess', 
              skipfinished = FALSE)
    message(paste(iter, 'completed'))
    # unlink(file.path(sim_dir, 'no_ind', iter, 'em', 'bias_00'), recursive = TRUE)
  })
}

# Run EM under different index SDs ----------------------------------------
  
run_index_sims <- function(sim_dir, rec_flt_ind, nsim, do_bias,
                          sd_seq, rec_ind_len) {
  
  purrr::walk(sd_seq, \(s.d) {
    purrr::walk(rec_ind_len, \(len) 
                dir.create(file.path(sim_dir, paste(s.d, len, sep = '_'))))
  })
  
  furrr::future_walk(1:nsim, \(iter) {
    mod <- SS_read(file.path(sim_dir, 'base', iter, 'em'))
    rec_yrs <- mod$dat$end - (max(rec_ind_len) - 1):0

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
      tmp_dat <- sample_index(om_dat, fleets = rec_flt_ind, 
                              years = list(rec_yrs), 
                              sds_obs = list(s.d))
      
      purrr::walk(rec_ind_len, \(len)
                  run_iter(
                    iter = iter, sim_dir = sim_dir, s.d = s.d, 
                    mod = mod, tmp_dat = tmp_dat, do_bias = do_bias,
                    rec_yrs = tail(rec_yrs, len))) 
    })
  }, .options = furrr::furrr_options(seed = 5890238))
}
