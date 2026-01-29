library(r4ss)
library(here)
library(ggplot2)
library(dplyr)

theme_set(theme_classic(base_size = 14))

read_sim_output <- function(filepath, max_grad_criteria = 0.1) {
  scalar <- file.path(filepath, 'ss3sim_scalar.csv') |>
    readr::read_csv() |>
    mutate(scenario = ifelse(scenario == 'no.ind', 'No index_10', scenario)) |>
    tidyr::separate_wider_delim(
      cols = scenario,
      delim = "_",
      names = c('scenario', 'nyr')
    ) |>
    mutate(nyr = as.numeric(nyr)) %>%
    bind_rows({
      filter(., scenario == 'No index') |>
        mutate(nyr = 30)
    })

  bad_sims <- scalar |>
    filter(max_grad > max_grad_criteria) |>
    select(iteration, scenario, nyr)

  scalar_filtered <- anti_join(scalar, bad_sims)

  ts <- file.path(filepath, 'ss3sim_ts.csv') |>
    readr::read_csv() |>
    mutate(scenario = ifelse(scenario == 'no.ind', 'No index_10', scenario)) |>
    tidyr::separate_wider_delim(
      cols = scenario,
      delim = "_",
      names = c('scenario', 'nyr')
    ) |>
    mutate(nyr = as.numeric(nyr)) %>%
    bind_rows({
      filter(., scenario == 'No index') |> # replicate no index rows for both index lengths (for plotting ease)
        mutate(nyr = 30)
    }) |>
    anti_join(bad_sims)

  dq <- file.path(filepath, 'ss3sim_dq.csv') |>
    readr::read_csv() |>
    mutate(scenario = ifelse(scenario == 'no.ind', 'No index_10', scenario)) |>
    tidyr::separate_wider_delim(
      cols = scenario,
      delim = "_",
      names = c('scenario', 'nyr')
    ) |>
    mutate(nyr = as.numeric(nyr)) %>%
    bind_rows({
      filter(., scenario == 'No index') |>
        mutate(nyr = 30)
    }) |>
    anti_join(bad_sims)

  message(paste0(
    nrow(bad_sims),
    ' simulations were filtered out of ',
    filepath,
    ' due to exceeding the maximum gradient criterion of ',
    max_grad_criteria,
    '. They are:'
  ))

  return(list(ts = ts, scalar = scalar_filtered, dq = dq, bad_sims = bad_sims))
}

cod_om <- SS_read(here('inst/extdata/models/cod/om'))
cod_ctl <- cod_om$ctl

petrale_om <- SS_read(here('inst/extdata/models/petrale/om'))
petrale_ctl <- petrale_om$ctl

cod_om_rep <- SS_output(
  here('simulations/cod/no.ind/1/om'),
  verbose = FALSE,
  printstats = FALSE
)
petrale_om_rep <- SS_output(
  here('simulations/petrale/no.ind/1/om'),
  verbose = FALSE,
  printstats = FALSE
)

sim_names <- c(
  'cod',
  'cod_high_sigR',
  'petrale',
  'petrale_high_sigR',
  # 'petrale_high_sigR_high_index_se',
  NULL
)
big_res <- here::here('simulations', sim_names) |>
  `names<-`(sim_names) |>
  purrr::map(read_sim_output)

ts <- purrr::map(big_res, purrr::pluck, 'ts') |>
  bind_rows(.id = 'ID') |>
  mutate(
    species = stringr::str_to_title(stringr::str_extract(ID, '^[:alpha:]+')), # any number of letters starting at beginning
    sigR = ifelse(grepl('_high_sigR', ID), 'high', 'low'),
    indexSE = ifelse(grepl('index_se', ID), 'high', 'low')
  ) |>
  # + 1) * # = 1 if low, 2 if high
  # ifelse(species == 'Cod', 0.4, 0.5)) |> # these are the baseline sigma Rs for each species
  select(-ID)

ts_long <- ts |>
  tidyr::pivot_longer(cols = c(Bio_smry:raw_rec_dev, retainB_2:F_2)) |>
  tidyr::pivot_wider(
    names_from = model_run,
    values_from = value,
    id_cols = c(iteration, scenario, year, name, species, nyr, sigR)
  ) |>
  filter(!is.na(em)) |>
  group_by(species, nyr, name, scenario, year, sigR) |>
  summarise(mare = mean(abs((em - om) / om)), mre = mean((em - om) / om)) |>
  mutate(year = ifelse(species == 'Petrale', year - petrale_om$dat$styr, year))

