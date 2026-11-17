#
# t-test for foliar clipping biomass.
#

df <- read.csv("data/exp2023.csv")

df_clipping <- df[df[["foliar_damage"]] == 1, ]

t.test(biom_aerea_cortada ~ endo, data = df_clipping, var.equal = TRUE)

