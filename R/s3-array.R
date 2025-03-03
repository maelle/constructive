#' @export
construct_idiomatic.array <- function(x, ...) {
  dim <- attr(x, "dim")
  dimnames <- attr(x, "dimnames")
  dim_names_lst <- if (!is.null(dimnames)) list(dimnames = dimnames)
  attr(x, "dim") <- NULL
  attr(x, "dimnames") <- NULL
  construct_apply(
    c(list(x, dim = dim), dim_names_lst),
    fun = "array",
    ...,
    new_line = TRUE
  )
}

#' @export
repair_attributes.array <- function(x, code, ..., pipe ="base") {
  repair_attributes_impl(
    x, code, ...,
    pipe = pipe,
    ignore = c("dim")
  )
}