scalar <- purrr::map(big_res, purrr::pluck, 'scalar') |>
  bind_rows(.id = 'ID') |>
  mutate(
    species = stringr::str_to_title(stringr::str_extract(ID, '^[:alpha:]+')), # any number of letters starting at beginning
    sigR = ifelse(grepl('_high_sigR', ID), 'high', 'low'),
    indexSE = ifelse(grepl('index_se', ID), 'high', 'low')
  ) |>
  # + 1) * # = 1 if low, 2 if high
  # ifelse(species == 'Cod', 0.4, 0.5)) |> # these are the baseline sigma Rs for each species
  select(-ID)

dq <- purrr::map(big_res, purrr::pluck, 'dq') |>
  bind_rows(.id = 'ID') |>
  mutate(
    species = stringr::str_to_title(stringr::str_extract(ID, '^[:alpha:]+')), # any number of letters starting at beginning
    sigR = ifelse(grepl('_high_sigR', ID), 'high', 'low'),
    indexSE = ifelse(grepl('index_se', ID), 'high', 'low')
  ) |>
  # + 1) * # = 1 if low, 2 if high
  # ifelse(species == 'Cod', 0.4, 0.5)) |> # these are the baseline sigma Rs for each species
  select(-ID)

dq_long <- dq |>
  tidyr::pivot_longer(Value.SSB:Value.lnSPB) |>
  tidyr::pivot_wider(
    names_from = model_run,
    values_from = value,
    id_cols = c(iteration, scenario, year, name, species, nyr, sigR)
  ) |>
  filter(!is.na(em)) |>
  group_by(species, nyr, name, scenario, year, sigR) |>
  summarise(mare = mean(abs((em - om) / om)), mre = mean((em - om) / om)) |>
  mutate(year = ifelse(species == 'Petrale', year - petrale_om$dat$styr, year))

bad_sims <- purrr::map(big_res, purrr::pluck, 'bad_sims') |>
  bind_rows(.id = 'ID')

## Terminal year recruitment
ts |>
  filter(year == 100 | year == 2022, nyr == 30, sigR == 'low') |>
  tidyr::pivot_wider(
    names_from = model_run,
    values_from = Recruit_0,
    id_cols = c(iteration, scenario, species)
  ) |>
  mutate(are = abs((em - om) / om), rel_err = (em - om) / om) |>
  group_by(scenario) |>
  ggplot() +
  geom_violin(
    aes(x = scenario, y = rel_err, fill = scenario),
    alpha = 0,
    col = 'white'
  ) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_fill_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6))) +
  theme(legend.position = 'none') +
  labs(x = 'Index SE', y = 'Relative error of terminal\nyear recruitment') +
  facet_wrap(~species)
ggsave(
  'nsaw_figs/rec_100_axes.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

ts |>
  filter(year == 100 | year == 2022, nyr == 30, sigR == 'low') |>
  tidyr::pivot_wider(
    names_from = model_run,
    values_from = Recruit_0,
    id_cols = c(iteration, scenario, species)
  ) |>
  mutate(are = abs((em - om) / om), rel_err = (em - om) / om) |>
  group_by(scenario) |>
  ggplot() +
  geom_violin(aes(x = scenario, y = rel_err, fill = scenario)) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_fill_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6))) +
  theme(legend.position = 'none') +
  labs(x = 'Index SE', y = 'Relative error of terminal\nyear recruitment') +
  facet_wrap(~species)
