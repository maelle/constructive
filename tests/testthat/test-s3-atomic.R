test_that("numeric", {
  expect_snapshot({
    # by default no scientific notation
    construct(10000)
    # by default scientific notation
    construct(100000)
    # not truncated
    construct(.1000000000000001)
    # truncated
    construct(.10000000000000001)
    # by default scientific notation
    construct(.0000000000000011)
    # trim
    construct(c(1, 2, 3), opts_atomic(trim = 0))
    construct(c(1, 2, 3), opts_atomic(trim = 1))
    construct(c(1, 2, 3), opts_atomic(trim = 2))
    construct(c(1, 2, 3), opts_atomic(trim = 1, fill = "rlang"))
    construct(c(1, 2, 3), opts_atomic(trim = 1, fill = "+"))
    construct(c(1, 2, 3), opts_atomic(trim = 1, fill = "..."))
    construct(c(1, 2, 3), opts_atomic(trim = 1, fill = "none"))
    # don't print useless extra digits (thanks to format(x, digits = 15))
    construct(0.07)
    construct(NA_real_)
    construct(c(1, NA_real_))
    # one_liner
    construct(c(0, 1:30))
    construct(c(0, 1:30), one_liner = TRUE)
    # empty names
    construct(structure("a", names = ""))
  })
})

test_that("other atomic", {
  expect_snapshot({
    construct(letters)
    construct(letters, one_liner = TRUE)
    construct(letters, opts_atomic(trim = 1, fill = "rlang"))
    construct(letters, opts_atomic(trim = 1, fill = "+"))
    construct(letters, opts_atomic(trim = 1, fill = "..."))
    construct(letters, opts_atomic(trim = 1, fill = "none"))
  })
})
