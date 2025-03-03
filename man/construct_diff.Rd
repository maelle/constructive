% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/construct_diff.R
\name{construct_diff}
\alias{construct_diff}
\title{Display diff of object definitions}
\usage{
construct_diff(
  target,
  current,
  ...,
  data = NULL,
  pipe = c("base", "magrittr"),
  check = TRUE,
  ignore_srcref = TRUE,
  ignore_attr = FALSE,
  ignore_function_env = FALSE,
  ignore_formula_env = FALSE,
  one_liner = FALSE,
  template = getOption("constructive_opts_template"),
  mode = c("sidebyside", "auto", "unified", "context"),
  interactive = TRUE
)
}
\arguments{
\item{target}{the reference object}

\item{current}{the object being compared to \code{target}}

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

\item{mode, interactive}{passed to \code{diffobj::diffChr()}}
}
\value{
Returns \code{NULL} invisibly, called for side effects
}
\description{
Display diff of object definitions
}
\examples{
\dontrun{
# some object print the same though they're differemt
# `construct_diff()` shows how they differ :
df1 <- data.frame(a=1, b = "x")
df2 <- data.frame(a=1L, b = "x", stringsAsFactors = TRUE)
attr(df2, "some_attribute") <- "a value"
df1
df2
construct_diff(df1, df2)


# Those are made easy to compare
construct_diff(substr, substring)
construct_diff(month.abb, month.name)

# more examples borrowed from {waldo} package
construct_diff(c("a", "b", "c"), c("a", "B", "c"))
construct_diff(c("X", letters), c(letters, "X"))
construct_diff(list(factor("x")), list(1L))
construct_diff(df1, df2)
x <- list(a = list(b = list(c = list(structure(1, e = 1)))))
y <- list(a = list(b = list(c = list(structure(1, e = "a")))))
construct_diff(x, y)
}
}
