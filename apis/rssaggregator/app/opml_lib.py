import opml
from typing import Optional,TextIO
from pathlib import Path

def get_feeds(opml_text: bytes, selected_shows: Optional[list] = None ) -> list:
    if selected_shows:
        print('These are the selected shows: {}'.format(', '.join(selected_shows)))
    opml_feeds = opml.from_string(opml_text)

    filtered_feeds = []

    if selected_shows:
        # https://stackoverflow.com/questions/59825/how-to-retrieve-an-element-from-a-set-without-removing-it#answer-59841
        first_obj = next(iter(selected_shows))
        if first_obj != '':
            opml_feeds = filter_shows( opml_feeds, selected_shows)

    for feed in opml_feeds:
        if feed.type == 'rss':
            filtered_feeds.append(
                {
                    'feed_name': feed.title,
                    'feed_url': feed.htmlUrl
                }
            )
        else:
            raise Exception("Your file had a non rss value.")
        
    show_names = [ show['feed_name'] for show in filtered_feeds ]
    print('This is the filtered show list: {}'.format(', '.join(show_names)))
    return filtered_feeds

def filter_shows(opml_list: list, selected_shows: list) -> list:
    filtered_list = []
    for feed in opml_list:
        if feed.title in selected_shows:
            filtered_list.append(feed)
    
    return filtered_list
