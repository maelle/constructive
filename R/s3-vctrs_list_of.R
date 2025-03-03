#' Constructive options for class 'data.table'
#'
#' These options will be used on objects of class 'data.table'.
#'
#' Depending on `constructor`, we construct the object as follows:
#' * `"list_of"` (default): Wrap the column definitions in a `list_of()` call.
#' * `"list"` : Use `list()` and treat the class as a regular attribute.
#'
#' @param constructor String. Name of the function used to construct the environment, see Details section.
#' @inheritParams opts_atomic
#' @return An object of class <constructive_options/constructive_options_data.table>
#' @export
opts_vctrs_list_of <- function(constructor = c("list_of", "list"), ...) {
  combine_errors(
    constructor <- rlang::arg_match(constructor),
    ellipsis::check_dots_empty()
  )
  constructive_options("vctrs_list_of", constructor = constructor)
}

#' @export
construct_idiomatic.vctrs_list_of <- function(x, ...) {
  opts <- fetch_opts("vctrs_list_of", ...)
  if (opts$constructor == "list") {
    return(construct_idiomatic.list(x, ...))
  }
  construct_apply(
    args = c(as.list(x), list(.ptype= attr(x, "ptype"))),
    fun = "vctrs::list_of",
    ...
  )
}

#' @export
repair_attributes.vctrs_list_of <- function(x, code, ..., pipe = "base") {
  opts <- fetch_opts("vctrs_list_of", ...)
  if (opts$constructor == "list") {
    return(repair_attributes.default(x, code, ..., pipe = pipe))
  }
  repair_attributes_impl(
    x, code, ...,
    pipe = pipe,
    ignore = "ptype",
    idiomatic_class = c("vctrs_list_of", "vctrs_vctr", "list")
  )
}
