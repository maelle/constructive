% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/construct.R
\name{construct}
\alias{construct}
\alias{construct_multi}
\title{Build code to recreate an object}
\usage{
construct(
  x,
  ...,
  data = NULL,
  pipe = c("base", "magrittr"),
  check = NULL,
  ignore_srcref = TRUE,
  ignore_attr = FALSE,
  ignore_function_env = FALSE,
  ignore_formula_env = FALSE,
  one_liner = FALSE,
  template = getOption("constructive_opts_template")
)

construct_multi(
  x,
  ...,
  data = NULL,
  pipe = c("base", "magrittr"),
  check = NULL,
  ignore_srcref = TRUE,
  ignore_attr = FALSE,
  ignore_function_env = FALSE,
  ignore_formula_env = FALSE,
  one_liner = FALSE,
  template = getOption("constructive_opts_template")
)
}
\arguments{
\item{x}{An object, for \code{construct_multi()} a named list or an environment.}

\item{...}{Constructive options built with the \verb{opts_*()} family of functions. See the "Constructive options"
section below.}

\item{data}{named list of objects we don't want to deparse, can also be a package
name and its namespace and datasets will be used to look for objects. Both can
be combined so you can provide a list of named objects and unnamed namespaces.}

\item{pipe}{Which pipe to use, either "base" or "magrittr"}

\item{check}{Boolean. Whether to check if the created code reproduces the object
using \code{waldo::compare()}}

\item{ignore_srcref, ignore_attr, ignore_function_env, ignore_formula_env}{passed to \code{waldo::compare()}}

\item{one_liner}{Boolean. Whether to collapse the output to a single line of code.}

\item{template}{A list of constructive options build with \verb{opts_*()} functions,
they will be overriden by \code{...}. This is designed to help users set a default
behavior for \code{{constructive}}.}
}
\value{
An object of class 'constructive'
}
\description{
\code{construct()} builds the code to reproduce one object, \code{construct_multi()}
builds the code to reproduce objects stored in a named list or environment.
}
\section{Constructive options}{
Constructive options provide a way to customize the output of `construct()`.
We can provide calls to `opts_*()` functions to the `...` argument. Each of these functions targets a specific element type and is documented on its own page.

\itemize{
  \item \code{\link[=opts_Date]{opts_Date}(constructor = c("as.Date", "as_date", "date", "new_date", "as.Date.numeric", "as_date.numeric"), ..., origin = "1970-01-01")}
  \item \code{\link[=opts_POSIXct]{opts_POSIXct}(constructor = c("as.POSIXct", ".POSIXct", "as_datetime", "as.POSIXct.numeric", "as_datetime.numeric"), ..., origin = "1970-01-01")}
  \item \code{\link[=opts_atomic]{opts_atomic}(..., trim = NULL, fill = c("default", "rlang", "+", "...", "none"))}
  \item \code{\link[=opts_data.frame]{opts_data.frame}(constructor = c("data.frame", "read.table", "list"), ...)}
  \item \code{\link[=opts_data.table]{opts_data.table}(constructor = c("data.table", "list"), ...)}
  \item \code{\link[=opts_environment]{opts_environment}(constructor = c("env", "list2env", "as.environment", "new.env", "topenv", "new_environment"), ..., recurse = FALSE, predefine = FALSE)}
  \item \code{\link[=opts_factor]{opts_factor}(constructor = c("factor", "as_factor", "new_factor"), ...)}
  \item \code{\link[=opts_formula]{opts_formula}(constructor = c("~", "formula", "as.formula", "new_formula"), ..., environment = constructor != "~")}
  \item \code{\link[=opts_function]{opts_function}(constructor = c("function", "as.function", "new_function"), ..., environment = TRUE, srcref = FALSE, trim = NULL)}
  \item \code{\link[=opts_list]{opts_list}(constructor = c("list", "list2"), ..., trim = NULL, fill = c("vector", "new_list", "+", "...", "none"))}
  \item \code{\link[=opts_ordered]{opts_ordered}(constructor = c("ordered", "factor", "new_ordered"), ...)}
  \item \code{\link[=opts_tbl_df]{opts_tbl_df}(constructor = c("tibble", "tribble", "list"), ..., trailing_comma = TRUE)}
  \item \code{\link[=opts_vctrs_list_of]{opts_vctrs_list_of}(constructor = c("list_of", "list"), ...)}
}
}

