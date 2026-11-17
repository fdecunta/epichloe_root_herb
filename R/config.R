labels <- list(
    cn_ratio       = "Root C:N ratio",
    np_ratio       = "Root N:P ratio",
    root_biom      = "Root Biomass (g)",
    shoot_biom     = "Shoot Biomass (g)",
    sr_ratio       = "Shoot:root ratio", 
    foliar_damage  = "Mechanical Foliar Damage",
    root_damage    = "Mechanical Root Damage",
    herb           = "Root Herbivory",
    endo           = "Endophyte",
    weight_change  = expression(atop("Root Herbivore RGR", "(mg" ~ "." ~ "g"^-1 ~ "." ~ "day"^-1 ~ ")")),
    lolines        = expression("Root Lolines (µg" ~ "." ~ "g"^-1 ~")")
)

colors <- list(
	endo = c("skyblue", "orange"),
	herb = c("seagreen", "mediumpurple"),
	foliar_damage = c("goldenrod", "indianred")
)

# ------------------------------------------------------

font_family <- "Helvetica"

labs_cex <- 1.1
xlabs_cex <- 1.0

box_type <- "l"

axis_width <- 0.7

## stripchart points size
rawpts_cex <- 1.3

## estimate mean point size
estimate_cex <- 1.9
