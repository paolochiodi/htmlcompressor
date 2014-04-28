require "htmlcompressor/compressor"
require "yui/compressor"

module HtmlCompressor
  class Compressor

    DEFAULT_OPTIONS.merge!(
      :javascript_compressor => YUI::JavaScriptCompressor.new(
        :munge => true,
        :preserve_semicolons => true,
        :optimize => true,
        :line_break => nil
      )
    )

  end
end
