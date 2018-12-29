require 'json'

def handler(event:, context:)
  r = {
    version: "Current lambda ruby versions is #{RUBY_VERSION}",
    endless: [0, 1, 2][0..]
  }
  { statusCode: 200, body: JSON.generate(r) }
end
