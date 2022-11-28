
#' @export
`$.opt_object` <- function(x, y) {
  res <- list()
  class(res) <- "opt_package"
  attr(res, "name") <- y
  res
}

#' @export
`$.opt_package` <- function(x, y) {
  pkg <- attr(x, "name")
  file <- system.file("opt.dcf", package = pkg)
  if (file == "") {
    option_check <- NULL
  } else {
    option_check <- parse(text = read.dcf(file)[,sub(paste0("^",pkg, "\\."), "", y)])
  }

  fun <- function(value) {
    if (missing(value)) {
      if (!isFALSE(getOption("opt.verbose"))) message(sprintf("getOption(\"%s\")", y))
      return(getOption(y))
    }
    eval(option_check)
    if (!isFALSE(getOption("opt.verbose"))) message(sprintf("options(%s = %s)", y, trimws(paste(deparse(value), collapse = " "))))
    args <- list(value)
    names(args) <- y
    do.call(options, args)
  }
  class(fun) <- "opt_function"
  attr(fun, "name") <- y
  attr(fun, "package") <- pkg
  fun
}

#' @importFrom utils .DollarNames
#' @export
.DollarNames.opt_object <- function(x, pattern="") {
  #print("!")
  update_loaded_options()
  c("ALL", globals$names)
}

#' @export
.DollarNames.opt_package <- function(x, pattern="") {
  #print("!!")
  pkg <- attr(x, "name")
  #if(!pkg %in% loadedNamespaces()) loadNamespace(pkg)
  update_loaded_options()
  if (pkg == "ALL") {
    sort(union(names(options()), unlist(globals$loaded_options)))
  } else {
    globals$loaded_options[[pkg]]
  }
}


# seems like we cannot load implicitly because dollar is cached for unknown names for some reason
