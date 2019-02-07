#!/bin/bash -e

cd "`dirname $0`"

lambda_zip="./lambda_function-$(date +%Y-%m-%d).zip"

zip ./$lambda_zip ./source/main.py

aws s3 cp ./$lambda_zip s3://<bucket-name>/ --profile <profile>

