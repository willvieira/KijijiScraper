KijijiScraper <- NULL

.onLoad <- function(libname, pkgname) {

  reticulate::use_python(Sys.which("python3"))

  the_module <- reticulate::import_from_path(module = "kijiji_scrap", path = system.file("python", package = packageName(), mustWork = TRUE))
  KijijiScraper <<- the_module$KijijiScraper

  invisible()
}
