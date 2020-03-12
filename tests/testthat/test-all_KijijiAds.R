context("test all_KijijiAds function")
library(KijijiScraper)

# define some variables
URL = "https://www.kijiji.ca/b-audio/ville-de-montreal/turntable/k0c767l1700281?ll=45.501689%2C-73.567256&address=Montr%C3%A9al%2C+QC&radius=15.0"
pages = 2

# get the ads
ads <- all_KijijiAds(URL, exclude = NULL, pages, NULL)


# Testing
test_that("output of function is a list", {

  # is ads a list?
  expect_true(class(ads) == 'list')

})

test_that("An ad has the main objects", {

  # whitin one ad, is there he following elements?
  expect_equal(sum(c('Title', 'Url', 'Location', 'mainURL') %in% names(ads[[1]])), 4)

})
