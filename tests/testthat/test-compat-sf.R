
test_that("sf CRS objects can be compared", {
  skip_if_not_installed("sf")

  expect_true(wk_crs_equal(sf::st_crs(4326), 4326))
  expect_true(wk_crs_equal(sf::st_crs(4326), 4326L))
  expect_true(wk_crs_equal(sf::st_crs(NA), NULL))
  expect_true(wk_crs_equal(NULL, sf::st_crs(NA)))
})

test_that("wk_crs/set_crs works on sf/sfc", {
  skip_if_not_installed("sf")

  sf <- sf::st_as_sf(data.frame(geometry = sf::st_as_sfc("POINT (1 2)")))
  expect_identical(wk_crs(sf), sf::st_crs(sf))
  expect_identical(sf::st_crs(wk_set_crs(sf, 4326)), sf::st_crs(4326))

  sfc <- sf::st_as_sfc("POINT (1 2)")
  expect_identical(wk_crs(sfc), sf::st_crs(sfc))
  expect_identical(sf::st_crs(wk_set_crs(sfc, 4326)), sf::st_crs(4326))
})

test_that("conversion from sf to wkt works", {
  skip_if_not_installed("sf")

  sfc <- sf::st_sfc(sf::st_point(), sf::st_point(c(0, 1)), crs = 4326)
  expect_s3_class(as_wkt(sfc), "wk_wkt")
  expect_identical(
    as.character(as_wkt(sfc)),
    c("POINT EMPTY", "POINT (0 1)")
  )
  expect_identical(wk_crs(as_wkt(sfc)), sf::st_crs(sfc))

  sf <- sf::st_as_sf(new_data_frame(list(geometry = sfc)))
  expect_identical(
    as.character(as_wkt(sf)),
    c("POINT EMPTY", "POINT (0 1)")
  )
  expect_identical(wk_crs(as_wkt(sf)), sf::st_crs(sf))
})

test_that("conversion from sf to wkb works", {
  skip_if_not_installed("sf")

  sfc <- sf::st_sfc(sf::st_point(), sf::st_point(c(0, 1)), crs = 4326)
  expect_s3_class(as_wkb(sfc), "wk_wkb")
  expect_identical(
    as.character(as_wkt(as_wkb(sfc))),
    c("POINT (nan nan)", "POINT (0 1)")
  )
  expect_identical(wk_crs(as_wkb(sfc)), sf::st_crs(sfc))

  sfg <- sf::st_point(c(0, 1))
  expect_s3_class(as_wkb(sfg), "wk_wkb")
  expect_identical(
    as.character(as_wkt(as_wkb(sfg))),
    "POINT (0 1)"
  )

  sf <- sf::st_as_sf(new_data_frame(list(geometry = sfc)))
  expect_identical(
    as.character(as_wkt(as_wkb(sf))),
    c("POINT (nan nan)", "POINT (0 1)")
  )
  expect_identical(wk_crs(as_wkb(sf)), sf::st_crs(sf))
})

test_that("conversion from sf to xy works", {
  skip_if_not_installed("sf")

  sfc <- sf::st_sfc(sf::st_point(), sf::st_point(c(0, 1)))
  expect_s3_class(as_xy(sfc), "wk_xy")
  expect_identical(as_xy(sfc), xy(c(NA, 0), c(NA, 1)))

  sf <- sf::st_as_sf(new_data_frame(list(geometry = sfc)))
  expect_identical(as_xy(sf), xy(c(NA, 0), c(NA, 1)))

  expect_identical(as_xy(sf::st_sfc()), xy(crs = NULL))
  expect_identical(as_xy(sf::st_sfc(sf::st_linestring())), xy(NA, NA, crs = sf::NA_crs_))

  # check all dimensions
  expect_identical(as_xy(sf::st_sfc(sf::st_point(c(1, 2, 3, 4), dim = "XYZM"))), xyzm(1, 2, 3, 4))
  expect_identical(as_xy(sf::st_sfc(sf::st_point(c(1, 2, 3), dim = "XYZ"))), xyz(1, 2, 3))
  expect_identical(as_xy(sf::st_sfc(sf::st_point(c(1, 2, 3), dim = "XYM"))), xym(1, 2, 3))
  expect_identical(as_xy(sf::st_sfc(sf::st_point(c(1, 2)))), xy(1, 2))
})

test_that("conversion from bbox to rct works", {
  skip_if_not_installed("sf")

  sfc <- sf::st_sfc(sf::st_point(c(2, 3)), sf::st_point(c(0, 1)))
  expect_identical(as_rct(sf::st_bbox(sfc)), rct(0, 1, 2, 3))
})

