require 'htmlcompressor/compressor'
require 'minitest/autorun'
require 'closure-compiler'

module Htmlcompressor

  class TestCompressor < MiniTest::Unit::TestCase

    def setup
      @compressor = Compressor.new
    end

    def test_enabled
      source = read_resource("testEnabled.html")
      result = read_resource("testEnabledResult.html")

      @compressor.set_enabled(false);

      assert_equal result, @compressor.compress(source)
    end

    def test_remove_spaces_inside_tags
      source = read_resource("testRemoveSpacesInsideTags.html")
      result = read_resource("testRemoveSpacesInsideTagsResult.html")

      @compressor.set_remove_multi_spaces(false)

      assert_equal result, @compressor.compress(source)
    end

    def test_remove_comments
      source = read_resource("testRemoveComments.html")
      result = read_resource("testRemoveCommentsResult.html")

      @compressor.set_remove_comments(true)
      @compressor.set_remove_intertag_spaces(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_remove_quotes
      source = read_resource("testRemoveQuotes.html")
      result = read_resource("testRemoveQuotesResult.html")

      @compressor.set_remove_quotes(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_remove_multi_spaces
      source = read_resource("testRemoveMultiSpaces.html")
      result = read_resource("testRemoveMultiSpacesResult.html")

      @compressor.set_remove_multi_spaces(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_remove_intertag_spaces
      source = read_resource("testRemoveIntertagSpaces.html")
      result = read_resource("testRemoveIntertagSpacesResult.html")

      @compressor.set_remove_intertag_spaces(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_preserve_patterns
      source = read_resource("testPreservePatterns.html")
      result = read_resource("testPreservePatternsResult.html")

      preservePatterns = [
        Compressor::PHP_TAG_PATTERN,                                      # <?php ... ?> blocks
        Compressor::SERVER_SCRIPT_TAG_PATTERN,                            # <% ... %> blocks
        Compressor::SERVER_SIDE_INCLUDE_PATTERN,                          # <!--# ... --> blocks
        Regexp.new("<jsp:.*?>", Regexp::MULTILINE | Regexp::IGNORECASE)   # <jsp: ... > tags
      ]


      @compressor.set_preserve_patterns(preservePatterns)
      @compressor.set_remove_comments(true)
      @compressor.set_remove_intertag_spaces(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_compress_javascript_yui
      source = read_resource("testCompressJavaScript.html");
      result = read_resource("testCompressJavaScriptYuiResult.html");

      @compressor.set_compress_javascript(true);
      @compressor.set_remove_intertag_spaces(true);

      assert_equal result, @compressor.compress(source)
    end

    def test_compress_java_script_closure
      source = read_resource("testCompressJavaScript.html")
      result = read_resource("testCompressJavaScriptClosureResult.html")

      @compressor.set_compress_javascript(true)
      @compressor.set_javascript_compressor(Closure::Compiler.new(:compilation_level => 'ADVANCED_OPTIMIZATIONS'))
      @compressor.set_remove_intertag_spaces(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_compress_css
      source = read_resource("testCompressCss.html")
      result = read_resource("testCompressCssResult.html")

      @compressor.set_compress_css(true)
      @compressor.set_remove_intertag_spaces(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_compress
      source = read_resource("testCompress.html")
      result = read_resource("testCompressResult.html")

      assert_equal result, @compressor.compress(source)
    end

    def test_simple_doctype
      source = read_resource("testSimpleDoctype.html")
      result = read_resource("testSimpleDoctypeResult.html")

      @compressor.set_simple_doctype(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_remove_script_attributes
      source = read_resource("testRemoveScriptAttributes.html")
      result = read_resource("testRemoveScriptAttributesResult.html")

      @compressor.set_remove_script_attributes(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_remove_style_attributes
      source = read_resource("testRemoveStyleAttributes.html")
      result = read_resource("testRemoveStyleAttributesResult.html")

      @compressor.set_remove_style_attributes(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_remove_link_attributes
      source = read_resource("testRemoveLinkAttributes.html")
      result = read_resource("testRemoveLinkAttributesResult.html")

      @compressor.set_remove_link_attributes(true)

      assert_equal result, @compressor.compress(source)
    end

    def test_remove_form_attributes
      source = read_resource("testRemoveFormAttributes.html")
      result = read_resource("testRemoveFormAttributesResult.html")

      @compressor.set_remove_form_attributes(true)

      assert_equal result, @compressor.compress(source)
    end

    private

    def resource_path
      File.join File.expand_path(File.dirname(__FILE__)), 'resources', 'html'
    end

    def read_resource file
      File.open File.join(resource_path, file), 'r' do |f|
        return f.readlines.join('')
      end
    end

  end

end