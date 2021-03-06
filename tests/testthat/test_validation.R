context("Validation sets")

library(testthat)
library(rsample)
library(purrr)

dat1 <- data.frame(a = 1:20, b = letters[1:20])

test_that('default param', {
  set.seed(11)
  rs1 <- validation_split(dat1)
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis == 15))
  expect_true(all(sizes1$assessment == 5))
  same_data <-
    map_lgl(rs1$splits, function(x)
      all.equal(x$data, dat1))
  expect_true(all(same_data))

  good_holdout <- map_lgl(rs1$splits,
                          function(x) {
                            length(intersect(x$in_ind, x$out_id)) == 0
                          })
  expect_true(all(good_holdout))
})

test_that('different percent', {
  set.seed(11)
  rs2 <- validation_split(dat1, prop = .5)
  sizes2 <- dim_rset(rs2)

  expect_true(all(sizes2$analysis == 10))
  expect_true(all(sizes2$assessment == 10))
  same_data <-
    map_lgl(rs2$splits, function(x)
      all.equal(x$data, dat1))
  expect_true(all(same_data))

  good_holdout <- map_lgl(rs2$splits,
                          function(x) {
                            length(intersect(x$in_ind, x$out_id)) == 0
                          })
  expect_true(all(good_holdout))
})

test_that('strata', {
  iris2 <- iris[1:130, ]
  set.seed(11)
  rs3 <- validation_split(iris2, strata = "Species")
  sizes3 <- dim_rset(rs3)

  expect_true(all(sizes3$analysis == 99))
  expect_true(all(sizes3$assessment == 31))

  rate <- map_dbl(rs3$splits,
                  function(x) {
                    dat <- as.data.frame(x)$Species
                    mean(dat == "virginica")
                  })
  expect_true(length(unique(rate)) == 1)

  good_holdout <- map_lgl(rs3$splits,
                          function(x) {
                            length(intersect(x$in_ind, x$out_id)) == 0
                          })
  expect_true(all(good_holdout))
})


test_that('bad args', {
  expect_error(validation_split(iris, strata = iris$Species))
  expect_error(validation_split(iris, strata = c("Species", "Sepal.Length")))
})


test_that('printing', {
  expect_output(print(validation_split(iris)), "Validation Set Split")
})


test_that('printing', {
  expect_output(print(validation_split(iris)$splits[[1]]), "Training/Validation/Total")
})

test_that('rsplit labels', {
  rs <- validation_split(mtcars)
  all_labs <- map_df(rs$splits, labels)
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})