test_that("conversion to sf works", {
  skip_if_not_installed("sf")

  sfc <- sf::st_sfc(sf::st_point(), sf::st_point(c(0, 1)), crs = 4326)
  sf <- sf::st_as_sf(new_data_frame(list(geometry = sfc)))
  wkb <- as_wkb(c("POINT EMPTY", "POINT (0 1)"), crs = 4326)
  wkt <- as_wkt(c("POINT EMPTY", "POINT (0 1)"), crs = 4326)

  expect_equal(sf::st_as_sf(wkb), sf)
  expect_equal(sf::st_as_sfc(wkb), sfc)
  expect_equal(sf::st_as_sf(wkt), sf)
  expect_equal(sf::st_as_sfc(wkt), sfc)

  # xy
  expect_equal(sf::st_as_sf(xy(c(NA, 0), c(NA, 1), crs = 4326)), sf)
  expect_equal(sf::st_as_sfc(xy(c(NA, 0), c(NA, 1), crs = 4326)), sfc)

  # xy with all !is.na() uses faster sf conversion with coords
  expect_equal(sf::st_as_sf(xy(0, 1, crs = 4326)), sf[-1, , drop = FALSE])
  expect_equal(sf::st_as_sfc(xy(0, 1, crs = 4326)), sfc[-1])

  # rct can only generate rectangles
  expect_equal(
    sf::st_as_sfc(rct(1, 2, 3, 4, crs = 4326)),
    sf::st_as_sfc(sf::st_bbox(c(xmin = 1, ymin = 2, xmax = 3, ymax = 4), crs =  4326))
  )

  expect_equal(
    sf::st_as_sf(rct(1, 2, 3, 4, crs = 4326)),
    sf::st_as_sf(
      data.frame(
        geometry = sf::st_as_sfc(
          sf::st_bbox(c(xmin = 1, ymin = 2, xmax = 3, ymax = 4), crs =  4326)
        )
      )
    )
  )

  # crc only generates circles
  expect_equal(
    as_rct(sf::st_bbox(sf::st_as_sfc(crc(1, 2, 3)))),
    rct(-2, -1, 4, 5)
  )

  expect_equal(
    as_rct(sf::st_bbox(sf::st_as_sf(crc(1, 2, 3)))),
    rct(-2, -1, 4, 5)
  )
})

test_that("wk_handle.sfg works", {
  skip_if_not_installed("sf")
  expect_identical(
    wk_handle(wkt("POINT (1 2)"), wkb_writer()),
    wk_handle(sf::st_point(c(1, 2)), wkb_writer())
  )
})

test_that("wk_handle.bbox works", {
  skip_if_not_installed("sf")

  expect_identical(
    wk_handle(sf::st_bbox(sf::st_linestring(rbind(c(0, 1), c(2, 3)))), wkb_writer()),
    wk_handle(rct(0, 1, 2, 3), wkb_writer())
  )
})

test_that("wk_translate.sfc() works", {
  skip_if_not_installed("sf")

  expect_identical(
    wk_translate(wkt("POINT (1 2)", crs = 4326), sf::st_sfc(crs = 4326)),
    sf::st_sfc(sf::st_point(c(1, 2)), crs = 4326)
  )
})


test_that("wk_translate() works for sf", {
  skip_if_not_installed("sf")

  expect_identical(
    wk_translate(
      sf::st_as_sf(data.frame(geometry = sf::st_as_sfc("POINT (1 2)"))),
      sf::st_as_sf(data.frame(a = sf::st_sfc()))
    ),
    sf::st_as_sf(data.frame(geometry = sf::st_as_sfc("POINT (1 2)")))
  )

  expect_identical(
    wk_translate(
      data.frame(a = 1, geometry = wkt("POINT (1 2)")),
      sf::st_as_sf(data.frame(a = sf::st_sfc()))
    ),
    sf::st_as_sf(data.frame(a = 1, geometery = sf::st_as_sfc("POINT (1 2)")))
  )

  expect_identical(
    wk_translate(as_wkb("POINT (1 2)"), sf::st_as_sf(data.frame(a = sf::st_sfc()))),
    sf::st_as_sf(data.frame(a = sf::st_as_sfc("POINT (1 2)")))
  )

  expect_identical(
    wk_translate(
      as_wkb("POINT (1 2)", crs = 4326),
      sf::st_as_sf(data.frame(a = sf::st_sfc(crs = 4326)))
    ),
    sf::st_as_sf(data.frame(a = sf::st_as_sfc("POINT (1 2)", crs = 4326)))
  )
})

test_that("wk_restore() works for sf", {
  skip_if_not_installed("sf")

  expect_identical(
    wk_identity(sf::st_as_sf(data.frame(a = sf::st_as_sfc("POINT (1 2)")))),
    sf::st_as_sf(data.frame(a = sf::st_as_sfc("POINT (1 2)")))
  )

  expect_identical(
    wk_identity(sf::st_as_sf(data.frame(a = sf::st_as_sfc("POINT (1 2)", crs = 4326)))),
    sf::st_as_sf(data.frame(a = sf::st_as_sfc("POINT (1 2)", crs = 4326)))
  )

  expect_identical(
    wk_restore(
      sf::st_as_sf(data.frame(geometry = sf::st_as_sfc("POINT (1 2)"))),
      sf::st_as_sfc(c("POINT (3 4)", "POINT (5 6)"))
    ),
    sf::st_as_sf(data.frame(geometry = sf::st_as_sfc(c("POINT (3 4)", "POINT (5 6)"))))
  )

  expect_error(
    wk_restore(
      sf::st_as_sf(data.frame(geometry = sf::st_as_sfc(rep("POINT (1 2)", 3)))),
      sf::st_as_sfc(c("POINT (3 4)", "POINT (5 6)"))
    ),
    "Can't assign"
  )
})
