#!/usr/bin/env ruby

require_relative 'lambda_errors'
require_relative 'lambda_server'
require_relative 'lambda_handler'
require_relative 'lambda_context'
require_relative 'lambda_logger'
require_relative 'aws_lambda_marshaller'

@env_handler = ENV["_HANDLER"]
@lambda_server = LambdaServer.new
STDOUT.sync = true # Ensures that logs are flushed promptly.
runtime_loop_active = true # if false, we will exit the program
exit_code = 0

begin
  @lambda_handler = LambdaHandler.new(env_handler: @env_handler)
  require @lambda_handler.handler_file_name
rescue Exception => e # which includes LoadError or any exception within static user code
  runtime_loop_active = false
  exit_code = -4
  ex = LambdaErrors::LambdaRuntimeInitError.new(e)
  LambdaLogger.log_error(exception: ex, message: "Init error when loading handler #{@env_handler}")
  @lambda_server.send_init_error(error_object: ex.to_lambda_response, error: ex)
end

while runtime_loop_active
  begin
    request_id, raw_request = @lambda_server.next_invocation
    if trace_id = raw_request['Lambda-Runtime-Trace-Id']
      ENV["_X_AMZN_TRACE_ID"] = trace_id
    end
    request = AwsLambda::Marshaller.marshall_request(raw_request)
  rescue LambdaErrors::InvocationError => e
    runtime_loop_active = false # ends the loop
    raise e # ends the process
  end

  begin
    context = LambdaContext.new(raw_request) # pass in opts
    # start of user code
    handler_response, content_type = @lambda_handler.call_handler(
      request: request,
      context: context
    )
    # end of user code
    @lambda_server.send_response(
      request_id: request_id,
      response_object: handler_response,
      content_type: content_type
    )
  rescue LambdaErrors::LambdaHandlerError => e
    LambdaLogger.log_error(exception: e, message: "Error raised from handler method")
    @lambda_server.send_error_response(
      request_id: request_id,
      error_object: e.to_lambda_response,
      error: e
    )
  rescue LambdaErrors::LambdaHandlerCriticalException => e
    LambdaLogger.log_error(exception: e, message: "Critical exception from handler")
    @lambda_server.send_error_response(
      request_id: request_id,
      error_object: e.to_lambda_response,
      error: e
    )
    runtime_loop_active = false
    exit_code = -1
  rescue LambdaErrors::LambdaRuntimeError => e
    @lambda_server.send_error_response(
      request_id: request_id,
      error_object: e.to_lambda_response,
      error: e
    )
    runtime_loop_active = false
    exit_code = -2
  end
end
exit(exit_code)
