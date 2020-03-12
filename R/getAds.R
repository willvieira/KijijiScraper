#' Retrieve all Kijiji ads
#'
#' This function retrieves all ads from a Kijiji search URL. Third party ads
#' are removed.
#'
#' @importFrom rjson fromJSON
#' @importFrom rjson toJSON
#' @importFrom stats setNames
#'
#' @param URL character, the address after doing a specific search on Kijiji
#' @param exclude vector, keywords to remove unwanted ads
#' @param pages numeric, total amount of pages to look for ads
#' @param outputFile character, name of the output file to save the retrieved ads.
#' If \code{NULL} it will return a list of ads

#' @return list of ads
#' @export
#' @examples
#' \dontrun{
#' # Retrieve all ads renting an apartment 3 1/2 in Montreal
#' # Exclude ads looking for an exchange
#' # And save the result in the 'ads.json' file
#' URL <- 'https://www.kijiji.ca/b-a-louer/ville-de-montreal/3-1-2/k0c30349001l1700281?price=__860'
#' all_KijijiAds(URL, exclude = 'echange', pages = 3, outputFile = 'ads.json')
#' }

all_KijijiAds = function(URL, exclude, pages = 3, outputFile = NULL)
{

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
      sURL = paste0(firstURL, '/page-', page, '/', lastURL)
      ads <- append(ads, kijiji$scrape_kijiji_for_ads(sURL))
    }
  }

  # clean ads
  ads <- lapply(ads, function(x) lapply(x, function(xx) gsub("[\r\n]", "", xx)))

  # add mail URL info for each add (useful when one list of multiple URL requires)
  for(i in 1:length(ads)) {
    ads[[i]] <- append(ads[[i]], setNames(URL, 'mainURL'))
  }

  # output results
  if(is.null(outputFile))
  {
    return(ads)

  }else{
    # save ads in the file
    write(rjson::toJSON(ads), file = outputFile)
  }
}



#' Retrieve new Kijiji ads not present in the database
#'
#' This function retrieves all new ads from a Kijiji search URL that are not present
#' in the defined database `inputFile`.
#'
#' @param URL character, the address after doing a specific search on Kijiji
#' @param exclude vector, keywords to remove unwanted ads
#' @param pages numeric, total amount of pages to look for ads
#' @param inputFile character, name of the database file used in the \code{\link{all_KijijiAds}} function
#' @param updateInput logical, if FALSE it will not update the inputFile with the new retrieved ads.
#' Useful in case of debuging
#' @param outputFile character, name of the output file to save the retrieved new ads
#' If `NULL` it will retun a list of ads

#' @return list of new ads
#' @export

new_KijijiAds = function(URL, exclude, pages, inputFile, updateInput = TRUE, outputFile = NULL)
{

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
      sURL = paste0(firstURL, '/page-', page, '/', lastURL)
      newAds <- append(newAds, kijiji$scrape_kijiji_for_ads(sURL))
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

    # add mail URL info for each add (useful when one list of multiple URL requires)
    for(i in 1:length(newAds)) {
      newAds[[i]] <- append(newAds[[i]], setNames(URL, 'mainURL'))
    }

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
