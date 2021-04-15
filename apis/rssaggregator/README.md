# RSS Agregator

## Credits

- rss parser: <https://github.com/dhvcc/rss-parser>
- rss generator: <https://github.com/Dogeek/fastapi_rss/>
- opml parser: <https://pypi.org/project/opml/>
- fastapi: <https://github.com/tiangolo/fastapi> ⬅️ thanks to [@CoderRadioShow](https://twitter.com/CoderRadioShow) for mentioning this :grin: , made life a lot easier 😁

## Temp Docs

If you pass in a file for the form submission ( i.e. `-F 'selected_shows=<podcast.txt'` ), then make sure to add a comma at the end of the file. For some reason curl needs that to not mess up passing the last show specified.
