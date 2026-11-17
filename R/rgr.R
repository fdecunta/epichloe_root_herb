#
# Root Herbivore Weight Change
#

library(nlme)
library(emmeans)
library(multcomp)

source("R/config.R")

df <- read.csv("data/exp2023.csv")

df[["endo"]]          <- as.factor(df[["endo"]])
df[["herb"]]          <- as.factor(df[["herb"]])
df[["sim_herb"]]      <- as.factor(df[["sim_herb"]])
df[["foliar_damage"]] <- as.factor(df[["foliar_damage"]])
df[["root_damage"]]   <- as.factor(df[["root_damage"]])

## -------------------------------------------------------------------
## Calculate Relative Weight Change

# Filter to rows with both initial and final biomass measurements
df_herb <- df[!is.na(df$dabderus_biom_inicial) & !is.na(df$dabderus_biom_final), ]

# Calculate relative growth rate: log(final / initial) / days
df_herb$days_in_plant <- -1

df_herb$days_in_plant <- ifelse(df_herb$bloque %in% c("bloque_1", "bloque_2"), 28, df_herb$days_in_plant)
df_herb$days_in_plant <- ifelse(df_herb$bloque %in% c("bloque_3", "bloque_4"), 29, df_herb$days_in_plant)
df_herb$days_in_plant <- ifelse(df_herb$bloque %in% c("bloque_5", "bloque_6"), 31, df_herb$days_in_plant)
df_herb$days_in_plant <- ifelse(df_herb$bloque %in% c("bloque_7", "bloque_8"), 31, df_herb$days_in_plant)

df_herb$rgr <- log(df_herb$dabderus_biom_final / df_herb$dabderus_biom_inicial) / df_herb$days_in_plant
df_herb$rgr <- df_herb$rgr * 1000  # transform to mg g^-1 day^-1, or (day -1)

## ------------------------------------------------------------------
## Data Modelling

options(contrasts = c("contr.sum", "contr.poly"))

mod_weight <- lme(rgr ~ endo * root_damage * foliar_damage,
                  random = ~ 1 | bloque,
                  method = "REML",
                  data = df_herb)

## ------------------------------------------------------------------
## Check Assumptions

E <- residuals(mod_weight, type = "normalized")

origpar <- par(no.readonly = TRUE)

par(mfrow = c(1, 2))
plot(E ~ fitted(mod_weight))
qqnorm(E)
qqline(E)
par(origpar)

opar <-par(mfrow = c(2, 2))
boxplot(E ~ df_herb$endo)
boxplot(E ~ df_herb$root_damage)
boxplot(E ~ df_herb$foliar_damage)
boxplot(E ~ df_herb$foliar_damage)
par(opar)

## ------------------------------------------------------------------
## Inference

summary(mod_weight)

car::Anova(mod_weight, type = "III")

## Marginal Means

emmeans(mod_weight, pairwise ~ endo | foliar_damage)

## ------------------------------------------------------------------
## Plots

y_lim <- c(-16, 15)

plot_endo_x_foliar_damage <- function() {
    origpar <- par(no.readonly = TRUE)
    
    par(
        mar = c(4, 6, 1, 1),
        mgp = c(2.2, 0.75, 0),
        cex.lab = labs_cex,
        cex.axis = labs_cex * 0.85
    )

    df <- as.data.frame(emmeans(mod_weight, ~ endo * foliar_damage, sort = FALSE))

    stripchart(
        rgr ~ endo * foliar_damage,
        data = df_herb,
        method = "jitter",
        jitter = 0.17,
        vertical = TRUE,
        pch = 19,
        ylab = "",
        xlab = labels$foliar_damage,
        col = adjustcolor(colors$endo, alpha.f = 0.15),
        ylim = y_lim,
        axes = FALSE,
        cex = rawpts_cex
    )

    ## Y axis
    axis(2, lwd = 0, lwd.ticks = axis_width, las = 1)

    title(
      ylab = labels$weight_change,
      line = 2.5,
      cex = labs_cex
    )

    ## Box
    box(bty = box_type, lwd = axis_width)

    ## Vertical line dividing endophyte levels
    abline(v = 2.5, lty = "dashed", lwd = axis_width)

    ## Errorbars
    arrows(
        x0 = 1:nrow(df),
        y0 = df$emmean - df$SE,
        x1 = 1:nrow(df),
        y1 = df$emmean + df$SE,
        length = 0.05,
        angle = 90,
        code = 3,
        lwd = 1.5
    )

    ## Mean Estimates
    points(
        x = 1:nrow(df),
        y = df$emmean,
        pch = 21,
        bg = colors$endo,
        col = "black",
        cex = estimate_cex
    )

    ## Legend
    legend(
        "topright",
        legend = c("E-", "E+"),
        pt.bg = colors$endo,
        pch = 21,
        cex = labs_cex,
        pt.cex = xlabs_cex * 1.2,
        bty = "n"
    )

    ## Letters (positioned above errorbars)
    text(
        x = c(1.5, 3.5),
        y = c(5, 5),
        labels = c("p = 0.312", "p = 0.007"),
        cex = xlabs_cex * 0.925,
        font = c(1, 3)
    )

    ## No/Yes labels at bottom
    text(
        x = c(1.5, 3.5),
        y = -20,
        labels = c("D-", "D+"),
        cex = xlabs_cex,
        xpd = TRUE
    )

    par(origpar)
}


## ------------------------------------------------------------------


png(
    file = "figures/png/rgr.png",
    units = "in",
    res = 300,
    width = 4,
    height = 3.5,
    family = font_family,
    type = "cairo"
)
plot_endo_x_foliar_damage()
dev.off()
