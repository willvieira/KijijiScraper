# from https://community.rstudio.com/t/build-package-namespace-dynamically-during-onload/4101/3
# Load the module and create dummy objects from it, all of which are NULL
the_module <- reticulate::import_from_path(
  "kijiji_scrap",
  file.path("inst", "python")
)
for (obj in names(the_module)) {
  assign(obj, NULL)
}

# Clean up
rm(the_module)

# Now all those names are in the namespace, and ready to be replaced on load
.onLoad <- function(libname, pkgname) {
  the_module <- reticulate::import_from_path(
    "kijiji_scrap",
    system.file("python", package = utils::packageName())
  )

  # assignInMyNamespace(...) is meant for namespace manipulation
  for (obj in names(the_module)) {
    utils::assignInMyNamespace(obj, the_module[[obj]])
  }
}
