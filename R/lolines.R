#
# Lolines
#

source("R/config.R")

library(emmeans)
library(lattice)
library(nlme)
library(multcomp)

df <- read.csv("data/exp2023.csv")

## Need to filter only E+ plants

df <- df[df[["endo"]] == 1, ] 
df[["herb"]] <- as.factor(df[["herb"]])
df[["root_damage"]] <- as.factor(df[["root_damage"]])
df[["foliar_damage"]] <- as.factor(df[["foliar_damage"]]) 

df[["total_lolines"]] <- df[["nanl"]] + df[["nfl"]]

df_lol <- df[!is.na(df[["total_lolines"]]), ]

## Total Lolines

## ------------------------------------------------------------------
## Model Selection

options(contrasts = c("contr.sum", "contr.poly"))

res0 <- lme(log(total_lolines) ~ foliar_damage * root_damage * herb,
           random = ~ 1 | bloque,
           method = "ML",
           data = df_lol)

res1 <- lme(log(total_lolines) ~ foliar_damage * root_damage * herb,
           random = ~ 1 | bloque,
           weights = varIdent(form = ~ 1 | herb),
           method = "ML",
           data = df_lol)

res2 <- lme(log(total_lolines) ~ foliar_damage * root_damage * herb,
           random = ~ 1 | bloque,
           weights = varIdent(form = ~ 1 | root_damage),
           method = "ML",
           data = df_lol)

res3 <- lme(log(total_lolines) ~ foliar_damage * root_damage * herb,
           random = ~ 1 | bloque,
           weights = varIdent(form = ~ 1 | foliar_damage),
           method = "ML",
           data = df_lol)

AIC(res0, res1, res2, res3)

## ------------------------------------------------------------------
## Final model

res <- lme(log(total_lolines) ~ foliar_damage * root_damage * herb,
           random = ~ 1 | bloque,
           method = "REML",
           data = df_lol)

## ------------------------------------------------------------------
## Check assumptions

E <- residuals(res, type = "normalized")

plot_resids <- function(E) {
    opar <- par(mfrow = c(1, 2))
    on.exit(par(opar))

    plot(E ~ fitted(res))
    qqnorm(E)
    qqline(E)
}

plot_resids(E)

car::Anova(res, type = 3)

emmeans(res, ~ herb, type = "response")

emmeans(res, ~ foliar_damage, type = "response")

emm <- emmeans(res, ~ herb * foliar_damage, type = "response", sort = FALSE)

cld(
    emm,
    sort = FALSE,
    Letters = LETTERS
)

## ------------------------------------------------------------------
## Variables for both plots

# Y axis
y_lim <- c(0, 120)

# Letters for subplots (a) and (b)
letters_xpos <- -0.05
letters_ypos <- 138

# p-values
pval_xpos <- 1.5
pval_ypos <- 100

# xlabs
xlabs_ypos <- -18

# error bars
errbar_len <- 0.07


plot_lol_x_herb <- function() {
    opar <- par(
        mar = c(4, 4, 2, 1),
        mgp = c(2.2, 0.75, 0),
        cex.lab = labs_cex,
        cex.axis = labs_cex * 0.9
    )
    on.exit(par(opar))

    df <- as.data.frame(emmeans(res, ~ herb, type = "response"))
    pval <- "0.012"

    stripchart(
        total_lolines ~ herb,
        data = df_lol,
        method = "jitter",
        jitter = 0.15,
        vertical = TRUE,
        pch = 19,
        ylab = labels$lolines,
        xlab = labels$herb,
        ylim = y_lim,
        xlim = c(0.5, 2.5),
        col = adjustcolor(colors$herb, alpha.f = 0.15),
	cex = rawpts_cex,
        axes = FALSE
    )

    ## Y axis
    axis(
	side = 2,
        lwd = 0,
        lwd.ticks = axis_width,
        las = 1,
        at = seq(from=y_lim[1], to=y_lim[2], by=25)
    )

    ## Box
    box(bty = box_type, lwd = axis_width)

    ## Letters
    text(
        x = pval_xpos,
        y = pval_ypos,
        labels = paste("p =", pval),
        cex = xlabs_cex,
        font = 3
    )

    ## Error bars
    arrows(
        x0 = 1:nrow(df),
        y0 = df$response - df$SE,
        x1 = 1:nrow(df),
        y1 = df$response + df$SE,
        length = errbar_len,
        angle = 90,
        code = 3,  # heads at both ends
        lwd = 1.5
    )

    points(
        x = 1:nrow(df),
        y = df$response,
        pch = 21,
        cex = estimate_cex,
        bg = colors$herb,
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
        x = letters_xpos,
        y = letters_ypos,
        labels = "(b)",
        xpd = TRUE,
        cex = labs_cex,
        font = 2
    )
}


plot_lol_x_foliar <- function() {
    opar <- par(
        mar = c(4, 4, 2, 1),
        mgp = c(2.2, 0.75, 0),
        cex.lab = labs_cex,
        cex.axis = labs_cex * 0.9
    )
    on.exit(par(opar))

    df <- as.data.frame(emmeans(res, ~ foliar_damage, type = "response"))
    pval <- "0.040"


    stripchart(
        total_lolines ~ foliar_damage,
        data = df_lol,
        method = "jitter",
        jitter = 0.15,
        vertical = TRUE,
        pch = 19,
        ylab = labels$lolines,
        xlab = labels$foliar_damage,
        ylim = c(0, 120),
        xlim = c(0.5, 2.5),
        col = adjustcolor(colors[["foliar_damage"]], alpha.f = 0.15),
	cex = rawpts_cex,
        axes = FALSE
    )

    ## Y axis
    axis(
	side = 2,
        lwd = 0,
        lwd.ticks = axis_width,
        las = 1,
        at = seq(from=y_lim[1], to=y_lim[2], by=25)
    )

    ## Box
    box(bty = box_type, lwd = axis_width)

    ## Letters
    text(
        x = pval_xpos,
        y = pval_ypos,
        labels = paste("p =", pval),
        cex = xlabs_cex,
        font = 3
    )

    ## Error bars
    arrows(
        x0 = 1:nrow(df),
        y0 = df$response - df$SE,
        x1 = 1:nrow(df),
        y1 = df$response + df$SE,
        length = errbar_len,
        angle = 90,
        code = 3,  # heads at both ends
        lwd = 1.5
    )

    points(
        x = 1:nrow(df),
        y = df$response,
        pch = 21,
        cex = estimate_cex,
        bg = colors[["foliar_damage"]],
        col = "black"
    )

    # xlabs
    text(
        x = c(1, 2),
        y = xlabs_ypos,
        cex = xlabs_cex,
        labels = c("D-", "D+"),
        xpd = TRUE
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


plot_figure1 <- function() {
    par(
        mfrow = c(1, 2),
        mar = c(4, 4, 2, 1),
        mpg = c(2.5, 1, 0)
    )

    plot_lol_x_foliar()
    plot_lol_x_herb()
}


## ------------------------------------------------------------------
## Save plots


png(
    file = "figures/png/lolines.png",
    units = "in",
    res = 300,
    width = 7,
    height = 3.5,
    type = "cairo",
    family = font_family
)
plot_figure1()
dev.off()

