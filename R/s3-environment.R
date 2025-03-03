#' Constructive options for type 'environment'
#'
#' @details
#' Environments use reference semantics, they cannot be copied.
#' An attempt to copy an environment would indeed yield a different environment and `identical(env, copy)` would be `FALSE`.\cr
#' Moreover every environment (except for `emptyenv()`) has a
#' parent and thus to copy the environment we'd have to have a way to point to
#' the parent, or copy it too.\cr
#' For this reason environments are {constructive}'s cryptonite. They make some objects
#' impossible to reproduce exactly. And since every function or formula has one they're hard to
#' avoid \cr
#'
#' In some case we can build code that points to a specific environment, namely:
#' * `.GlobalEnv`, `.BaseNamespaceEnv`, `baseenv()` and `emptyenv()` are used to construct
#'   the global environment, the base namespace, the base package environment and the empty
#'   environment
#' * Namespaces are constructed using `asNamespace("pkg")`
#' * Package environments are constructed using `as.environment("package:pkg")`
#'
#' By default For other environments we use {constructive}'s function `constructive::env()`, it fetches
#'   the environment from its memory address and provides as additional information
#'   the sequence of parents until we reach a special environment (those enumerated above).
#'   The advantage of this approach is that it's readable and that the object is accurately reproduced.
#'   Inconvenient is that it's not stable between sessions.
#'
#' Often however we wish to be able to reproduce from scratch a similar environment,
#' so that we might run the constructed code later in a new session. We offer different
#' different options to do this, with different trade-offs regarding accuracy and verbosity.
#' We might set the `constructor` argument to:
#'
#' * `"list2env"`: We construct the environment as a list then
#'   use `base::list2env()` to convert it to an environment and assign it a parent. By
#'   default we will use `base::topenv()` to construct a parent. If `recurse` is `TRUE`
#'   the parent will be built recursively so all ancestors will be created until
#'   we meet a known environment, this might be verbose and will fail if environments
#'   are nested too deep or have a circular relationship. If the environment is empty we use `new.env(parent=)`
#'   for a more economic syntax.
#' * `"new_environment"` : Similar to the above, but using `rlang::new_environment()`.
#' * `"new.env"` : All environments will be recreated with the code `"base::new.env()"`,
#'   without argument, effectively creating an empty environment child of
#'   the local (often global) environment. This is enough in cases where the environment
#'   doesn't matter (or matters as long as it inherits from the local environment),
#'   as is often the case with formulas. `recurse` is ignored.
#' * `"as.environment"` : we attempt to construct the environment as a list and use
#' `base::as.environment()` on top of it, as in `as.environment(list(a=1, b=2))`, it will
#'  contain the same variables as the original environment but the parent will be the
#'  `emptyenv()`. `recurse` is ignored.
#' * `"topenv"` : we construct `base::topenv(x)`, see `?topenv`. `recurse` is ignored.
#'   This is the most accurate we can be when constructing only special environments.
#'
#' {constructive} will not signal any difference if it can reproduce an equivalent environment,
#' defined as containing the same values and having a same or equivalent parent.\cr
#'
#' Building environments from scratch using the above methods can be verbose and
#' sometimes redundant if and environment is used several time. One last option
#' is to define the environments and their content above the object returning call,
#' using placeholder names `..env.1..`, `..env.2..` etc. This is done by setting
#' `predefine` to `TRUE`. `constructor` and `recurse` are ignored in that case.
#'
#' See also the `ignore_function_env` argument in `?construct`, which disables the check
#' of environments of function.
#'
#' @param constructor String. Name of the function used to construct the environment, see Details section.
#' @inheritParams opts_atomic
#' @param recurse Boolean. Only considered if `constructor` is `"list2env"` or `"new_environment"`. Whether to
#'   attempt to recreate all parent environments until a known environment is found,
#'   if `FALSE` (the default) we will use `topenv()` to find a known ancestor to set as
#'   the parent.
#' @param predefine Boolean. Whether to define environments first. If `TRUE` `constructor` and `recurse`
#'   are ignored. It circumvents the circularity, recursivity and redundancy issues of
#'   other constructors. The caveat is that the created code won't be a single call
#'   and will create objects in the workspace.
#'
#' @return An object of class <constructive_options/constructive_options_environment>
#' @export
opts_environment <- function(constructor = c("env", "list2env", "as.environment", "new.env", "topenv", "new_environment"), ..., recurse = FALSE, predefine = FALSE) {
  combine_errors(
    constructor <- rlang::arg_match(constructor),
    ellipsis::check_dots_empty(),
    abort_not_boolean(recurse)
  )

  structure(
    class = c("constructive_options", "constructive_options_environment"),
    list(constructor = constructor, recurse = recurse, predefine = predefine)
  )
}

