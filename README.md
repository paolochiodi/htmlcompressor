# Htmlcompressor
[![Build Status](https://travis-ci.org/paolochiodi/htmlcompressor.svg?branch=master)](https://travis-ci.org/paolochiodi/htmlcompressor)

## Put your html on a diet

Htmlcompressor provides tools to minify html code.
It includes
- HtmlCompressor::Compressor class which is a raw port of [google's htmlcompressor](http://code.google.com/p/htmlcompressor/)
- HtmlCompressor::Rack a rack middleware to compress html pages on the fly

Please note that Htmlcompressor is still in alpha version and need some additional love.

## Usage

Using the compressor class is straightforward:

```ruby
  compressor = HtmlCompressor::Compressor.new
  compressor.compress('<html><body><div id="compress_me"></div></body></html>')
```

The compressor ships with basic and safe default options that may be overwritten passing the options hash to the constructor:

```ruby
  options = {
    :enabled => true,
    :remove_multi_spaces => true,
    :remove_comments => true,
    :remove_intertag_spaces => false,
    :remove_quotes => false,
    :compress_css => false,
    :compress_javascript => false,
    :simple_doctype => false,
    :remove_script_attributes => false,
    :remove_style_attributes => false,
    :remove_link_attributes => false,
    :remove_form_attributes => false,
    :remove_input_attributes => false,
    :remove_javascript_protocol => false,
    :remove_http_protocol => false,
    :remove_https_protocol => false,
    :preserve_line_breaks => false,
    :simple_boolean_attributes => false
  }
```

Using rack middleware is as easy as:

```ruby
  config.middleware.use HtmlCompressor::Rack, options
```

The middleware uses a little more aggressive options by default:

```ruby
  options = {
    :enabled => true,
    :remove_multi_spaces => true,
    :remove_comments => true,
    :remove_intertag_spaces => false,
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
  }
```

Rails 2.3 users may need to add
```ruby
  require 'htmlcompressor'
```

## CSS and JavaScript Compression

By default CSS/JS compression is disabled.
In order to minify in page javascript and css, you need to supply a compressor in the options hash.
A compressor can be `:yui` or `:closure` or any object that responds to `:compress`. E.g.: `compressed = compressor.compress(source)`

```ruby

  class MyCompressor

    def compress(source)
      return 'minified'
    end

  end

  options = {
    :compress_css => true,
    :css_compressor => MyCompressor.new,
    :compress_javascript => true,
    :javascript_compressor => MyCompressor.new
  }

```

Please note that in order to use yui or closure compilers you need to manually add them to the Gemfile

```ruby
  gem 'yui-compressor'

  ...

  options = {
    :compress_javascript => true,
    :javascript_compressor => :yui,
    :compress_css => true
    :css_compressor => :yui
  }
```

```ruby
  gem 'closure-compiler'

  ...

  options = {
    :compress_javascript => true,
    :javascript_compressor => :closure
  }
```

## Statistics

As of now the statistic framework hasn't been ported. Refer to original [htmlcompressor documentation](http://code.google.com/p/htmlcompressor/) for statistics on minified pages.

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
