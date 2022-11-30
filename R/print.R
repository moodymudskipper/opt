#' @export
print.opt_object <- function(x, ...) {
  writeLines("opt object")
  invisible(x)
}

#' @export
print.opt_package <- function(x, ...) {
  name <-  attr(x, "name")
  writeLines(sprintf(
    "Call `opt$%s$` and use auto-complete to choose the option to get or set", name
  ))
  invisible(x)
}

#' @export
print.opt_function <- function(x, ...) {
  name <-  attr(x, "name")
  package <- attr(x, "package")
  topics <- filter_doc_opt(package, name)
  call_line <- sprintf(
    "Call `opt$%s$%s()` to get and `opt$%s$%s(value)` to set.",
    package, name, package, name
  )
  topic_lines <- if (length(topics)) {
    c("Try the following topic(s) for help on this option:",
      sprintf("help(\"%s\", \"%s\")", topics, package)
    )
  }
  # redundant but since we're printing so we have time ?
  function_lines <- paste(
    "This option is used by :",
    toString(fetch_opt_funs_for_print(package, name))
  )
  lines <- c(call_line, topic_lines, function_lines)
  writeLines(lines)
  invisible(x)
}


#' @export
print.ev_object <- function(x, ...) {
  writeLines("ev object")
  invisible(x)
}

#' @export
print.ev_package <- function(x, ...) {
  name <-  attr(x, "name")
  writeLines(sprintf(
    "Call `ev$%s$` and use auto-complete to choose the environment variable to get or set", name
  ))
  invisible(x)
}

#' @export
print.ev_function <- function(x, ...) {
  name <-  attr(x, "name")
  package <- attr(x, "package")
  topics <- filter_doc_ev(package, name)
  call_line <- sprintf(
    "Call `ev$%s$%s()` to get and `ev$%s$%s(value)` to set.",
    package, name, package, name
  )
  topic_lines <- if (length(topics)) {
    c("Try the following topic(s) for help on this option:",
      sprintf("help(\"%s\", \"%s\")", topics, package)
    )
  }
  function_lines <- paste(
    "This option is used by :",
    toString(fetch_ev_funs_for_print(package, name))
  )
  lines <- c(call_line, topic_lines, function_lines)
  writeLines(lines)
  invisible(x)
}
