
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
