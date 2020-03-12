context("test all_KijijiAds function")
library(KijijiScraper)

# define some variables
URL = "https://www.kijiji.ca/b-a-louer/ville-de-montreal/3-1-2/k0c30349001l1700281?ll=45.531715%2C-73.593726&address=5500+Rue+St-Hubert%2C+Montr%C3%A9al%2C+QC+H2J+2Y6%2C+Canada&radius=2.0&price=__900"
pages = 2
excludeWords = c('echange', 'swap')

# get the ads
ads <- all_KijijiAds(URL, excludeWords, pages, NULL)


# Testing
test_that("output of function is a list", {

  # is ads a list?
  expect_true(class(ads) == 'list')

})

test_that("An ad has the main objects", {

  # whitin one ad, is there he following elements?
  expect_equal(sum(c('Title', 'Url', 'Location', 'mainURL') %in% names(ads[[1]])), 4)

})
