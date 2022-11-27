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
  writeLines(sprintf(
    "Call `opt$%s$%s()` to get and `opt$%s$%s(value)` to set.",
    package, name, package, name
  ))
  x
}
