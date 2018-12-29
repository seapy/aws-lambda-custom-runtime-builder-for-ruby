#!/bin/sh
RUBY_VERSION=$1
ruby-build $RUBY_VERSION /opt/ruby

TMP_BUILD_DIR=/tmp/build_tmp
mkdir -p $TMP_BUILD_DIR
mv /opt/ruby $TMP_BUILD_DIR/ruby
cp -r /tmp/runtime/* $TMP_BUILD_DIR

cd $TMP_BUILD_DIR
rm -rf /tmp/build/runtime.zip
zip -r /tmp/build/runtime.zip . -x "*.DS_Store"