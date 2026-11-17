#
# Root C:N ratio
#

source("R/config.R")

library(lattice)
library(nlme)
library(emmeans)
library(multcomp)

dat <- read.csv("data/exp_nut.csv")

dat[["endophyte"]]   <- as.factor(dat[["endophyte"]])
dat[["root_herb"]]   <- as.factor(dat[["root_herb"]])
dat[["foliar_herb"]] <- as.factor(dat[["foliar_herb"]])
dat[["bloque"]]      <- as.factor(dat[["bloque"]])

## --------------------------------------------------

hist(dat$root_C_perc)


options(contrasts = c("contr.sum", "contr.poly"))

c_res <- lme(root_C_perc ~ endophyte * root_herb * foliar_herb,
               random = ~ 1 | bloque,
               method = "REML",
               data = dat)


E <- residuals(c_res, type = "normalized")

par(mfrow = c(1, 2))
# subplot 1
plot(
    E ~ fitted(c_res),
    xlab = "Fitted values",
    ylab = "Normalized residuals"
)
# subplot 2
qqnorm(E)
qqline(E)


par(mfrow = c(2, 2))
boxplot(E ~ dat$endophyte)
boxplot(E ~ dat$root_herb)
boxplot(E ~ dat$foliar_herb)
boxplot(E ~ dat$foliar_herb)
par(mfrow = c(1, 1))

car::Anova(c_res, type = "III")
