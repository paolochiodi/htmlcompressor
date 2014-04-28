require 'test_helper'
reset_default_options!
require 'htmlcompressor/closure'

module HtmlCompressor

  class TestCompressor < Minitest::Test

    def test_compress_java_script_closure
      source = read_resource("testCompressJavaScript.html")
      result = read_resource("testCompressJavaScriptClosureResult.html")

      compressor = Compressor.new(
        :compress_javascript => true,
        # :javascript_compressor => Closure::Compiler.new(:compilation_level => 'ADVANCED_OPTIMIZATIONS'),
        :remove_intertag_spaces => true
      )

      assert_equal result, compressor.compress(source)
    end

  end

end
