library(ggplot2)
library(dplyr)
library(r4ss)
theme_set(theme_classic(base_size = 14))


# hake figure -------------------------------------------------------------

hake <- SS_output('inst/extdata/models/PacificHake', covar = FALSE, 
                     verbose = FALSE, printstats = FALSE)
hake$recruit |> 
  select(Yr, raw_dev) |>
  filter(Yr < 2020, Yr > 1990) |>
  ggplot() +
  geom_line(aes(x = Yr, y = raw_dev), col = rgb(35, 74, 131, maxColorValue = 255)) +
  geom_hline(yintercept = 0) +
  labs(x = 'Year', y = 'Recruitment deviation')
ggsave(filename = 'wfc_figs/hake_recdev.png', device = 'png', dpi = 500, width = 10, height = 5)


# load simulation results -------------------------------------------------

cod10_ts <- readr::read_csv('cod_10/ss3sim_ts.csv') |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))
cod10_scalar <- readr::read_csv('cod_10/ss3sim_scalar.csv')  |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))
cod10_dq <- readr::read_csv('cod_10/ss3sim_dq.csv') |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))

cod30_ts <- readr::read_csv('bias_adjust/ss3sim_ts.csv') |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))
cod30_scalar <- readr::read_csv('bias_adjust/ss3sim_scalar.csv')  |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))
cod30_dq <- readr::read_csv('bias_adjust/ss3sim_dq.csv') |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))

petrale10_ts <- readr::read_csv('petrale_10/ss3sim_ts.csv') |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))
petrale10_scalar <- readr::read_csv('petrale_10/ss3sim_scalar.csv')  |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))
petrale10_dq <- readr::read_csv('petrale_10/ss3sim_dq.csv') |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))

petrale30_ts <- readr::read_csv('petrale_30/ss3sim_ts.csv') |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))
petrale30_scalar <- readr::read_csv('petrale_30/ss3sim_scalar.csv')  |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))
petrale30_dq <- readr::read_csv('petrale_30/ss3sim_dq.csv') |>
  mutate(scenario = ifelse(scenario == 'no.ind', 'No index', scenario))

ts <- bind_rows(cod_10 = cod10_ts, cod_30 = cod30_ts, petrale_10 = petrale10_ts, petrale_30 = petrale30_ts, .id = 'df') |>
  tidyr::separate_wider_delim(df, names = c('species', 'nyr'), delim = '_') |>
  mutate(nyr = as.numeric(nyr))

scalar <- bind_rows(cod_10 = cod10_scalar, cod_30 = cod30_scalar, petrale_10 = petrale10_scalar, petrale_30 = petrale30_scalar, .id = 'df') |>
  tidyr::separate_wider_delim(df, names = c('species', 'nyr'), delim = '_') |>
  mutate(nyr = as.numeric(nyr))

dq <- bind_rows(cod_10 = cod10_dq, cod_30 = cod30_dq, petrale_10 = petrale10_dq, petrale_30 = petrale30_dq, .id = 'df') |>
  tidyr::separate_wider_delim(df, names = c('species', 'nyr'), delim = '_') |>
  mutate(nyr = as.numeric(nyr))

# single simulation example -----------------------------------------------

lty_vec <- c(2, rep(1, 6)) |>
  `names<-`(c('Oper. mod.', rev(unique(cod30_ts$scenario))))
scenario_ex <- ts |> 
  filter(model_run == 'em' | scenario == 'No index', iteration == 25, species == 'cod', nyr == 30) |>
  mutate(Model = factor(ifelse(model_run == 'om', 'Oper. mod.', scenario))) |>
  mutate(Model = forcats::fct_rev(Model)) |>
  ggplot() +
  geom_rect(aes(ymax = max(Bio_smry)), xmin = 100, xmax = 112, ymin = 0, fill = 'gray90') +
  geom_rect(aes(ymax = max(Bio_smry)), xmin = 0, xmax = 26, ymin = 0, fill = 'gray90') +
  geom_line(aes(x = year, y = SpawnBio, col = Model, lty = Model, alpha = Model), 
            linewidth = 1) +
  scale_color_manual(values = c('gray50', LaCroixColoR::lacroix_palette('Orange', 6))) +
  labs(x = 'Year', y = 'Spawning Biomass') +
  scale_y_continuous(labels = NULL)

