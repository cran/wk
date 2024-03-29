
test_that("single chunk strategy works", {
  feat <- c(as_wkt(xy(1:4, 1:4)), wkt("LINESTRING (1 1, 2 2)"))
  expect_identical(
    wk_chunk_strategy_single()(list(feat), 5),
    data.frame(from = 1, to = 5)
  )
})

test_that("chunk by feature strategy works", {
  feat <- c(as_wkt(xy(1:4, 1:4)), wkt("LINESTRING (1 1, 2 2)"))
  expect_identical(
    wk_chunk_strategy_feature(chunk_size = 2)(list(feat), 5),
    data.frame(from = c(1, 3, 5), to = c(2, 4, 5))
  )
})

test_that("chunk by coordinates strategy works", {
  n_coord <- c(1, 5, 1, 5, 1)
  xs <- unlist(lapply(n_coord, seq_len))
  ys <- unlist(lapply(n_coord, seq_len))
  id <- vctrs::vec_rep_each(seq_along(n_coord), n_coord)
  feat <- wk_linestring(xy(xs, ys), feature_id = id)

  expect_identical(
    wk_chunk_strategy_coordinates(chunk_size = 6)(list(feat), length(n_coord)),
    data.frame(from = c(1L, 3L, 5L), to = c(2L, 4L, 5L))
  )

  # for points there's a shortcut for calculating the chunks
  expect_identical(
    wk_chunk_strategy_coordinates(chunk_size = 2)(list(xy(1:6, 1:6)), 6),
    data.frame(from = c(1, 3, 5), to = c(2, 4, 6))
  )
})

test_that("chunk_info() works", {
  expect_identical(
    chunk_info(5, chunk_size = 2),
    list(n_chunks = 3, chunk_size = 2)
  )
  expect_identical(
    chunk_info(5, chunk_size = 5),
    list(n_chunks = 1, chunk_size = 5)
  )
  expect_identical(
    chunk_info(0, chunk_size = 5),
    list(n_chunks = 0, chunk_size = 5)
  )

  expect_identical(
    chunk_info(5, n_chunks = 3),
    list(n_chunks = 3, chunk_size = 2)
  )
  expect_identical(
    chunk_info(5, n_chunks = 1),
    list(n_chunks = 1, chunk_size = 5)
  )
  expect_identical(
    chunk_info(0, n_chunks = 5),
    list(n_chunks = 0L, chunk_size = 1L)
  )
  expect_error(chunk_info(1), "exactly one")
  expect_error(chunk_info(1, chunk_size = 1, n_chunks = 1), "exactly one")
})
