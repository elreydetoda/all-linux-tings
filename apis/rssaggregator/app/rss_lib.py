from botocore import retries
from requests.api import get
from rss_parser import Parser
from rss_parser.models import RSSFeed
from requests import get as r_get
from typing import List
from datetime import datetime,timezone
from fastapi_rss.rss_response import RSSResponse as NewRSSResponse
from fastapi_rss.models import Item as NewRssItem
from os import SEEK_SET
from hashlib import md5
from object_stor import check_md5sum, generate_presigned_url, upload_feed, get_specific_obj
from opml_lib import upload_opml
from generator_override import NewRSSFeed, NewItem

def get_feed_item_date(obj):
    # %a, %d %b %Y %H:%M:%S%z
    rss_datetime_fmt='%a, %d %b %Y %H:%M:%S %z'
    try:
        obj.publish_date = datetime.strptime(
            obj.publish_date, rss_datetime_fmt
            )
    except ValueError:
        rss_datetime_fmt='%a, %d %b %Y %H:%M:%S %Z'
        obj.publish_date = datetime.strptime(
            obj.publish_date, rss_datetime_fmt
            ).astimezone(timezone.utc)
    except TypeError:
        print(obj.publish_date)
        print(type(obj.publish_date))
        raise("I don't know what happened...")
    return obj.publish_date

def merge_remote_feeds(rss_unmerged_list: List[dict], rss_merged_list: set = set()) -> List:

    for rss_feed in rss_unmerged_list:

        feed_contents = get_feed_contents(rss_feed['feed_url'])

        if feed_contents:
            rss_merged_list.update(
                merge_feeds(
                    feed_contents.content, 5
                    )
                )
    returned_list = list(rss_merged_list)
    returned_list.sort(key=get_feed_item_date, reverse=True)
    return returned_list

def get_feed_contents(feed_url: str):
    headerz= {
        # adding because some websites blocked python headers...
        #   specifically s3daily
        'User-Agent': 'curl'
    }
    # print(rss_feed['feed_url'])
    try:
        feed_contents = r_get(feed_url, headers=headerz)
        return feed_contents
    except Exception as e:
        print('WARNING:\nhad the following error for url: {}\n: {}'.format(feed_url, e))
        return None

def merge_feeds(rss_string: str, limit: int = None) -> list:
    return_list = []
    # rss_parser._parser.Parser
    parser = Parser(xml=rss_string, limit=limit)
    # rss_parser.models.RSSFeed
    meta_feed = parser.parse()
    for feed_item in meta_feed.feed:
        # rss_parser.models.FeedItem
        feed_item.category = meta_feed.title
        return_list.append(feed_item)
    return return_list

def get_feed_md5(rss_list: List[dict]) -> str:
    sum_list = []

    for rss_item in rss_list:
        sum_list.append(rss_item['feed_name'])

    return md5(''.join(sum_list).encode()).hexdigest()

def check_exists(rss_md5: str) -> bool:
    return check_md5sum(rss_md5)

def convert_to_new_rss_items(old_rss_items: list) -> List['NewRssItem']:
    new_rss_items = []
    for rss_item in old_rss_items:
        new_rss_items.append(
            NewItem(
                title=rss_item.title,
                link=rss_item.link,
                pub_date=rss_item.publish_date,
                author=rss_item.category,
                description=rss_item.description,
                enclosure=rss_item.enclosure,
                itunes=rss_item.itunes
            )
        )
    return new_rss_items

def generate_rss_feed(rss_items: List[RSSFeed]) -> NewRSSResponse:
    feed_data = {
        'title': "Alex's Master Feed",
        'link': 'https://elrey.casa/blog',
        'description': 'All my favorite rss feeds into one',
        'last_build_date': datetime.now(tz=timezone.utc).isoformat(),
        'ttl': 30,
        'item': convert_to_new_rss_items(rss_items)
    }
    return NewRSSFeed(**feed_data)

def get_master_feed(rss_list: List[dict], force: bool) -> dict:

    return_item = {}
    feed_md5 = get_feed_md5(rss_list)
    if check_exists(feed_md5) and force != True:
        presigned = generate_presigned_url(feed_md5)
        return_item = {
            'msg': "This list already exists, here is a presigned url for it.",
            'url': presigned
        }
    else:
        master_feed_list = merge_remote_feeds( rss_list )
        upload_opml(feed_md5 , rss_list)
        rss_feed = generate_rss_feed(master_feed_list)
        presigned = upload_rss(feed_md5 ,rss_feed.tostring())
        return_item = {
            'msg': 'Created rss feed.',
            'url': "{}".format(presigned)
        }
    return return_item

def upload_rss(md5_key: str, file_uploaded: str):
    presigned_url = upload_feed(md5_key , file_uploaded, 'rss')
    return presigned_url

def get_rss(rss_path: str):
    return get_specific_obj(rss_path)

def update_feed(feed_md5: str, rss_path: str, rss_list: List[dict]) -> dict:
    updated_feed_list = []
    updated_feed_list.extend(merge_feeds(get_rss(rss_path).decode()))
    print('before update number: {}'.format(len(updated_feed_list)))
    updated_feed_list = merge_remote_feeds(rss_list, set(updated_feed_list))
    print('after update number: {}'.format(len(updated_feed_list)))
    rss_feed = generate_rss_feed(updated_feed_list)
    presigned = upload_rss(feed_md5 ,rss_feed.tostring())
    return_item = {
        'msg': 'Updated rss feed.',
        'url': "{}".format(presigned)
    }
    return return_item
