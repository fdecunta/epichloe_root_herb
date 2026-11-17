#
# Root N:P ratio
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

# Transform phosphorus ppm to percentage, so they are in the same units
dat[["root_NP"]] <- dat[["root_Nt_perc"]] / (dat[["root_P_ppm"]] / 10000)

### NP ratio

summary(dat[["root_NP"]])

#coplot(root_NP ~ endophyte | root_herb * foliar_herb, data = dat)

#hist(dat$root_NP)

#hist(log(dat$root_NP))

### Modelling

options(contrasts = c("contr.sum", "contr.poly"))

### Modelling

np_0 <- lme(log(root_NP) ~ endophyte * root_herb * foliar_herb,
           random = ~ 1 | bloque,
           method = "ML",
           data = dat)

np_1 <- lme(log(root_NP) ~ endophyte * root_herb * foliar_herb,
           random = ~ 1 | bloque,
           weights = varIdent(form = ~ 1 | endophyte),
           method = "ML",
           data = dat)

np_2 <- lme(log(root_NP) ~ endophyte * root_herb * foliar_herb,
           random = ~ 1 | bloque,
           weights = varIdent(form = ~ 1 | root_herb),
           method = "ML",
           data = dat)

np_3 <- lme(log(root_NP) ~ endophyte * root_herb * foliar_herb,
           random = ~ 1 | bloque,
           weights = varIdent(form = ~ 1 | foliar_herb),
           method = "ML",
           data = dat)

AIC(np_0, np_1, np_2, np_3)

#### Final model

np_final <- lme(log(root_NP) ~ endophyte * root_herb * foliar_herb,
               random = ~ 1 | bloque,
               method = "REML",
               data = dat)

#### Diagnostics

E <- residuals(np_final, type = "normalized")

