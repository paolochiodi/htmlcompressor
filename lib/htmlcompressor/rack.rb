module HtmlCompressor

  class Rack

      def initialize app
        @app = app

        @compressor = Htmlcompressor::Compressor.new(
          :enabled => true,
          :remove_multi_spaces => true,
          :remove_comments => true,
          :remove_intertag_spaces => true,
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
          :remove_http_protocol => true,
          :remove_https_protocol => false,
          :preserve_line_breaks => false,
          :simple_boolean_attributes => true
        )

      end

      def call env
        status, headers, body = @app.call(env)

        if headers.key? 'Content-Type' and headers['Content-Type'] =~ /html/
          content = ''

          body.each do |part|
            content << part
          end

          content = @compressor.compress(content)
          headers['Content-Length'] = content.length.to_s if headers['Content-Length']

          [status, headers, [content]]
        else
          [status, headers, body]
        end
      ensure
        body.close if body.respond_to?(:close)
      end

  end

end