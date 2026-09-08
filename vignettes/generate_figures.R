if (!requireNamespace("pkgload", quietly = TRUE)) {
  stop("Install 'pkgload' before running this script: install.packages('pkgload').")
}
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop("Install 'ggplot2' before running this script: install.packages('ggplot2').")
}

package_dir <- normalizePath("../SimplicialComplex", mustWork = TRUE)
figure_dir <- normalizePath("./vignettes/man/figures", mustWork = TRUE)
pkgload::load_all(package_dir, quiet = TRUE)

save_base_png <- function(filename, expression, width = 1700, height = 1150) {
  grDevices::png(
    file.path(figure_dir, filename),
    width = width,
    height = height,
    res = 180,
    bg = "white"
  )
  on.exit(grDevices::dev.off(), add = TRUE)
  force(expression)
}

draw_edges <- function(points, edges, colour = "#2c6e9b", width = 1.4) {
  if (is.null(edges) || nrow(edges) == 0) return(invisible(NULL))
  graphics::segments(
    points[edges[, 1], 1], points[edges[, 1], 2],
    points[edges[, 2], 1], points[edges[, 2], 2],
    col = colour,
    lwd = width
  )
}

simplex_edges <- function(simplices) {
  edge_list <- lapply(simplices, function(simplex) {
    if (length(simplex) < 2) return(NULL)
    pairs <- utils::combn(simplex, 2)
    t(pairs)
  })
  edge_list <- Filter(Negate(is.null), edge_list)
  if (length(edge_list) == 0) return(matrix(integer(), ncol = 2))
  unique(do.call(rbind, edge_list))
}

set.seed(20260717)
n_circle <- 18L
theta <- seq(0, 2 * pi, length.out = n_circle + 1L)[-(n_circle + 1L)]
circle <- cbind(cos(theta), sin(theta))
circle_noisy <- circle + matrix(stats::rnorm(length(circle), sd = 0.035), ncol = 2)

vr_complex <- VietorisRipsComplex(circle_noisy, epsilon = 0.72)
alpha_complex <- AlphaComplex(circle_noisy, epsilon = 0.62)
witness_complex <- WitnessComplex(circle_noisy, landmarks = 9, epsilon = 0.72)

save_base_png("ComplexConstructions.png", {
  old_par <- graphics::par(
    mfrow = c(2, 2),
    mar = c(2.2, 2.2, 3.0, 1.0),
    oma = c(0, 0, 1.2, 0)
  )
  on.exit(graphics::par(old_par), add = TRUE)

  graphics::plot(
    circle_noisy,
    asp = 1,
    pch = 19,
    col = "#3b7ea1",
    xlab = "",
    ylab = "",
    main = "Point cloud"
  )

  graphics::plot(
    circle_noisy,
    asp = 1,
    pch = 19,
    col = "#3b7ea1",
    xlab = "",
    ylab = "",
    main = "Vietoris--Rips 1-skeleton"
  )
  draw_edges(
    circle_noisy,
    igraph::as_edgelist(vr_complex$network, names = FALSE),
    colour = "#2c6e9b"
  )
  graphics::points(circle_noisy, pch = 19, col = "#3b7ea1")

  alpha_triangles <- Filter(function(simplex) length(simplex) == 3L, alpha_complex$simplices)
  graphics::plot(
    circle_noisy,
    asp = 1,
    pch = 19,
    col = "#c76b1d",
    xlab = "",
    ylab = "",
    main = "Alpha complex"
  )
  for (triangle in alpha_triangles) {
    graphics::polygon(
      circle_noisy[triangle, 1],
      circle_noisy[triangle, 2],
      col = grDevices::adjustcolor("#efb366", alpha.f = 0.30),
      border = NA
    )
  }
  draw_edges(circle_noisy, simplex_edges(alpha_complex$simplices), colour = "#b25912")

  graphics::points(circle_noisy, pch = 19, col = "#c76b1d")

  landmark_points <- witness_complex$landmarks
  graphics::plot(
    circle_noisy,
    asp = 1,
    pch = 16,
    cex = 0.65,
    col = "grey70",
    xlab = "",
    ylab = "",
    main = "Witness complex"
  )
  draw_edges(
    landmark_points,
    igraph::as_edgelist(witness_complex$network, names = FALSE),
    colour = "#31805a"
  )
  graphics::points(landmark_points, pch = 21, bg = "#4a9c73", cex = 1.35)
  graphics::mtext("Complexes use different geometric information",
                  outer = TRUE, font = 2, cex = 1.05)
})

