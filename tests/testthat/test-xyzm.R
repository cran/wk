
test_that("wk_xy class works", {
  expect_s3_class(xy(), "wk_xy")
  expect_output(print(xy(1, 2)), "\\(1 2\\)")
  expect_identical(xy_dims(xy()), c("x", "y"))

  expect_identical(as_xy(xy()), xy())
  expect_identical(as_xy(xy(), dims = NULL), xy())
  expect_identical(as_xy(xy(), dims = c("x", "y")), xy())
  expect_identical(as_xy(xy(), dims = c("x", "y", "z")), xyz())
  expect_identical(as_xy(xy(), dims = c("x", "y", "m")), xym())
  expect_identical(as_xy(xy(), dims = c("x", "y", "z", "m")), xyzm())

  expect_identical(as_xy(xy(1, 2), dims = NULL), xy(1, 2))
  expect_identical(as_xy(xy(1, 2), dims = c("x", "y")), xy(1, 2))
  expect_identical(as_xy(xy(1, 2), dims = c("x", "y", "z")), xyz(1, 2, NA))
  expect_identical(as_xy(xy(1, 2), dims = c("x", "y", "m")), xym(1, 2, NA))
  expect_identical(as_xy(xy(1, 2), dims = c("x", "y", "z", "m")), xyzm(1, 2, NA, NA))
})

test_that("wk_xyz class works", {
  expect_s3_class(xyz(), "wk_xyz")
  expect_s3_class(xyz(), "wk_xy")
  expect_output(print(xyz(1, 2, 3)), "Z \\(1 2 3\\)")
  expect_identical(xy_dims(xyz()), c("x", "y", "z"))

  expect_identical(as_xy(xyz()), xyz())
  expect_identical(as_xy(xyz(), dims = NULL), xyz())
  expect_identical(as_xy(xyz(), dims = c("x", "y")), xy())
  expect_identical(as_xy(xyz(), dims = c("x", "y", "z")), xyz())
  expect_identical(as_xy(xyz(), dims = c("x", "y", "m")), xym())
  expect_identical(as_xy(xyz(), dims = c("x", "y", "z", "m")), xyzm())

  expect_identical(as_xy(xyz(1, 2, 3), dims = NULL), xyz(1, 2, 3))
  expect_identical(as_xy(xyz(1, 2, 3), dims = c("x", "y")), xy(1, 2))
  expect_identical(as_xy(xyz(1, 2, 3), dims = c("x", "y", "z")), xyz(1, 2, 3))
  expect_identical(as_xy(xyz(1, 2, 3), dims = c("x", "y", "m")), xym(1, 2, NA))
  expect_identical(as_xy(xyz(1, 2, 3), dims = c("x", "y", "z", "m")), xyzm(1, 2, 3, NA))
})

test_that("wk_xym class works", {
  expect_s3_class(xym(), "wk_xym")
  expect_s3_class(xym(), "wk_xy")
  expect_output(print(xym(1, 2, 3)), "M \\(1 2 3\\)")
  expect_identical(xy_dims(xym()), c("x", "y", "m"))

  expect_identical(as_xy(xym()), xym())
  expect_identical(as_xy(xym(), dims = NULL), xym())
  expect_identical(as_xy(xym(), dims = c("x", "y")), xy())
  expect_identical(as_xy(xym(), dims = c("x", "y", "z")), xyz())
  expect_identical(as_xy(xym(), dims = c("x", "y", "m")), xym())
  expect_identical(as_xy(xym(), dims = c("x", "y", "z", "m")), xyzm())

  expect_identical(as_xy(xym(1, 2, 3), dims = NULL), xym(1, 2, 3))
  expect_identical(as_xy(xym(1, 2, 3), dims = c("x", "y")), xy(1, 2))
  expect_identical(as_xy(xym(1, 2, 3), dims = c("x", "y", "z")), xyz(1, 2, NA))
  expect_identical(as_xy(xym(1, 2, 3), dims = c("x", "y", "m")), xym(1, 2, 3))
  expect_identical(as_xy(xym(1, 2, 3), dims = c("x", "y", "z", "m")), xyzm(1, 2, NA, 3))
})

