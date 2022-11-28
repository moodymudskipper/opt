#' @export
print.opt_object <- function(x, ...) {
  writeLines("opt object")
  invisible(x)
}

#' @export
print.opt_package <- function(x, ...) {
  name <-  attr(x, "name")
  writeLines(sprintf(
    "Call `opt$%s$` and use auto-complete to choose opt to get or set", name
  ))
  invisible(x)
}

#' @export
print.opt_function <- function(x, ...) {
  name <-  attr(x, "name")
  package <- attr(x, "package")
  topics <- filter_doc(package, name)
  call_line <- sprintf(
    "Call `opt$%s$%s()` to get and `opt$%s$%s(value)` to set.",
    package, name, package, name
  )
  topic_lines <- if (length(topics)) {
    c("Try the following topic(s) for help on this option:",
      sprintf("help(\"%s\", \"%s\")", topics, package)
    )
  }
  lines <- c(call_line, topic_lines)
  writeLines(lines)
  x
}
