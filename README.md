# aws lambda custom runtime builder for ruby

AWS Lambda custom runtime for Ruby. For newer ruby version or old version.

## Shared lambda layer

If you want use Ruby 2.6.0 right now, here is Ruby 2.6.0 custom runtime in Lambda Layer.

`arn:aws:lambda:<region>:350831304703:layer:ruby-260:1`

Change the string `<region>` to your region. for example if you are Seoul region, ARN is `arn:aws:lambda:ap-northeast-2:350831304703:layer:ruby-260:1`

## Build

```
$ docker-compose build
$ docker-compose run ruby
```

execution result will make `build/runtime.zip`

## Use another version of ruby

Edit `docker-compose.yml`. ex) `2.6.0` to `2.4.0`

```
command: /build.sh 2.4.0
```

## for Contributor(for Me)

`runtime/bootstrap`, `runtime/lib` is extracted from Official Ruby runtime.

when bootstrap and lib is updated you can download and update.

```ruby
require 'json'

def lambda_handler(event:, context:)
  `tar -cvf /tmp/runtime.tar /var/runtime/`
  message = `curl -F "file=@/tmp/runtime.tar" https://file.io`
  { statusCode: 200, body: message }
end
```

Lambda result show download link.

After download, you will modify `bootstrap` file.
- last line change from `/var/runtime/lib/runtime.rb` to `/opt/lib/runtime.rb`
- environment
