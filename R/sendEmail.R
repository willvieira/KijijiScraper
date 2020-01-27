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
    # laod user infos
    infos = yaml::yaml.load_file(input = mailInfo)

    # set ads infos for email
    nNew = length(newAds)

    Subject = paste0('I found ', nNew, ' new ', ifelse(nNew == 1, 'ad', 'ads'), ' on Kijiji')

    Body = c()
    for(i in 1:nNew) {
      Body = append(Body, paste(paste(newAds[[i]]['Title'],
                                      newAds[[i]]['Url'],
                                      newAds[[i]]['Date'],
                                      newAds[[i]]['Location'],
                                      newAds[[i]]['Price'], sep = '\n'), '\n', '\n'))
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
