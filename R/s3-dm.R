#' @export
construct_idiomatic.dm <- function(x, pipe = "base", one_liner = FALSE, ...) {
  def <- unclass(x)$def
  named_list_of_tables <- set_names(def$data, def$table)
  code <- construct_apply(
    named_list_of_tables, fun = "dm::dm", keep_trailing_comma = TRUE, implicit_names = TRUE, one_liner = one_liner, ...)

  pk_code <- unlist(Map(
    function(table, pk_tibble) {
      if (!nrow(pk_tibble)) return(character())
      column_code <- construct_raw(pk_tibble$column[[1]], pipe = pipe, one_liner = one_liner, ...)
      paste0("dm::dm_add_pk(", protect(table), ", ", paste(column_code, collapse = "\n") , ")")
    } ,
    def$table,
    def$pks,
    USE.NAMES = FALSE))
  if (length(pk_code)) {
    pk_code <- paste(pk_code, collapse = "|>\n")
    code <- pipe(code, pk_code, pipe, one_liner)
  }

  fk_code <- unlist(Map(
    function(ref_table, fk_tibble) {
      if (!nrow(fk_tibble)) return(character())
      Map(function(table, column, ref_column) {
        paste0(
          "dm::dm_add_fk(",
          protect(table), ", ",
          paste(construct_raw(column, pipe = pipe, one_liner = one_liner, ...), collapse = "\n"), ",",
          protect(ref_table), ", ",
          paste(construct_raw(ref_column, pipe = pipe, one_liner = one_liner, ...), collapse = "\n"), ")"
        )
      },
      fk_tibble$table,
      fk_tibble$column,
      fk_tibble$ref_column
      )
    } ,
    def$table,
    def$fks,
    USE.NAMES = FALSE))
  if (length(fk_code)) {
    fk_code <- paste(fk_code, collapse = "|>\n")
    code <- pipe(code, fk_code, pipe, one_liner)
  }

  colors <- set_names(def$table, def$display)[!is.na(def$display)]
  if (length(colors)) {
    color_code <- construct_apply(colors, "dm::dm_set_colors", pipe = pipe, one_liner = one_liner, ...)
    code <- pipe(code, color_code, pipe, one_liner)
  }

  code
}


#' @export
repair_attributes.dm <- function(x, code, ..., pipe ="base") {
  repair_attributes_impl(
    x, code, ...,
    pipe = pipe,
    idiomatic_class = "dm",
    ignore = c("version")
  )
}
