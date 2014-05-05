require 'test_helper'

module HtmlCompressor

  class TestCompressor < Minitest::Test

    def test_compress_java_script_closure
      source = read_resource("testCompressJavaScript.html")
      result = read_resource("testCompressJavaScriptClosureResult.html")

      compressor = Compressor.new(
        :compress_javascript => true,
        :javascript_compressor => :closure,
        :remove_intertag_spaces => true
      )

      assert_equal result, compressor.compress(source)
    end

  end

end
