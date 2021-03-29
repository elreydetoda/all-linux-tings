from rss_parser import Parser
from requests import get as r_get
from typing import List
from datetime import datetime

from rss_parser.models import FeedItem

def get_feed_item_date(obj):
    obj.publish_date
    # %a, %d %b %Y %H:%M:%S%z
    rss_datetime_fmt='%a, %d %b %Y %H:%M:%S %z'
    obj.publish_date = datetime.strptime(
        obj.publish_date, rss_datetime_fmt
        )
    return obj.publish_date

def merge_feeds(rss_unmerged_list: List[dict]) -> List:
    headerz= {
        # adding because some websites blocked python headers...
        #   specifically s3daily
        'User-Agent': 'curl'
    }

    rss_merged_list = []

    for rss_feed in rss_unmerged_list:
        print(rss_feed['feed_url'])
        feed_contents = r_get(rss_feed['feed_url'], headers=headerz)
        # rss_parser._parser.Parser
        parser = Parser(xml=feed_contents.content, limit=5)
        # rss_parser.models.RSSFeed
        meta_feed = parser.parse()
        for feed_item in meta_feed.feed:
            # rss_parser.models.FeedItem
            rss_merged_list.append(feed_item)
    
    return rss_merged_list

def get_master_feed(rss_list: List[dict]) -> str:

    master_feed = merge_feeds( rss_list )
    master_feed.sort(key=get_feed_item_date, reverse=True)
    
    for feed_item in master_feed:
        print(feed_item.title)
        print(feed_item.publish_date)
        print(feed_item.link)
