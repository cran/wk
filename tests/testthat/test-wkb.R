
test_that("wkb class works", {
  x <- wkb(wkt_translate_wkb("POINT (40 10)", endian = 1))
  expect_s3_class(x, "wk_wkb")
  expect_true(is_wk_wkb(x))
  expect_s3_class(x, "wk_vctr")
  expect_output(print(x), "wk_wkb")
  expect_match(as.character(x), "POINT")

  expect_s3_class(wkb(list(NULL)), "wk_wkb")
  expect_true(is.na(wkb(list(NULL))))

  expect_error(new_wk_wkb(structure(list(), thing = "stuff")), "must be a list")
  expect_error(new_wk_wkb("char!"), "must be a list")
  expect_error(wkb(list("not raw()")), "must be raw")
  expect_error(wkb(list(raw())), "Encountered 1 parse problem")
  expect_error(wkb(rep(list(raw()), 10)), "Encountered 10 parse problems")
  expect_error(validate_wk_wkb("char!"), "must be of type list")
  # See #123 and revert in dev wk after CRAN release
  # expect_error(validate_wk_wkb(list()), "must inherit from")

  expect_s3_class(x[1], "wk_wkb")
  expect_identical(x[[1]], x[1])
  expect_s3_class(c(x, x), "wk_wkb")
  expect_identical(rep(x, 2), c(x, x))
  expect_identical(rep(wkb(), 3), wkb())
  expect_length(c(x, x), 2)

  x[1] <- "POINT (11 12)"
  expect_identical(as_wkt(x[1]), wkt("POINT (11 12)"))

  skip_if_not(packageVersion("base") >= "3.6")
  expect_identical(rep_len(x, 2), c(x, x))
})

test_that("as_wkb() works", {
  x <- wkb(wkt_translate_wkb("POINT (40 10)"))
  expect_identical(as_wkb(x), x)
  expect_identical(as_wkb("POINT (40 10)"), x)
  expect_identical(as_wkb(wkt("POINT (40 10)")), x)

  # blob and WKB methods
  expect_identical(
    as_wkb(structure(wkt_translate_wkb("POINT (11 12)"), class = "blob")),
    as_wkb("POINT (11 12)")
  )
  expect_identical(
    as_wkb(structure(wkt_translate_wkb("POINT (11 12)"), class = "WKB")),
    as_wkb("POINT (11 12)")
  )
})

test_that("parse_wkb() works", {
  x <- wkt_translate_wkb("POINT (40 10)", endian = 1)
  expect_silent(parsed <- parse_wkb(x))
  expect_false(is.na(parsed))
  expect_null(attr(parsed, "problems"))

  x[[1]][2:3] <- as.raw(0xff)
  expect_warning(parsed <- parse_wkb(x), "Encountered 1 parse problem")
  expect_true(is.na(parsed))
  expect_s3_class(attr(parsed, "problems"), "data.frame")
  expect_identical(nrow(attr(parsed, "problems")), 1L)
})

test_that("wkb() propagates CRS", {
  x <- as_wkb("POINT (1 2)")
  wk_crs(x) <- 1234

  expect_identical(wk_crs(x[1]), 1234)
  expect_identical(wk_crs(c(x, x)), 1234)
  expect_identical(wk_crs(rep(x, 2)), 1234)

  expect_error(x[1] <- wkb(x, crs = NULL), "are not equal")
  x[1] <- wkb(x, crs = 1234L)
  expect_identical(wk_crs(x), 1234)
})

test_that("wkb() propagates geodesic", {
  x <- wkb(as_wkb("POINT (1 2)"), geodesic = TRUE)
  expect_true(wk_is_geodesic(x))
  expect_true(wk_is_geodesic(x[1]))
  expect_true(wk_is_geodesic(c(x, x)))
  expect_true(wk_is_geodesic(rep(x, 2)))

  expect_error(x[1] <- wk_set_geodesic(x, FALSE), "objects have differing values")
  x[1] <- wk_set_geodesic(x, TRUE)
  expect_true(wk_is_geodesic(x))
})

test_that("as_wkb() propagates CRS", {
  x <- as_wkb("POINT (1 2)", crs = 1234)
  expect_identical(wk_crs(x), 1234)
  expect_identical(wk_crs(as_wkb(wkt("POINT (1 2)", crs = 1234))), 1234)
})

test_that("as_wkb() propagates geodesic", {
  x <- as_wkb("POINT (1 2)", geodesic = TRUE)
  expect_true(wk_is_geodesic(x))
  expect_true(wk_is_geodesic(as_wkb(wkt("POINT (1 2)", geodesic = TRUE))))
})

test_that("examples as wkb roundtrip", {
  for (which in names(wk_example_wkt)) {
    expect_identical(
      wk_handle(as_wkb(wk_example(!!which, crs = NULL)), wkt_writer()),
      wk_example(!!which, crs = NULL)
    )
  }
})

test_that("wk_c_wkb_to_hex works", {
  list_of_raw <- list(as.raw(0:255), raw(0), NULL)
  expect_identical(
    .Call(wk_c_wkb_to_hex, list_of_raw),
    c(paste(sprintf("%02x", 0:255), collapse = ""), "", NA_character_)
  )
})

test_that("wkb_to_hex works", {
  features <- wkt(c("POINT (0 0)", "LINESTRING (1 1, 2 2)", "POLYGON EMPTY", NA))

  # little endian
  wkb_little <- wk_handle(features, wkb_writer(endian = 1))
  hex_little <- c(
    "010100000000000000000000000000000000000000",
    "010200000002000000000000000000f03f000000000000f03f00000000000000400000000000000040",
    "010300000000000000",
    NA_character_
  )

  expect_equal(wkb_to_hex(wkb_little), hex_little)

  # big endian
  wkb_big <- wk_handle(features, wkb_writer(endian = 0))
  hex_big <- c(
    "000000000100000000000000000000000000000000",
    "0000000002000000023ff00000000000003ff000000000000040000000000000004000000000000000",
    "000000000300000000",
    NA_character_
  )

  expect_equal(wkb_to_hex(wkb_big), hex_big)
})

test_that("vec_equal(wkb) works", {
  points <- wkt(c("POINT (1 1)", "POINT (2 2)", "POINT (3 3)"))

  # little endian
  wkb_little <- wk_handle(points, wkb_writer(endian = 1))
  hex_little <- c(
    "0101000000000000000000f03f000000000000f03f",
    "010100000000000000000000400000000000000040",
    "010100000000000000000008400000000000000840"
  )

  expect_equal(vctrs::vec_proxy_equal(wkb_little), hex_little)
  expect_equal(vctrs::vec_equal(wkb_little, wkb_little), c(TRUE, TRUE, TRUE))
  expect_equal(vctrs::vec_equal(wkb_little[1], wkb_little[2]), FALSE)

  # big endian
  wkb_big <- wk_handle(points, wkb_writer(endian = 0))
  hex_big <- c(
    "00000000013ff00000000000003ff0000000000000",
    "000000000140000000000000004000000000000000",
    "000000000140080000000000004008000000000000"
  )

  expect_equal(vctrs::vec_proxy_equal(wkb_big), hex_big)
  expect_equal(vctrs::vec_equal(wkb_big, wkb_big), c(TRUE, TRUE, TRUE))
  expect_equal(vctrs::vec_equal(wkb_big[1], wkb_big[2]), FALSE)
})
