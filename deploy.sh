#!/bin/sh

set -e

if [ -z "$LAMBDA_LAYER_NAME" ]; then
  LAMBDA_LAYER_NAME="ruby-260"
fi

# Lambda upload from S3 need same region bucket. maybe sometime this restrict sloved.
# LAYER_S3_BUCKET='seapy-tmp'
# LAYER_S3_PATH='lambda/custom_runtime_ruby.zip'
# echo Upload to S3
# aws s3 cp build/runtime.zip s3://$LAYER_S3_BUCKET/$LAYER_S3_PATH

regions=($(aws ec2 describe-regions --query "Regions[].{Name:RegionName}" --output text))
for region in "${regions[@]}" ; do
  echo Deploy to $region
  AWS_DEFAULT_REGION=$region \
    LAMBDA_LAYER_NAME=$LAMBDA_LAYER_NAME \
    LAYER_S3_BUCKET=$LAYER_S3_BUCKET \
    LAYER_S3_PATH=$LAYER_S3_PATH \
    ./publish_layer.sh
done
