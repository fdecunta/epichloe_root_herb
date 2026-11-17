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

dat[["root_CN"]] <- dat[["root_C_perc"]] / dat[["root_Nt_perc"]]

### CN ratio

summary(dat[["root_CN"]])

#coplot(root_CN ~ endophyte | root_herb * foliar_herb, data = dat)

#hist(dat$root_CN)

#hist(log(dat$root_CN))

#coplot(log(root_CN) ~ endophyte | root_herb * foliar_herb, data = dat)

### Modelling

options(contrasts = c("contr.sum", "contr.poly"))

### Modelling

cn_res <- lme(log(root_CN) ~ endophyte * root_herb * foliar_herb,
               random = ~ 1 | bloque,
               method = "REML",
               data = dat)

#### Diagnostics

E <- residuals(cn_res, type = "normalized")

par(mfrow = c(1, 2))
# subplot 1
plot(
    E ~ fitted(cn_res),
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

shapiro.test(E)

#### Inference

summary(cn_res)

car::Anova(cn_res, type = "III")

emmeans(cn_res, ~ endophyte | root_herb * foliar_herb, type = "response")

df_emmeans <- as.data.frame(
    emmeans(cn_res, ~ endophyte * root_herb * foliar_herb, type = "response")
)

df_emmeans[["root_herb_f"]] <- factor(
    df_emmeans[["root_herb"]],
    levels = c(0, 1),
    labels = c("No", "Si")
)

df_emmeans[["foliar_herb_f"]] <- factor(
    df_emmeans[["foliar_herb"]],
    levels = c(0, 1),
    labels = c("No", "Si")
)

df_emmeans <- df_emmeans[ , !(names(df_emmeans) %in% c("df", "lower.CL", "upper.CL"))]


## Plot
estimate_cex_scaling <- 0.9

letters_xpos <- 0
letters_ypos <- 43

x_lim <- c(0.5, 2.5)
y_lim <- c(20, 40)

## x == 1 : herb
## x == 0 : no herb
cn_subplot <- function(x, title, letter) {
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
        ylim = c(20, 40),
        xaxt = "n", 
        xlab = labels[["herb"]],
        ylab = labels[["cn_ratio"]],
        axes = FALSE,
        main = title
    )

    ## E- points
    stripchart(
        root_CN ~ root_herb,
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
        root_CN ~ root_herb,
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
        lwd.ticks = axis_width
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

plot_cn <- function() {
    par(mfrow = c(1,2))
    cn_subplot(0, "No foliar damage", "(a)")
    cn_subplot(1, "Foliar damage", "(b)")
}    

plot_cn()

## Save
w <- 7
h <- 3.5


png(
    file = "figures/png/cn.png",
    units = "in",
    res = 300,
    width = w,
    height = h,
    type = "cairo",
    family = font_family
)
plot_cn()
dev.off()
