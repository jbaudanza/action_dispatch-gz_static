# encoding: utf-8
require 'rack/utils'
require 'rack/mime'
require 'rack/file'
require 'active_support/core_ext/uri'

require 'action_dispatch/gz_railtie' if defined?(Rails)

module ActionDispatch
  class GzStatic
    def initialize(app, root, cache_control=nil)
      @app           = app
      @root          = root.chomp('/')
      @compiled_root = /^#{Regexp.escape(@root)}/
      @file_server   = ::Rack::File.new(@root, cache_control)
    end

    def match?(path)
      path = path.dup

      full_path = path.empty? ? @root : File.join(@root, escape_glob_chars(unescape_path(path)))
      paths = "#{full_path}#{ext}"

      matches = Dir[paths]
      matches.detect { |m| File.file?(m) }
    end

    def call(env)
      case env['REQUEST_METHOD']
      when 'GET', 'HEAD'
        path = env['PATH_INFO'].chomp('/')
        if match = match?(path)

          compressed_match = "#{match}.gz"
          compressed_exists = File.file?(compressed_match)
            
          wants_compressed = !!(env['HTTP_ACCEPT_ENCODING'] =~ /\bgzip\b/)

          if wants_compressed && compressed_exists
            mime = Rack::Mime.mime_type(::File.extname(match), 'text/plain')
            match = compressed_match
          end

          match.sub!(@compiled_root, '')
          env["PATH_INFO"] = ::Rack::Utils.escape(match)
          status, headers, body = @file_server.call(env)

          if compressed_exists
            headers['Vary'] = 'Accept-Encoding'

            if wants_compressed
              headers['Content-Encoding'] = 'gzip'
              headers['Content-Type'] = mime if mime
            end
          end

          return [status, headers, body]
        end
      end

      @app.call(env)
    end

    def ext
      @ext ||= begin
        #ext = ::ActionController::Base.default_static_extension
        ext = ".html"
        "{,#{ext},/index#{ext}}"
      end
    end

    def unescape_path(path)
      URI.parser.unescape(path)
    end

    def escape_glob_chars(path)
      path.force_encoding('binary') if path.respond_to? :force_encoding
      path.gsub(/[*?{}\[\]]/, "\\\\\\&")
    end
  end
end