#' @export
construct_idiomatic.environment <- function(x, ..., pipe = "base", one_liner = FALSE) {
  # The name of `asNamespace("pkg")` is always "pkg" and print as `<environment: namespace:pkg>`
  # The name of `as.environment("package:pkg")` is ALMOST always "package:pkg" and prints as
  #  `<environment: package:pkg>` + attributes
  # The exception is `as.environment("package:base")` which prints as
  #   `<environment: base>` and whose name is "base"
  # This means `asNamespace("base")` (a.k.a. `.BaseNamespaceEnv`) and
  #   `as.environment("package:base")` (a.k.a. `baseenv()`) have the same name
  #   but are different. So we implement a workaround.
  opts <- fetch_opts("environment", ...)
  constructor <- opts$constructor
  recurse <- opts$recurse
  predefine <- opts$predefine

  if (predefine) {
    globals$special_envs <-  c(row.names(installed.packages()), search(), "R_EmptyEnv", "R_GlobalEnv")
    # construct only if not found
    if (!environmentName(x) %in% globals$special_envs) {
      code <- update_predefinition(x, ..., pipe = pipe, one_liner = one_liner)
      return(code)
    }
  }


  if (identical(x, baseenv())) return('baseenv()')
  if (identical(x, emptyenv())) return('emptyenv()')
  if (identical(x, .GlobalEnv)) return(".GlobalEnv")
  if (identical(x, .BaseNamespaceEnv)) return(".BaseNamespaceEnv")
  # testing on name is not enough but we use it to identify candidated
  name <- environmentName(x)
  # handle {testthat} corner case
  if (identical(Sys.getenv("TESTTHAT"), "true") && name == "constructive") return('asNamespace("constructive")')
  if (name %in% row.names(installed.packages()) && identical(x, asNamespace(name))) return(sprintf('asNamespace("%s")', name))
  if (name %in% search() && identical(x, as.environment(name))) return(sprintf('as.environment("%s")', name))

  if (constructor == "env") {
    res <- construct_apply(
      list(env_memory_address(x), parents = fetch_parent_names(x)),
      "constructive::env",
      ..., pipe = pipe, one_liner = one_liner
    )
    return(res)
  }

  if (constructor %in% c("list2env", "new_environment")) {
    constructor <- switch(
      constructor,
      list2env = "list2env",
      new_environment = "rlang::new_environment"
    )

    if (!recurse) {
      if (length(names(x))) {
        code <- construct_apply(list(as.list.environment(x), parent = topenv(x)), constructor, ..., pipe = pipe, one_liner = one_liner)
        return(code)
      }
      if (constructor == "list2env") constructor <- "new.env"
      code <- construct_apply(list(parent = topenv(x)), constructor, ..., pipe = pipe, one_liner = one_liner)
      return(code)
    }

    place_holder = c(base = "_", magrittr = ".")[pipe]
    lhs_code <- construct_raw(parent.env(x), ..., pipe = pipe, one_liner = one_liner)
    if (length(names(x))) {
      data_code <- construct_raw(as.list.environment(x), ..., pipe = pipe, one_liner = one_liner)
      rhs_code <- construct_apply(list(data_code, parent = place_holder), constructor, ..., language = TRUE, pipe = pipe, one_liner = one_liner)
      code <- pipe(lhs_code, rhs_code, pipe = pipe, one_liner = one_liner)
    } else {
      if (constructor == "list2env") constructor <- "new.env"
      rhs_code <- construct_apply(list(parent = place_holder), constructor, ..., language = TRUE, pipe = pipe, one_liner = one_liner)
      code <- pipe(lhs_code, rhs_code, pipe = pipe, one_liner = one_liner)
    }
    return(code)
  }

  if (constructor == "new.env") return("new.env()")

  if (constructor == "as.environment") {
    # We need to use as.list.environment directly because as.list will only map
    # to "as.list.environment" if class was not overriden
    code <- wrap(
      construct_raw(as.list.environment(x), ..., pipe = pipe, one_liner = one_liner),
      "as.environment",
      new_line = FALSE
    )
    return(code)
  }

  # constructor == "topenv"
  construct_raw(topenv(x), ...,  pipe = pipe, one_liner = one_liner)
}

