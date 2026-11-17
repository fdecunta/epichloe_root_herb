#
# Root Herbivore Weight Change and its relation to lolines
#

source("R/config.R")

library(nlme)
library(emmeans)
library(multcomp)

df <- read.csv("data/exp2023.csv")

df[["endo"]]          <- as.factor(df[["endo"]])
df[["herb"]]          <- as.factor(df[["herb"]])
df[["sim_herb"]]      <- as.factor(df[["sim_herb"]])
df[["foliar_damage"]] <- as.factor(df[["foliar_damage"]])
df[["root_damage"]]   <- as.factor(df[["root_damage"]])

df <- df[df[["endo"]] == 1, ] 

df[["total_lolines"]] <- df[["nanl"]] + df[["nfl"]]
df_lol <- df[!is.na(df[["total_lolines"]]), ]

## Calculate Relative Weight Change

# Filter to rows with both initial and final biomass measurements
df_herb <- df_lol[!is.na(df_lol$dabderus_biom_inicial) & !is.na(df_lol$dabderus_biom_final), ]

df_herb$rgr <- (df_herb$dabderus_biom_final - df_herb$dabderus_biom_inicial) / df_herb$dabderus_biom_inicial

# Calculate relative growth rate: log(final / initial) / 180 days
df_herb$days_in_plant <- -1

df_herb$days_in_plant <- ifelse(df_herb$bloque %in% c("bloque_1", "bloque_2"), 28, df_herb$days_in_plant)
df_herb$days_in_plant <- ifelse(df_herb$bloque %in% c("bloque_3", "bloque_4"), 29, df_herb$days_in_plant)
df_herb$days_in_plant <- ifelse(df_herb$bloque %in% c("bloque_5", "bloque_6"), 31, df_herb$days_in_plant)
df_herb$days_in_plant <- ifelse(df_herb$bloque %in% c("bloque_7", "bloque_8"), 31, df_herb$days_in_plant)

df_herb$rgr <- log(df_herb$dabderus_biom_final / df_herb$dabderus_biom_inicial) / df_herb$days_in_plant

# transform to mg g 
df_herb$rgr <- df_herb$rgr * 1000


## Define lolines content
df_herb[["lolines_content"]] <- df_herb[["root_biom"]] * df_herb[["total_lolines"]]

## Data Modelling
options(contrasts = c("contr.sum", "contr.poly"))

mod_weight <- lme(rgr ~ lolines_content + root_damage + foliar_damage,
                  random = ~ 1 | bloque,
                  method = "REML",
                  data = df_herb)

## Check Assumptions

E <- residuals(mod_weight, type = "normalized")

opar <- par(mfrow = c(1, 2))
plot(E ~ fitted(mod_weight))
qqnorm(E)
qqline(E)
par(opar)

shapiro.test(E)

opar = par(mfrow = c(1, 2))
boxplot(E ~ df_herb$root_damage)
boxplot(E ~ df_herb$foliar_damage)
par(opar)

summary(mod_weight)

car::Anova(mod_weight, type = "III")

