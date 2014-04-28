require "htmlcompressor/compressor"
require "yui/compressor"

module HtmlCompressor
  class Compressor

    DEFAULT_OPTIONS.merge!(
      :css_compressor => YUI::CssCompressor.new(
        :line_break => -1
      )
    )

  end
end
