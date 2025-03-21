# KijijiScraper
## Retrieve new ads and keep me updated when new ads are found

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://www.tidyverse.org/lifecycle/#stable)
![R-CMD-check](https://github.com/willvieira/KijijiScraper/workflows/R-CMD-check/badge.svg)
![Weekly test](https://github.com/willvieira/KijijiScraper/workflows/Weekly%20test/badge.svg?branch=master) [![time tracker](https://wakatime.com/badge/github/willvieira/KijijiScraper.svg)](https://wakatime.com/badge/github/willvieira/KijijiScraper) [![codecov](https://codecov.io/gh/willvieira/KijijiScraper/branch/master/graph/badge.svg)](https://codecov.io/gh/willvieira/KijijiScraper)

This R package have three simple functionalities. From a specific search on [Kijiji](https://www.kijiji.ca/), it can (i) retrieve all ads and save it in a database to further exploration; (ii) retrieve new ads not present in the current database; and (iii) send a message with the new ads retrieved in the last step.

#### ⚠️ Caution ⚠️
Kijiji does not have an API to retrieve new ads. It means this package relies on web based scrapping, which is not reliable on the long-term. Aware of that, I automated some GitHub actions to test the code every week and keep me updated of any possible bug :bug:

## Installation

This package requires Python 3+ to be installed along with some Python packages, which can be installed with a standard shell on terminal:

```bash
# or pip3
pip install requests bs4 pyyaml
```

A R alternative to install Python packages is to use `reticulate`, which will require a virtual environment (more details [here](https://rstudio.github.io/reticulate/articles/python_packages.html)):

```r
# install.packages('reticulate')
reticulate::py_install(c('requests', 'bs4', 'pyyaml'))
```

Once Python dependencies are solved, you can install the `KijijiScraper` R package from GitHub:

```r
devtools::install_github('willvieira/kijijiScraper')
```

## Quick start

```r
library(kijijiScraper)

## My request

  # the url got from a search on kijiji
  URL = "https://www.kijiji.ca/b-appartement-condo/ville-de-montreal/3-1-2/k0c37l1700281?price=__840"

  # keywords to exclude from search
  excludeWords = c('recherche', 'recherché', 'échange', 'echange')

  # the number of pages it will search for ads
  pages = 3

  # file to save the ads (if `NULL` it will return an object list)
  File = "ads.json"

  # search to be saved in the `ads.json` file
  all_KijijiAds(URL, excludeWords, pages, File)

  # Once the database is built, get new ads not present in the `ads.json` file,
  # and update the `ads.json` with the new ads
  new_KijijiAds(URL, excludeWords, pages = 1, inputFile = 'ads.json', updateInput = TRUE)

##
```

## Automating with scheduled ads search

To automate the `new_KijijiAds()` function at some time interval, you can use [Crontab](http://man7.org/linux/man-pages/man5/crontab.5.html) on Linux/macOS or [Task Scheduler](https://docs.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-start-page) on windodws.

When automating, you can use either the `sendEmail()` or `sendTelegram()` functions to send you a message with the new ads found through the `new_KijijiAds()` function.

### Send email

Before using the `sendEmail()` function, you must create a local file (saved here as `_mailInfo.yml`) in the project directory with the following information:

```yaml
from: sender_example@server.com
to: example@server.com
host: smtp.gmail.com
port: 465
username: sender_example@server.com
password: myPassword
```

When setting the `sendEmail()` function, first run the `all_KijijiAds()` function to create a database of ads:

```r
library(kijijiScraper)
all_KijijiAds(URL = 'myURL', exclude = c('keyword1', 'keyword2'), pages = 4, outputFile = 'ads.json')
```

Once your database of ads is set, you can create an R script which will be called by Crontab/Task Scheduler, send you an email if it finds new ads, and finally update your database with the new ads (if `updateInput = TRUE`):

```r
URL = 'myURL'
excludeWords = c('keyword1', 'keyword12', '...')
sendEmail(mailInfo = '_mailInfo.yml', newAds = new_KijijiAds(URL,
                                                             excludeWords,
                                                             pages = 2,
                                                             inputFile = 'ads.json',
                                                             updateInput = TRUE))
```

Now you just have to set a Crontab/Task Scheduler to execute the R script above.

#### Using STARTTLS

As stated in the [emayili](https://github.com/datawookie/emayili) R package:

> if you’re trying to send email with a host that uses the STARTTLS security protocol (like Google Mail, Yahoo! or AOL), then it will most probably be blocked due to insufficient security.

They point out in their README some articles about how to work around this issue.

## Disclaimer

The aim of this package was to learn about the `reticulate` R package, in which integrates R and Python. The Python scripts used here are inspired from the Kijiji-scraper Python project found [here](https://github.com/CRutkowski/Kijiji-Scraper), thank you all for sharing! 💚
