
test_that("basic translation works on non-empty 2D geoms", {
  expect_identical(
    wkt_translate_wkt("POINT (30 10)"),
    "POINT (30 10)"
  )
  expect_identical(
    wkt_translate_wkt("LINESTRING (30 10, 0 0)"),
    "LINESTRING (30 10, 0 0)"
  )
  expect_identical(
    wkt_translate_wkt("POLYGON ((30 10, 0 0, 10 10, 30 10))"),
    "POLYGON ((30 10, 0 0, 10 10, 30 10))"
  )
  expect_identical(
    wkt_translate_wkt("POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30))"),
    "POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30))"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOINT (30 10, 0 0, 10 10)"),
    "MULTIPOINT ((30 10), (0 0), (10 10))"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOINT ((30 10), (0 0), (10 10))"),
    "MULTIPOINT ((30 10), (0 0), (10 10))"
  )
  expect_identical(
    wkt_translate_wkt("MULTILINESTRING ((30 10, 0 0), (20 20, 0 0))"),
    "MULTILINESTRING ((30 10, 0 0), (20 20, 0 0))"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOLYGON (((30 10, 0 0, 10 10, 30 10)), ((30 10, 0 0, 10 10, 30 10)))"),
    "MULTIPOLYGON (((30 10, 0 0, 10 10, 30 10)), ((30 10, 0 0, 10 10, 30 10)))"
  )
  expect_identical(
    wkt_translate_wkt(
      "GEOMETRYCOLLECTION (POINT (30 10), GEOMETRYCOLLECTION (POINT (12 6)), LINESTRING (1 2, 3 4))"
    ),
    "GEOMETRYCOLLECTION (POINT (30 10), GEOMETRYCOLLECTION (POINT (12 6)), LINESTRING (1 2, 3 4))"
  )
})

test_that("basic translation works on empty geoms", {
  expect_identical(
    wkt_translate_wkt("POINT EMPTY"),
    "POINT EMPTY"
  )
  expect_identical(
    wkt_translate_wkt("LINESTRING EMPTY"),
    "LINESTRING EMPTY"
  )
  expect_identical(
    wkt_translate_wkt("POLYGON EMPTY"),
    "POLYGON EMPTY"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOINT EMPTY"),
    "MULTIPOINT EMPTY"
  )
  expect_identical(
    wkt_translate_wkt("MULTILINESTRING EMPTY"),
    "MULTILINESTRING EMPTY"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOLYGON EMPTY"),
    "MULTIPOLYGON EMPTY"
  )
  expect_identical(
    wkt_translate_wkt(
      "GEOMETRYCOLLECTION EMPTY"
    ),
    "GEOMETRYCOLLECTION EMPTY"
  )
})

test_that("mutli* geometries can contain empties", {
  expect_identical(
    wkt_translate_wkt("MULTIPOINT (EMPTY)"),
    "MULTIPOINT (EMPTY)"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOINT (1 1, EMPTY)"),
    "MULTIPOINT ((1 1), EMPTY)"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOINT ((1 1), EMPTY)"),
    "MULTIPOINT ((1 1), EMPTY)"
  )
  expect_identical(
    wkt_translate_wkt("MULTILINESTRING (EMPTY)"),
    "MULTILINESTRING (EMPTY)"
  )
  expect_identical(
    wkt_translate_wkt("MULTILINESTRING ((1 1, 2 4), EMPTY)"),
    "MULTILINESTRING ((1 1, 2 4), EMPTY)"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOLYGON (((1 1, 2 4, 3 6)), EMPTY)"),
    "MULTIPOLYGON (((1 1, 2 4, 3 6)), EMPTY)"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOLYGON (EMPTY)"),
    "MULTIPOLYGON (EMPTY)"
  )
})

test_that("Z, ZM, and M prefixes are parsed", {
  expect_identical(
    wkt_translate_wkt("POINT (30 10)"),
    "POINT (30 10)"
  )
  expect_identical(
    wkt_translate_wkt("POINT Z (30 10 1)"),
    "POINT Z (30 10 1)"
  )
  expect_identical(
    wkt_translate_wkt("POINT M (30 10 1)"),
    "POINT M (30 10 1)"
  )
  expect_identical(
    wkt_translate_wkt("POINT ZM (30 10 0 1)"),
    "POINT ZM (30 10 0 1)"
  )
})

test_that("SRID prefixes are parsed", {
  expect_identical(
    wkt_translate_wkt("SRID=218;POINT (30 10)"),
    "SRID=218;POINT (30 10)"
  )
})

