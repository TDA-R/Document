# TDA-R Documentation

This repository contains the Bookdown documentation for the TDA-R project. It brings together the user-facing workflows of two R packages:

- [MapperAlgo](https://github.com/TDA-R/MapperAlgo): conventional Mapper, F-Mapper, G-Mapper, cover construction, clustering, visualisation, and PNG export.
- [SimplicialComplex](https://github.com/TDA-R/SimplicialComplex): simplicial-complex construction, filtrations, persistent homology, persistence landscapes, diagram distances, matching, Flood complexes, and the Shiny explorer.

## Documentation structure

The source files are stored under `vignettes/`:

```text
vignettes/
├── index.Rmd
├── Mapper.Rmd
├── SimplicialComplex.Rmd
├── _bookdown.yml
├── generate_figures.R
├── renv.lock
└── man/figures/
```

`index.Rmd` introduces the combined documentation. `Mapper.Rmd` and `SimplicialComplex.Rmd` contain the two main chapters. `_bookdown.yml` defines their rendering order.
