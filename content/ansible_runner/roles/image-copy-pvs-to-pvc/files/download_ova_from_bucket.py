import os
import sys
import json
import base64

from pathlib import Path
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad

import ibm_boto3
from ibm_botocore.client import Config, ClientError

wrkdir = os.path.dirname(os.path.realpath(__file__))

key  = os.environ.get('CREDS_AES_KEY')
iv   = os.environ.get('CREDS_AES_IV')
encr = Path(wrkdir + '/credentials.aes').read_text()

key  = base64.b64decode(key)
iv   = base64.b64decode(iv)
encr = base64.b64decode(encr)

cipher = AES.new(key, AES.MODE_CBC, iv)
creds = json.loads(unpad(cipher.decrypt(encr), AES.block_size).decode('utf-8'))

COS_ENDPOINT = creds['url_endpoint']
COS_BUCKET_LOCATION = creds['bucket_name']
COS_API_KEY_ID = creds['apikey']
COS_INSTANCE_CRN = creds['resource_instance_id']
IMAGE_NAME = sys.argv[1]
IMAGE_FL_PATH = sys.argv[2]

cos = ibm_boto3.client("s3", ibm_api_key_id=COS_API_KEY_ID, ibm_service_instance_id=COS_INSTANCE_CRN, config=Config(signature_version="oauth"), endpoint_url=COS_ENDPOINT)

cos.download_file(COS_BUCKET_LOCATION, IMAGE_NAME, IMAGE_FL_PATH)