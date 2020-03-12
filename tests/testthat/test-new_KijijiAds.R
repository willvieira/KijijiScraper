context("test new_KijijiAds function")
library(KijijiScraper)

# define some variables
URL = "https://www.kijiji.ca/b-audio/ville-de-montreal/turntable/k0c767l1700281?ll=45.501689%2C-73.567256&address=Montr%C3%A9al%2C+QC&radius=15.0"
pages = 2
excludeWords = c('mixer')

# get the ads
ads <- all_KijijiAds(URL, excludeWords, pages, NULL)

# remove one ad from ads to make new_KijijiAds function retrieve a new ad
ads <- ads[-1]
write(rjson::toJSON(ads), file = 'ads.json')

# get the ads
newAds <- new_KijijiAds(URL, excludeWords, pages = 1, inputFile = 'ads.json')

# Testing
test_that("output of function is a list", {

  # is ads a list?
  expect_true(class(newAds) == 'list')

})

test_that("An ad has the main objects", {

  # whitin one ad, is there he following elements?
  expect_equal(sum(c('Title', 'Url', 'Location', 'mainURL') %in% names(newAds[[1]])), 4)

})

test_that("newAds has only one ad", {

  # whitin one ad, is there he following elements?
  expect_equal(length(newAds), 1)

})

test_that("the newAd is not in the ads list", {

  # whitin one ad, is there he following elements?
  expect_false(names(newAds) %in% names(ads))

})
