# epichloe_root_herb

This repository contains the reproducible source for a research manuscript and its supplementary materials on root-herb interactions in an *Epichloë*-associated system.

It is a document-generation project that assembles the main paper and supporting appendix from analysis scripts, data, figures, and manuscript sections.

## Contents

- `R/` — analysis scripts used to generate figures and model outputs
- `data/` — datasets used in the study
- `figures/` — figure assets and collage generation
- `sections/` — manuscript text fragments, acknowledgements, funding, and references
- `bib/` — bibliography and citation style files
- `supplementary/` — supplementary tables and appendix materials compiled into `sup.docx`
- `m4/` and `Makefile` — manuscript build pipeline

## Dependencies

- R
- R packages: `car`, `emmeans`, `lattice`, `multcomp`, and `nlme`
- Pandoc
- GNU M4
- GNU Make
- ImageMagick (only needed to generate Figure S1 in the supplementary material)

## Build

Run from the repository root:

```sh
make
```

This builds the manuscript and supplementary document(s). ImageMagick is only required when generating supplementary Figure S1.