ggsave(
  'nsaw_figs/rec_100.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

## MARE(SSB)
ranges <- dq_long |>
  filter(sigR == 'low') |>
  group_by(species, name) |>
  summarise(
    max_mare = max(mare, na.rm = TRUE),
    max_mre = max(mre, na.rm = TRUE),
    min_mre = min(mre, na.rm = TRUE)
  )

mare_ts <- dq_long |>
  filter(name == 'Value.SSB', sigR == 'low', nyr == 30) |>
  ggplot(aes(
    x = year,
    y = mare,
    col = scenario,
    group = paste(scenario, nyr)
  )) +
  geom_rect(
    aes(ymax = 1.05 * max_mare),
    xmin = 100,
    xmax = 114,
    ymin = 0,
    fill = 'gray90',
    data = filter(ranges, name == 'Value.SSB'),
    inherit.aes = FALSE
  ) +
  geom_line() +
  scale_color_manual(values = rev(LaCroixColoR::lacroix_palette('Orange', 6))) +
  labs(
    x = 'Year',
    y = 'Mean absolute relative error(SSB)',
    color = 'Index SE'
  ) +
  facet_wrap(~species, scales = 'free_y', nrow = 1) +
  theme(strip.text = element_text(margin = margin(t = 2, b = 2, unit = 'mm'))) +
  NULL

mare_ts +
  geom_line(col = 'white', linewidth = 2) +
  geom_rect(
    aes(ymax = 1.05 * max_mare),
    xmin = 100,
    xmax = 114,
    ymin = 0,
    fill = 'gray90',
    data = filter(ranges, name == 'Value.SSB'),
    inherit.aes = FALSE
  )
ggsave(
  'nsaw_figs/ssb_mare1.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

mare_ts +
  # filter(dq_long, name == 'Value.SSB', sigR == 'low', nyr == 30) +
  geom_rect(
    aes(ymax = 1.05 * max_mare),
    xmin = 100,
    xmax = 114,
    ymin = 0,
    fill = 'gray90',
    data = filter(ranges, name == 'Value.SSB'),
    inherit.aes = FALSE
  )
ggsave(
  'nsaw_figs/ssb_mare2.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

mare_ts
ggsave(
  'nsaw_figs/ssb_mare3.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

mare_ts +
  filter(dq_long, name == 'Value.SSB', sigR == 'low') +
  aes(alpha = factor(nyr, levels = c(30, 10))) +
  scale_alpha_manual(values = c(0.25, 1), guide = 'none')
ggsave(
  'nsaw_figs/ssb_mare4.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

## Unfished recruitment
r0 <- scalar |>
  tidyr::pivot_wider(
    names_from = model_run,
    values_from = Recr_Unfished,
    id_cols = c(iteration, scenario, species, nyr, sigR)
  ) |>
  mutate(are = abs((em - om) / om), rel_err = (em - om) / om) |>
  group_by(scenario, species, nyr) |>
  ggplot(aes(x = scenario, y = rel_err, fill = scenario)) +
  scale_fill_manual(
    values = rev(LaCroixColoR::lacroix_palette('Orange', 6))
  ) +
  labs(x = 'Index SE', y = 'Relative error of unfished recruitment') +
  facet_wrap(~species, scales = 'free_y', nrow = 1) +
  theme(legend.position = 'none')

r0 +
  geom_violin(data = \(x) filter(x, nyr == 30, sigR == 'low')) +
  geom_hline(yintercept = 0, color = 'black')
ggsave(
  'nsaw_figs/r0_1.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

r0 +
  geom_violin(
    aes(
      alpha = factor(nyr, levels = c(30, 10)),
      color = factor(nyr, levels = c(30, 10))
    ),
    data = \(x) filter(x, sigR == 'low')
  ) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_alpha_manual(values = c(0.25, 0)) +
  scale_color_manual(values = c('black', 'white'))
ggsave(
  'nsaw_figs/r0_2.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

r0 +
  geom_violin(
    aes(
      alpha = factor(nyr, levels = c(30, 10)),
      color = factor(nyr, levels = c(30, 10))
    ),
    data = \(x) filter(x, sigR == 'low')
  ) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_alpha_manual(values = c(0.25, 1)) +
  scale_color_manual(values = c('black', 'black'))
ggsave(
  'nsaw_figs/r0_3.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

r0 +
  geom_violin(data = \(x) filter(x, nyr == 30, sigR == 'high')) +
  geom_hline(yintercept = 0, color = 'black')
ggsave(
  'nsaw_figs/r0_4.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

## Natural mortality
natM <- scalar |>
  filter(species == 'Petrale') |>
  tidyr::pivot_wider(
    names_from = model_run,
    values_from = NatM_uniform_Fem_GP_1,
    id_cols = c(iteration, scenario, species, nyr, sigR)
  ) |>
  mutate(are = abs((em - om) / om), rel_err = (em - om) / om) |>
  group_by(scenario, species, nyr) |>
  ggplot(aes(x = scenario, y = rel_err, fill = scenario)) +
  scale_fill_manual(
    values = rev(LaCroixColoR::lacroix_palette('Orange', 6))
  ) +
  labs(x = 'Index SE', y = 'Relative error of natural mortality') +
  theme(legend.position = 'none')

natM +
  geom_violin(data = \(x) filter(x, nyr == 30, sigR == 'low')) +
  geom_hline(yintercept = 0, color = 'black')
ggsave(
  'nsaw_figs/M_1.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)

natM +
  geom_violin(
    aes(
      alpha = factor(nyr, levels = c(30, 10))
    ),
    data = \(x) filter(x, sigR == 'low')
  ) +
  geom_hline(yintercept = 0, color = 'black') +
  scale_alpha_manual(values = c(0.25, 1))
ggsave(
  'nsaw_figs/M_2.png',
  device = 'png',
  width = 8,
  height = 4,
  dpi = 500
)
