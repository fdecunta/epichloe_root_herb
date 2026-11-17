# epichloe_root_herb

This repository contains the reproducible source for a research manuscript and its supplementary materials on root-herb interactions in an Epichloe-associated system.

It is not a standalone software package; rather, it is a document-generation project that assembles the main paper and supporting appendix from analysis scripts, data, figures, and manuscript sections.

## Contents

- `R/` — analysis scripts used to generate figures and model outputs
- `data/` — datasets used in the study
- `figures/` — figure assets and collage generation
- `sections/` — manuscript text fragments, acknowledgements, funding, and references
- `bib/` — bibliography and citation style files
- `supplementary/` — supplementary tables and appendix materials compiled into `sup.docx`
- `m4/` and `Makefile` — manuscript build pipeline using `m4` and `pandoc`

## Build

Run:

```bash
make
```

This generates the manuscript and supplementary document(s) in the repository root.

## Notes

Yes — the supplementary material here is clearly associated with a research paper. The repo includes a manuscript build workflow, figure generation, and a dedicated `supplementary/` document, which is typical of a paper appendix or online supplement.
