# patch for rack.rb of HtmlCompressor
module HtmlCompressor

  class Rack

    DEFAULT_OPTIONS = {
        :enabled => true,
        :remove_multi_spaces => true,
        :remove_comments => true,
        :remove_intertag_spaces => false,
        :remove_quotes => true,
        :compress_css => false,
        :compress_javascript => false,
        :simple_doctype => false,
        :remove_script_attributes => true,
        :remove_style_attributes => true,
        :remove_link_attributes => true,
        :remove_form_attributes => false,
        :remove_input_attributes => true,
        :remove_javascript_protocol => true,
        :remove_http_protocol => false,
        :remove_https_protocol => false,
        :preserve_line_breaks => false,
        :simple_boolean_attributes => true,
        :compress_by_default => true
    }

    def initialize app, options = {}
      @app = app

      @options = DEFAULT_OPTIONS.merge(options)

      @compressor = HtmlCompressor::Compressor.new(@options)

    end

    def call env
      status, headers, body = @app.call(env)

      path = Rails.application.routes.recognize_path(env['PATH_INFO'])
      compress_info = path[:compress]
      should_we_compress = @options[:compress_by_default]
      if (compress_info == true)
        should_we_compress = true
      elsif (compress_info == false)
        should_we_compress = false
      else (compress_info == nil)
        # Do nothing, leave default
      end

      if headers.key? 'Content-Type' and headers['Content-Type'] =~ /html/ and should_we_compress
        content = ''

        body.each do |part|
          content << part
        end

        content = @compressor.compress(content)
        headers['Content-Length'] = content.bytesize.to_s if headers['Content-Length']

        [status, headers, [content]]
      else
        [status, headers, body]
      end
    ensure
      body.close if body.respond_to?(:close)
    end

  end

end