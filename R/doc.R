get_topics <- function (package){
  help_path <- system.file("help", package = package)
  file_path <- file.path(help_path, "AnIndex")
  if (length(readLines(file_path, n = 1)) < 1) {
    return(NULL)
  }
  topics <- read.table(file_path, sep = "\t", stringsAsFactors = FALSE,
                       comment.char = "", quote = "", header = FALSE)
  names(topics) <- c("alias", "file")
  sort(unique(topics[complete.cases(topics), "file"]))
}

fetch_rdb <- function(pkg, topic) {
  rdb_path <- file.path(system.file("help", package = pkg), pkg)
  tools:::fetchRdDB(rdb_path, topic)
}

filter_doc_opt <- function(pkg, opt_name) {
  topic_names <- get_topics(pkg)
  topic_pages <- sapply(topic_names, fetch_rdb, pkg = pkg, USE.NAMES = TRUE)
  topic_pages <- lapply(topic_pages, paste, collapse = "")
  # find raw option name in doc ------------------------------------------------
  option_name_pattern <- gsub("\\.", "\\.", opt_name)
  found_option_name <- grepl(option_name_pattern, topic_pages)
  # # find quoted suffix ---------------------------------------------------------
  prefix_pattern <- paste0("^", gsub("\\.", "\\.?", pkg), "[._]?")
  option_suffix <- sub(prefix_pattern, "", opt_name)
  option_suffix <- gsub("\\.", "\\.", option_suffix)
  found_option_suffix <- grepl(option_suffix, topic_pages)
  # suffixes are too general however (e.g. "width"), so we limit their search to specific pages
  found_option_suffix <-
    found_option_suffix &
    (endsWith(topic_names, "options") | endsWith(topic_names, "config") | endsWith(topic_names, "package"))
  topic_names[found_option_name | found_option_suffix]
}

filter_doc_ev <- function(pkg, opt_name) {
  topic_names <- get_topics(pkg)
  topic_pages <- sapply(topic_names, fetch_rdb, pkg = pkg, USE.NAMES = TRUE)
  topic_pages <- lapply(topic_pages, paste, collapse = "")
  # find raw ev name in doc ------------------------------------------------
  ev_name_pattern <- gsub("\\.", "\\.", opt_name, ignore.case = TRUE)
  found_ev_name <- grepl(ev_name_pattern, topic_pages)
  topic_names[found_ev_name]
}
