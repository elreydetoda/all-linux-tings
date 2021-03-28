import boto3
from os import getenv
from datetime import timezone

# not passing creds, because of this: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html#environment-variables
s3 = boto3.client('s3')
rss_folder = 'rss/'
opml_folder = 'opml/'

def bucket_init(BucketName: str) -> None:

    folders = [
        rss_folder,
        opml_folder
    ]

    for folder in folders:
        try:

            s3.get_object(
                Bucket = BucketName,
                Key = folder
            )

        except s3.exceptions.NoSuchKey:

            s3.put_object(
                Bucket = BucketName,
                Key = folder
            )

def get_all(object_type: str) -> dict:

    obj_key = ''
    if object_type == 'rss':
        obj_key = rss_folder
    elif object_type == 'opml':
        obj_key = opml_folder

    bucket_info = get_bucket_info()
    obj_response = s3.list_objects_v2(
        Bucket=bucket_info['bucket_name'],
        Prefix=obj_key
        )
    obj_contents = obj_response['Contents']

    obj_list = []

    for obj_object in obj_contents:
        if obj_object['Key'] != obj_key:
            obj_list.append(
                {
                    'Name': obj_object['Key'],
                    'LastModified': str(obj_object['LastModified'].replace(tzinfo=timezone.utc)) # https://stackoverflow.com/questions/57308678/how-to-create-a-datetime-object-with-tzinfo-set-as-utc#answer-57309278
                }
            )
    
    return obj_list

def get_bucket_info():
    bucket_info = {
        'bucket_name' : '{}'.format(getenv('BUCKET_NAME'))
    }
    bucket_init(bucket_info['bucket_name'])

    return bucket_info
