#!/usr/bin/env python3

import pathlib, json, argparse

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

def check_dup(key_word: str, ref_file: str, potential_dup: str):
    if ref_file:
        if not ref_file == potential_dup:
            trimming = ref_file.split(key_word)[0]
            comparing = ref_file.split(key_word)[1]
            # print(trimming)
            parsed_potential_dup = '/' + '/'.join(potential_dup.split(trimming)[1].split('/')[1:])

            if comparing == parsed_potential_dup:
                return potential_dup
            else:
                return None
    else:
        return None

def remove_file(file_path: pathlib.Path):
    try:
        print("removing file: {}".format(file_path))
        file_path.unlink()
    except FileNotFoundError as e:
        print("file didn't exist: {}".format(file_path))
        print("proceeding on though...")
        file_path.unlink(missing_ok=True)
    except Exception as e:
        print("unknown error happened: {}".format(file_path))
        exit(2)

def main():
    parser = argparse.ArgumentParser(description='This is used to ingest the .json file that fclones produces. After ingested it deletes file that are duplicates')

    parser.add_argument('fclones_file', help='This is the json file that fclones outputted')
    parser.add_argument('key_folder', help="Folder that is used to be the key reference folder")

    args = parser.parse_args()

    dedups_file = pathlib.Path(args.fclones_file)
    json_obj = get_json_file(dedups_file)
    deleted_files = 0

    for dup in json_obj:

        check_list(dup['files'])

        old_ref = ''

        for file_path in dup['files']:

            ref_file = get_reference_file(file_path, args.key_folder)
            if ref_file is None:
                ref_file = old_ref

            dup_file = check_dup(args.key_folder, ref_file, file_path)

            if dup_file:
                remove_file(pathlib.Path(dup_file))
                deleted_files += 1


            old_ref = ref_file
    
    print("Deleted {} files.".format(deleted_files))

if __name__ == "__main__":
    main()
