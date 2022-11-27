fetch_options <- function(pkg) {
  ns <- asNamespace(pkg)
  funs <- Filter(is.function, as.list(ns))
  option_funs <- c("getOption", "local_options", "with_options", "push_options", "peek_options", "peek_option")
  relevant_funs <- Filter(
    function(x) any(option_funs %in% all.names(body(x))) || any(option_funs %in% all.names(formals(x))),
    funs
  )
  options <- unique(unlist(lapply(relevant_funs, function(x) c(rec(body(x)), rec(formals(x))))))
  options <- sort(unname(unlist(Filter(is.character, options))))
  options <- grep(paste0("^", pkg, "[._]"), options, value = TRUE)
  options
}

rec <- function(call) {
  if (!is.call(call) && !is.pairlist(call)) return(NULL)
  if(list(call[[1]]) %in% expression(
    getOption,
    local_options, with_options, push_options, peek_options, peek_option,
    rlang::local_options, rlang::with_options, rlang::push_options, rlang::peek_options, rlang::peek_option
  )) return(as.list(call)[-1])
  unlist(lapply(call, rec))
}

globals <- new.env()
update_loaded_options <- function() {
  new_namespaces <- setdiff(loadedNamespaces(), names(globals$loaded_options))
  new_options <- sapply(new_namespaces, function(pkg) {
    # if (pkg == "opt") browser()
    file <- system.file("opt.dcf", package = pkg)
    if (file == "") {
      fetch_options(pkg)
    } else {
      checks <- read.dcf(file)
      paste0(pkg, ".", colnames(checks))
    }
    }, USE.NAMES = TRUE, simplify = FALSE)
  all_options <- c(globals$loaded_options, new_options)
  all_options <-all_options[sort(names(all_options))]
  globals$loaded_options <- all_options
  globals$names <- names(all_options[lengths(all_options) > 0])
  invisible(NULL)
}