par(mfrow = c(1, 2))
# subplot 1
plot(
    E ~ fitted(np_final),
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

#### Inference

summary(np_final)

car::Anova(np_final, type = "III")



emmeans(np_final, ~ endophyte * root_herb * foliar_herb, type = "response")

cld(
    emmeans(np_final, ~ endophyte * root_herb * foliar_herb, type = "response"),
    sort = FALSE,
    Letters = LETTERS
)


emmeans(np_final, pairwise ~ endophyte | root_herb * foliar_herb, type = "response")


df <- as.data.frame(
    emmeans(np_final, ~ endophyte * root_herb * foliar_herb, type = "response")
)

df[["root_herb_f"]] <- factor(
    df[["root_herb"]],
    levels = c(0, 1),
    labels = c("No", "Si")
)


df[["foliar_herb_f"]] <- factor(
    df[["foliar_herb"]],
    levels = c(0, 1),
    labels = c("No", "Si")
)

df_emmeans <- df[ , !(names(df) %in% c("df", "lower.CL", "upper.CL"))]

no_foliar_df <- df[df[["foliar_herb"]] == 0, ]
foliar_df    <- df[df[["foliar_herb"]] == 1, ]


estimate_cex_scaling <- 0.9

letters_xpos <- 0
letters_ypos <- 16

xlim <- c(0.5, 2.5)
ylim <-  c(5, 15)

np_subplot <- function(x, title, letter) {
    opar = par(
        mar = c(4, 4, 2, 0.5),
        mgp = c(2, 0.7, 0),
        cex.lab = labs_cex,
        cex.axis = xlabs_cex,
        font.main = 1
    )
    on.exit(par(opar))

    df <- df_emmeans[df_emmeans[["foliar_herb"]] == x, ]
    plot_dat <- dat[dat[["foliar_herb"]] == x, ]
    x_pos <- as.numeric(df$root_herb_f)

    plot(
        x_pos,
        df$response, 
        type = "n", # empty plot
        xlim = c(0.5, 2.5),
        ylim = c(5, 15),
        xaxt = "n", 
        xlab = labels[["herb"]],
        ylab = labels[["np_ratio"]],
        axes = FALSE,
        main = title
    )

    ## E- points
    stripchart(
        root_NP ~ root_herb,
        data = plot_dat,
        method = "jitter",
        jitter = 0.15,
        vertical = TRUE,
        pch = 19,
        xlab = labels[["herb"]],
        ylab = labels[["cn_ratio"]],
        xlim = x_lim,
        ylim = y_lim,
        col = adjustcolor(colors[["endo"]][1], alpha.f = 0.10),
        subset = plot_dat[["endophyte"]] == "E-",
        cex = rawpts_cex,
        axes = FALSE,
        add = TRUE
    )

    ## E+ points
    stripchart(
        root_NP ~ root_herb,
        data = plot_dat,
        method = "jitter",
        jitter = 0.15,
        vertical = TRUE,
        pch = 19,
        xlab = labels[["herb"]],
        ylab = labels[["cn_ratio"]],
        xlim = x_lim,
        ylim = y_lim,
        col = adjustcolor(colors[["endo"]][2], alpha.f = 0.10),
        subset = plot_dat[["endophyte"]] == "E+",
        cex = rawpts_cex,
        axes = FALSE,
        add = TRUE
    )    

    segments(
        x0 = c(1, 1),
        y0 = df$response[1:2],
        x1 = c(2, 2),
        y1 = df$response[3:4],
        col = colors[["endo"]],
        lwd = 2.5
    )

    arrows(
        x0 = x_pos,
        y0 = df$response - df$SE,
        x1 = x_pos,
        y1 = df$response + df$SE,
        angle = 90,
        code = 3,
        length = 0.05
    )

    points(
        x = x_pos,
        y = df$response,
        pch = 21,
        col = "black",
        bg = colors[["endo"]],
        cex = estimate_cex * estimate_cex_scaling
    )

    legend(
        "topright",
        legend = c("E−", "E+"),
        pt.bg = colors$endo,
        pch = 21,
        pt.cex = 1.2,
        bty = "n",
	cex = xlabs_cex
    )

    box(bty = box_type, lwd = axis_width)

    ## Y axis
    axis(
        side = 2,
        lwd = 0,
        lwd.ticks = axis_width,
        las = 1
    )

    ## X axis
    axis(
        side = 1,
        at = c(1, 2),
        labels = c("H−", "H+"),
        lwd = 0,
        lwd.ticks = axis_width,
	cex.axis = xlabs_cex
    )

    # subplot letter
    text(
        x = letters_xpos,
        y = letters_ypos,
        labels = letter,
        xpd = TRUE,
        cex = labs_cex,
        font = 2
    )
}


add_asterisk <- function() {
    ## This is a helper function to add significance asterisk 
    ## to the 2nd subplot for NP ratios.
    ## Add asterisk with square bracket: 
    ## only in foliar herbivory AND root herbivory

    signif_df <- foliar_df[foliar_df[["root_herb"]] == 1, ]    

    segments(
        x0 = 2.12,
        y0 = min(signif_df[["response"]]),
        x1 = 2.15,
        y1 = min(signif_df[["response"]])
    )

    segments(
        x0 = 2.12,
        y0 = max(signif_df[["response"]]),
        x1 = 2.15,
        y1 = max(signif_df[["response"]])
    )

    segments(
        x0 = 2.15,
        y0 = min(signif_df[["response"]]),
        x1 = 2.15,
        y1 = max(signif_df[["response"]])
    )

    text(
        x = 2.25,
        y = mean(signif_df[["response"]]),
        labels = "*",
        cex = 1.5
    )
}


plot_np <- function() {
    par(mfrow = c(1,2))
    np_subplot(0, "No foliar damage", "(c)")
    np_subplot(1, "Foliar damage", "(d)")
    add_asterisk()
} 


w <- 7
h <- 3.5

## Save plot

png(
    file = "figures/png/np.png",
    units = "in",
    res = 300,
    width = w,
    height = h,
    type = "cairo",
    family = font_family
)
plot_np()
dev.off()
