#
# Shoot:Root Ratio
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
dat_2023[["shoot_root_ratio"]] <- dat_2023[["shoot_biom"]] / dat_2023[["root_biom"]]

## Explore shoot:root ratio

summary(dat_2023[["shoot_root_ratio"]])

# Model Selection

options(contrasts = c("contr.sum", "contr.poly"))

mod_sr_0 <- gls(shoot_root_ratio ~ endo * foliar_damage * root_damage * herb,
                method = "ML",
                data = dat_2023)

mod_sr_1 <- lme(shoot_root_ratio ~ endo * foliar_damage * root_damage * herb,
                random = ~ 1 | bloque,
                method = "ML",
                data = dat_2023)

mod_sr_2 <- gls(shoot_root_ratio ~ endo * foliar_damage * root_damage * herb,
                weights = varIdent(form = ~ 1 | foliar_damage),
                method = "ML",
                data = dat_2023)

mod_sr_3 <- lme(shoot_root_ratio ~ endo * foliar_damage * root_damage * herb,
                random = ~ 1 | bloque,
                weights = varIdent(form = ~ 1 | root_damage),
                method = "ML",
                data = dat_2023)

mod_sr_4 <- lme(shoot_root_ratio ~ endo * foliar_damage * root_damage * herb,
                random = ~ 1 | bloque,
                weights = varIdent(form = ~ 1 | endo),
                method = "ML",
                data = dat_2023)

AIC(mod_sr_0, mod_sr_1, mod_sr_2, mod_sr_3, mod_sr_4)

mod_sr <- lme(shoot_root_ratio ~ endo * foliar_damage * root_damage * herb,
              random = ~ 1 | bloque,
              weights = varIdent(form = ~ 1 | endo),
              method = "REML",
              data = dat_2023)


## Check Assumptions

E <- residuals(mod_sr, type = "normalized")

origpar <- par(no.readonly = TRUE)
par(mfrow = c(1, 2))
plot(E ~ fitted(mod_sr))
qqnorm(E)
qqline(E)
par(origpar)

par(mfrow = c(2, 2))
boxplot(E ~ dat_2023$endo)
boxplot(E ~ dat_2023$root_damage)
boxplot(E ~ dat_2023$foliar_damage)
boxplot(E ~ dat_2023$herb)
par(origpar)


car::Anova(mod_sr, type = "III")

## Marginal Means

emmeans(mod_sr, ~ herb)

emmeans(mod_sr, ~ foliar_damage)

cld(
	emmeans(mod_sr, ~ herb * foliar_damage),
	sort = FALSE,
	Letters = LETTERS
)

## ------------------------------------------------------------------
## Plots 

## Variables for both plots

# Y axis
y_lim <- c(1, 8)

# Letters for subplots (a) and (b)
letters_xpos <- -0.05
letters_ypos <- 9

# p-values
pval_ypos <- 7

# xlabs
xlabs_ypos <- 0

# Estimate

# raw points


### Root herbivory