#' @export
repair_attributes.environment <- function(x, code, ..., pipe ="base") {
  opts <- fetch_opts("environment", ...)
  constructor <- opts$constructor
  if (constructor == "env" ||
      grepl("^asNamespace\\(\"[^\"]+\"\\)", code) ||
      code %in% c("baseenv()", "emptyenv()", ".GlobalEnv", ".BaseNamespaceEnv")
  ) {
    # nothing to repair
    return(code)
  }

  pkg_env_lgl <- grepl("as.environment\\(\"[^\"]+\"\\)", code[[1]])
  repair_attributes_impl(
    x, code, ...,
    pipe = pipe,
    ignore = c(
      # pkg:fun envs have name and path attributes already set by `as.environment()`
      if (pkg_env_lgl) c("name", "path"),
      if (opts$predefine) "class"
    )
  )
}

env_memory_address <- function(x) {
  sub("<environment: (.*)>", "\\1", capture.output(print.default(x))[[1]])
}

# adapted from rlang::env_name
env_name <- function (env) {
  if (identical(env, global_env())) {
    return("global")
  }
  if (identical(env, base_env())) {
    return("package:base")
  }
  if (identical(env, empty_env())) {
    return("empty")
  }
  nm <- environmentName(env)
  if (isNamespace(env)) {
    return(paste0("namespace:", nm))
  }
  nm
}

fetch_parent_names <- function(x) {
  parents <- character()
  repeat {
    x <- parent.env(x)
    nm <- env_name(x)
    if (nm != "") {
      return(c(parents, nm))
    }
    nm <- env_memory_address(x)
    parents <- c(parents, nm)
  }
}

#' Fetch environment from memory address
#'
#' This is designed to be used in constructed output. The `parents` argument is not processed
#'  and only used to display additional information. If used on an improper memory address
#'  the output might be erratic or the session might crash.
#'
#' @param address Memory adress of the environment
#' @param parents ignored
#' @export
env <- function(address, parents = NULL) {
  force(parents) # to avoid notes
  env_impl(address)
}

update_predefinition <- function(env, ...) {
  # construct parent before constructing env
  parent_code <- construct_raw(parent.env(env), ...)
  # if env was already constructed (recorded in globals$env), just return its name
  hash <- format(env)
  if (hash %in% globals$envs$hash) {
    return(globals$envs$name[hash == globals$envs$hash][[1]])
  }
  # create a new name, incrementing count
  env_name <- sprintf("..env.%s..", nrow(globals$envs) + 1)
  # update globals$envs with new row (hash + variable name)
  globals$envs <- rbind(globals$envs, data.frame(hash = hash, name = env_name))
  # initialize with new.env(), repairing attributes
  code <- sprintf("new.env(parent = %s)", parent_code)
  # hack: we use  opts_environment(predefine = FALSE) to switch on attribute reparation just there
  code <- repair_attributes.environment(env, code, opts_environment(predefine = FALSE), ...)
  code[[1]] <- sprintf("%s <- %s", env_name, code[[1]])
  # update predefinitions with env definition
  globals$predefinition <- c(
    globals$predefinition,
    code
  )
  # build non environment objects of env above
  for(nm in names(env)) {
    obj <- env[[nm]]
    if (missing(obj)) {
      obj_code <- sprintf("%s$%s <- quote(expr=)", env_name, nm)
      globals$predefinition <- c(
        globals$predefinition,
        obj_code
      )
    } else if (!is.environment(obj)) {
      nm <- protect(nm)
      # this defines the objects as a side effect
      obj_code <- construct_raw(obj, ...)
      obj_code[[1]] <- sprintf("%s$%s <- %s", env_name, nm, obj_code[[1]])
      globals$predefinition <- c(
        globals$predefinition,
        obj_code
      )
    }
  }

  # build environment objects of env above
  for(nm in names(env)) {
    obj <- env[[nm]]
    if (missing(obj)) {
      obj_code <- sprintf("%s$%s <- quote(expr=)", env_name, nm)
      globals$predefinition <- c(
        globals$predefinition,
        obj_code
      )
    } else if (is.environment(obj)) {
      nm <- protect(nm)
      sub_env_name <- construct_raw(obj, ...) # this will also print code
      globals$predefinition <- c(
        globals$predefinition,
        sprintf("%s$%s <- %s", env_name, nm, sub_env_name)
      )
    }
  }
  env_name
}
