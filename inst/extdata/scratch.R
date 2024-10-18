library(ggplot2)

om_dat <- SS_readdat(file.path(sim_dir, 'base', iter, "om", 'data_expval.ss'), 
                     verbose = FALSE)
ForeCatch <- filter(om_dat$catch, year > 100) |>
  rename(Year = year, Seas = seas, Fleet = fleet,
         `Catch or F` = catch) |>
  select(-catch_se)

out.1 <- SS_output(here('bias_adjust/0.1/1/em'), 
                   printstats = FALSE, verbose = FALSE) 

out.7 <- SS_output(here('sims/0.7/1/em'), 
                   printstats = FALSE, verbose = FALSE) 

out.1 |>
  SS_plots(c(1,2,3,4,7,11,13,14))
ts <- readr::read_csv('sims_low_n/ss3sim_ts.csv')
scalar <- readr::read_csv('sims_low_n/ss3sim_scalar.csv')
dq <- readr::read_csv('sims_low_n/ss3sim_dq.csv')
sim_res <- list(ts = ts, scalar = scalar, dq = dq)

sim_res$scalar |> 
  as_tibble() |>
  # filter(year == 100) |>
  # filter(iteration %in% c(5,8,9,10,12)) |>
  tidyr::pivot_wider(names_from = model_run, values_from = Recr_Unfished, 
                     id_cols = c(iteration, scenario)) |>
  mutate(are = abs((em-om)/om),
         rel_err = (em - om)/om) |> 
  # tidyr::pivot_wider(values_from = rel_err, names_from = scenario, id_cols = iteration)
  group_by(scenario) |>
  summarise(low.low = quantile(are, 0.025),
            low = quantile(are, 0.25),
            mid = mean(are), 
            high = quantile (are, 0.75),
            high.high = quantile(are, 0.975)) |>
  ggplot() +
  geom_linerange(aes(x =scenario, ymin = low.low, ymax = high.high)) +
  geom_point(aes(x = scenario, y = mid)) +
  labs(x = 'Index SE', y = 'Absolute relative error in terminal recruitment')

sim_res$ts |> 
  as_tibble() |>
  filter(year > 30) |>
  tidyr::pivot_wider(names_from = model_run, values_from = SpawnBio, 
                     id_cols = c(iteration, scenario, year)) |>
  mutate(are = abs((em-om)/om)) |> 
  group_by(scenario, year) |>
  summarise(low.low = quantile(are, 0.025),
            low = quantile(are, 0.25),
            mid = mean(are),
            high = quantile (are, 0.75),
            high.high = quantile(are, 0.975)) |>
  ggplot() +
  geom_line(aes(x = year, y = mid, col = scenario, group = paste(scenario))) +
  labs(x = 'forecast year', y = 'mean absolute relative error in SSB', col = 'SE of index')
library(future)

sim_res$scalar |> 
  as_tibble() |>
  filter(year == 100) |>
  tidyr::pivot_wider(names_from = model_run, values_from = Recruit_0, 
                     id_cols = c(iteration, scenario)) |>
  mutate(are = abs((em-om)/om)) |> 
  tidyr::pivot_wider(names_from = scenario, values_from = are, id_cols = iteration) |>
  filter(`0.1` < no_ind)
  
sim_res$ts |> 
  as_tibble() |>
  filter(year == 100) |>
  tidyr::pivot_wider(names_from = model_run, values_from = SpawnBio, 
                     id_cols = c(iteration, scenario)) |>
  mutate(are = abs((em-om)/om)) |> 
  tidyr::pivot_wider(names_from = scenario, values_from = are, id_cols = iteration) |>
  filter(no_ind < `0.1`)

sim_res$ts |> as_tibble() |>
  filter(iteration %in% 1:6) |>
  tidyr::pivot_wider(names_from = model_run, values_from = Recruit_0, 
                     id_cols = c(iteration, scenario, year)) |> 
  arrange(year) |> 
  # tidyr::pivot_wider(names_from = scenario, values_from = em, id_cols = c(iteration, om, year)) |>
  ggplot() +
  # geom_linerange(aes(x = om, ymin = `0.05`, ymax = `0.2`,
            # col = year)) +
  geom_point(aes(x = om, y = em, col = year, pch = scenario)) +
  # geom_path(aes(x = om, y = em, col = scenario, group = scenario)) +
  geom_abline(slope = 1, intercept = 0) +
  facet_wrap(~iteration)