plot_herb_effect <- function() {
    opar <- par(
        mar = c(4, 4, 2, 1),
        mgp = c(2.2, 0.75, 0),
        cex.lab = labs_cex,
        cex.axis = labs_cex * 0.9
    )
    on.exit(par(opar))

    df <- as.data.frame(emmeans(mod_sr, ~ herb), sort = FALSE)
    pval <- "0.048"

    stripchart(
        shoot_root_ratio ~ herb,
        data = dat_2023,
        method = "jitter",
        jitter = 0.12,
        vertical = TRUE,
        pch = 19,
        ylab = labels$sr_ratio,
        xlab = labels$herb,
        col = adjustcolor(colors[["herb"]], alpha.f = 0.13),
        ylim = y_lim,
        xlim = c(0.5, 2.5),
        cex = rawpts_cex,
        axes = FALSE
    )

    ## Y axis
    axis(
        side = 2,
        lwd = 0,
        lwd.ticks = 0.6,
        las = 1,
        at = seq(from=y_lim[1], to=y_lim[2], by=2)
    )

    ## Box
    box(bty = box_type, lwd = 0.6)

    # Errorbars
    arrows(
        x0 = 1:nrow(df),
        y0 = df$emmean - df$SE,
        x1 = 1:nrow(df),
        y1 = df$emmean + df$SE,
        length = 0.09,
        angle = 90,
        code = 3,
        lwd = 1.5
    )

    # Mean Estimates
    points(
        x = 1:nrow(df),
        y = df$emmean,
        pch = 21,
        cex = estimate_cex,
        bg = colors[["herb"]],
        col = "black"
    )

    text(
        x = c(1, 2),
        y = xlabs_ypos,
        cex = xlabs_cex,
        labels = c("H-", "H+"),
        xpd = TRUE
    )

    text(
        x = 1.5,
        y = pval_ypos,
        labels = paste("p =", pval),
        cex = xlabs_cex,
        font = 3
    )

    text(
        x = letters_xpos,
        y = letters_ypos,
        labels = "(b)",
        xpd = TRUE,
        cex = labs_cex ,
        font = 2
    )
}


plot_foliar_effect <- function() {
    opar <- par(
        mar = c(4, 4, 2, 1),
        mgp = c(2.2, 0.75, 0),
        cex.lab = labs_cex,
        cex.axis = labs_cex * 0.9
    )
    on.exit(par(opar))

    df <- as.data.frame(emmeans(mod_sr, ~ foliar_damage))
    pval <- "0.021"

    stripchart(
        shoot_root_ratio ~ foliar_damage,
        data = dat_2023,
        method = "jitter",
        jitter = 0.12,
        vertical = TRUE,
        pch = 19,
        ylab = labels$sr_ratio,
        xlab = labels$foliar_damage,
        col = adjustcolor(colors[["foliar_damage"]], alpha.f = 0.15),
        ylim = y_lim,
        xlim = c(0.5, 2.5),
	cex = rawpts_cex,
        axes = FALSE
    )

    ## Y axis
    axis(
        side = 2,
        lwd = 0,
        lwd.ticks = axis_width,
        las = 1,
        at = seq(from=y_lim[1], to=y_lim[2], by=2)
    )

    ## Box
    box(bty = box_type, lwd = axis_width)

    # Errorbars
    arrows(
        x0 = 1:nrow(df),
        y0 = df$emmean - df$SE,
        x1 = 1:nrow(df),
        y1 = df$emmean + df$SE,
        length = 0.09,
        angle = 90,
        code = 3,
        lwd = 1.5
    )

    # Mean Estimates
    points(
        x = 1:nrow(df),
        y = df$emmean,
        pch = 21,
        cex = estimate_cex,
        bg = colors[["foliar_damage"]],
        col = "black"
    )

    text(
        x = c(1, 2),
        y = xlabs_ypos,
        cex = xlabs_cex,
        labels = c("D-", "D+"),
        xpd = TRUE
    )

    text(
        x = 1.5,
        y = pval_ypos,
        labels = paste("p =", pval),
        cex = xlabs_cex,
        font = 3
    )

    text(
        x = letters_xpos,
        y = letters_ypos,
        labels = "(a)",
        xpd = TRUE,
        cex = labs_cex,
        font = 2
    )
}


plot_shoot_root <- function() {
    par(
        mfrow = c(1, 2),
        mar = c(4, 4, 1, 1),
        mgp = c(2.5, 0.75, 0)
    )

    plot_foliar_effect()
    plot_herb_effect()
}


## ------------------------------------------------------------------
## Save plots



png(
    file = "figures/png/shoot_root.png",
    units  = "in",
    res = 300,
    width = 7,
    height = 3.5,
    type = "cairo",
    family = font_family
)
plot_shoot_root()
dev.off()

