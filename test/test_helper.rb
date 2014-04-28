require 'minitest/autorun'
require 'htmlcompressor/compressor'

def reset_default_options!
  HtmlCompressor::Compressor::DEFAULT_OPTIONS.merge!(
    :compress_javascript => false,
    :javascript_compressor => nil,
    :compress_css => false,
    :css_compressor => nil
  )
end

module HtmlCompressor

  class TestCompressor < Minitest::Test

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