test_that("correctly formatted ZM geomteries are translated identically", {
  expect_identical(
    wkt_translate_wkt("POINT ZM (30 10 0 1)"),
    "POINT ZM (30 10 0 1)"
  )
  expect_identical(
    wkt_translate_wkt("LINESTRING ZM (30 10 0 1, 0 0 2 3)"),
    "LINESTRING ZM (30 10 0 1, 0 0 2 3)"
  )
  expect_identical(
    wkt_translate_wkt("POLYGON ZM ((30 10 2 1, 0 0 9 10, 10 10 10 8, 30 10 3 8))"),
    "POLYGON ZM ((30 10 2 1, 0 0 9 10, 10 10 10 8, 30 10 3 8))"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOINT ZM (30 10 32 1, 0 0 2 8, 10 10 1 99)"),
    "MULTIPOINT ZM ((30 10 32 1), (0 0 2 8), (10 10 1 99))"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOINT ZM ((30 10 32 1), (0 0 2 8), (10 10 1 99))"),
    "MULTIPOINT ZM ((30 10 32 1), (0 0 2 8), (10 10 1 99))"
  )
  expect_identical(
    wkt_translate_wkt("MULTILINESTRING ZM ((30 10 2 1, 0 0 2 8), (20 20 1 1, 0 0 2 2))"),
    "MULTILINESTRING ZM ((30 10 2 1, 0 0 2 8), (20 20 1 1, 0 0 2 2))"
  )
  expect_identical(
    wkt_translate_wkt("MULTIPOLYGON ZM (((30 10 1 3, 0 0 9 1, 10 10 5 9, 30 10 1 2)))"),
    "MULTIPOLYGON ZM (((30 10 1 3, 0 0 9 1, 10 10 5 9, 30 10 1 2)))"
  )
  expect_identical(
    wkt_translate_wkt("GEOMETRYCOLLECTION (POINT ZM (30 10 1 2))"),
    "GEOMETRYCOLLECTION (POINT ZM (30 10 1 2))"
  )
})

test_that("wkt_translate_wkb() works on NA", {
  expect_identical(wkt_translate_wkb(NA_character_), list(NULL))
})

test_that("wkt_translate_wkb() works on empty points", {
  expect_identical(
    wkb_translate_wkt(wkt_translate_wkb("POINT EMPTY")),
    "POINT EMPTY"
  )
})

test_that("wkt_translate_wkb() works simple geometries", {

  # POINT (30 10)
  point <- as.raw(c(0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x3e, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
                    0x00, 0x24, 0x40))

  # LINESTRING (30 10, 12 42)
  linestring <- as.raw(c(0x01, 0x02, 0x00, 0x00, 0x00, 0x02, 0x00,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x40, 0x00,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x40, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x00, 0x28, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x45,
                         0x40))

  # POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30))
  polygon <- as.raw(c(0x01, 0x03, 0x00, 0x00, 0x00, 0x02, 0x00,
                      0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                      0x80, 0x41, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x40,
                      0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x46, 0x40, 0x00, 0x00, 0x00,
                      0x00, 0x00, 0x80, 0x46, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                      0x2e, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x44, 0x40, 0x00,
                      0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x40, 0x00, 0x00, 0x00, 0x00,
                      0x00, 0x00, 0x34, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x41,
                      0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x40, 0x04, 0x00,
                      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x40, 0x00,
                      0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x40, 0x00, 0x00, 0x00, 0x00,
                      0x00, 0x80, 0x41, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x41,
                      0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x40, 0x00, 0x00,
                      0x00, 0x00, 0x00, 0x00, 0x34, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
                      0x00, 0x34, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x40))

  expect_identical(wkt_translate_wkb("POINT (30 10)", endian = 1L), list(point))
  expect_identical(
    wkt_translate_wkb("LINESTRING (30 10, 12 42)", endian = 1L),
    list(linestring)
  )
  expect_identical(
    wkt_translate_wkb(
      "POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30))",
      endian = 1L
    ),
    list(polygon)
  )
})

test_that("wkt_translate_wkb() works with multi geometries", {
  # MULTIPOINT ((10 40), (40 30), (20 20), (30 10))
  multipoint <- as.raw(c(0x01, 0x04, 0x00, 0x00, 0x00, 0x04, 0x00,
                         0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x00, 0x24, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x44,
                         0x40, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x44, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x40,
                         0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x34, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x40, 0x01,
                         0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e,
                         0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x40))

  expect_identical(
    wkt_translate_wkb("MULTIPOINT ((10 40), (40 30), (20 20), (30 10))", endian = 1L),
    list(multipoint)
  )
})

