require "yui/compressor"

module Htmlcompressor
  class Compressor

    JS_COMPRESSOR_YUI = "yui";
    JS_COMPRESSOR_CLOSURE = "closure";

    # Predefined pattern that matches <code>&lt;?php ... ?></code> tags.
    # Could be passed inside a list to {@link #setPreservePatterns(List) setPreservePatterns} method.
    PHP_TAG_PATTERN = /<\?php.*?\?>/im

    # Predefined pattern that matches <code>&lt;% ... %></code> tags.
    # Could be passed inside a list to {@link #setPreservePatterns(List) setPreservePatterns} method.
    SERVER_SCRIPT_TAG_PATTERN = /<%.*?%>/m

    # Predefined pattern that matches <code>&lt;--# ... --></code> tags.
    # Could be passed inside a list to {@link #setPreservePatterns(List) setPreservePatterns} method.
    SERVER_SIDE_INCLUDE_PATTERN = /<!--\s*#.*?-->/m

    # Predefined list of tags that are very likely to be block-level.
    #Could be passed to {@link #setRemoveSurroundingSpaces(String) setRemoveSurroundingSpaces} method.
    BLOCK_TAGS_MIN = "html,head,body,br,p"

    # Predefined list of tags that are block-level by default, excluding <code>&lt;div></code> and <code>&lt;li></code> tags.
    #Table tags are also included.
    #Could be passed to {@link #setRemoveSurroundingSpaces(String) setRemoveSurroundingSpaces} method.
    BLOCK_TAGS_MAX = BLOCK_TAGS_MIN + ",h1,h2,h3,h4,h5,h6,blockquote,center,dl,fieldset,form,frame,frameset,hr,noframes,ol,table,tbody,tr,td,th,tfoot,thead,ul"

    # Could be passed to {@link #setRemoveSurroundingSpaces(String) setRemoveSurroundingSpaces} method
    # to remove all surrounding spaces (not recommended).
    ALL_TAGS = "all"

    # temp replacements for preserved blocks
    TEMP_COND_COMMENT_BLOCK = "%%%~COMPRESS~COND~{0,number,#}~%%%"
    TEMP_PRE_BLOCK = "%%%~COMPRESS~PRE~{0,number,#}~%%%"
    TEMP_TEXT_AREA_BLOCK = "%%%~COMPRESS~TEXTAREA~{0,number,#}~%%%"
    TEMP_SCRIPT_BLOCK = "%%%~COMPRESS~SCRIPT~{0,number,#}~%%%"
    TEMP_STYLE_BLOCK = "%%%~COMPRESS~STYLE~{0,number,#}~%%%"
    TEMP_EVENT_BLOCK = "%%%~COMPRESS~EVENT~{0,number,#}~%%%"
    TEMP_LINE_BREAK_BLOCK = "%%%~COMPRESS~LT~{0,number,#}~%%%"
    TEMP_SKIP_BLOCK = "%%%~COMPRESS~SKIP~{0,number,#}~%%%"
    TEMP_USER_BLOCK = "%%%~COMPRESS~USER{0,number,#}~{1,number,#}~%%%"

    # compiled regex patterns
    EMPTY_PATTERN = Regexp.new("\\s")
    SKIP_PATTERN = Regexp.new("<!--\\s*\\{\\{\\{\\s*-->(.*?)<!--\\s*\\}\\}\\}\\s*-->", Regexp::MULTILINE | Regexp::IGNORECASE)
    COND_COMMENT_PATTERN = Regexp.new("(<!(?:--)?\\[[^\\]]+?]>)(.*?)(<!\\[[^\\]]+]-->)", Regexp::MULTILINE | Regexp::IGNORECASE)
    COMMENT_PATTERN = Regexp.new("<!---->|<!--[^\\[].*?-->", Regexp::MULTILINE | Regexp::IGNORECASE)
    INTERTAG_PATTERN_TAG_TAG = Regexp.new(">\\s+<", Regexp::MULTILINE | Regexp::IGNORECASE)
    INTERTAG_PATTERN_TAG_CUSTOM = Regexp.new(">\\s+%%%~", Regexp::MULTILINE | Regexp::IGNORECASE)
    INTERTAG_PATTERN_CUSTOM_TAG = Regexp.new("~%%%\\s+<", Regexp::MULTILINE | Regexp::IGNORECASE)
    INTERTAG_PATTERN_CUSTOM_CUSTOM = Regexp.new("~%%%\\s+%%%~", Regexp::MULTILINE | Regexp::IGNORECASE)
    MULTISPACE_PATTERN = Regexp.new("\\s+", Regexp::MULTILINE | Regexp::IGNORECASE)
    TAG_END_SPACE_PATTERN = Regexp.new("(<(?:[^>]+?))(?:\\s+?)(/?>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    TAG_LAST_UNQUOTED_VALUE_PATTERN = Regexp.new("=\\s*[a-z0-9-_]+$", Regexp::IGNORECASE)
    TAG_QUOTE_PATTERN = Regexp.new("\\s*=\\s*([\"'])([a-z0-9-_]+?)\\1(/?)(?=[^<]*?>)", Regexp::IGNORECASE)
    PRE_PATTERN = Regexp.new("(<pre[^>]*?>)(.*?)(</pre>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    TA_PATTERN = Regexp.new("(<textarea[^>]*?>)(.*?)(</textarea>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    SCRIPT_PATTERN = Regexp.new("(<script[^>]*?>)(.*?)(</script>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    STYLE_PATTERN = Regexp.new("(<style[^>]*?>)(.*?)(</style>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    TAG_PROPERTY_PATTERN = Regexp.new("(\\s\\w+)\\s*=\\s*(?=[^<]*?>)", Regexp::IGNORECASE)
    CDATA_PATTERN = Regexp.new("\\s*<!\\[CDATA\\[(.*?)\\]\\]>\\s*", Regexp::MULTILINE | Regexp::IGNORECASE)
    DOCTYPE_PATTERN = Regexp.new("<!DOCTYPE[^>]*>", Regexp::MULTILINE | Regexp::IGNORECASE)
    TYPE_ATTR_PATTERN = Regexp.new("type\\s*=\\s*([\\\"']*)(.+?)\\1", Regexp::MULTILINE | Regexp::IGNORECASE)
    JS_TYPE_ATTR_PATTERN = Regexp.new("(<script[^>]*)type\\s*=\\s*([\"']*)(?:text|application)\/javascript\\2([^>]*>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    JS_LANG_ATTR_PATTERN = Regexp.new("(<script[^>]*)language\\s*=\\s*([\"']*)javascript\\2([^>]*>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    STYLE_TYPE_ATTR_PATTERN = Regexp.new("(<style[^>]*)type\\s*=\\s*([\"']*)text/style\\2([^>]*>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    LINK_TYPE_ATTR_PATTERN = Regexp.new("(<link[^>]*)type\\s*=\\s*([\"']*)text/(?:css|plain)\\2([^>]*>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    LINK_REL_ATTR_PATTERN = Regexp.new("<link(?:[^>]*)rel\\s*=\\s*([\"']*)(?:alternate\\s+)?stylesheet\\1(?:[^>]*)>", Regexp::MULTILINE | Regexp::IGNORECASE)
    FORM_METHOD_ATTR_PATTERN = Regexp.new("(<form[^>]*)method\\s*=\\s*([\"']*)get\\2([^>]*>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    INPUT_TYPE_ATTR_PATTERN = Regexp.new("(<input[^>]*)type\\s*=\\s*([\"']*)text\\2([^>]*>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    BOOLEAN_ATTR_PATTERN = Regexp.new("(<\\w+[^>]*)(checked|selected|disabled|readonly)\\s*=\\s*([\"']*)\\w*\\3([^>]*>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    EVENT_JS_PROTOCOL_PATTERN = Regexp.new("^javascript:\\s*(.+)", Regexp::MULTILINE | Regexp::IGNORECASE)
    HTTP_PROTOCOL_PATTERN = Regexp.new("(<[^>]+?(?:href|src|cite|action)\\s*=\\s*['\"])http:(//[^>]+?>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    HTTPS_PROTOCOL_PATTERN = Regexp.new("(<[^>]+?(?:href|src|cite|action)\\s*=\\s*['\"])https:(//[^>]+?>)", Regexp::MULTILINE | Regexp::IGNORECASE)
    REL_EXTERNAL_PATTERN = Regexp.new("<(?:[^>]*)rel\\s*=\\s*([\"']*)(?:alternate\\s+)?external\\1(?:[^>]*)>", Regexp::MULTILINE | Regexp::IGNORECASE)
    EVENT_PATTERN1 = Regexp.new("(\\son[a-z]+\\s*=\\s*\")([^\"\\\\\\r\\n]*(?:\\\\.[^\"\\\\\\r\\n]*)*)(\")", Regexp::IGNORECASE) # unmasked: \son[a-z]+\s*=\s*"[^"\\\r\n]*(?:\\.[^"\\\r\n]*)*""
    EVENT_PATTERN2 = Regexp.new("(\\son[a-z]+\\s*=\\s*')([^'\\\\\\r\\n]*(?:\\\\.[^'\\\\\\r\\n]*)*)(')", Regexp::IGNORECASE)
    LINE_BREAK_PATTERN = Regexp.new("(?:\\p{Blank}*(\\r?\\n)\\p{Blank}*)+")
    SURROUNDING_SPACESMIN_PATTERN = Regexp.new("\\s*(</?(?:" + BLOCK_TAGS_MIN.gsub(",", "|") + ")(?:>|[\\s/][^>]*>))\\s*", Regexp::MULTILINE | Regexp::IGNORECASE)
    SURROUNDING_SPACESMAX_PATTERN = Regexp.new("\\s*(</?(?:" + BLOCK_TAGS_MAX.gsub(",", "|") + ")(?:>|[\\s/][^>]*>))\\s*", Regexp::MULTILINE | Regexp::IGNORECASE)
    SURROUNDING_SPACES_ALL_PATTERN = Regexp.new("\\s*(<[^>]+>)\\s*", Regexp::MULTILINE | Regexp::IGNORECASE)

    # patterns for searching for temporary replacements
    TEMP_COND_COMMENT_PATTERN = Regexp.new("%%%~COMPRESS~COND~(\\d+?)~%%%")
    TEMP_PRE_PATTERN = Regexp.new("%%%~COMPRESS~PRE~(\\d+?)~%%%")
    TEMP_TEXT_AREA_PATTERN = Regexp.new("%%%~COMPRESS~TEXTAREA~(\\d+?)~%%%")
    TEMP_SCRIPT_PATTERN = Regexp.new("%%%~COMPRESS~SCRIPT~(\\d+?)~%%%")
    TEMP_STYLE_PATTERN = Regexp.new("%%%~COMPRESS~STYLE~(\\d+?)~%%%")
    TEMP_EVENT_PATTERN = Regexp.new("%%%~COMPRESS~EVENT~(\\d+?)~%%%")
    TEMP_SKIP_PATTERN = Regexp.new("%%%~COMPRESS~SKIP~(\\d+?)~%%%")
    TEMP_LINE_BREAK_PATTERN = Regexp.new("%%%~COMPRESS~LT~(\\d+?)~%%%")


    def initialize
      @enabled = true

      # default settings
      @removeComments = true
      @removeMultiSpaces = true

      # optional settings
      @removeIntertagSpaces = false;
      @removeQuotes = false
      @compressJavaScript = false
      @compressCss = false
      @simpleDoctype = false
      @removeScriptAttributes = false
      @removeStyleAttributes = false
      @removeLinkAttributes = false
      @removeFormAttributes = false
      @removeInputAttributes = false
      @simpleBooleanAttributes = false
      @removeJavaScriptProtocol = false
      @removeHttpProtocol = false
      @removeHttpsProtocol = false
      @preserveLineBreaks = false
      @removeSurroundingSpaces = nil

      @preservePatterns = nil
      @javaScriptCompressor = nil
      @cssCompressor = nil

      # YUICompressor settings
      @yuiCssLineBreak = -1
      @yuiJsNoMunge = false
      @yuiJsPreserveAllSemiColons = false
      @yuiJsDisableOptimizations = false

    end

    def set_enabled enabled
      @enabled = enabled
    end

    def set_remove_multi_spaces multi_spaces
      @removeMultiSpaces = multi_spaces
    end

    def set_remove_comments comments
      @removeComments = comments
    end

    def set_remove_intertag_spaces intertag_spaces
      @removeIntertagSpaces = intertag_spaces
    end

    def set_remove_quotes remove_quotes
      @removeQuotes = remove_quotes
    end

    def set_preserve_patterns preserve_patterns
      @preservePatterns = preserve_patterns
    end

    def set_compress_css compressCss
      @compressCss = compressCss
    end

    def set_compress_javascript compressJavaScript
      @compressJavaScript = compressJavaScript
    end

    def set_javascript_compressor compressor
      @javaScriptCompressor = compressor
    end

    def set_simple_doctype simple_doctype
      @simpleDoctype = simple_doctype
    end

    def set_remove_script_attributes remove_script_attributes
      @removeScriptAttributes = remove_script_attributes
    end

    def set_remove_style_attributes remove_style_attributes
      @removeStyleAttributes = remove_style_attributes
    end

    def set_remove_link_attributes remove_link_attributes
      @removeLinkAttributes = remove_link_attributes
    end

    def set_remove_form_attributes remove_form_attributes
      @removeFormAttributes = remove_form_attributes
    end

    def set_remove_input_attributes remove_input_attributes
      @removeInputAttributes = remove_input_attributes
    end

    def set_remove_javascript_protocol remove_javascript_protocol
      @removeJavaScriptProtocol = remove_javascript_protocol
    end

    def set_remove_http_protocol remove_http_protocol
      @removeHttpProtocol = remove_http_protocol
    end

    def set_remove_https_protocol remove_https_protocol
      @removeHttpsProtocol = remove_https_protocol
    end

    def compress html
      if not @enabled or html.nil? or html.length == 0
        return html
      end

      # preserved block containers
      condCommentBlocks = []
      preBlocks = []
      taBlocks = []
      scriptBlocks = []
      styleBlocks = []
      eventBlocks = []
      skipBlocks = []
      lineBreakBlocks = []
      userBlocks = []

      # preserve blocks
      html = preserveBlocks(html, preBlocks, taBlocks, scriptBlocks, styleBlocks, eventBlocks, condCommentBlocks, skipBlocks, lineBreakBlocks, userBlocks)

      # process pure html
      html = processHtml(html)

      # process preserved blocks
      processPreservedBlocks(preBlocks, taBlocks, scriptBlocks, styleBlocks, eventBlocks, condCommentBlocks, skipBlocks, lineBreakBlocks, userBlocks)

      # put preserved blocks back
      html = returnBlocks(html, preBlocks, taBlocks, scriptBlocks, styleBlocks, eventBlocks, condCommentBlocks, skipBlocks, lineBreakBlocks, userBlocks)

      html
    end

    private

    def preserveBlocks(html, preBlocks, taBlocks, scriptBlocks, styleBlocks, eventBlocks, condCommentBlocks, skipBlocks, lineBreakBlocks, userBlocks)

      # preserve user blocks
      unless (@preservePatterns.nil?)
        @preservePatterns.each_with_index do |preservePattern, i|
          userBlock = []
          index = -1

          html = html.gsub(preservePattern) do |match|
            if match.strip.length > 0
              userBlock << match
              index += 1
              message_format(TEMP_USER_BLOCK, i, index)
            else
              ''
            end
          end

          userBlocks << userBlock
        end
      end

      # preserve <!-- {{{ ---><!-- }}} ---> skip blocks
      skipBlockIndex = -1

      html = html.gsub(SKIP_PATTERN) do |match|
        if $1.strip.length > 0
          skipBlocks << match
          skipBlockIndex += 1
          message_format(TEMP_SKIP_BLOCK, skipBlockIndex)
        else
          match
        end
      end

      # preserve conditional comments
      condCommentCompressor = self.clone
      index = -1

      html = html.gsub(COND_COMMENT_PATTERN) do |match|
        if $2.strip.length > 0
          index += 1
          condCommentBlocks << ($1 + condCommentCompressor.compress($2) + $3)
          message_format(TEMP_COND_COMMENT_BLOCK, index)
        else
          ''
        end
      end

      # preserve inline events
      index = -1

      html = html.gsub(EVENT_PATTERN1) do |match|
        if $2.strip.length > 0
          eventBlocks << $2
          index += 1
          $1 + message_format(TEMP_EVENT_BLOCK, index) + $3
        else
          ''
        end
      end

      html = html.gsub(EVENT_PATTERN2) do |match|
        if $2.strip.length > 0
          eventBlocks << $2
          index += 1
          $1 + message_format(TEMP_EVENT_BLOCK, index) + $3
        else
          ''
        end
      end

      # preserve PRE tags
      index = -1
      html = html.gsub PRE_PATTERN do |match|
        if $2.strip.length > 0
          index += 1
          preBlocks << $2
          $1 + message_format(TEMP_PRE_BLOCK, index) + $3
        else
          ''
        end
      end

      # preserve SCRIPT tags
      index = -1

      html = html.gsub(SCRIPT_PATTERN) do |match|
        group_1 = $1
        group_2 = $2
        group_3 = $3
        # ignore empty scripts
        if group_2.strip.length > 0
          # check type
          type = ""
          if group_1 =~ TYPE_ATTR_PATTERN
            type = $2.downcase
          end

          if type.length == 0 or type == 'text/javascript' or type == 'application/javascript'
            # javascript block, preserve and compress with js compressor
            scriptBlocks << group_2
            index += 1
            group_1 + message_format(TEMP_SCRIPT_BLOCK, index) + group_3
          elsif type == 'text/x-jquery-tmpl'
            # jquery template, ignore so it gets compressed with the rest of html
            match
          else
            # some custom script, preserve it inside "skip blocks" so it won't be compressed with js compressor
            skipBlocks << group_2
            skipBlockIndex += 1
            group_1 + message_format(TEMP_SKIP_BLOCK, skipBlockIndex) + group_3
          end

        else
          match
        end
      end

      # preserve STYLE tags
      index = -1

      html = html.gsub(STYLE_PATTERN) do |match|
        if $2.strip.length > 0
          styleBlocks << $2
          index += 1
          $1 + message_format(TEMP_STYLE_BLOCK, index) + $3
        else
          match
        end
      end

      # preserve TEXTAREA tags
      index = -1
      html = html.gsub(TA_PATTERN) do |match|
        if $2.strip.length > 0
          taBlocks << $2
          index += 1
          $1 + message_format(TEMP_TEXT_AREA_BLOCK, index) + $3
        else
          ''
        end
      end

      # preserve line breaks
      if @preserveLineBreaks
        index = -1
        html = html.gsub(LINE_BREAK_PATTERN) do |match|
          lineBreakBlocks << $1
          index += 1
          message_format(TEMP_LINE_BREAK_BLOCK, index)
        end
      end

      html
    end

    def returnBlocks(html, preBlocks, taBlocks, scriptBlocks, styleBlocks, eventBlocks, condCommentBlocks, skipBlocks, lineBreakBlocks, userBlocks)

      # put line breaks back
      if @preserveLineBreaks
        html = html.gsub(TEMP_LINE_BREAK_PATTERN) do |match|
          i = $1.to_i
          if lineBreakBlocks.size > i
            lineBreakBlocks[i]
          else
            ''
          end
        end
      end

      # put TEXTAREA blocks back
      html = html.gsub(TEMP_TEXT_AREA_PATTERN) do |match|
        i = $1.to_i
        if taBlocks.size > i
          taBlocks[i]
        else
          ''
        end
      end

      # put STYLE blocks back
      html = html.gsub(TEMP_STYLE_PATTERN) do |match|
        i = $1.to_i
        if styleBlocks.size > i
          styleBlocks[i]
        else
          ''
        end
      end

      # put SCRIPT blocks back
      html = html.gsub(TEMP_SCRIPT_PATTERN) do |match|
        i = $1.to_i
        if scriptBlocks.size > i
          scriptBlocks[i]
        end
      end

      # put PRE blocks back
      html = html.gsub TEMP_PRE_PATTERN do |match|
        i = $1.to_i
        if preBlocks.size > i
          preBlocks[i] # quoteReplacement ?
        else
          ''
        end
      end

      # put event blocks back
      html = html.gsub(TEMP_EVENT_PATTERN) do |match|
        i = $1.to_i
        if eventBlocks.size > i
          eventBlocks[i]
        else
          ''
        end
      end

      # put conditional comments back
      html = html.gsub(TEMP_COND_COMMENT_PATTERN) do |match|
        i = $1.to_i
        if condCommentBlocks.size > i
          condCommentBlocks[i] # quoteReplacement ?
        else
          ''
        end
      end

      # put skip blocks back
      html = html.gsub(TEMP_SKIP_PATTERN) do |match|
        i = $1.to_i
        if skipBlocks.size > i
          skipBlocks[i]
        else
          ''
        end
      end

      # put user blocks back
      unless @preservePatterns.nil?
        @preservePatterns.each_with_index do |preservePattern, p|
          tempUserPattern = Regexp.new("%%%~COMPRESS~USER#{p}~(\\d+?)~%%%")
          html = html.gsub(tempUserPattern).each do |match|
            i = $1.to_i
            if userBlocks.size > p and userBlocks[p].size > i
              userBlocks[p][i]
            else
              ''
            end
          end
        end
      end

      html
    end

    def processPreservedBlocks(preBlocks, taBlocks, scriptBlocks, styleBlocks, eventBlocks, condCommentBlocks, skipBlocks, lineBreakBlocks, userBlocks)
      # processPreBlocks(preBlocks)
      # processTextAreaBlocks(taBlocks)
      processScriptBlocks(scriptBlocks)
      processStyleBlocks(styleBlocks)
      processEventBlocks(eventBlocks)
      # processCondCommentBlocks(condCommentBlocks)
      # processSkipBlocks(skipBlocks)
      # processUserBlocks(userBlocks)
      # processLineBreakBlocks(lineBreakBlocks)
    end

    def processScriptBlocks(scriptBlocks)
      if @compressJavaScript
        scriptBlocks.map! do |block|
          compressJavaScript(block)
        end
      end
    end

    def processStyleBlocks(styleBlocks)
      if @compressCss
        styleBlocks.map! do |block|
          compressCssStyles(block)
        end
      end
    end

    def processEventBlocks(eventBlocks)
      if @removeJavaScriptProtocol
        eventBlocks.map! do |block|
          removeJavaScriptProtocol(block)
        end
      end
    end

    def compressJavaScript(source)
      # set default javascript compressor
      if @javaScriptCompressor.nil?
        @javaScriptCompressor = YUI::JavaScriptCompressor.new(
          :munge => !@yuiJsNoMunge,
          :preserve_semicolons => !@yuiJsDisableOptimizations,
          :optimize => !@yuiJsDisableOptimizations,
          :line_break => @yuiJsLineBreak
        )
      end

      # detect CDATA wrapper
      cdataWrapper = false
      if source =~ CDATA_PATTERN
        cdataWrapper = true
        source = $1
      end

      result = @javaScriptCompressor.compress(source).strip

      if cdataWrapper
        result = "<![CDATA[" + result + "]]>"
      end

      result
    end

    def compressCssStyles(source)
      # set default css compressor
      if @cssCompressor.nil?
        @cssCompressor = YUI::CssCompressor.new(:line_break => @yuiCssLineBreak)
      end

      # detect CDATA wrapper
      cdataWrapper = false
      if source =~ CDATA_PATTERN
        cdataWrapper = true
        source = $1
      end

      result = @cssCompressor.compress(source)

      if cdataWrapper
        result = "<![CDATA[" + result + "]]>"
      end

      result
    end

    def removeJavaScriptProtocol(source)
      # remove javascript: from inline events
      source.sub(EVENT_JS_PROTOCOL_PATTERN, '\1')
    end

    def processHtml(html)

      # remove comments
      html = removeComments(html)

      # simplify doctype
      html = simpleDoctype(html)

      # remove script attributes
      html = removeScriptAttributes(html)

      # remove style attributes
      html = removeStyleAttributes(html)

      # remove link attributes
      html = removeLinkAttributes(html)

      # remove form attributes
      html = removeFormAttributes(html)

      # remove input attributes
      html = removeInputAttributes(html)

      # # simplify boolean attributes
      # html = simpleBooleanAttributes(html)

      # remove http from attributes
      html = removeHttpProtocol(html)

      # remove https from attributes
      html = removeHttpsProtocol(html)

      # remove inter-tag spaces
      html = removeIntertagSpaces(html)

      # remove multi whitespace characters
      html = removeMultiSpaces(html)

      # remove spaces around equals sign and ending spaces
      html = removeSpacesInsideTags(html)

      # remove quotes from tag attributes
      html = removeQuotesInsideTags(html)

      # # remove surrounding spaces
      # html = removeSurroundingSpaces(html)

      html.strip
    end

    def removeComments(html)

      # remove comments
      if @removeComments
        html = html.gsub(COMMENT_PATTERN, '')
      end

      html
    end

    def simpleDoctype(html)
      # simplify doctype
      if @simpleDoctype
        html = html.gsub(DOCTYPE_PATTERN, '<!DOCTYPE html>')
      end

      html
    end

    def removeScriptAttributes(html)
      if @removeScriptAttributes
        #remove type from script tags
        html = html.gsub(JS_TYPE_ATTR_PATTERN, '\1\3')

        #remove language from script tags
        html = html.gsub(JS_LANG_ATTR_PATTERN, '\1\3')
      end

      html
    end

    def removeStyleAttributes(html)
      # remove type from style tags
      if @removeStyleAttributes
        html = html.gsub(STYLE_TYPE_ATTR_PATTERN, '\1\3')
      end

      html
    end

    def removeLinkAttributes(html)
      # remove type from link tags with rel=stylesheet
      if @removeLinkAttributes
        html = html.gsub(LINK_TYPE_ATTR_PATTERN) do |match|
          group_1 = $1
          group_3 = $3
          # if rel=stylesheet
          if match =~ LINK_REL_ATTR_PATTERN
            group_1 + group_3
          else
            match
          end
        end
      end

      html
    end

    def removeFormAttributes(html)
      # remove method from form tags
      if @removeFormAttributes
        html = html.gsub(FORM_METHOD_ATTR_PATTERN, '\1\3')
      end

      html
    end

    def removeInputAttributes(html)
      # remove type from input tags
      if @removeInputAttributes
        html = html.gsub(INPUT_TYPE_ATTR_PATTERN, '\1\3')
      end

      html
    end

    def removeHttpProtocol(html)
      # remove http protocol from tag attributes
      if @removeHttpProtocol
        html = html.gsub(HTTP_PROTOCOL_PATTERN) do |match|
          group_1 = $1
          group_2 = $2

          if match =~ REL_EXTERNAL_PATTERN
            match
          else
            "#{group_1}#{group_2}"
          end
        end
      end

      html
    end

    def removeHttpsProtocol(html)
      # remove https protocol from tag attributes
      if @removeHttpsProtocol
        html = html.gsub(HTTPS_PROTOCOL_PATTERN) do |match|
          group_1 = $1
          group_2 = $2

          if match =~ REL_EXTERNAL_PATTERN
            match
          else
            "#{group_1}#{group_2}"
          end
        end
      end

      html
    end


    def removeIntertagSpaces(html)

      # remove inter-tag spaces
      if @removeIntertagSpaces
        html = html.gsub(INTERTAG_PATTERN_TAG_TAG, '><')
        html = html.gsub(INTERTAG_PATTERN_TAG_CUSTOM, '>%%%~')
        html = html.gsub(INTERTAG_PATTERN_CUSTOM_TAG, '~%%%<')
        html = html.gsub(INTERTAG_PATTERN_CUSTOM_CUSTOM, '~%%%%%%~')
      end

      html
    end

    def removeSpacesInsideTags(html)
      #remove spaces around equals sign inside tags

      html = html.gsub(TAG_PROPERTY_PATTERN, '\1=')

      #remove ending spaces inside tags

      html.gsub!(TAG_END_SPACE_PATTERN) do |match|

        group_1 = $1
        group_2 = $2

        # keep space if attribute value is unquoted before trailing slash
        if group_2.start_with?("/") and (TAG_LAST_UNQUOTED_VALUE_PATTERN =~ group_1)
          "#{group_1} #{group_2}"
        else
          "#{group_1}#{group_2}"
        end
      end


      html
    end

    def removeQuotesInsideTags(html)
      if @removeQuotes
        html = html.gsub(TAG_QUOTE_PATTERN) do |match|
          # if quoted attribute is followed by "/" add extra space
          if $3.strip.length == 0
            "=#{$2}"
          else
            "=#{$2} #{$3}"
          end
        end
      end

      html
    end

    def removeMultiSpaces(html)
      # collapse multiple spaces
      if @removeMultiSpaces
        html = html.gsub(MULTISPACE_PATTERN, ' ')
      end

      html
    end

    def simpleBooleanAttributes(html)
      # simplify boolean attributes
      if @simpleBooleanAttributes
        html = html.gsub(BOOLEAN_ATTR_PATTERN, '\1\2\4')
      end

      html
    end

    private

    def message_format(message, *params)
      message.gsub(/\{(\d+),number,#\}/) do
        params[$1.to_i]
      end
    end

  end

end