# OM only
scenario_ex +
  scale_linetype_manual(values = lty_vec) +
  scale_alpha_manual(values = c(1, rep(0, 6)))
ggsave('wfc_figs/scenario_ex1.png', device = 'png', width = 8, height = 4, dpi = 500)

# OM + 1 EM no forecast, there is probably a better way to do this
ts |>
  filter(model_run == 'em' | scenario == 'No index', iteration == 25, species == 'cod', nyr == 30) |>
  mutate(Model = factor(ifelse(model_run == 'om', 'Oper. mod.', scenario))) |>
  mutate(Model = forcats::fct_rev(Model)) |>
  filter(Model == 'Oper. mod.' | year <= 100) |>
  ggplot() +
  geom_rect(aes(ymax = max(Bio_smry)), xmin = 100, xmax = 112, ymin = 0, fill = 'gray90') +
  geom_rect(aes(ymax = max(Bio_smry)), xmin = 0, xmax = 26, ymin = 0, fill = 'gray90') +
  geom_line(aes(x = year, y = SpawnBio, col = Model, lty = Model, alpha = Model), 
            linewidth = 1) +
  scale_color_manual(values = c('gray50', LaCroixColoR::lacroix_palette('Orange', 6))) +
  labs(x = 'Year', y = 'Spawning Biomass') +
  scale_y_continuous(labels = NULL) +
  scale_linetype_manual(values = lty_vec) +
  scale_alpha_manual(values = c(1, 1, rep(0, 5)))
ggsave('wfc_figs/scenario_ex2.png', device = 'png', width = 8, height = 4, dpi = 500)

# OM + 1 EM forecast
scenario_ex +
  scale_linetype_manual(values = lty_vec) +
  scale_alpha_manual(values = c(1, 1, rep(0, 5)))
ggsave('wfc_figs/scenario_ex3.png', device = 'png', width = 8, height = 4, dpi = 500)

# OM + all EMs
scenario_ex +
  scale_linetype_manual(values = lty_vec) +
  scale_alpha_manual(values = rep(1, 7))
ggsave('wfc_figs/scenario_ex4.png', device = 'png', width = 8, height = 4, dpi = 500)


# Single year recruitment estimates ---------------------------------------

# Recruitment terminal year
ts |> 
  filter(year == 100 | year == 2022, nyr == 30) |>
  tidyr::pivot_wider(names_from = model_run, values_from = Recruit_0, 
                     id_cols = c(iteration, scenario, species)) |>
  mutate(are = abs((em-om)/om),
         rel_err = (em - om)/om) |> 
  group_by(scenario) |>
  ggplot() +
  geom_violin(aes(x = scenario, y = rel_err, fill = scenario), 
              alpha = 0, col = 'white') +
  geom_hline(yintercept = 0, color = 'black') +
  scale_fill_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6))) +
  theme(legend.position = 'none') +
  labs(x = 'Index SE', y = 'Relative error of terminal\nyear recruitment') +
  facet_wrap(~species)
ggsave('wfc_figs/rec_100_axes.png', device = 'png', width = 8, height = 4, dpi = 500)

ts |> 
  filter(year == 100 | year == 2022, nyr == 30) |>
  tidyr::pivot_wider(names_from = model_run, values_from = Recruit_0, 
                     id_cols = c(iteration, scenario, species)) |>
  mutate(are = abs((em-om)/om),
         rel_err = (em - om)/om) |> 
  group_by(scenario) |>
  ggplot() +
  geom_violin(aes(x = scenario, y = rel_err, fill = scenario)) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_fill_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6))) +
  theme(legend.position = 'none') +
  labs(x = 'Index SE', y = 'Relative error of terminal\nyear recruitment') +
  facet_wrap(~species)

