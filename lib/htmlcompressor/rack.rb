module HtmlCompressor

  class Rack

      def initialize app
        @app = app

        @compressor = Htmlcompressor::Compressor.new
        @compressor.set_enabled true
        @compressor.set_remove_multi_spaces true
        @compressor.set_remove_comments true
        @compressor.set_remove_intertag_spaces true
        @compressor.set_remove_quotes true
        @compressor.set_compress_css false
        @compressor.set_compress_javascript false
        @compressor.set_simple_doctype false
        @compressor.set_remove_script_attributes true
        @compressor.set_remove_style_attributes true
        @compressor.set_remove_link_attributes true
        @compressor.set_remove_form_attributes false
        @compressor.set_remove_input_attributes true
        @compressor.set_remove_javascript_protocol true
        @compressor.set_remove_http_protocol true
        @compressor.set_remove_https_protocol false
        @compressor.set_preserve_line_breaks false
        @compressor.set_simple_boolean_attributes true
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