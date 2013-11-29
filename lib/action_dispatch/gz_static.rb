# encoding: utf-8
require 'rack/mime'
require 'rack/file'

require 'action_dispatch/gz_railtie' if defined?(Rails)
require 'action_dispatch/middleware/static'
require 'action_controller'

module ActionDispatch
  class GzStatic < Static
    def call(env)
      return super unless %w[GET HEAD].include? env['REQUEST_METHOD']
      path = env['PATH_INFO'].chomp('/')
      return super unless @file_handler.match?(path)

      compressed_path = "#{path}.gz"

      compressed_exists = @file_handler.match?(compressed_path)
      wants_compressed  = env['HTTP_ACCEPT_ENCODING'] =~ /\bgzip\b/

      if wants_compressed && compressed_exists
        env["PATH_INFO"] = compressed_path
      end

      status, headers, body = super

      if compressed_exists
        headers['Vary'] = 'Accept-Encoding'

        if wants_compressed
          headers['Content-Encoding'] = 'gzip'
          mime = Rack::Mime.mime_type(::File.extname(path), 'text/plain')
          headers['Content-Type'] = mime if mime
        end
      end

      [status, headers, body]
    end
  end
end
