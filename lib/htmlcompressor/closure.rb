require "htmlcompressor/compressor"
require "closure-compiler"

module HtmlCompressor
  class Compressor

    DEFAULT_OPTIONS.merge!(
      :javascript_compressor => Closure::Compiler.new(
        :compilation_level => 'ADVANCED_OPTIMIZATIONS'
      )
    )

  end
end
