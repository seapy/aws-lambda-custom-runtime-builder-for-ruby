
```
$ zip hello.zip hello.rb
$ aws lambda create-function \
    --function-name ruby260_test \
    --runtime provided \
    --memory-size 128 \
    --handler hello.handler \
    --layers arn:aws:lambda:ap-northeast-2:xxxxx:layer:custom-ruby-260:1 \
    --role arn:aws:iam::xxxxx:role/service-role/lambda-basic-role \
    --zip-file fileb://hello.zip
$ aws lambda invoke --function-name ruby260_test output.txt
$ cat output.txt
```