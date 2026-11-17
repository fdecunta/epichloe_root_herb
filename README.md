[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24319661.svg)](https://doi.org/10.5281/zenodo.24319661)

## Foliar clipping and root herbivory induce root alkaloids from the foliar endophyte *Epichloë occultans* in *Lolium multiflorum*, but not resistance to root herbivores

Decunta, F.A.^1*^, Pérez, L.I.^2^, Mace, W.^3^, Card, S.D.^3^  and Gundel, P.E.^4,5^

^1^Universidad de Buenos Aires, Facultad de Agronomía, Departamento de Métodos Cuantitativos y Sistemas de Información, IFEVA, CONICET, Av. San Martín 4453, C1417DSE, Buenos Aires, Argentina

^2^Universidad de Buenos Aires, Facultad de Agronomía, Cátedra de Ecología, IFEVA, CONICET, Av. San Martín 4453, C1417DSE, Buenos Aires, Argentina

^3^Bioeconomy Science Institute, Grasslands Research Centre, Palmerston North, New Zealand

^4^Instituto de Biología Funcional y Biotecnología (BIOLAB)-INBIOTEC-CONICET-CICBA, Facultad de Agronomía, Universidad Nacional del Centro de la Provincia de Buenos Aires (UNICEN), Azul, BA, Argentina

^5^Centro de Ecología Integrativa, Instituto de Ciencias Biológicas, Universidad de Talca, Talca, Chile 

*Corresponding author: Facundo Decunta (fdecunta@agro.uba.ar)

---

This repository contains all data and code needed to reproduce the manuscript.

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
make clean all
```

