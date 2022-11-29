#' @export
names.opt_object <- function(x, pattern="") {
  loadedNamespaces()
}

#' @export
names.opt_package <- function(x, pattern="") {
  pkg <- attr(x, "name")
  fetch_options(pkg)
}

#' @export
names.ev_object <- function(x, pattern="") {
  loadedNamespaces()
}

#' @export
names.ev_package <- function(x, pattern="") {
  pkg <- attr(x, "name")
  fetch_evs(pkg)
}

#' @export
length.opt_object <- function(x) {
  length(names(x))
}

#' @export
length.opt_package <- function(x) {
  length(names(x))
}

#' @export
length.ev_object <- function(x) {
  length(names(x))
}

#' @export
length.ev_package <- function(x) {
  length(names(x))
}
