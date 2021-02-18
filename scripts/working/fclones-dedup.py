#!/usr/bin/env python3

import pathlib, json

def get_json_file(file_path: pathlib.Path):
    return json.loads(file_path.read_bytes())

# def get_reference_file(files_list: list):



def main():
    dedups_file = pathlib.Path('/storage/backups/laptop.bak/linux/personal/2021-02-17-dupes.json')
    keep_top_level_folder_key = '20170328'

    json_obj = get_json_file(dedups_file)

    for dup in json_obj:
        print(type(dup))
        print(dup)

if __name__ == "__main__":
    main()
