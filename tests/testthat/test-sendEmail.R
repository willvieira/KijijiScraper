context("test sendEmail function")
library(KijijiScraper)
remotes::install_github("datawookie/emayili");library(emayili)

# laading ads
ads <- rjson::fromJSON(file = 'ads.json')
ads <- ads[1]

# loading mailInfo
download.file(Sys.getenv('mailINFO'), '_mailInfo.yml', method = 'auto', quiet = TRUE)


# Testing
test_that("email is sent", {

  sendEmail(mailInfo = '_mailInfo.yml', newAds = ads)

})
