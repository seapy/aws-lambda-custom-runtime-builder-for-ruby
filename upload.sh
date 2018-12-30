#!/bin/sh

LAMBDA_LAYER_NAME='custom-ruby-260'

aws lambda publish-layer-version \
  --layer-name $LAMBDA_LAYER_NAME \
  --description "Custom Runtime for Ruby" \
  --compatible-runtimes provided \
  --license-info MIT \
  --zip-file fileb://build/runtime.zip
