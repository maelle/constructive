test_that("quosure", {
  expect_snapshot(construct(rlang::new_quosure(quote(x)), opts_environment("list2env")))
})
