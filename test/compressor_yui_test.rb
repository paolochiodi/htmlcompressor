require 'test_helper'
reset_default_options!
require 'htmlcompressor/yui'

module HtmlCompressor

  class TestCompressor < Minitest::Test

    def test_compress_javascript_yui
      source = read_resource("testCompressJavaScript.html");
      result = read_resource("testCompressJavaScriptYuiResult.html");

      compressor = Compressor.new(
        :compress_javascript => true,
        :remove_intertag_spaces => true
      )

      assert_equal result, compressor.compress(source)
    end

    def test_compress_css
      source = read_resource("testCompressCss.html")
      result = read_resource("testCompressCssResult.html")

      compressor = Compressor.new(
        :compress_css => true,
        :remove_intertag_spaces => true
      )

      assert_equal result, compressor.compress(source)
    end

  end

end
