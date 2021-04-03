from botocore import retries
from rss_parser import Parser
from requests import get as r_get
from typing import List
from datetime import datetime,timezone
from fastapi_rss.rss_response import RSSResponse as NewRSSResponse
from fastapi_rss.models import Item as NewRssItem
from os import SEEK_SET
from hashlib import md5
from object_stor import check_md5sum, generate_presigned_url, upload_feed, get_specific_obj
from opml_lib import upload_opml
from parser_override import NewParser
from generator_override import NewRSSFeed, NewItem

def get_feed_item_date(obj):
    obj.publish_date
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
    return obj.publish_date

def merge_feeds(rss_unmerged_list: List[dict]) -> List:
    headerz= {
        # adding because some websites blocked python headers...
        #   specifically s3daily
        'User-Agent': 'curl'
    }

    rss_merged_list = []

    for rss_feed in rss_unmerged_list:
        # print(rss_feed['feed_url'])
        try:
            feed_contents = r_get(rss_feed['feed_url'], headers=headerz)
        except Exception as e:
            print('WARNING:\n{}had the following error for url: {}\n: {}'.format(rss_feed['feed_name'], rss_feed['feed_url'], e))
            continue
        # rss_parser._parser.Parser
        parser = NewParser(xml=feed_contents.content, limit=5)
        # rss_parser.models.RSSFeed
        meta_feed = parser.parse()
        for feed_item in meta_feed.feed:
            # rss_parser.models.FeedItem
            feed_item.category = meta_feed.title
            rss_merged_list.append(feed_item)
    
    return rss_merged_list.sort(key=get_feed_item_date, reverse=True)

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

def generate_rss_feed(rss_items: list) -> NewRSSResponse:
    feed_data = {
        'title': "Alex's Master Feed",
        'link': '',
        'description': 'All my favorite rss feeds into one',
        'last_build_date': datetime.now(tz=timezone.utc).isoformat(),
        'ttl': 30,
        'item': convert_to_new_rss_items(rss_items)
    }
    return NewRSSFeed(**feed_data)

def get_master_feed(rss_list: List[dict], force: bool) -> str:

    return_item = {}
    feed_md5 = get_feed_md5(rss_list)
    if check_exists(feed_md5) and force != True:
        presigned = generate_presigned_url(feed_md5)
        return_item = {
            'msg': "This list already exists, here is a presigned url for it.",
            'url': presigned
        }
    else:
        master_feed_list = merge_feeds( rss_list )
        shows_name_list = [ curr_show['feed_name'] for curr_show in rss_list ]
        upload_opml(feed_md5 , shows_name_list)
        rss_feed = generate_rss_feed(master_feed_list)
        presigned = upload_rss(feed_md5 ,rss_feed.tostring())
        # tmp_file = NamedTemporaryFile()
        # tmp_file.write(rss_feed.tostring())
        # tmp_file.seek(SEEK_SET)
        # presigned = upload_rss_feed(feed_md5 ,tmp_file.read())
        # tmp_file.close()
        return_item = {
            'url': "{}".format(presigned)
        }
    return return_item

def upload_rss(md5_key: str, file_uploaded: str):
    presigned_url = upload_feed(md5_key , file_uploaded, 'rss')
    return presigned_url

def get_rss(rss_path: str):
    print(get_specific_obj(rss_path))
    print(type(get_specific_obj(rss_path)))
    return ''

def update_feed(rss_path: str, rss_list: List[dict]) -> str:
    get_rss(rss_path)
    return ''
