import boto3
from os import getenv

# not passing creds, because of this: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html#environment-variables
client = boto3.client('s3')