test_that("wk_xyzm class works", {
  expect_s3_class(xyzm(), "wk_xyzm")
  expect_s3_class(xyzm(), "wk_xyz")
  expect_s3_class(xyzm(), "wk_xym")
  expect_s3_class(xyzm(), "wk_xy")
  expect_output(print(xyzm(1, 2, 3, 4)), "ZM \\(1 2 3 4\\)")
  expect_identical(xy_dims(xyzm()), c("x", "y", "z", "m"))

  expect_identical(as_xy(xyzm()), xyzm())
  expect_identical(as_xy(xyzm(), dims = NULL), xyzm())
  expect_identical(as_xy(xyzm(), dims = c("x", "y")), xy())
  expect_identical(as_xy(xyzm(), dims = c("x", "y", "z")), xyz())
  expect_identical(as_xy(xyzm(), dims = c("x", "y", "m")), xym())
  expect_identical(as_xy(xyzm(), dims = c("x", "y", "z", "m")), xyzm())

  expect_identical(as_xy(xyzm(1, 2, 3, 4), dims = NULL), xyzm(1, 2, 3, 4))
  expect_identical(as_xy(xyzm(1, 2, 3, 4), dims = c("x", "y")), xy(1, 2))
  expect_identical(as_xy(xyzm(1, 2, 3, 4), dims = c("x", "y", "z")), xyz(1, 2, 3))
  expect_identical(as_xy(xyzm(1, 2, 3, 4), dims = c("x", "y", "m")), xym(1, 2, 4))
  expect_identical(as_xy(xyzm(1, 2, 3, 4), dims = c("x", "y", "z", "m")), xyzm(1, 2, 3, 4))
})

test_that("wk_xy* are vctrs", {
  expect_true(vctrs::vec_is(xy()))
  expect_true(vctrs::vec_is(xyz()))
  expect_true(vctrs::vec_is(xym()))
  expect_true(vctrs::vec_is(xyzm()))
})

test_that("wk_xy* vectors can be constructed from matrices/data.frames", {
  expect_identical(as_xy(data.frame(x = 1, y = 2, z = 3, m = 4), dims = NULL), xyzm(1, 2, 3, 4))
  expect_identical(as_xy(data.frame(x = 1, y = 2, z = 3, m = 4), dims = c("x", "y")), xy(1, 2))
  expect_identical(as_xy(data.frame(x = 1, y = 2, z = 3, m = 4), dims = c("x", "y", "z")), xyz(1, 2, 3))
  expect_identical(as_xy(data.frame(x = 1, y = 2, z = 3, m = 4), dims = c("x", "y", "m")), xym(1, 2, 4))
  expect_identical(as_xy(data.frame(x = 1, y = 2, z = 3, m = 4), dims = c("x", "y", "z", "m")), xyzm(1, 2, 3, 4))

  expect_identical(as_xy(data.frame(x = 1, y = 2), dims = NULL), xy(1, 2))
  expect_identical(as_xy(data.frame(x = 1, y = 2), dims = c("x", "y")), xy(1, 2))
  expect_identical(as_xy(data.frame(x = 1, y = 2), dims = c("x", "y", "z")), xyz(1, 2, NA))
  expect_identical(as_xy(data.frame(x = 1, y = 2), dims = c("x", "y", "m")), xym(1, 2, NA))
  expect_identical(as_xy(data.frame(x = 1, y = 2), dims = c("x", "y", "z", "m")), xyzm(1, 2, NA, NA))

  expect_error(as_xy(data.frame(x = 1, y = 2), dims = "L"), "Unknown dims")

  expect_identical(
    as_xy(as.matrix(data.frame(x = 1, y = 2, z = 3, m = 4))),
    xyzm(1, 2, 3, 4)
  )
  expect_identical(
    as_xy(matrix(1:2, nrow = 1)),
    xy(1, 2)
  )
  expect_identical(
    as_xy(matrix(1:3, nrow = 1)),
    xyz(1, 2, 3)
  )
  expect_identical(
    as_xy(matrix(1:4, nrow = 1)),
    xyzm(1, 2, 3, 4)
  )

  expect_identical(
    as_xy(matrix(1:2, nrow = 1, dimnames = list(NULL, c("x", "y")))),
    xy(1, 2)
  )
  expect_identical(
    as_xy(matrix(1:3, nrow = 1, dimnames = list(NULL, c("x", "y", "m")))),
    xym(1, 2, 3)
  )

  expect_error(as_xy(matrix(1:10, nrow = 1)), "Can't guess dimensions")

  weird_matrix <- matrix(1:9, ncol = 3)
  colnames(weird_matrix) <- c("tim", "suzie", "bill")
  expect_error(as_xy(weird_matrix), "Can't guess dimensions")
  colnames(weird_matrix) <- c("x", "y", "bill")
  expect_identical(as_xy(weird_matrix), xy(1:3, 4:6))
})