ggsave('wfc_figs/rec_100.png', device = 'png', width = 8, height = 4, dpi = 500)

# Recruitment year 80  
ts |> 
  filter(year == 80 | year == 2002, nyr == 30) |>
  tidyr::pivot_wider(names_from = model_run, values_from = Recruit_0, 
                     id_cols = c(iteration, scenario, species)) |>
  mutate(are = abs((em-om)/om),
         rel_err = (em - om)/om) |> 
  group_by(scenario) |>
  ggplot() +
  geom_violin(aes(x = scenario, y = rel_err, fill = scenario)) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_fill_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6)), ) +
  theme(legend.position = 'none') +
  labs(x = 'Index SE', y = 'Relative error of terminal\nyear-20 recruitment') +
  facet_wrap(~species)
ggsave('wfc_figs/rec_80.png', device = 'png', width = 8, height = 4, dpi = 500)



# Full time series --------------------------------------------------------


# SSB time series
# dq_all <- bind_rows(free = dq, zero_sum = dq_zero_sum, .id = 'do_rec') |> 
dq_long <- dq |>
  tidyr::pivot_longer(Value.SSB:Value.lnSPB) |>
  tidyr::pivot_wider(names_from = model_run, values_from = value, 
                     id_cols = c(iteration, scenario, year, name, species, nyr)) |>
  filter(!is.na(em)) |>
  group_by(species, nyr, name, scenario, year) |>
  summarise(mare = mean(abs((em-om)/om)),
            mre = mean((em-om)/om))
yr_max <- tibble(species = c('cod', 'petrale'), year = c(100, 2022))

mare_ts <- dq_long |>
  filter(nyr == 30) |>
  ggplot() +
  geom_rect(aes(xmin = year, xmax = year+14), ymin = 0, ymax = 1.5, fill = 'gray90', data = yr_max) +
  geom_line(aes(x = year, y = mare, col = scenario, group = paste(scenario)), linewidth = 1) +
  scale_color_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6))) +
  labs(x = 'Year', color = 'Index SE') +
  facet_wrap(~species, scales = 'free') +
  NULL

mare_ts %+% filter(dq_long, name == 'Value.SSB', nyr == 30) +
  geom_line(aes(x = year, y = mare, group = paste(scenario)), 
            col = 'white', linewidth = 1) +
  geom_rect(aes(xmin = year, xmax = year+14), ymin = 0, ymax = 1.5, fill = 'gray90', data = yr_max) +
  ylab('Mean absolute relative error(SSB)') +
  geom_rect(xmin = 100, xmax = 114, ymin = 0, ymax = 0.35, fill = 'gray90')
ggsave('wfc_figs/ssb_mare1.png', device = 'png', width = 8, height = 4, dpi = 500)

mare_ts %+% filter(dq_long, name == 'Value.SSB', nyr == 30) +
  ylab('Mean absolute relative error(SSB)') +
  geom_rect(aes(xmin = year, xmax = year+14), ymin = 0, ymax = 1.5, fill = 'gray90', data = yr_max)
ggsave('wfc_figs/ssb_mare2.png', device = 'png', width = 8, height = 4, dpi = 500)

mare_ts %+% filter(dq_long, name == 'Value.SSB', nyr == 30) +
  ylab('Mean absolute relative error(SSB)') 
ggsave('wfc_figs/ssb_mare3.png', device = 'png', width = 8, height = 4, dpi = 500)

mre_ts <- dq_long |>
  filter(nyr == 30) |>
  ggplot() +
  geom_rect(aes(xmin = year, xmax = year+14), ymin = 0, ymax = 1.5, fill = 'gray90', data = yr_max) +
  geom_line(aes(x = year, y = mre, col = scenario, group = paste(scenario)), linewidth = 2) +
  scale_color_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6))) +
  geom_hline(yintercept = 0) +
  labs(x = 'Year', color = 'Index SE') +
  facet_wrap(~species, scales = 'free_x') +
  NULL

