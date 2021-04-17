from typing import List, Optional, Union
from bs4.element import Tag as bs4_tag
from rss_parser import Parser
from rss_parser.models import RSSFeed, FeedItem

# TODO: fix duplication to include description changes
class NewFeedItem(FeedItem):
    def __hash__(self):
        return hash(self.title.strip() + self.description)

    def __eq__(self, other):
        return self.title.strip() == other.title.strip() and \
            self.description == self.description

class NewRSSFeed(RSSFeed):
    feed: List[NewFeedItem]

class NewParser(Parser):
    def check_none(
        self,
        item: Union[dict, str, bs4_tag],
        default: Union[dict,str],
        item_dict: Optional[str] = None,
        default_dict: Optional[str] = None,
    ) -> Union[dict, str]:
        if item:
            if item_dict:
                return item[item_dict]
            else:
                if isinstance(item, str):
                    return item
                else:
                    return item.get_text()
        else:
            if default_dict:
                return default[default_dict]
            else:
                if isinstance(default, str):
                    return default
                else:
                    return default.get_text()

    def parse(self) -> RSSFeed:
        main_soup = self.get_soup(self.xml)
        self.raw_data = {
            "title": main_soup.title.text,
            "version": main_soup.rss.get("version"),
            "language": getattr(main_soup.language, "text", ""),
            "description": getattr(main_soup.description, "text", ""),
            "feed": [],
        }
        items = main_soup.findAll("item")
        if self.limit is not None:
            items = items[: self.limit]
        for item in items:
            # Using html.parser instead of lxml because lxml can't parse <link>
            description_soup = self.get_soup(item.description.text, "html.parser")
            item_dict = {
                "title": item.title.text,
                "link": item.link.text,
                "publish_date": getattr(item.pubDate, "text", ""),
                "category": getattr(item.category, "text", ""),
                "description": self.check_none(
                    item.find("content:encoded"),
                    str(description_soup)
                ),
                "description_links": [
                    anchor.get("href")
                    for anchor in description_soup.findAll("a")
                    # if statement to avoid non true values in the list
                    if anchor.get("href")
                ],
                "description_images": [
                    {"alt": image.get("alt", ""), "source": image.get("src")}
                    for image in description_soup.findAll("img")
                ],
            }
            try:
                item_dict.update(
                    {
                        "enclosure": {
                            "content": "",
                            "attrs": {
                                "url": item.enclosure["url"],
                                "length": item.enclosure["length"],
                                "type": item.enclosure["type"],
                            },
                        },
                        "itunes": {
                            "content": "",
                            "attrs": {
                                "href": self.check_none(
                                    item.find("itunes:image"),
                                    main_soup.find("itunes:image"),
                                    "href",
                                    "href",
                                )
                            },
                        },
                    }
                )
            except (TypeError, KeyError, AttributeError):
                pass
            self.raw_data["feed"].append(item_dict)

        return RSSFeed(**self.raw_data)
