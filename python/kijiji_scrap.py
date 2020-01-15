# Python code from https://github.com/CRutkowski/Kijiji-Scraper
import requests
from bs4 import BeautifulSoup
import json
from python.kijiji_ad import KijijiAd

class KijijiScraper():

    def __init__(self, exclude):
        self.all_ads = {}
        self.ads = {}

        self.third_party_ads = []
        self.exclude_list = []

        self.exclude_list = self.words_to_lower(exclude)


    # Returns a given list of words to lower-case words
    def words_to_lower(self, words):
        return [word.lower() for word in words]


    # Pulls page data from a given kijiji url and finds all ads on each page
    def scrape_kijiji_for_ads(self, url):
        self.ads = {}

        # Get the html data from the URL
        page = requests.get(url)
        soup = BeautifulSoup(page.content, "html.parser")

        # Find ads on the page
        self.find_ads(soup)

        return self.ads


    def find_ads(self, soup):
        # Finds all ad trees in page html.
        kijiji_ads = soup.find_all("div", {"class": "search-item regular-ad"})

        # If no ads use different class name
        if not kijiji_ads:
            kijiji_ads = soup.find_all("div", {"class": "search-item"})

        # Find all third-party ads to skip them
        third_party_ads = soup.find_all("div", {"class": "third-party"})

        # Use different class name if no third party ads found
        if not third_party_ads:
            third_party_ads = soup.find_all("div", {"class": "search-item showcase top-feature"})

        for ad in third_party_ads:
            third_party_ad_id = KijijiAd(ad).id
            self.third_party_ads.append(third_party_ad_id)

        # Create a dictionary of all ads with ad id being the key
        for ad in kijiji_ads:
            kijiji_ad = KijijiAd(ad)

            # If any of the title words match the exclude list then skip
            if not [False for match in self.exclude_list
                    if match in kijiji_ad.title.lower()]:

                # Skip third-party ads and ads already found
                if (kijiji_ad.id not in self.third_party_ads):

                    self.ads[kijiji_ad.id] = kijiji_ad.info
