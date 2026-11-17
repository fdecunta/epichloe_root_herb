#
# Total N in roots
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

hist(dat$root_P_ppm)


options(contrasts = c("contr.sum", "contr.poly"))

res <- lme(root_P_ppm ~ endophyte * root_herb * foliar_herb,
               random = ~ 1 | bloque,
               method = "REML",
               data = dat)


E <- residuals(res, type = "normalized")

par(mfrow = c(1, 2))
# subplot 1
plot(
    E ~ fitted(res),
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

car::Anova(res, type = "III")

emmeans(res, ~ endophyte * root_herb)

emmeans(res, pairwise ~ endophyte | root_herb)

100/1536 * 2058