test_that("wk_xy* vectors can be created from data.frames with handleable columns", {
  expect_identical(
    as_xy(data.frame(geom = xy(1, 2, crs = 1234))),
    xy(1, 2, crs = 1234)
  )

  expect_error(
    as_xy(data.frame(geom = xy(1, 2)), crs = 1234),
    "missing\\(crs\\) is not TRUE"
  )

  expect_identical(
    as_xy(data.frame(geom = xy(1, 2, crs = 1234)), dims = c("x", "y", "z")),
    xyz(1, 2, NA, crs = 1234)
  )
})

test_that("coercion to wk* vectors works", {
  expect_identical(as_wkt(xy(1, 2)), wkt("POINT (1 2)"))
  expect_identical(as_wkb(xy(1, 2)), as_wkb("POINT (1 2)"))
})

test_that("coercion from wk* vectors works", {
  expect_identical(as_xy(wkt("POINT (1 2)")), xy(1, 2))
  expect_identical(as_xy(wkt("POINT Z (1 2 3)")), xyz(1, 2, 3))
  expect_identical(as_xy(wkt("POINT M (1 2 4)")), xym(1, 2, 4))
  expect_identical(as_xy(wkt("POINT ZM (1 2 3 4)")), xyzm(1, 2, 3, 4))
  expect_identical(as_xy(wkt("POINT (1 2)"), dims = c("x", "y", "z", "m")), xyzm(1, 2, NA, NA))

  expect_identical(as_xy(as_wkb("POINT (1 2)")), xy(1, 2))

  expect_error(as_xy(wkt("POINT (1 2)"), dims = "L"), "Unknown dims")
})

test_that("subset-assign works for wk_xy", {
  x <- xyzm(1:2, 2, 3, 4)
  x[2] <- xy(10, 20)
  expect_identical(x[2], xyzm(10, 20, NA, NA))
  x[2:3] <- xy(11:12, 21:22)
  expect_identical(x[2:3], xyzm(11:12, 21:22, NA, NA))

  x[[2]] <- xy(11, 21)
  expect_identical(x[2], xyzm(11, 21, NA, NA))
})

test_that("is.na() returns FALSE for EMPTY xy()", {
  expect_identical(
    is.na(as_xy(wkt(c("POINT EMPTY", NA, "POINT (0 1)")))),
    c(FALSE, TRUE, FALSE)
  )
})

test_that("xy() propagates CRS", {
  x <- xy(1, 2)
  wk_crs(x) <- 1234

  expect_identical(wk_crs(x[1]), 1234)
  expect_identical(wk_crs(c(x, x)), 1234)
  expect_identical(wk_crs(rep(x, 2)), 1234)

  expect_error(x[1] <- wk_set_crs(x, NULL), "are not equal")
  x[1] <- wk_set_crs(x, 1234L)
  expect_identical(wk_crs(x), 1234)
})

test_that("as_xy() works for geodesic objects", {
  expect_identical(as_xy(wkt("POINT (0 1)", geodesic = TRUE)), xy(0, 1))
  expect_identical(as_xy(as_wkb(wkt("POINT (0 1)", geodesic = TRUE))), xy(0, 1))
})

test_that("xy_(xyzm)() return the correct components", {
  x <- xyz(1:5, 6:10, 11:15)
  expect_identical(xy_x(x), as.double(1:5))
  expect_identical(xy_y(x), as.double(6:10))
  expect_identical(xy_z(x), as.double(11:15))
  expect_null(xy_m(x))
})