test_that("wkt_translate_wkb() works with nested collections", {

  wkt <-
    "GEOMETRYCOLLECTION (
    POINT (40 10),
    LINESTRING (10 10, 20 20, 10 40),
    POLYGON ((40 40, 20 45, 45 30, 40 40)),
    GEOMETRYCOLLECTION (
      POINT (40 10),
      LINESTRING (10 10, 20 20, 10 40),
      POLYGON ((40 40, 20 45, 45 30, 40 40))
    ),
    GEOMETRYCOLLECTION EMPTY,
    POINT (30 10)
  )"

  collection <- as.raw(c(0x01, 0x07, 0x00, 0x00, 0x00, 0x06, 0x00,
                         0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x00, 0x44, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24,
                         0x40, 0x01, 0x02, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x40, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x00, 0x24, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34,
                         0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x40, 0x00, 0x00,
                         0x00, 0x00, 0x00, 0x00, 0x24, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x44, 0x40, 0x01, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
                         0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x44, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x44, 0x40, 0x00,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x40, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x80, 0x46, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x46,
                         0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x40, 0x00, 0x00,
                         0x00, 0x00, 0x00, 0x00, 0x44, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x44, 0x40, 0x01, 0x07, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00,
                         0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x44, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x40,
                         0x01, 0x02, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x00, 0x00, 0x00, 0x24, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x00, 0x24, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x40,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x40, 0x00, 0x00, 0x00,
                         0x00, 0x00, 0x00, 0x24, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x44, 0x40, 0x01, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
                         0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x44,
                         0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x44, 0x40, 0x00, 0x00,
                         0x00, 0x00, 0x00, 0x00, 0x34, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x80, 0x46, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x46, 0x40,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x40, 0x00, 0x00, 0x00,
                         0x00, 0x00, 0x00, 0x44, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x44, 0x40, 0x01, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x3e, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x40))

  expect_identical(wkt_translate_wkb(wkt, endian = 1L), list(collection))
})

test_that("wkt_translate_* has reasonable error messages", {
  # one or more of these expectations fail on CRAN MacOS for R 3.6.2
  # I can't replicate the check failure using a fresh install
  # of R 3.6.2 on MacOS Mojave, but as all of these functions
  # are intended to error anyway, I am skipping this check on
  # CRAN for that platform (with the danger that the errors
  # that are given are less informative than intended).
  is_macos <- Sys.info()["sysname"] == "Darwin"
  is_old_rel <- packageVersion("base") < "4.0.0"
  is_cran <- !identical(Sys.getenv("NOT_CRAN"), "true")
  skip_if(is_macos && is_old_rel && is_cran)

  # close enough to inf to trigger the parse check
  expect_error(wkt_translate_wkt("MULTIPOINT (iambic 3)"), "^Expected")
  expect_error(wkt_translate_wkt(""), "^Expected")
  expect_error(wkt_translate_wkt("SRID=fish;POINT (30 10)"), "^Expected")
  expect_error(wkt_translate_wkt("SRID="), "^Expected")
  expect_error(wkt_translate_wkt("POINT (fish fish)"), "^Expected")
  expect_error(wkt_translate_wkt("POINT ("), "^Expected")
  expect_error(wkt_translate_wkt("POINT (3"), "^Expected")
  expect_error(wkt_translate_wkt("POINT"), "^Expected")
  expect_error(wkt_translate_wkt("POINT "), "^Expected")
  expect_error(wkt_translate_wkt("POINT (30 10="), "^Expected")
  expect_error(wkt_translate_wkt("POINT (30 10)P"), "^Expected")
  expect_error(wkt_translate_wkt("LINESTRING (30 10, 0 0="), "^Expected")
  expect_error(wkt_translate_wkt("LINESTRING (30A"), "^Expected")
  expect_error(wkt_translate_wkt("LINESTRING (30,"), "^Expected")
  expect_error(wkt_translate_wkt("LINESTRING (30"), "^Expected")
  expect_error(wkt_translate_wkt("SRID=30A"), "^Expected")
  expect_error(wkt_translate_wkt("SRID"), "^Expected")
  expect_error(
    wkt_translate_wkt(strrep("a", 4096)),
    "Expected a value with fewer than 4096 character"
  )
})

test_that("wkt_translate_* can handle non-finite values", {
  expect_identical(wkt_translate_wkt("MULTIPOINT (nan nan)"), "MULTIPOINT ((nan nan))")
})

test_that("wkt_translate_* doesn't segfault on other inputs", {
  expect_error(wkt_translate_wkt(as_wkb("POINT (30 10)")), "must be a character vector")
})
