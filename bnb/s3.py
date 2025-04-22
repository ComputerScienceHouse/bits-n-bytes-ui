import boto3
from botocore.exceptions import ClientError
import logging
import json
from pathlib import Path
import os
import argparse
import bnb.config

s3_key = os.getenv('BNB_S3_ACCESS_KEY')
s3_secret = os.getenv('BNB_S3_SECRET_KEY')
s3_url = os.getenv('BNB_S3_URL')


s3 = boto3.resource(
    's3', 
    endpoint_url=s3_url, 
    aws_access_key_id=s3_key, 
    aws_secret_access_key=s3_secret
)

def get_public_s3_url(bucket_name: str, region: str, file_name: str):
    return f"https://{bucket_name}.{s3_url}.com/{file_name}"

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

def get_s3_bucket(bucket_name: str):
    return s3.Bucket(bucket_name)

def put_s3_file(bucket_name: str, file_name: str, file_path: Path):
    with open(file_path, 'rb') as f:
        s3.Object(bucket_name, file_name).put(Body=f, ACL='public-read') 

def get_s3_file(bucket_name: str, file_name: str):
    return s3.Object(bucket_name, file_name)

def remove_s3_bucket(bucket_name: str):
    bucket = s3.Bucket(bucket_name)
    bucket.objects.all().delete() # delete all objects in bucket
    bucket.delete()

def create_s3_bucket(bucket_name: str):
    return s3.create_bucket(Bucket=bucket_name)

def list_s3_buckets():
    s3 = boto3.client('s3')
    try:
        response = s3.list_buckets()
        print("Buckets:")
        for bucket in response['Buckets']:
            print(f" - {bucket['Name']}")
    except Exception as e:
        print("❌ Failed to list buckets:", e)


def delete_s3_file(bucket_name: str, file_name: str):
    s3.Object(bucket_name, file_name).delete()

def main():
    parser = argparse.ArgumentParser(description="S3 Utility CLI")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Upload
    upload_parser = subparsers.add_parser("upload")
    upload_parser.add_argument("bucket", help="Bucket name")
    upload_parser.add_argument("key", help="Object key to use in S3")
    upload_parser.add_argument("file_path", help="Path to local file")

    # Download
    download_parser = subparsers.add_parser("download")
    download_parser.add_argument("bucket", help="Bucket name")
    download_parser.add_argument("key", help="Object key in S3")

    # Delete file
    delete_file_parser = subparsers.add_parser("delete-file")
    delete_file_parser.add_argument("bucket", help="Bucket name")
    delete_file_parser.add_argument("key", help="Object key to delete")

    # Create bucket
    create_bucket_parser = subparsers.add_parser("create-bucket")
    create_bucket_parser.add_argument("bucket", help="Bucket name")

    # Remove bucket
    remove_bucket_parser = subparsers.add_parser("remove-bucket")
    remove_bucket_parser.add_argument("bucket", help="Bucket name")

    gen_psurl_parser = subparsers.add_parser("gen-psurl")
    gen_psurl_parser.add_argument("bucket", help="Bucket name")
    gen_psurl_parser.add_argument("key", help="Object key to delete")

    get_public_parser = subparsers.add_parser("get-public-url")
    get_public_parser.add_argument("bucket", help="Bucket name")
    get_public_parser.add_argument("region", help="Region of bucket")
    get_public_parser.add_argument("key", help="Object key to delete")

    subparsers.add_parser("list-buckets")

    args = parser.parse_args()

    if args.command == "upload":
        put_s3_file(args.bucket, args.key, Path(args.file_path))
        print(f"Uploaded {args.file_path} to s3://{args.bucket}/{args.key}")

    elif args.command == "download":
        content = get_s3_file(args.bucket, args.key)
        print(f"Downloaded from s3://{args.bucket}/{args.key}")
        print(content)

    elif args.command == "delete-file":
        delete_s3_file(args.bucket, args.key)
        print(f"Deleted s3://{args.bucket}/{args.key}")

    elif args.command == "create-bucket":
        create_s3_bucket(args.bucket)
        print(f"Created bucket: {args.bucket}")

    elif args.command == "remove-bucket":
        remove_s3_bucket(args.bucket)
        print(f"Removed bucket: {args.bucket}")

    elif args.command == "gen-psurl":
        url = gen_s3_psurl(args.bucket, args.key)
        print(f"Generated {url} for {args.key}")

    elif args.command == "get-public-url":
        url = get_public_s3_url(args.bucket, args.region, args.key)
        print(f"Public url {url} for {args.key}")
        
    elif args.command == "list-buckets":
        list_s3_buckets()

if __name__ == "__main__":
    main()