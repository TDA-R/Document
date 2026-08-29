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

## Build locally

Open `Document.Rproj` in Posit/RStudio, then run the following commands:

```r
setwd("vignettes")

bookdown::render_book(
  "index.Rmd",
  output_format = "bookdown::gitbook"
)
```

The generated website is written to:

```text
vignettes/_book/index.html
```

## Regenerate SimplicialComplex figures

The SimplicialComplex images are computed locally and saved as static PNG files. From `Document/vignettes`, run:

```r
source("generate_figures.R")
```

This regenerates:

- `ComplexConstructions.png`
- `FloodComplex.png`
- `PersistenceDiagram.png`
- `PersistenceLandscape.png`
- `DiagramMatching.png`

The files are saved in `vignettes/man/figures/`. The Bookdown pages load them statically with commands such as:

```r
knitr::include_graphics("./man/figures/PersistenceDiagram.png")
```

This keeps the Posit deployment lightweight because the expensive examples do not run again while the book is being published.

The MNIST Mapper image is generated separately from the example in the [`PaperExample`](https://github.com/TDA-R/PaperExample) repository and is stored as `vignettes/man/figures/MNISTMapper.png`.

## Publish to Posit Connect Cloud

The existing public documentation is available at:

<https://019c9000-f3f9-6599-47b4-1cff4047c68f.share.connect.posit.cloud>

To update this same deployment without changing its URL:

1. Open `Document/vignettes` as the publishing project root.
2. Open Posit Publisher.
3. Select the existing deployment configuration `MapperAlgo Document-4QIO`.
4. Confirm that `_bookdown.yml`, the three R Markdown files, `renv.lock`, and `man/` are included.
5. Click **Deploy Your Project**.

The current content was originally uploaded through Posit Publisher. Consequently, pushing a commit to GitHub alone does not update this deployment; the updated local bundle must also be deployed through the existing Publisher configuration.

## Development workflow

When updating the documentation:

1. Edit the relevant R Markdown source.
2. Regenerate affected static figures.
3. Render the complete book locally.
4. Check `vignettes/_book/index.html` and both chapter pages.
5. Commit and push the source changes.
6. Deploy with `MapperAlgo Document-4QIO` when the public Posit version should also be updated.

