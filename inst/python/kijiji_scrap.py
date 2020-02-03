# Python code from https://github.com/CRutkowski/Kijiji-Scraper
import requests
from bs4 import BeautifulSoup
import json

class KijijiAd():

    def __init__(self, ad):
        self.title = ad.find('a', {"class": "title"}).text.strip()
        self.id = ad['data-listing-id']
        self.ad = ad
        self.info = {}

        self.__locate_info()
        self.__parse_info()

    def __locate_info(self):
        # Locate ad information
        self.info["Title"] = self.ad.find('a', {"class": "title"})
        self.info["Image"] = str(self.ad.find('img'))
        self.info["Url"] = self.ad.get("data-vip-url")
        self.info["Details"] = self.ad.find(
            'div', {"class": "details"})
        self.info["Description"] = self.ad.find(
            'div', {"class": "description"})
        self.info["Date"] = self.ad.find(
            'span', {"class": "date-posted"})
        self.info["Location"] = self.ad.find('div', {"class": "location"})
        self.info["Price"] = self.ad.find('div', {"class": "price"})

    def __parse_info(self):
        # Parse Details and Date information
        self.info["Details"] = self.info["Details"].text.strip() \
            if self.info["Details"] is not None else ""
        self.info["Date"] = self.info["Date"].text.strip() \
            if self.info["Date"] is not None else ""

        # Parse remaining ad information
        for key, value in self.info.items():
            if value:
                if key == "Url":
                    self.info[key] = 'http://www.kijiji.ca' + value

                elif key == "Description":
                    self.info[key] = value.text.strip() \
                        .replace(self.info["Details"], '')

                elif key == "Location":
                    self.info[key] = value.text.strip() \
                        .replace(self.info["Date"], '')

                elif key not in ["Image", "Details", "Date"]:
                    self.info[key] = value.text.strip()

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
