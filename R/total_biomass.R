#
# Total biomass
#

# Must run from notebooks/, not from root dir
# Load config for colors, labels, etc.
source("R/config.R")

library(lattice)
library(nlme)
library(emmeans)
library(multcomp)

dat_2023 <- read.csv("data/exp2023.csv")

dat_2023[["endo"]] <- as.factor(dat_2023[["endo"]])
dat_2023[["herb"]] <- as.factor(dat_2023[["herb"]])
dat_2023[["foliar_damage"]] <- as.factor(dat_2023[["foliar_damage"]])
dat_2023[["root_damage"]] <- as.factor(dat_2023[["root_damage"]])
dat_2023[["sim_herb"]] <- as.factor(dat_2023[["sim_herb"]])

# Compute shoot:root ratio
dat_2023[["total_biom"]] <- dat_2023[["shoot_biom"]] + dat_2023[["root_biom"]]


## Summary

summary(dat_2023[["total_biom"]])

# Model Selection

options(contrasts = c("contr.sum", "contr.poly"))

mod_sr_0 <- gls(total_biom ~ endo * foliar_damage * root_damage * herb,
                method = "ML",
                data = dat_2023)

mod_sr_1 <- lme(total_biom ~ endo * foliar_damage * root_damage * herb,
                random = ~ 1 | bloque,
                method = "ML",
                data = dat_2023)

mod_sr_2 <- gls(total_biom ~ endo * foliar_damage * root_damage * herb,
                weights = varIdent(form = ~ 1 | foliar_damage),
                method = "ML",
                data = dat_2023)

mod_sr_3 <- lme(total_biom ~ endo * foliar_damage * root_damage * herb,
                random = ~ 1 | bloque,
                weights = varIdent(form = ~ 1 | root_damage),
                method = "ML",
                data = dat_2023)

mod_sr_4 <- lme(total_biom ~ endo * foliar_damage * root_damage * herb,
                random = ~ 1 | bloque,
                weights = varIdent(form = ~ 1 | endo),
                method = "ML",
                data = dat_2023)

mod_sr_5 <- lme(total_biom ~ endo * foliar_damage * root_damage * herb,
                random = ~ 1 | bloque,
                weights = varIdent(form = ~ 1 | foliar_damage * root_damage),
                method = "ML",
                data = dat_2023)

AIC(mod_sr_0, mod_sr_1, mod_sr_2, mod_sr_3, mod_sr_4, mod_sr_5)


res <- lme(total_biom ~ endo * foliar_damage * root_damage * herb,
              random = ~ 1 | bloque,
              weights = varIdent(form = ~ 1 | foliar_damage),
              method = "REML",
              data = dat_2023)

## Check Assumptions

E <- residuals(res, type = "normalized")

origpar <- par(no.readonly = TRUE)
par(mfrow = c(1, 2))
plot(E ~ fitted(res))
qqnorm(E)
qqline(E)
par(origpar)

par(mfrow = c(2, 2))
boxplot(E ~ dat_2023$endo)
boxplot(E ~ dat_2023$root_damage)
boxplot(E ~ dat_2023$foliar_damage)
boxplot(E ~ dat_2023$herb)
par(origpar)

car::Anova(res, type = "III")

## Marginal Means

emmeans(res, ~ root_damage)

emmeans(res, ~ foliar_damage)
