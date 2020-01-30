#' Send email with new retrieved ads
#'
#' This function is a wrapper of the emayili R package to send email messages
#' with the information of the new ads
#'
#' The \code{mailInfo} file needs the following arguments: \cr
#' from: \cr
#' to: \cr
#' host: \cr
#' port: \cr
#' username: \cr
#' password: \cr
#'
#' @importFrom magrittr %>%
#' @param mailInfo character, the name of the file where all addresses and server
#' information are saved
#' @param newAds list, the output of the \code{\link{new_KijijiAds}} function

#' @export
#' @examples
#' \dontrun{
#' URL <- 'https://www.kijiji.ca/b-a-louer/ville-de-montreal/3-1-2/k0c30349001l1700281?price=__860'
#' sendEmail('_mailInfo.yml',
#'           newAds = new_KijijiAds(URL, excludeWords, pages = 2,
#'                                  inputFile = 'ads.json', updateInput = TRUE))
#' }

sendEmail = function(mailInfo = '_mailInfo.yml', newAds = new_KijijiAds(URL, excludeWords, pages, inputFile))
{

  # test if output is empty
  if(is.list(newAds)) {

    ## Remove empty add if any of the URL did not find new ads
    if(any(nchar(names(newAds)) == 0)) {
      rmEmptyAdd <- which(nchar(names(newAds)) == 0)
      newAds <- newAds[-rmEmptyAdd]
    }

    ## laod user infos
    infos = yaml::yaml.load_file(input = mailInfo)

    ## set ads infos for email
    # separete ads by main URL search (if multiple URL's at once)
    mainURLs <- unique(unlist(lapply(newAds, function(x) x$mainURL)))

    # nb of ads
    nNew = length(newAds)

    Subject = paste0('I found ', nNew, ' new ', ifelse(nNew == 1, 'ad', 'ads'), ' on Kijiji')

    Body = c()
    for(mURL in mainURLs) {

      # get ads for specific main URL
      addID <- which(unlist(lapply(newAds, function(x) x$mainURL == mURL)))

      # add main URL as a title
      Body <- append(Body, paste('\nAds for the searching URL:', mURL, ':\n'))

      for(i in 1:length(addID)) {
        Body = append(Body, paste(paste(paste('-', newAds[[i]]['Title']),
                                        newAds[[i]]['Url'],
                                        newAds[[i]]['Date'],
                                        newAds[[i]]['Location'],
                                        newAds[[i]]['Price'], sep = '\n'), '\n', '\n'))
      }
    }

    # Send email
    email <- emayili::envelope() %>%
             emayili::from(infos[['from']]) %>%
             emayili::to(infos[['to']]) %>%
             emayili::subject(Subject) %>%
             emayili::text(Body)

    smtp <- emayili::server(host = infos[['host']],
                            port = infos[['port']],
                            username = infos[['username']],
                            password = infos[['password']]
    )

    smtp(email, verbose = F)
  }
}