mre_ts %+% filter(dq_long, name == 'Value.SSB', nyr == 30) +
  ylab('Mean relative error(SSB)')
ggsave('wfc_figs/ssb_mre.png', device = 'png', width = 8, height = 4, dpi = 500)

mre_ts %+% filter(dq_long,  name == 'Value.Bratio', nyr == 30) +
  ylab('Mean relative error(Depletion)')


# distributions of parameter estimates ------------------------------------

scalar |> 
  filter(nyr == 30) |>
  tidyr::pivot_wider(names_from = model_run, values_from = Recr_Unfished, 
                     id_cols = c(iteration, scenario, species)) |>
  mutate(are = abs((em-om)/om),
         rel_err = (em - om)/om) |> 
  group_by(scenario) |>
  ggplot() +
  geom_violin(aes(x = scenario, y = rel_err, fill = scenario)) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_fill_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6)), ) +
  theme(legend.position = 'none') +
  labs(x = 'Index SE', y = 'Relative error of unfished recruitment') +
  facet_wrap(~species)
ggsave('wfc_figs/r0.png', device = 'png', width = 8, height = 4, dpi = 500)

scalar |> 
  filter(nyr == 30, species == 'petrale') |>
  tidyr::pivot_wider(names_from = model_run, values_from = NatM_uniform_Fem_GP_1, 
                     id_cols = c(iteration, scenario, species)) |>
  mutate(are = abs((em-om)/om),
         rel_err = (em - om)/om) |> 
  group_by(scenario) |>
  ggplot() +
  geom_violin(aes(x = scenario, y = rel_err, fill = scenario)) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_fill_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6)), ) +
  theme(legend.position = 'none') +
  labs(x = 'Index SE', y = 'Relative error of natural mortality')
ggsave('wfc_figs/M.png', device = 'png', width = 8, height = 4, dpi = 500)


# shorter index -----------------------------------------------------------

scalar |> 
  tidyr::pivot_wider(names_from = model_run, values_from = Recr_Unfished, 
                     id_cols = c(iteration, scenario, species, nyr)) |>
  mutate(are = abs((em-om)/om),
         rel_err = (em - om)/om) |> 
  group_by(scenario, species, nyr) |>
  ggplot() +
  geom_violin(aes(x = scenario, y = rel_err, fill = scenario, 
                  alpha = factor(nyr, levels = c(30, 10)))) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_fill_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6)), ) +
  theme(legend.position = 'none') +
  labs(x = 'Index SE', y = 'Relative error of unfished recruitment') +
  facet_wrap(~species) +
  scale_alpha_manual(values = c(0.25, 1))
ggsave('wfc_figs/r0_fixed.png', device = 'png', width = 8, height = 4, dpi = 500)

scalar |> 
  tidyr::pivot_wider(names_from = model_run, values_from = Recr_Unfished, 
                     id_cols = c(iteration, scenario, species, nyr)) |>
  mutate(are = abs((em-om)/om),
         rel_err = (em - om)/om) |> 
  group_by(scenario, species, nyr) |>
  ggplot() +
  geom_violin(aes(x = scenario, y = rel_err, fill = scenario, 
                  alpha = factor(nyr, levels = c(30, 10)),
                  color = factor(nyr, levels = c(30, 10)))) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_fill_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6)), ) +
  theme(legend.position = 'none') +
  labs(x = 'Index SE', y = 'Relative error of unfished recruitment') +
  facet_wrap(~species) +
  scale_alpha_manual(values = c(0.25, 0)) +
  scale_color_manual(values = c('black', 'white'))
ggsave('wfc_figs/r0_fixed0.png', device = 'png', width = 8, height = 4, dpi = 500)

