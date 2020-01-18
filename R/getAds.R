# get adds
all_KijijiAds = function(URL, exclude, pages = 3, outputFile = NULL)
{
  # source python functions
  reticulate::source_python('python/kijiji_scrap.py')

  # pass adsList to KijijiScraper python function
  kijiji = KijijiScraper(exclude = exclude)

  # get ads from first page
  ads = kijiji$scrape_kijiji_for_ads(URL)

  # get ads from other pages if requested
  if(pages > 1) {

    # get first and last part of URL to add page number
    firstURL = sub('/[^/]*$', '', URL)
    lastURL = sub('.*[^/]/', '', URL)

    for(page in 2:pages)
    {
      URL = paste0(firstURL, '/page-', page, '/', lastURL)
      ads <- append(ads, kijiji$scrape_kijiji_for_ads(URL))
    }
  }

  # clean ads
  ads <- lapply(ads, function(x) lapply(x, function(xx) gsub("[\r\n]", "", xx)))

  # output results
  if(is.null(outputFile))
  {
    return(ads)

  }else{
    # save ads in the file
    write(rjson::toJSON(ads), file = outputFile)
  }
}




new_KijijiAds = function(URL, exclude, pages, inputFile, updateInput = TRUE, outputFile = NULL)
{

  # source python functions
  reticulate::source_python('python/kijiji_scrap.py')

  # load ads file if it exists
  if(file.exists(inputFile)) {
    adsFile = rjson::fromJSON(file = inputFile)
    adsNames = as.list(names(adsFile))
  }else {
    stop('inputFile is not correct. If you do not have a json file with previews ads, please use the all_KijijiAds() function.')
  }

  # pass adsList to KijijiScraper python function
  kijiji = KijijiScraper(exclude = exclude)

  newAds = kijiji$scrape_kijiji_for_ads(URL)

  # get ads from other pages if requested
  if(pages > 1) {

    # get first and last part of URL to add page number
    firstURL = sub('/[^/]*$', '', URL)
    lastURL = sub('.*[^/]/', '', URL)

    for(page in 2:pages)
    {
      URL = paste0(firstURL, '/page-', page, '/', lastURL)
      newAds <- append(newAds, kijiji$scrape_kijiji_for_ads(URL))
    }
  }

  # clean newAds
  newAds <- lapply(newAds, function(x) lapply(x, function(xx) gsub("[\r\n]", "", xx)))

  # remove ads already present in data base
  newAds = newAds[!(names(newAds) %in% adsNames)]

  if(length(newAds) == 0) {

    print('Did not find new ads')

  }else {

    print(paste('Found', length(newAds), 'ads'))

    # update data base
    if(updateInput) {
      print(paste('Updating the `', inputFile, '` file'))
      ads = append(adsFile, newAds)
      write(rjson::toJSON(ads), file = inputFile)
    }

    # output results
    if(is.null(outputFile))
    {
      return(newAds)

    }else{
      # save ads in the file
      write(rjson::toJSON(newAds), file = outputFile)
    }
  }
}