dat <- r4ss::SS_readdat(
   file = system.file(
      "extdata", "models", "PacificHake", "hake_data.ss",
      package = "ss3roms"
   ),
   verbose = FALSE
)
ctl <- r4ss::SS_readctl(
   file = system.file(
      "extdata", "models", "PacificHake", "hake_control.ss",
      package = "ss3roms"
   ),
   use_datlist = TRUE,
   datlist = dat,
   verbose = FALSE,
   version = 3.30
)

newlists <- add_fleet(
   datlist = dat,
   ctllist = ctl,
   data = data.frame(
      year = ROMS[["year"]],
      seas = 7,
      obs = exp(-ROMS$EKEpre.ms.c),
#      obs = exp(ROMS[["EKEpre.ms.c"]]),
#      obs = exp(1.1 * ROMS$dev),
      se_log = 0.01
   ),
   fleetname = "env",
   fleettype = "CPUE", 
   units = 31
)
dirname <- 'test_negEKE'
#dirname <- 'test_posEKE'

fs::dir_copy(
   path = system.file("extdata", "models", "PacificHake",
                      package = "ss3roms"
   ),
   new_path = file.path(dirname),
   overwrite = TRUE
)

r4ss::SS_writectl(
   ctllist = newlists[["ctllist"]],
   outfile = file.path(
      dirname,
      basename(newlists[["ctllist"]][["sourcefile"]])
   ),
   overwrite = TRUE,
   verbose = FALSE
)
r4ss::SS_writedat(
   datlist = newlists[["datlist"]],
   outfile = file.path(
      dirname,
      basename(newlists[["datlist"]][["sourcefile"]])
   ),
   overwrite = TRUE,
   verbose = FALSE
)

plan(multisession, workers = 3)
#future_map(
purrr::map(
   .x = 'test_negEKE', #c('test_negEKE', 'test_posEKE'), 
   .f = r4ss::run_SS_models, 
   model = 'inst/extdata/bin/Windows64/ss', 
   skipfinished = FALSE
)

r4ss::run_SS_models(dirvec = 'test_negEKE', skipfinished = FALSE, model = 'inst/extdata/bin/Windows64/ss')

r4ss::run_SS_models(dirvec = c('test_negEKE', 'test_posEKE'),
                    model = 'inst/extdata/bin/Windows64/ss',
                    skipfinished = FALSE)

temp <- r4ss::SSgetoutput(dirvec = c('test_negEKE', 'inst/extdata/models/PacificHake')) %>%
   r4ss::SSsummarize() %>% 
   r4ss::SSplotComparisons(subplots = 11, legendlabels = c('exp(-EKE)', '2021 Age1'))
abline(v = c(1980.5, 2010.5))


r4ss::SSgetoutput(dirvec = c('test_posEKE', 'test_negEKE')) %>%
   r4ss::SSsummarize() %>%
   r4ss::SSplotComparisons(subplots = 13, legendlabels = c('+EKE', '-EKE', '2021 Age1'))

dplyr::right_join(temp$recdevs, ROMS, by = c('Yr' = 'year')) %>%
   tidyr::pivot_longer(cols = c('replist3', 'EKEpre.ms.c'), names_to = 'name') %>%
   ggplot(aes(x = Yr, y = value)) +
   geom_point() +
   geom_line()+
   xlab('Yr') +
   facet_wrap(~name, scales = 'free_y')

r4ss::SS_doRetro(
   masterdir = here('inst/extdata/models'),
   oldsubdir = 'PacificHake',
   years = -(10:15)
)

dplyr::left_join(temp$indices, temp$recdevs) %>% 
   dplyr::filter(Fleet_name == "Acoustic_Survey", Obs != 1) %>% View

r4ss::SS_output('test_negEKE') %>%
   r4ss::SS_plots(html = TRUE)

r4ss::SS_doRetro(masterdir = here('test_negEKE'),
                 oldsubdir = '', 
                 years = -(10:15)
)

temp <- r4ss::SSgetoutput(dirvec = paste0(here('test_negEKE', 'retrospectives', 'retro'), -(10:15))) %>%
   r4ss::SSsummarize()

temp %>%
   r4ss::SSsummarize() %>%
   r4ss::SSplotRetroRecruits(cohorts = 2000:2010, endyrvec = 2020 - 10:15)
