% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/s3-environment.R
\name{opts_environment}
\alias{opts_environment}
\title{Constructive options for type 'environment'}
\usage{
opts_environment(
  constructor = c(".env", "list2env", "as.environment", "new.env", "topenv",
    "new_environment", "predefine"),
  ...,
  recurse = FALSE
)
}
\arguments{
\item{constructor}{String. Name of the function used to construct the
environment, see \strong{Constructors} section.}

\item{...}{Additional options used by user defined constructors through the \code{opts} object}

\item{recurse}{Boolean. Only considered if \code{constructor} is \code{"list2env"} or
\code{"new_environment"}. Whether to attempt to recreate all parent environments
until a known environment is found, if \code{FALSE} (the default) we will use
\code{topenv()} to find a known ancestor to set as the parent.}
}
\value{
An object of class <constructive_options/constructive_options_environment>
}
\description{
Environments use reference semantics, they cannot be copied.
An attempt to copy an environment would indeed yield a different environment and \code{identical(env, copy)} would be \code{FALSE}.\cr
Moreover most environments have a parent (exceptions are \code{emptyenv()} and some
rare cases where the parent is \code{NULL}) and thus to copy the environment we'd
have to have a way to point to the parent, or copy it too. \cr
For this reason environments are \pkg{constructive}'s cryptonite. They make some objects
impossible to reproduce exactly. And since every function or formula has one they're hard to
avoid. \cr
}
\details{
In some case we can build code that points to a specific environment, namely:
\itemize{
\item \code{.GlobalEnv}, \code{.BaseNamespaceEnv}, \code{baseenv()} and \code{emptyenv()} are used to construct
the global environment, the base namespace, the base package environment and the empty
environment
\item Namespaces are constructed using \code{asNamespace("pkg")}
\item Package environments are constructed using \code{as.environment("package:pkg")}
\item "imports" environments are constructed with \code{parent.env(asNamespace("pkg"))}
\item "lazydata" environments are constructed with \code{getNamespaceInfo("pkg", "lazydata")}
}

By default For other environments we use \pkg{constructive}'s function \code{constructive::.env()}, it fetches
the environment from its memory address and provides as additional information
the sequence of parents until we reach a special environment (those enumerated above).
The advantage of this approach is that it's readable and that the object is accurately reproduced.
The inconvenient is that it's not stable between sessions. If an environment has a \code{NULL} parent it's always constructed
with \code{constructive::.env()}, whatever the choice of the constructor.

Often however we wish to be able to reproduce from scratch a similar environment,
so that we might run the constructed code later in a new session. We offer different
different options to do this, with different trade-offs regarding accuracy and verbosity.

\{constructive\} will not signal any difference if it can reproduce an equivalent environment,
defined as containing the same values and having a same or equivalent parent.\cr

See also the \code{ignore_function_env} argument in \code{?compare_options}, which disables the check
of environments of function.
}
\section{Constructors}{


We might set the \code{constructor} argument to:
\itemize{
\item \code{".env"} (default): use \code{constructive::.env()} to construct the environment from
its memory address.
}
\itemize{
\item \code{"list2env"}: We construct the environment as a list then
use \code{base::list2env()} to convert it to an environment and assign it a parent. By
default we use as a parent the first special environment we find when going
through ancestors, so we can print code that doesn't use \code{.env()}.
If \code{recurse} is \code{TRUE}
the parent will be built recursively so all ancestors will be created until
we meet a known environment, this might be verbose and will fail if environments
are nested too deep or have a circular relationship. If the environment is empty we use \code{new.env(parent=)}
for a more economic syntax.
\item \code{"new_environment"} : Similar to the above, but using \code{rlang::new_environment()}.
\item \code{"new.env"} : All environments will be recreated with the code \code{"base::new.env()"},
without argument, effectively creating an empty environment child of
the local (often global) environment. This is enough in cases where the environment
doesn't matter (or matters as long as it inherits from the local environment),
as is often the case with formulas. \code{recurse} is ignored.
\item \code{"as.environment"} : we attempt to construct the environment as a list and use
\code{base::as.environment()} on top of it, as in \code{as.environment(list(a=1, b=2))}, it will
contain the same variables as the original environment but the parent will be the
\code{emptyenv()}. \code{recurse} is ignored.
\item \code{"topenv"} : we construct \code{base::topenv(x)}, see \code{?topenv}. \code{recurse} is ignored.
This is the most accurate we can be when constructing only special environments.
\item \code{"predefine"} : Building environments from scratch using the above methods
can be verbose, sometimes redundant and sometimes even impossible due to
circularity (e.g. an environment referencing itself).  With \code{"predefine"}
we define the environments and their content  above the object returning
call, using placeholder names \code{..env.1..}, \code{..env.2..} etc.
The caveat is that the created code won't be a single call
and will create objects in the workspace. \code{recurse} is ignored.
}
}

