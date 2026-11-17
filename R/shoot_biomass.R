#
# Shoot Biomass
#

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

## Explore shoot biomass

summary(dat_2023[["shoot_biom"]])

# Model Selection

# contrasts for ANOVA type 3
options(contrasts = c("contr.sum", "contr.poly"))

mod_0 <- gls(shoot_biom ~ endo * foliar_damage * root_damage * herb,
             method = "ML",
             data = dat_2023)

mod_1 <- lme(shoot_biom ~ endo * foliar_damage * root_damage * herb,
             random = ~ 1 | bloque,
             method = "ML",
             data = dat_2023)

mod_2 <- gls(shoot_biom ~ endo * foliar_damage * root_damage * herb,
             weights = varIdent(form = ~ 1 | foliar_damage),
             method = "ML",
             data = dat_2023)

mod_3 <- lme(shoot_biom ~ endo * foliar_damage * root_damage * herb,
             random = ~ 1 | bloque,
             weights = varIdent(form = ~ 1 | foliar_damage),
             method = "ML",
             data = dat_2023)

AIC(mod_0, mod_1, mod_2, mod_3)

# The best model is the one that accounts for different variance across `foliar_damage` groups.

mod_shoot <- gls(shoot_biom ~ endo * foliar_damage * root_damage * herb,
                 weights = varIdent(form = ~ 1 | foliar_damage),
                 method = "REML",
                 data = dat_2023)


## Check Assumptions

E <- residuals(mod_shoot, type = "normalized")

origpar <- par(no.readonly = TRUE)

par(mfrow = c(1, 2))
plot(E ~ fitted(mod_shoot))
qqnorm(E)
qqline(E)
par(origpar)

par(mfrow = c(2, 2))

boxplot(E ~ dat_2023$endo)
boxplot(E ~ dat_2023$root_damage)
boxplot(E ~ dat_2023$foliar_damage)
boxplot(E ~ dat_2023$herb)

par(origpar)

# Residuals show no clear patterns; assumptions appear reasonable.

car::Anova(mod_shoot, type = "III")

emmeans(mod_shoot, ~ foliar_damage)

emmeans(mod_shoot, ~ root_damage)