scalar |> 
  filter(species == 'petrale') |>
  tidyr::pivot_wider(names_from = model_run, values_from = NatM_uniform_Fem_GP_1, 
                     id_cols = c(iteration, scenario, species, nyr)) |>
  mutate(are = abs((em-om)/om),
         rel_err = (em - om)/om) |> 
  group_by(scenario) |>
  ggplot() +
  geom_violin(aes(x = scenario, y = rel_err, fill = scenario, 
                  alpha = factor(nyr, levels = c(30, 10)))) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_fill_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6)), ) +
  theme(legend.position = 'none') +
  labs(x = 'Index SE', y = 'Relative error of natural mortality') +
  scale_alpha_manual(values = c(0.25, 1))
ggsave('wfc_figs/M_fixed.png', device = 'png', width = 8, height = 4, dpi = 500)

dq_long |>
  filter(name == 'Value.SSB') |>
  ggplot() +
  geom_rect(aes(xmin = year, xmax = year+14), ymin = 0, ymax = 1.5, fill = 'gray90', data = yr_max) +
  geom_line(aes(x = year, y = mare, col = scenario, group = paste(scenario, factor(nyr)), 
                alpha = factor(nyr, levels = c(30, 10))), linewidth = 1) +
  scale_color_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6))) +
  labs(x = 'Year', color = 'Index SE') +
  facet_wrap(~species, scales = 'free') +
  scale_alpha_manual(values = c(0.25, 1), guide = 'none') +
  ylab('Mean absolute relative error(SSB)') +
  NULL
ggsave('wfc_figs/mare_ssb_fixed.png', device = 'png', width = 8, height = 4, dpi = 500)

# Empirical petrale results -----------------------------------------------
file.copy(exe_loc, 'inst/extdata/models/petrale/klo_env_runs')
out1 <- SS_output('inst/extdata/models/petrale/klo_env_runs/est_q')
copy_SS_inputs('inst/extdata/models/petrale/klo_env_runs/est_q', 'inst/extdata/models/petrale/klo_env_runs/est_q_bias_adj')
SS_fitbiasramp(out1, oldctl = 'inst/extdata/models/petrale/klo_env_runs/est_q_bias_adj/petrale_control.ss',
               newctl = 'inst/extdata/models/petrale/klo_env_runs/est_q_bias_adj/petrale_control.ss')

copy_SS_inputs('inst/extdata/models/petrale/klo_env_runs/est_q_10yr', 'inst/extdata/models/petrale/klo_env_runs/est_q_10yr_bias_adj')
SS_fitbiasramp(out1, oldctl = 'inst/extdata/models/petrale/klo_env_runs/est_q_10yr_bias_adj/petrale_control.ss',
               newctl = 'inst/extdata/models/petrale/klo_env_runs/est_q_10yr_bias_adj/petrale_control.ss')


dirs <- sapply(c('production', 'klo_env_runs/est_q_bias_adj', 'klo_env_runs/est_q_10yr_bias_adj'),
               \(x) file.path('inst/extdata/models/petrale', x)) |>
  `names<-`(NULL) %>%
  r4ss::SSgetoutput(dirvec = ., getcovar = FALSE, getcomp = FALSE, verbose = FALSE) |>
  r4ss::SSsummarize()

SStableComparisons(out, modelnames = c('base', 'env', 'env_10yr'), 
                   names = c("Recr_Virgin", "R0", "NatM", "L_at_Amax", "VonBert_K", "SSB_Virg", 
                             "Bratio_2023", "SPRratio_2022", "OFLCatch_2023")) |>
  write.csv('inst/extdata/models/petrale/klo_env_runs/comparison_table.csv', row.names = FALSE)

ssb <- out$SpawnBio |>
  rename(Base = replist1, Env = replist2, Env_10yr = replist3) |>
  tidyr::pivot_longer(cols = Base:Env_10yr, names_to = 'Model', values_to = 'value') |>
  ggplot() +
  geom_rect(aes(ymax = max(value)), xmin = 2022.5, xmax = 2034, ymin = 0, fill = 'gray90') +
  geom_line(aes(x = Yr, y = value, col = Model), linewidth = 1) +
  labs(x = 'Year', y = 'Spawning Output') +
  theme(legend.position = 'none') +
  scale_color_manual(values = inauguration::inauguration('inauguration_2021', n = 3))

