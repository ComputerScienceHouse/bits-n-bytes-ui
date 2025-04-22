import boto3
from botocore.exceptions import ClientError
import logging
import json
from pathlib import Path
import os
import argparse
import config
import typer

s3_cli = typer.Typer()

s3_key = os.getenv('BNB_S3_ACCESS_KEY')
s3_secret = os.getenv('BNB_S3_SECRET_KEY')
s3_url = os.getenv('BNB_S3_URL')


s3_resource = boto3.resource(
    's3', 
    endpoint_url=s3_url, 
    aws_access_key_id=s3_key, 
    aws_secret_access_key=s3_secret
)

@s3_cli.command('get-public-url')
def get_public_s3_url(bucket_name: str, region: str, file_name: str):
    return f"https://{bucket_name}.{s3_url}.com/{file_name}"

@s3_cli.command('gen-s3-psurl')
def gen_s3_psurl(bucket_name: str, file_name: str):
    s3_client = s3.meta.client
    try:
        psurl = s3_client.generate_presigned_url(
            'get_object', 
            Params={'Bucket':bucket_name,'Key':file_name}
            )
    except ClientError as e:
        logging.error(e)
        return None

    return psurl

@s3_cli.command('get-s3-bucket')
def get_s3_bucket(bucket_name: str):
    return s3_resource.Bucket(bucket_name)

@s3_cli.command('put-s3-file')
def put_s3_file(bucket_name: str, file_name: str, file_path: Path):
    with open(file_path, 'rb') as f:
        s3_resource.Object(bucket_name, file_name).put(Body=f, ACL='public-read') 

@s3_cli.command('get-s3-file')
def get_s3_file(bucket_name: str, file_name: str):
    return s3_resource.Object(bucket_name, file_name)

@s3_cli.command('remove-s3-bucket')
def remove_s3_bucket(bucket_name: str):
    bucket = s3_resource.Bucket(bucket_name)
    bucket.objects.all().delete() # delete all objects in bucket
    bucket.delete()

@s3_cli.command('create-s3-bucket')
def create_s3_bucket(bucket_name: str):
    return s3_resource.create_bucket(Bucket=bucket_name)

@s3_cli.command('list-s3-bucket')
def list_s3_buckets():
    s3 = boto3.client('s3')
    try:
        response = s3.list_buckets()
        print("Buckets:")
        for bucket in response['Buckets']:
            print(f" - {bucket['Name']}")
    except Exception as e:
        print("❌ Failed to list buckets:", e)


@s3_cli.command('delete-s3-file')
def delete_s3_file(bucket_name: str, file_name: str):
    s3_resource.Object(bucket_name, file_name).delete()