vr_filtration <- build_filtration(circle, method = "VR", eps_max = 1.85, max_dimension = 1)
vr_pairs <- persistence_pairs(vr_filtration, max_dimension = 1)
pd_plot <- plot_persistence(vr_pairs)

ggplot2::ggsave(
  file.path(figure_dir, "PersistenceDiagram.png"),
  pd_plot,
  width = 7,
  height = 5.2,
  dpi = 180,
  bg = "white"
)

landscape <- persistence_landscape(vr_pairs, dimension = 1, k_max = 1, resolution = 500)
landscape_plot <- plot_landscape(landscape)

ggplot2::ggsave(
  file.path(figure_dir, "PersistenceLandscape.png"),
  landscape_plot,
  width = 7,
  height = 5.2,
  dpi = 180,
  bg = "white"
)

noisy_filtration <- build_filtration(circle_noisy, method = "VR", eps_max = 1.85, max_dimension = 1)
noisy_pairs <- persistence_pairs(noisy_filtration, max_dimension = 1)
matching_plot <- plot_matching(
  vr_pairs,
  noisy_pairs,
  dimension = 1,
  distance = "bottleneck",
  ground = "Linf",
  labels = c("Circle", "Noisy circle")
)
ggplot2::ggsave(
  file.path(figure_dir, "DiagramMatching.png"),
  matching_plot,
  width = 7.2,
  height = 5.4,
  dpi = 180,
  bg = "white"
)

n_flood <- 400L
theta_flood <- stats::runif(n_flood, 0, 2 * pi)
group <- rep(c(-1.25, 1.25), each = n_flood / 2)
flood_points <- cbind(
  cos(theta_flood) + group,
  sin(theta_flood)
) + matrix(stats::rnorm(2 * n_flood, sd = 0.045), ncol = 2)

flood <- flood_complex(
  flood_points,
  landmarks = 28,
  max_dimension = 2,
  points_per_edge = 8,
  backend = "cpu",
  batch_points = 65536
)
flood_dims <- lengths(flood$simplices) - 1L
flood_threshold <- as.numeric(stats::quantile(flood$filtration, probs = 0.58))
flood_alive <- flood$filtration <= flood_threshold

save_base_png("FloodComplex.png", {
  graphics::par(mar = c(3.5, 3.5, 3.2, 1.0))
  graphics::plot(
    flood_points,
    pch = 16,
    cex = 0.45,
    col = "grey70",
    asp = 1,
    xlab = "x",
    ylab = "y",
    main = sprintf("Flood complex at t = %.3f", flood_threshold)
  )
  for (i in which(flood_alive & flood_dims == 2L)) {
    simplex <- flood$simplices[[i]]
    graphics::polygon(
      flood$landmarks[simplex, 1],
      flood$landmarks[simplex, 2],
      col = grDevices::adjustcolor("#4c96d7", alpha.f = 0.28),
      border = NA
    )
  }
  for (i in which(flood_alive & flood_dims == 1L)) {
    simplex <- flood$simplices[[i]]
    graphics::lines(
      flood$landmarks[simplex, 1],
      flood$landmarks[simplex, 2],
      col = "#255f8d",
      lwd = 1.6
    )
  }
  graphics::points(flood$landmarks, pch = 21, bg = "#e98a2b", cex = 1.15)
  graphics::legend(
    "bottomright",
    legend = c("Data points", "FPS landmarks", "Alive simplices"),
    pch = c(16, 21, 15),
    pt.bg = c("grey70", "#e98a2b", grDevices::adjustcolor("#4c96d7", 0.28)),
    col = c("grey70", "black", grDevices::adjustcolor("#4c96d7", 0.45)),
    bty = "n"
  )
})

