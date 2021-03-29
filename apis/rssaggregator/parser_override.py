from bs4 import BeautifulSoup

from rss_parser import Parser
from rss_parser.models import RSSFeed, FeedItem
from typing import List, Optional

from pydantic import BaseModel

class EnclosureAttrs(BaseModel):
    url: str
    length: int
    type: str

class Enclosure(BaseModel):
    content: str
    attrs: Optional[EnclosureAttrs]

class NewFeedItem(FeedItem):
    enclosure: Optional[Enclosure]

class NewRSSFeed(RSSFeed):
    feed: List[NewFeedItem]

class NewParser(Parser):
    def parse(self) -> RSSFeed:
        main_soup = self.get_soup(self.xml)
        self.raw_data = {
            "title": main_soup.title.text,
            "version": main_soup.rss.get("version"),
            "language": getattr(main_soup.language, "text", ""),
            "description": getattr(main_soup.description, "text", ""),
            "feed": []
        }
        items = main_soup.findAll("item")
        if self.limit is not None:
            items = items[:self.limit]
        for item in items:
            # Using html.parser instead of lxml because lxml can't parse <link>
            description_soup = self.get_soup(item.description.text, "html.parser")
            item_dict = {
                "title": item.title.text,
                "link": item.link.text,
                "publish_date": getattr(item.pubDate, "text", ""),
                "category": getattr(item.category, "text", ""),
                "description": description_soup.text,
                "description_links": [
                    anchor.get("href") for anchor in description_soup.findAll('a')
                    # if statement to avoid non true values in the list
                    if anchor.get("href")
                ],
                "description_images": [
                    {"alt": image.get("alt", ""), "source": image.get("src")}
                    for image in description_soup.findAll('img')
                ]
                
            }
            if item.enclosure:
                item_dict["enclosure"] = {
                            'content': '',
                            'attrs': {
                                 'url': item.enclosure['url'] ,
                                 'length': item.enclosure['length'] ,
                                 'type': item.enclosure['type']
                                }
                    }
            self.raw_data["feed"].append(item_dict)
        return NewRSSFeed(**self.raw_data)
