#
# Root biomass
#

library(lattice)
library(nlme)
library(emmeans)

df <- read.csv("data/exp2023.csv")

df[["endo"]] <- as.factor(df[["endo"]])
df[["herb"]] <- as.factor(df[["herb"]])

df[["foliar_damage"]] <- as.factor(df[["foliar_damage"]])
df[["root_damage"]] <- as.factor(df[["root_damage"]])

## Look at the data

summary(df[["root_biom"]])

## ------------------------------------------------------------------
## Model

# Correct contrasts for ANOVA type 3.
options(contrasts = c("contr.sum", "contr.poly"))

mod_1 <- lme(root_biom ~ endo * foliar_damage * root_damage * herb,
             random = ~ 1 | bloque,
             data = df)


E <- residuals(mod_1, type = "normalized")

oldpar <- par(no.readonly = TRUE)

par(mfrow = c(1, 2))
plot(E ~ fitted(mod_1))
qqnorm(E)
qqline(E)

par(oldpar)

## Maybe there is a pattern in the residuals vs fitted.

oldpar <- par(no.readonly = TRUE)

par(mfrow = c(2, 2))
boxplot(E ~ df[["root_damage"]])
boxplot(E ~ df[["foliar_damage"]])
boxplot(E ~ df[["herb"]])
boxplot(E ~ df[["endo"]])

par(oldpar)


car::Anova(mod_1, type = "III")

emmeans(mod_1, ~ foliar_damage)

emmeans(mod_1, ~ root_damage)


