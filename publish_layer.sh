#!/bin/sh

if [ -z "$LAMBDA_LAYER_NAME" ]; then
  echo "ERROR : Environment LAMBDA_LAYER_NAME is not set" >&2
  exit 1
fi

# if [ -z "$LAYER_S3_BUCKET" ]; then
#   echo "ERROR : Environment LAYER_S3_BUCKET is not set" >&2
#   exit 1
# fi

# if [ -z "$LAYER_S3_PATH" ]; then
#   echo "ERROR : Environment LAYER_S3_PATH is not set" >&2
#   exit 1
# fi

aws lambda publish-layer-version \
  --layer-name $LAMBDA_LAYER_NAME \
  --description "Custom Runtime for Ruby" \
  --compatible-runtimes provided \
  --license-info MIT \
  --zip-file fileb://build/runtime.zip
  # --content S3Bucket=$LAYER_S3_BUCKET,S3Key=$LAYER_S3_PATH

aws lambda add-layer-version-permission \
  --layer-name $LAMBDA_LAYER_NAME \
  --version-number 1 \
  --statement-id share_all \
  --principal '*' \
  --action lambda:GetLayerVersion