
#' Plot well-known geometry vectors
#'
#' @param x A [wkb()] or [wkt()]
#' @param add Should a new plot be created, or should `handleable` be added to the
#'   existing plot?
#' @param ... Passed to plotting functions for features: [graphics::points()]
#'   for point and multipoint geometries, [graphics::lines()] for linestring
#'   and multilinestring geometries, and [graphics::polypath()] for polygon
#'   and multipolygon geometries.
#' @param bbox The limits of the plot as a [rct()] or compatible object
#' @param asp,xlab,ylab Passed to [graphics::plot()]
#' @param rule The rule to use for filling polygons (see [graphics::polypath()])
#' @inheritParams wk_handle
#'
#' @return The input, invisibly.
#' @importFrom graphics plot
#' @export
#'
#' @examples
#' plot(as_wkt("LINESTRING (0 0, 1 1)"))
#' plot(as_wkb("LINESTRING (0 0, 1 1)"))
#'
wk_plot <- function(handleable, ...,
                    asp = 1, bbox = NULL, xlab = "", ylab = "",
                    rule = "evenodd", add = FALSE) {
  UseMethod("wk_plot")
}

#' @rdname wk_plot
#' @export
wk_plot.default <- function(handleable, ...,
                            asp = 1, bbox = NULL, xlab = "", ylab = "",
                            rule = "evenodd", add = FALSE) {
  # this is too hard without vctrs (already in Suggests)
  if (!requireNamespace("vctrs", quietly = TRUE)) {
    stop("Package 'vctrs' is required for wk_plot()", call. = FALSE) # nocov
  }

  if (isTRUE(wk_is_geodesic(handleable))) {
    stop(
      paste0(
        "wk_plot.default() can't plot geodesic objects.\n",
        "Use `wk_set_geodesic(x, FALSE)` to ignore geodesic edge specification"
      ),
      call. = FALSE
    )
  }

  # should be refactored
  x <- handleable

  if (!add) {
    bbox <- unclass(bbox)
    bbox <- bbox %||% unclass(wk_bbox(x))
    xlim <- c(bbox$xmin, bbox$xmax)
    ylim <- c(bbox$ymin, bbox$ymax)

    graphics::plot(
      numeric(0),
      numeric(0),
      xlim = xlim,
      ylim = ylim,
      xlab = xlab,
      ylab = ylab,
      asp = asp
    )
  }

  # for everything below we'll need to be able to subset
  if (!vctrs::vec_is(x)) {
    wk_plot(as_wkb(x), ..., rule = rule, add = TRUE) # nocov
    return(invisible(x)) # nocov
  }

  # get some background info
  size <- vctrs::vec_size(x)
  meta <- wk_meta(x)

  # points can be handled by as_xy()
  if (all(meta$geometry_type == 1L, na.rm = TRUE)) {
    coords <- unclass(as_xy(x))
    graphics::points(coords, ...)
    return(invisible(x))
  }

  # evaluate the dots
  dots <- list(..., rule = rule)
  is_scalar <- !vapply(dots, vctrs::vec_is, logical(1))
  dots[is_scalar] <- lapply(dots[is_scalar], list)
  dots_length <- vapply(dots, vctrs::vec_size, integer(1))
  dots_constant <- all(dots_length == 1L)
  is_rule <- length(dots)

  # point + multipoint is probably faster with a single coord vector
  if (all(meta$geometry_type %in% c(1, 4), na.rm = TRUE)) {
    coords <- wk_coords(x)
    if (dots_constant) {
      graphics::points(coords[c("x", "y")], ...)
    } else {
      dots$rule <- NULL
      dots <- vctrs::vec_recycle_common(!!!dots, .size = size)
      dots_tbl <- vctrs::new_data_frame(dots, n = size)
      do.call(graphics::points, c(coords[c("x", "y")], dots_tbl[coords$feature_id, , drop = FALSE]))
    }
    return(invisible(x))
  }

  # it's not faster to flatten big vectors into a single go for anything else
  dots <- vctrs::vec_recycle_common(!!!dots, .size = size)
  for (i in seq_len(size)) {
    xi <- vctrs::vec_slice(x, i)
    dotsi <- lapply(dots, "[[", i)

    if (meta$geometry_type[i] %in% c(1, 4)) {
      wk_plot_point_or_multipoint(xi, dotsi[-is_rule])
    } else if (meta$geometry_type[i] %in% c(2, 5)) {
      wk_plot_line_or_multiline(xi, dotsi[-is_rule])
    } else if (meta$geometry_type[i] %in% c(3, 6)) {
      wk_plot_poly_or_multi_poly(xi, dotsi)
    } else {
      do.call(wk_plot, c(list(wk_flatten(xi, max_depth = .Machine$integer.max), add = TRUE), dotsi))
    }
  }

  invisible(x)
}

wk_plot_point_or_multipoint <- function(x, dots) {
  dots_without_border <- dots[setdiff(names(dots), "border")]
  coords <- wk_coords(x)
  do.call(graphics::points, c(coords[c("x", "y")], dots_without_border))
}

