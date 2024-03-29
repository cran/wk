
test_that("wk_transform() works", {
  geoms <- wkt(
    c(
      "POLYGON ((0 0, 0 1, 1 0, 0 0))",
      "POINT (0 0)",
      "POINT Z (0 0 0)",
      "POINT M (0 0 0)",
      "POINT ZM (0 0 0 0)",
      NA
    )
  )

  expect_identical(
    wk_transform(geoms, wk_affine_translate(1, 2)),
    wkt(
      c(
        "POLYGON ((1 2, 1 3, 2 2, 1 2))",
        "POINT (1 2)",
        "POINT Z (1 2 0)",
        "POINT M (1 2 0)",
        "POINT ZM (1 2 0 0)",
        NA
      )
    )
  )

  # check error propagation
  expect_error(wk_transform(new_wk_wkt("POINT ENTPY"), wk_affine_identity()), "ENTPY")


})

test_that("wk_transform_filter() errors when the recursion limit is too high", {
  make_really_recursive_geom <- function(n) {
    wkt(paste0(
      c(rep("GEOMETRYCOLLECTION (", n), "POINT (0 1)", rep(")", n)),
      collapse = ""
    ))
  }

  # errors in geometry_start
  expect_error(
    wk_handle(
      make_really_recursive_geom(32),
      wk_transform_filter(wk_void_handler(), wk_affine_identity())
    ),
    "Too many recursive levels"
  )
})
