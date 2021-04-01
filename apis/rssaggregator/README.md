

If you pass in a file for the form submission ( i.e. `-F 'selected_shows=<podcast.txt'` ), then make sure to add a comma at the end of the file. For some reason curl needs that to not mess up passing the last show specified.
