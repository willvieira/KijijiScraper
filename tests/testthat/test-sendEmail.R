context("test sendEmail function")
library(KijijiScraper)

# laading ads
ads <- rjson::fromJSON(file = 'ads.json')
ads <- ads[1]

# loading mailInfo
SMTP_USERNAME <- Sys.getenv("SMTP_USERNAME")

infoList <- list(from = SMTP_USERNAME,
                 to = SMTP_USERNAME,
                 host = "mail.smtpbucket.com",
                 port = 8025,
                 username = SMTP_USERNAME)

write(rjson::toJSON(infoList), file = '_mailInfo.yml')


# Testing
test_that("email is sent", {

  sendEmail(mailInfo = '_mailInfo.yml', newAds = ads)

})
