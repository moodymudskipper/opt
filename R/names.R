#' @export
names.opt_object <- function(x, pattern="") {
  loadedNamespaces()
}

#' @export
names.opt_package <- function(x, pattern="") {
  pkg <- attr(x, "name")
  fetch_options(pkg)
}

