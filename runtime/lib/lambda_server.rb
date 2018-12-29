require 'net/http'
require 'json'

class LambdaServer
  LAMBDA_SERVER_ADDRESS = "http://127.0.0.1:9001/2018-06-01"

  LONG_TIMEOUT = 1_000_000

  def initialize(server_address: LAMBDA_SERVER_ADDRESS)
    @server_address = server_address
  end

  def next_invocation
    next_invocation_uri = URI(@server_address + "/runtime/invocation/next")
    begin
      http = Net::HTTP.new(next_invocation_uri.host, next_invocation_uri.port)
      http.read_timeout = LONG_TIMEOUT
      resp = http.start do |http|
        http.get(next_invocation_uri.path)
      end
      if resp.is_a?(Net::HTTPSuccess)
        request_id = resp["Lambda-Runtime-Aws-Request-Id"]
        [request_id, resp]
      else
        raise LambdaErrors::InvocationError.new(
          "Received #{resp.code} when waiting for next invocation."
        )
      end
    rescue LambdaErrors::InvocationError => e
      raise e
    rescue StandardError => e
      raise LambdaErrors::InvocationError.new(e)
    end
  end

  def send_response(request_id:, response_object:, content_type: 'application/json')
    response_uri = URI(
      @server_address + "/runtime/invocation/#{request_id}/response"
    )
    begin
      # unpack IO at this point
      if content_type == 'application/unknown'
        response_object = response_object.read
      end
      Net::HTTP.post(
        response_uri,
        response_object,
        {'Content-Type' => content_type}
      )
    rescue StandardError => e
      raise LambdaErrors::LambdaRuntimeError.new(e)
    end
  end

  def send_error_response(request_id:, error_object:, error:)
    response_uri = URI(
      @server_address + "/runtime/invocation/#{request_id}/error"
    )
    begin
      Net::HTTP.post(
        response_uri,
        error_object.to_json,
        { 'Lambda-Runtime-Function-Error-Type' => error.runtime_error_type }
      )
    rescue StandardError => e
      raise LambdaErrors::LambdaRuntimeError.new(e)
    end
  end

  def send_init_error(error_object:, error:)
    uri = URI(
      @server_address + "/runtime/init/error"
    )
    begin
      Net::HTTP.post(
        uri,
        error_object.to_json,
        {'Lambda-Runtime-Function-Error-Type' => error.runtime_error_type}
      )
    rescue StandardError
      raise LambdaErrors::LambdaRuntimeInitError.new(e)
    end
  end
end
