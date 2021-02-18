#!/usr/bin/env python3

import pathlib, json

def get_json_file(file_path: pathlib.Path):
    return json.loads(file_path.read_bytes())

def check_list(list_obj: list):
    if not isinstance(list_obj, list):
        print("Wasn't a list...weird should have been")
        print("obj: {}".format(list_obj))
        exit(2)

def get_reference_file(file_path: str, key_word: str):
    if key_word in file_path:
        return file_path


def main():
    dedups_file = pathlib.Path('/storage/backups/laptop.bak/linux/personal/2021-02-17-dupes.json')
    keep_top_level_folder_key = '20170328'

    json_obj = get_json_file(dedups_file)

    for dup in json_obj:

        check_list(dup['files'])

        old_ref = ''

        for file_path in dup['files']:

            ref_file = get_reference_file(file_path, keep_top_level_folder_key)
            if ref_file is None:
                ref_file = old_ref
            print(ref_file)

            old_ref = ref_file

if __name__ == "__main__":
    main()
