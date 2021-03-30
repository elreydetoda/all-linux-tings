from datetime import datetime
from typing import Optional, List

from fastapi import __version__ as faversion
from lxml import etree
from pydantic import BaseModel

from fastapi_rss import __version__ as farssversion
from fastapi_rss.utils import get_locale_code, to_camelcase
from fastapi_rss.models.category import Category
from fastapi_rss.models.cloud import Cloud
from fastapi_rss.models.image import Image
from fastapi_rss.models.textinput import TextInput
from fastapi_rss.models.item import Item
from fastapi_rss.models.feed import RSSFeed


class NewRSSFeed(RSSFeed):

    @staticmethod
    def generate_tree(root, dict_):
        for key, value in dict_.items():
            if value is None:
                continue
            if isinstance(value, list):
                for item in value:
                    attrs = item.pop('attrs', {})
                    content = item.pop('content', None)
                    itemroot = etree.SubElement(root, to_camelcase(key), attrs)
                    if content is not None:
                        itemroot.text = content
                    else:
                        NewRSSFeed.generate_tree(itemroot, item)
                continue

            if isinstance(value, BaseModel) or isinstance(value, dict):
                if hasattr(value, 'attrs'):
                    attrs = value.attrs.dict()
                elif 'attrs' in value:
                    attrs = value['attrs']
                    if 'length' in attrs:
                        # overriding length to be a string, because SeubElement ( first below )A
                        #   doesn't like ints
                        attrs['length'] = str(attrs['length'])
                else:
                    attrs = {}

                if hasattr(value, 'content'):
                    content = value.content
                elif 'content' in value:
                    content = value['content']
                else:
                    content = None

                if key == 'itunes':
                    element = etree.SubElement( root, '{http://www.itunes.com/dtds/podcast-1.0.dtd}image', attrs)
                    continue

                element = etree.SubElement(root, to_camelcase(key), attrs)
                if content:
                    element.text = content
                continue

            if isinstance(value, datetime):
                value = value.strftime('%a, %d %b %Y %H:%M:%S GMT')
            element = etree.SubElement(root, to_camelcase(key))
            element.text = str(value)

    def tostring(self):
        nsmap = {
            'itunes': "http://www.itunes.com/dtds/podcast-1.0.dtd"
        }
        rss = etree.Element('rss', version='2.0', nsmap=nsmap)
        channel = etree.SubElement(rss, 'channel')
        NewRSSFeed.generate_tree(channel, self.dict())
        return etree.tostring(rss, pretty_print=True)

class ItunesAttrs(BaseModel):
    url: str

class Itunes(BaseModel):
    content: str
    attrs: Optional[ItunesAttrs]


class NewItem(Item):
    itunes: Optional[Itunes]
