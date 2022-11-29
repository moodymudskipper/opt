
fetch_opt_funs <- function(pkg) {
  ns <- asNamespace(pkg)
  funs <- Filter(is.function, as.list(ns))
  option_funs <- c("getOption", "local_options", "with_options", "push_options", "peek_options", "peek_option")
  Filter(
    function(x) any(option_funs %in% all.names(body(x))) || any(option_funs %in% all.names(formals(x))),
    funs
  )
}

fetch_ev_funs <- function(pkg) {
  ns <- asNamespace(pkg)
  funs <- Filter(is.function, as.list(ns))
  Filter(
    function(x) "Sys.getenv" %in% all.names(body(x)) || "Sys.getenv" %in% all.names(formals(x)),
    funs
  )
}

fetch_opt_funs_for_print <- function(pkg, opt = NULL) {
  relevant_funs <- fetch_opt_funs(pkg)
  pkg_pattern <- gsub("\\.", "\\.?", pkg)
  ind_lgl <- sapply(relevant_funs, function(x) {
    opts <- unique(unlist(c(rec(body(x)), rec(formals(x)))))
    if (!is.null(opt)) return(opt %in% opts)
    any(grepl(paste0("^", pkg_pattern), opts ))
  })
  relevant_funs <- names(relevant_funs[ind_lgl])
  sprintf("`%s%s%s()`", pkg, ifelse(relevant_funs %in% getNamespaceExports(pkg), "::", ":::"), relevant_funs)
}

fetch_ev_funs_for_print <- function(pkg, ev = NULL) {
  relevant_funs <- fetch_ev_funs(pkg)
  pkg_pattern <- gsub("\\.", "\\.?", pkg)
  ind_lgl <- sapply(relevant_funs, function(x) {
    evs <- unique(unlist(c(rec_ev(body(x)), rec_ev(formals(x)))))
    if (!is.null(ev)) return(ev %in% evs)
    any(grepl(paste0("^", pkg_pattern), evs))
  })
  relevant_funs <- names(relevant_funs[ind_lgl])
  sprintf("`%s%s%s()`", pkg, ifelse(relevant_funs %in% getNamespaceExports(pkg), "::", ":::"), relevant_funs)
}

fetch_options <- function(pkg) {
  relevant_funs <- fetch_opt_funs(pkg)
  options <- unique(unlist(lapply(relevant_funs, function(x) c(rec(body(x)), rec(formals(x))))))
  options <- sort(unname(unlist(Filter(is.character, options))))
  # for data.table basically, since their options follow the datatable.print.topn format (no dot)
  pkg <- gsub("\\.", "\\.?", pkg)
  options <- grep(paste0("^", pkg), options, value = TRUE)
  options
}

fetch_evs <- function(pkg) {
  relevant_funs <- fetch_ev_funs(pkg)
  evs <- unique(unlist(lapply(relevant_funs, function(x) c(rec_ev(body(x)), rec_ev(formals(x))))))
  evs <- sort(unname(unlist(Filter(is.character, evs))))
  # for data.table basically, since their options follow the datatable.print.topn format (no dot)
  pkg <- toupper(gsub("\\.", "\\.?", pkg))
  evs <- grep(paste0("^", pkg), evs, value = TRUE)
  evs
}

rec <- function(call) {
  if (!is.call(call) && !is.pairlist(call)) return(NULL)
  if(list(call[[1]]) %in% expression(
    getOption,
    local_options, with_options, push_options, peek_options, peek_option,
    rlang::local_options, rlang::with_options, rlang::push_options, rlang::peek_options, rlang::peek_option
  )) return(c(as.list(call)[-1], names(call)[-1]))
  unlist(lapply(call, rec))
}

rec_ev <- function(call) {
  if (!is.call(call) && !is.pairlist(call)) return(NULL)
  if(list(call[[1]]) %in% expression(Sys.getenv)) return(as.list(call)[2])
  unlist(lapply(call, rec_ev))
}

globals <- new.env()
update_loaded_options <- function() {
  new_namespaces <- setdiff(loadedNamespaces(), names(globals$loaded_options))
  new_options <- sapply(new_namespaces, function(pkg) {
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


update_loaded_evs <- function() {
  new_namespaces <- setdiff(loadedNamespaces(), names(globals$loaded_evs))
  new_evs <- sapply(new_namespaces, function(pkg) {
    file <- system.file("ev.dcf", package = pkg)
    if (file == "") {
      fetch_evs(pkg)
    } else {
      checks <- read.dcf(file)
      paste0(toupper(pkg), "_", colnames(checks))
    }
  }, USE.NAMES = TRUE, simplify = FALSE)
  all_evs <- c(globals$loaded_evs, new_evs)
  all_evs <-all_evs[sort(names(all_evs))]
  globals$loaded_evs <- all_evs
  globals$ev_names <- names(all_evs[lengths(all_evs) > 0])
  invisible(NULL)
}