depl <- out$Bratio |>
  rename(Base = replist1, Env = replist2, Env_10yr = replist3) |>
  tidyr::pivot_longer(cols = Base:Env_10yr, names_to = 'Model', values_to = 'value') |>
  ggplot() +
  geom_rect(aes(ymax = max(value)), xmin = 2022.5, xmax = 2034, ymin = 0, fill = 'gray90') +
  geom_line(aes(x = Yr, y = value, col = Model), linewidth = 1) +
  labs(x = 'Year', y = 'Spawning Depletion') +
  scale_color_manual(values = inauguration::inauguration('inauguration_2021', n = 3))

recdev <- out$recdevs |>
  rename(Base = replist1, Env = replist2, Env_10yr = replist3) |>
  tidyr::pivot_longer(cols = Base:Env_10yr, names_to = 'Model', values_to = 'value') |>
  filter(grepl('Main', Label) | grepl('Late', Label)) |>
  ggplot() +
  geom_rect(aes(ymax = max(value), ymin = min(value)), xmin = 1992.5, xmax = 2022, fill = 'gray90', col = 'black') +
  geom_rect(aes(ymax = max(value), ymin = min(value)), xmin = 2012.5, xmax = 2022, fill = 'gray70', col = 'black') +
  geom_line(aes(x = Yr, y = value, col = Model), linewidth = 1) +
  labs(x = 'Year', y = 'Recruitment Deviation') +
  scale_color_manual(values = inauguration::inauguration('inauguration_2021', n = 3)) +
  theme(legend.position = 'none')

recruit <- out$recruits |>
  rename(Base = replist1, Env = replist2, Env_10yr = replist3) |>
  tidyr::pivot_longer(cols = Base:Env_10yr, names_to = 'Model', values_to = 'value') |>
  filter(Yr %in% 1959:2022) |>
  ggplot() +
  geom_rect(aes(ymax = max(value), ymin = min(value)), xmin = 1992.5, xmax = 2022, fill = 'gray90', col = 'black') +
  geom_rect(aes(ymax = max(value), ymin = min(value)), xmin = 2012.5, xmax = 2022, fill = 'gray70', col = 'black') +
  geom_line(aes(x = Yr, y = value, col = Model), linewidth = 1) +
  labs(x = 'Year', y = 'Recruitment') +
  scale_color_manual(values = inauguration::inauguration('inauguration_2021', n = 3))



gridExtra::grid.arrange(ssb, depl, nrow = 1, widths = c(0.42, 0.58)) |>
  ggsave(filename = 'inst/extdata/models/petrale/klo_env_runs/timeseries.png', device = 'png', width = 9, height = 4.5, units = 'in', dpi = 500)

gridExtra::grid.arrange(recdev, recruit, nrow = 1, widths = c(0.42, 0.58)) |>
  ggsave(filename = 'inst/extdata/models/petrale/klo_env_runs/recruitment.png', device = 'png', width = 9, height = 4.5, units = 'in', dpi = 500)


# cole idea ---------------------------------------------------------------

ts |>
  filter(species == 'petrale', nyr == 30, year >= 1959, model_run == 'em') |>
  group_by(scenario, iteration) |>
  summarise(sigR_emp = sd(rec_dev)) |>
  ggplot(aes(x = scenario, y = sigR_emp, fill = scenario)) +
  geom_violin() 

# well hmm that is hard ot think through, but if that index tells model big recruits are too big 
# (sometimes) it can kill them off faster and still fit the acomps the same?
# same effect with R0
# my intuition is that the index is going to pull big devs either lower (negative) or higher 
# (positive) by chance, but since it's exponentiated the big ones only matter so it induces a bias high
