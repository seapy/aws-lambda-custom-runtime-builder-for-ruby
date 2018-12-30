# aws lambda custom runtime builder for ruby

This is for newer ruby version or old version.

## Shared lambda layer



## Build

```
$ docker-compose build
$ docker-compose run ruby
```

execution result will make `build/runtime.zip`

## Create Lambda Layer

```
$ ./upload.sh
```

or 

Upload `build/runtime.zip` use aws console webpage.

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
