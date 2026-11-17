#
# Root lolines concentration and shoot:root ratio
#

library(nlme)

df <- read.csv("data/exp2023.csv")

df[["endo"]]          <- as.factor(df[["endo"]])
df[["herb"]]          <- as.factor(df[["herb"]])
df[["sim_herb"]]      <- as.factor(df[["sim_herb"]])
df[["foliar_damage"]] <- as.factor(df[["foliar_damage"]])
df[["root_damage"]]   <- as.factor(df[["root_damage"]])

df[["total_lolines"]] <- df[["nanl"]] + df[["nfl"]]
df_lol <- df[!is.na(df[["total_lolines"]]), ]

## Data Modelling

df_lol[["shoot_root"]] <- df_lol[["shoot_biom"]] / df_lol[["root_biom"]]

options(contrasts = c("contr.sum", "contr.poly"))

mod_weight <- lme(log(total_lolines) ~ shoot_root,
                  random = ~ 1 | bloque,
                  method = "REML",
                  data = df_lol)

## Check Assumptions

E <- residuals(mod_weight, type = "normalized")

opar <- par(mfrow = c(1, 2))
plot(E ~ fitted(mod_weight))
qqnorm(E)
qqline(E)
par(opar)

shapiro.test(E)

opar = par(mfrow = c(1, 2))
boxplot(E ~ df_lol$root_damage)
boxplot(E ~ df_lol$foliar_damage)
par(opar)

car::Anova(mod_weight, type = "III")
