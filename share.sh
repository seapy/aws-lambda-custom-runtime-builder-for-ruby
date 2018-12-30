#!/bin/sh

LAMBDA_LAYER_NAME='custom-ruby-260'

aws lambda add-layer-version-permission \
  --layer-name $LAMBDA_LAYER_NAME \
  --version-number 2 \
  --statement-id share_all \
  --principal '*' \
  --action lambda:GetLayerVersion