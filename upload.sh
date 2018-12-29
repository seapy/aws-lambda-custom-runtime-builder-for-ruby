#!/bin/sh

aws lambda publish-layer-version \
  --layer-name custom-ruby-260 \
  --description "Custom Runtime for Ruby" \
  --compatible-runtimes provided \
  --license-info MIT \
  --zip-file fileb://build/runtime.zip