wk_plot_line_or_multiline <- function(x, dots) {
  coords <- wk_coords(x)
  if (nrow(coords) == 0) {
    return()
  }

  geom_id <- coords$part_id
  geom_id_lag <- c(-1L, geom_id[-length(geom_id)])
  new_geom <- geom_id != geom_id_lag
  na_shift <- cumsum(new_geom) - 1L
  coords_seq <- seq_along(geom_id)

  coord_x <- rep(NA_real_, length(geom_id) + sum(new_geom) - 1L)
  coord_y <- rep(NA_real_, length(geom_id) + sum(new_geom) - 1L)

  coord_x[coords_seq + na_shift] <- coords$x
  coord_y[coords_seq + na_shift] <- coords$y

  dots$rule <- NULL
  do.call(graphics::lines, c(list(coord_x, coord_y), dots))
}

wk_plot_poly_or_multi_poly <- function(x, dots) {
  coords <- wk_coords(x)
  if (nrow(coords) == 0) {
    return()
  }

  # for polygons we can use the coord vectors directly
  # because the graphics device expects open loops
  geom_id <- coords$ring_id
  n <- length(geom_id)
  # leave the last loop closed the avoid a trailing NA (which results in error)
  geom_id_lead <- c(geom_id[-1L], geom_id[n])
  new_geom_next <- geom_id != geom_id_lead

  coords$x[new_geom_next] <- NA_real_
  coords$y[new_geom_next] <- NA_real_

  do.call(graphics::polypath, c(coords[c("x", "y")], dots))
}

#' @rdname wk_plot
#' @export
plot.wk_wkt <- function(x, ..., asp = 1, bbox = NULL, xlab = "", ylab = "",
                        rule = "evenodd", add = FALSE) {
  wk_plot(
    x,
    ...,
    asp = asp,
    bbox = bbox,
    xlab = xlab,
    ylab = ylab,
    rule = rule,
    add = add
  )

  invisible(x)
}

#' @rdname wk_plot
#' @export
plot.wk_wkb <- function(x, ..., asp = 1, bbox = NULL, xlab = "", ylab = "",
                        rule = "evenodd", add = FALSE) {
  wk_plot(
    x,
    ...,
    asp = asp,
    bbox = bbox,
    xlab = xlab,
    ylab = ylab,
    rule = rule,
    add = add
  )

  invisible(x)
}

#' @rdname wk_plot
#' @export
plot.wk_xy <- function(x, ..., asp = 1, bbox = NULL, xlab = "", ylab = "", add = FALSE) {
  x_bare <- unclass(x)

  if (!add) {
    graphics::plot(
      double(), double(),
      xlim = range(x_bare$x, finite = TRUE),
      ylim = range(x_bare$y, finite = TRUE),
      xlab = xlab,
      ylab = ylab,
      asp = asp
    )
  }

  graphics::points(x_bare$x, x_bare$y, ...)

  invisible(x)
}

#' @rdname wk_plot
#' @export
plot.wk_rct <- function(x, ..., asp = 1, bbox = NULL, xlab = "", ylab = "", add = FALSE) {
  x_bare <- unclass(x)

  if (!add) {
    xlim_min <- range(x_bare$xmin, finite = TRUE)
    xlim_max <- range(x_bare$xmax, finite = TRUE)
    ylim_min <- range(x_bare$ymin, finite = TRUE)
    ylim_max <- range(x_bare$ymax, finite = TRUE)

    graphics::plot(
      double(), double(),
      xlim = range(c(xlim_min, xlim_max), finite = TRUE),
      ylim = range(c(ylim_min, ylim_max), finite = TRUE),
      xlab = xlab,
      ylab = ylab,
      asp = asp
    )
  }

  graphics::rect(x_bare$xmin, x_bare$ymin, x_bare$xmax, x_bare$ymax, ...)
  invisible(x)
}

#' @rdname wk_plot
#' @export
plot.wk_crc <- function(x, ..., asp = 1, bbox = NULL, xlab = "", ylab = "",
                        add = FALSE) {
  x_bare <- unclass(x)

  if (!add) {
    xlim_min <- range(x_bare$x + x_bare$r, finite = TRUE)
    xlim_max <- range(x_bare$x - x_bare$r, finite = TRUE)
    ylim_min <- range(x_bare$y + x_bare$r, finite = TRUE)
    ylim_max <- range(x_bare$y - x_bare$r, finite = TRUE)

    graphics::plot(
      double(), double(),
      xlim = range(c(xlim_min, xlim_max), finite = TRUE),
      ylim = range(c(ylim_min, ylim_max), finite = TRUE),
      xlab = xlab,
      ylab = ylab,
      asp = asp
    )
  }

  # estimate resolution for turning circles into segments
  usr <- graphics::par("usr")
  usr_x <- usr[1:2]
  usr_y <- usr[3:4]
  device_x <- graphics::grconvertX(usr_x, to = "device")
  device_y <- graphics::grconvertY(usr_y, to = "device")

  # Use resolution of 1 at the device level, scale to usr coords.
  # Changing this number to 2 or 4 doesn't really affect the speed
  # at which these plot; a value of 1 tends to give very good
  # resolution and is acceptable even when a plot in the interactive
  # device is zoomed.
  scale_x <- diff(device_x) / diff(usr_x)
  scale_y <- diff(device_y) / diff(usr_y)
  scale <- min(abs(scale_x), abs(scale_y))
  resolution_usr <- 1 / scale

  plot(
    wk_handle(x, wkb_writer(), resolution = resolution_usr),
    ...,
    add = TRUE
  )

  invisible(x)
}
