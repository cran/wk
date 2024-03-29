
test_that("wk_vertices() works", {
  expect_identical(
    wk_vertices(wkt(c("POINT (0 0)", "POINT (1 1)", NA))),
    wkt(c("POINT (0 0)", "POINT (1 1)"))
  )
  expect_identical(
    wk_vertices(wkt(c("LINESTRING (0 0, 1 1)", NA))),
    wkt(c("POINT (0 0)", "POINT (1 1)"))
  )
  expect_error(wk_vertices(new_wk_wkt("POINT ENTPY")), "ENTPY")

  # we need this one to trigger a realloc on the details list
  xy_copy <- wk_handle(
    as_wkt(xy(1:1025, 1)),
    wk_vertex_filter(xy_writer(), add_details = TRUE)
  )
  expect_identical(
    attr(xy_copy, "wk_details"),
    list(feature_id = 1:1025, part_id = 1:1025, ring_id = rep(0L, 1025))
  )
  attr(xy_copy, "wk_details") <- NULL
  expect_identical(xy_copy, xy(1:1025, 1))
})

test_that("wk_vertices() works for data.frame", {
  expect_identical(
    wk_vertices(data.frame(geom = wkt(c("POINT (0 0)", "POINT (1 1)")))),
    data.frame(geom = wkt(c("POINT (0 0)", "POINT (1 1)")))
  )
})

test_that("wk_coords() works", {
  # point
  expect_identical(
    wk_coords(wkt("POINT (30 10)")),
    data.frame(
      feature_id = 1L,
      part_id = 1L,
      ring_id = 0L,
      x = 30,
      y = 10
    )
  )

  # point zm
  expect_identical(
    wk_coords(wkt("POINT ZM (30 10 1 2)")),
    data.frame(
      feature_id = 1L,
      part_id = 1L,
      ring_id = 0L,
      x = 30,
      y = 10,
      z = 1,
      m = 2
    )
  )

  # linestring
  expect_identical(
    wk_coords(wkt("LINESTRING (30 10, 20 11)")),
    data.frame(
      feature_id = c(1L, 1L),
      part_id = c(1L, 1L),
      ring_id = c(0L, 0L),
      x = c(30, 20),
      y = c(10, 11)
    )
  )

  # polygon
  expect_identical(
    wk_coords(wkt("POLYGON ((30 10, 20 11, 0 0, 30 10))")),
    data.frame(
      feature_id = c(1L, 1L, 1L, 1L),
      part_id = c(1L, 1L, 1L, 1L),
      ring_id = c(1L, 1L, 1L, 1L),
      x = c(30, 20, 0, 30),
      y = c(10, 11, 0, 10)
    )
  )

  # multipoint
  expect_identical(
    wk_coords(wkt("MULTIPOINT ((30 10), (20 11))")),
    data.frame(
      feature_id = c(1L, 1L),
      part_id = c(2L, 3L),
      ring_id = c(0L, 0L),
      x = c(30, 20),
      y = c(10, 11)
    )
  )

  # collection
  # point
  expect_identical(
    wk_coords(wkt("GEOMETRYCOLLECTION (POINT (30 10))")),
    data.frame(
      feature_id = 1L,
      part_id = 2L,
      ring_id = 0L,
      x = 30,
      y = 10
    )
  )
})

test_that("wk_vertices() communicates correct size and type", {
  expect_identical(
    wk_handle(wkt("POINT (0 0)"), wk_vertex_filter(wk_vector_meta_handler())),
    list(geometry_type = 1L, size = NA_real_, has_z = NA, has_m = NA)
  )

  skip_if_not_installed("sf")
  # need sf because these objects carry vector-level types
  expect_identical(
    wk_handle(sf::st_as_sfc("POINT (0 0)"), wk_vertex_filter(wk_vector_meta_handler())),
    list(geometry_type = 1L, size = 1, has_z = FALSE, has_m = FALSE)
  )
  expect_identical(
    wk_handle(sf::st_as_sfc("MULTIPOINT EMPTY"), wk_vertex_filter(wk_vector_meta_handler())),
    list(geometry_type = 1L, size = NA_real_, has_z = FALSE, has_m = FALSE)
  )
  expect_identical(
    wk_handle(sf::st_as_sfc("MULTILINESTRING EMPTY"), wk_vertex_filter(wk_vector_meta_handler())),
    list(geometry_type = 1L, size = NA_real_, has_z = FALSE, has_m = FALSE)
  )
  expect_identical(
    wk_handle(sf::st_as_sfc("MULTIPOLYGON EMPTY"), wk_vertex_filter(wk_vector_meta_handler())),
    list(geometry_type = 1L, size = NA_real_, has_z = FALSE, has_m = FALSE)
  )
  expect_identical(
    wk_handle(sf::st_as_sfc("GEOMETRYCOLLECTION EMPTY"), wk_vertex_filter(wk_vector_meta_handler())),
    list(geometry_type = 1L, size = NA_real_, has_z = FALSE, has_m = FALSE)
  )
})

test_that("optimized wk_coords() for xy() works", {
  xys <- xy(1:5, 6:10)
  expect_identical(wk_coords(xys), wk_coords.default(xys))

  xys_with_empty_and_null <- c(xys, xy(NA, NA), xy(NaN, NaN))
  expect_identical(
    wk_coords(xys_with_empty_and_null),
    wk_coords.default(xys_with_empty_and_null)
  )
})
