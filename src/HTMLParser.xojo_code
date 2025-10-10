#tag Class
Protected Class HTMLParser
	#tag Method, Flags = &h21, Description = 4164647320612070617273696E67206572726F722E20496E20737472696374206D6F64652C2077652072616973652074686520657863657074696F6E20696E206164646974696F6E20746F206C6F6767696E672069742E
		Private Sub AddError(errorType As HTMLParserException.Types, message As String, severity As HTMLParserException.Severities = HTMLParserException.Severities.Warning)
		  /// Adds a parsing error.
		  /// In strict mode, we raise the exception in addition to logging it.
		  
		  Var e As New HTMLParserException(errorType, mLineNumber, mColumnNumber, message, severity)
		  
		  // Add a context snippet.
		  Var contextStart As Integer = Max(0, mPosition - 20)
		  Var contextEnd As Integer = Min(mLength, mPosition + 20)
		  e.Context = mHTML.Middle(contextStart, contextEnd - contextStart)
		  
		  mErrors.Add(e)
		  
		  // In strict mode, errors are fatal.
		  If mStrictMode And severity = HTMLParserException.Severities.Error Then
		    Raise e
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 5570646174657320706F736974696F6E20747261636B696E672E
		Private Sub AdvancePosition(count As Integer = 1)
		  /// Updates position tracking.
		  
		  For i As Integer = 1 To count
		    If mPosition < mLength Then
		      If mHTML.Middle(mPosition, 1) = Chr(10) Then
		        mLineNumber = mLineNumber + 1
		        mColumnNumber = 1
		      Else
		        mColumnNumber = mColumnNumber + 1
		      End If
		      mPosition = mPosition + 1
		    End If
		  Next i
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function BlockTags() As String()
		  Static bt() As String = Array("div", "p", "h1", "h2", "h3", "h4", "h5", "h6", _
		  "ul", "ol", "li", "table", "tr", "td", "th", "thead", "tbody", "tfoot", _
		  "form", "fieldset", "blockquote", "pre", "article", "section", "nav", _
		  "aside", "header", "footer", "main", "figure", "figcaption", "address")
		  
		  Return bt
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 436865636B20666F7220726571756972656420617474726962757465732E
		Private Sub CheckRequiredAttributes(node As HTMLNode)
		  /// Check for required attributes.
		  
		  Select Case node.TagName
		  Case "img"
		    If node.AttributeValue("src") = "" Then
		      AddError(HTMLParserException.Types.MissingRequiredAttribute, _
		      "<img> tag missing required 'src' attribute", HTMLParserException.Severities.Error)
		    End If
		    If node.AttributeValue("alt") = "" And mStrictMode Then
		      AddError(HTMLParserException.Types.MissingRequiredAttribute, _
		      "<img> tag missing 'alt' attribute for accessibility", HTMLParserException.Severities.Warning)
		    End If
		    
		  Case "a"
		    If node.AttributeValue("href") = "" And node.AttributeValue("name") = "" Then
		      AddError(HTMLParserException.Types.MissingRequiredAttribute, _
		      "<a> tag should have 'href' or 'name' attribute", HTMLParserException.Severities.Warning)
		    End If
		    
		  Case "form"
		    If node.AttributeValue("action") = "" And mStrictMode Then
		      AddError(HTMLParserException.Types.MissingRequiredAttribute, _
		      "<form> tag missing 'action' attribute", HTMLParserException.Severities.Info)
		    End If
		    
		  Case "label"
		    If node.AttributeValue("for") = "" And mStrictMode Then
		      AddError(HTMLParserException.Types.MissingRequiredAttribute, _
		      "<label> tag should have 'for' attribute", HTMLParserException.Severities.Info)
		    End If
		  End Select
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 436C6F736573207468652074616720776974682074686520706173736564206E616D652E
		Private Sub CloseTag(tagName As String)
		  /// Closes the tag with the passed name.
		  
		  // Find the matching open tag.
		  Var foundIndex As Integer = -1
		  For i As Integer = mOpenTags.LastIndex DownTo 0
		    If mOpenTags(i) = tagName Then
		      foundIndex = i
		      Exit
		    End If
		  Next i
		  
		  If foundIndex = -1 Then
		    // No matching open tag, ignore.
		    Return
		  End If
		  
		  // Close all tags from the current to the matching tag.
		  For i As Integer = mOpenTags.LastIndex DownTo foundIndex
		    If mCurrentNode.Parent <> Nil Then
		      mCurrentNode = mCurrentNode.Parent
		    End If
		    mOpenTags.RemoveAt(mOpenTags.LastIndex)
		  Next i
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(strictMode As Boolean = False)
		  mStrictMode = strictMode
		  mTrackIDs = New Dictionary
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 4465636F6465732048544D4C20656E7469746965732077697468696E2060736020746F2074686569722061637475616C2076616C75657320616E642072657475726E732061206E657720737472696E6720776974682074686520656E746974696573206465636F6465642E
		Private Function DecodeHTMLEntities(s As String) As String
		  /// Decodes HTML entities within `s` to their actual values and returns a new string with the entities decoded.
		  
		  Var result As String = s
		  
		  // First, handle numeric entities (&#123; and &#xABC;)
		  result = DecodeNumericEntities(result)
		  
		  // Replace named entities.
		  Var pos As Integer = 0
		  While pos < result.Length
		    Var ampPos As Integer = result.IndexOf(pos, "&")
		    If ampPos = -1 Then Exit
		    
		    Var semiPos As Integer = result.IndexOf(ampPos, ";")
		    If semiPos = -1 Or semiPos > ampPos + 10 Then
		      pos = ampPos + 1
		      Continue
		    End If
		    
		    Var entity As String = result.Middle(ampPos + 1, semiPos - ampPos - 1)
		    If EntityMap.HasKey(entity) Then
		      result = result.Left(ampPos) + EntityMap.Value(entity) + result.Middle(semiPos + 1)
		      pos = ampPos + 1
		    Else
		      pos = ampPos + 1
		    End If
		  Wend
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 4465636F6465732048544D4C206E756D6572696320656E74697469657320286368617261637465727320726566657272656420746F20627920746865697220556E69636F64652076616C7565292E20452E673A2026233136303B
		Private Function DecodeNumericEntities(s As String) As String
		  /// Decodes HTML numeric entities (characters referred to by their Unicode value). 
		  /// E.g: &#160;
		  
		  Var result As String = s
		  Var pos As Integer = 0
		  
		  While pos < result.Length
		    Var ampPos As Integer = result.IndexOf(pos, "&#")
		    If ampPos = -1 Then Exit
		    
		    Var semiPos As Integer = result.IndexOf(ampPos, ";")
		    If semiPos = -1 Or semiPos > ampPos + 8 Then
		      pos = ampPos + 1
		      Continue
		    End If
		    
		    Var entity As String = result.Middle(ampPos + 2, semiPos - ampPos - 2)
		    Var charCode As Integer = 0
		    
		    If entity.Left(1) = "x" Or entity.Left(1) = "X" Then
		      // Hexadecimal entity.
		      Try
		        charCode = Integer.FromHex(entity.Middle(1))
		      Catch
		        pos = ampPos + 1
		        Continue
		      End Try
		    Else
		      // Decimal entity.
		      Try
		        charCode = entity.ToInteger
		      Catch
		        pos = ampPos + 1
		        Continue
		      End Try
		    End If
		    
		    If charCode > 0 And charCode < 65536 Then
		      result = result.Left(ampPos) + Chr(charCode) + result.Middle(semiPos + 1)
		      pos = ampPos + 1
		    Else
		      pos = ampPos + 1
		    End If
		  Wend
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320616E792070617273696E67206572726F72732074686174206F636375727265642E
		Function Errors() As HTMLParserException()
		  /// Returns any parsing errors that occurred.
		  
		  Return mErrors
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73205472756520696620616E79206572726F7273206F6363757272656420647572696E672070617273696E672E
		Function HasErrors() As Boolean
		  /// Returns True if any errors occurred during parsing.
		  
		  For Each e As HTMLParserException In mErrors
		    If e.Severity = HTMLParserException.Severities.Error Then
		      Return True
		    End If
		  Next e
		  
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73205472756520696620616E79207761726E696E6773206F6363757272656420647572696E672070617273696E672E
		Function HasWarnings() As Boolean
		  /// Returns True if any warnings occurred during parsing.
		  
		  For Each e As HTMLParserException In mErrors
		    If e.Severity = HTMLParserException.Severities.Warning Then
		      Return True
		    End If
		  Next e
		  
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E73207468652064696374696F6E61727920746F206265207573656420746F20696E697469616C6973652074686520736861726564204175746F436C6F7365546167732064696374696F6E6172792E
		Private Shared Function InitialiseAutoCloseTags() As Dictionary
		  /// Returns the dictionary to be used to initialise the shared AutoCloseTags dictionary.
		  
		  Var d As New Dictionary
		  
		  // li auto-closes li
		  d.Value("li") = New Dictionary("li" : Nil)
		  
		  // dt auto-closes dt and dd
		  d.Value("dt") = New Dictionary("dt" : Nil, "dd" : Nil)
		  
		  // dd auto-closes dt and dd
		  d.Value("dd") = New Dictionary("dt" : Nil, "dd" : Nil)
		  
		  // p auto-closes p
		  d.Value("p") = New Dictionary("p" : Nil)
		  
		  // tr auto-closes tr
		  d.Value("tr") = New Dictionary("tr" : Nil)
		  
		  // td auto-closes td and th
		  d.Value("td") = New Dictionary("td" : Nil, "th" : Nil)
		  
		  // th auto-closes td and th
		  d.Value("th") = New Dictionary("td" : Nil, "th" : Nil)
		  
		  // option auto-closes option
		  d.Value("option") = New Dictionary("option" : Nil)
		  
		  Return d
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E73207468652064696374696F6E61727920746F206265207573656420746F20696E697469616C697365207468652073686172656420456E746974794D61702064696374696F6E6172792E
		Private Shared Function InitialiseEntityMap() As Dictionary
		  /// Returns the dictionary to be used to initialise the shared EntityMap dictionary.
		  ///
		  /// Note this is not exhaustive.
		  
		  Var d As Dictionary = ParseJSON("{}") // HACK: Case-sensitive dictionary.
		  
		  // Common entities.
		  d.Value("amp") = "&"
		  d.Value("lt") = "<"
		  d.Value("gt") = ">"
		  d.Value("quot") = """"
		  d.Value("apos") = "'"
		  d.Value("nbsp") = " "
		  
		  // Currency.
		  d.Value("cent") = "¢"
		  d.Value("pound") = "£"
		  d.Value("yen") = "¥"
		  d.Value("euro") = "€"
		  
		  // Maths symbols.
		  d.Value("plusmn") = "±"
		  d.Value("times") = "×"
		  d.Value("divide") = "÷"
		  d.Value("ne") = "≠"
		  d.Value("le") = "≤"
		  d.Value("ge") = "≥"
		  
		  // Arrows.
		  d.Value("larr") = "←"
		  d.Value("uarr") = "↑"
		  d.Value("rarr") = "→"
		  d.Value("darr") = "↓"
		  d.Value("harr") = "↔"
		  
		  // Special characters.
		  d.Value("copy") = "©"
		  d.Value("reg") = "®"
		  d.Value("trade") = "™"
		  d.Value("para") = "¶"
		  d.Value("sect") = "§"
		  d.Value("deg") = "°"
		  d.Value("hellip") = "…"
		  d.Value("bull") = "•"
		  d.Value("middot") = "·"
		  
		  // Quotes.
		  d.Value("lsquo") = "'"
		  d.Value("rsquo") = "'"
		  d.Value("ldquo") = "“"
		  d.Value("rdquo") = "”"
		  d.Value("laquo") = "«"
		  d.Value("raquo") = "»"
		  
		  // Dashes.
		  d.Value("ndash") = "–"
		  d.Value("mdash") = "—"
		  
		  Return d
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function InlineTags() As String()
		  Static it() As String = Array("span", "a", "strong", "em", "b", "i", "u", "small", _
		  "mark", "del", "ins", "sub", "sup", "code", "kbd", "samp", "var", _
		  "time", "abbr", "cite", "q", "dfn")
		  
		  Return it
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E732054727565206966207468652063757272656E74206E6F6465206973206E657374656420696E20612076616C6964206D616E6E65722E
		Private Function IsValidNesting(tagName As String) As Boolean
		  /// Returns True if the current node is nested in a valid manner.
		  
		  // Check common invalid nesting patterns.
		  
		  Static pInvalid() As String = Array("div", "p", "h1", "h2", "h3", _
		  "h4", "h5", "h6", "ul", "ol", "table", "blockquote", "form")
		  
		  Static buttonInvalid() As String = Array("a", "button", "input", _
		  "select", "textarea", "iframe")
		  
		  If mCurrentNode.TagName = "p" Then
		    // p tags cannot contain block elements.
		    If pInvalid.IndexOf(tagName) <> -1 Then Return False
		  End If
		  
		  If mCurrentNode.TagName = "button" Then
		    // Buttons cannot contain interactive elements.
		    If buttonInvalid.IndexOf(tagName) <> -1 Then Return False
		  End If
		  
		  If tagName = "li" Then
		    // li must be in ul or ol.
		    Var ancestor As HTMLNode = mCurrentNode
		    Var found As Boolean = False
		    While ancestor <> Nil
		      If ancestor.TagName = "ul" Or ancestor.TagName = "ol" Then
		        found = True
		        Exit
		      End If
		      ancestor = ancestor.Parent
		    Wend
		    If Not found Then
		      Return False
		    End If
		  End If
		  
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parse(html As String) As HTMLNode
		  // Initialise.
		  mHTML = html
		  mPosition = 0
		  mLength = html.Length
		  mLineNumber = 1
		  mColumnNumber = 1
		  mErrors.ResizeTo(-1)
		  mTrackIDs.RemoveAll
		  
		  mRoot = New HTMLNode(HTMLNode.Types.Element)
		  mRoot.TagName = "document"
		  mCurrentNode = mRoot
		  mOpenTags.ResizeTo(-1)
		  
		  While mPosition < mLength
		    If PeekChar = "<" Then
		      ParseTag
		    Else
		      ParseText
		    End If
		  Wend
		  
		  // Check for unclosed tags and close any that remain.
		  While mOpenTags.Count > 0
		    Var tagName As String = mOpenTags(mOpenTags.LastIndex)
		    AddError(HTMLParserException.Types.UnclosedTag, _
		    "Tag <" + tagName + "> was not closed", HTMLParserException.Severities.Error)
		    CloseTag(tagName)
		  Wend
		  
		  Return mRoot
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273657320616E206174747269627574652E
		Private Sub ParseAttribute(node As HTMLNode)
		  /// Parses an attribute.
		  
		  SkipWhitespace
		  
		  // Parse the attribute's name.
		  Var attrName As String = ParseAttributeName
		  If attrName = "" Then
		    mPosition = mPosition + 1
		    Return
		  End If
		  
		  SkipWhitespace
		  
		  // Check for "="
		  If PeekChar <> "=" Then
		    // This is an attribute without a value.
		    node.AttributeValue(attrName.Lowercase) = ""
		    Return
		  End If
		  
		  // Skip "="
		  mPosition = mPosition + 1
		  
		  SkipWhitespace
		  
		  // Parse the attribute's value.
		  Var attrValue As String = ParseAttributeValue
		  node.AttributeValue(attrName.Lowercase) = DecodeHTMLEntities(attrValue)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273657320616E642072657475726E7320616E206174747269627574652773206E616D652E
		Private Function ParseAttributeName() As String
		  /// Parses and returns an attribute's name.
		  
		  Var startPos As Integer = mPosition
		  
		  While mPosition < mLength
		    Var c As String = PeekChar
		    If c = "=" Or c = " " Or c = "/" Or c = ">" Or c = Chr(9) Or c = Chr(10) Or c = Chr(13) Then
		      Exit
		    End If
		    mPosition = mPosition + 1
		  Wend
		  
		  Return mHTML.Middle(startPos, mPosition - startPos)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273657320616E642072657475726E7320616E2061747472696275746527732076616C75652E
		Private Function ParseAttributeValue() As String
		  /// Parses and returns an attribute's value.
		  
		  Var quote As String = PeekChar
		  
		  If quote = """" Or quote = "'" Then
		    // This is a quoted value.
		    mPosition = mPosition + 1
		    Var startPos As Integer = mPosition
		    
		    While mPosition < mLength And PeekChar() <> quote
		      mPosition = mPosition + 1
		    Wend
		    
		    Var value As String = mHTML.Middle(startPos, mPosition - startPos)
		    
		    If PeekChar = quote Then
		      mPosition = mPosition + 1
		    End If
		    
		    Return value
		    
		  Else
		    // This is a non-quoted value.
		    Var startPos As Integer = mPosition
		    
		    While mPosition < mLength
		      Var c As String = PeekChar
		      If c = " " Or c = ">" Or c = Chr(9) Or c = Chr(10) Or c = Chr(13) Then
		        Exit
		      End If
		      mPosition = mPosition + 1
		    Wend
		    
		    Return mHTML.Middle(startPos, mPosition - startPos)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 5061727365206174747269627574652076616C756520776974682071756F74652076616C69646174696F6E2E
		Private Function ParseAttributeValueWithValidation() As String
		  /// Parse attribute value with quote validation.
		  
		  Var quote As String = PeekChar
		  Var startLine As Integer = mLineNumber
		  Var startColumn As Integer = mColumnNumber
		  
		  If quote = """" Or quote = "'" Then
		    // Quoted value.
		    AdvancePosition
		    Var startPos As Integer = mPosition
		    Var foundClosingQuote As Boolean = False
		    
		    While mPosition < mLength
		      If PeekChar() = quote Then
		        foundClosingQuote = True
		        Exit
		      End If
		      AdvancePosition
		    Wend
		    
		    Var value As String = mHTML.Middle(startPos, mPosition - startPos)
		    
		    If foundClosingQuote Then
		      AdvancePosition // Skip the closing quote.
		    Else
		      AddError(HTMLParserException.Types.UnclosedQuote, _
		      "Unclosed quote in attribute value", HTMLParserException.Severities.Error)
		    End If
		    
		    Return value
		  Else
		    // Unquoted value.
		    If mStrictMode Then
		      AddError(HTMLParserException.Types.InvalidAttribute, _
		      "Attribute values should be quoted", HTMLParserException.Severities.Warning)
		    End If
		    
		    Var startPos As Integer = mPosition
		    While mPosition < mLength
		      Var c As String = PeekChar()
		      If c = " " Or c = ">" Or c = Chr(9) Or c = Chr(10) Or c = Chr(13) Then
		        Exit
		      End If
		      AdvancePosition
		    Wend
		    
		    Return mHTML.Middle(startPos, mPosition - startPos)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 2F2F2050617273652061747472696275746520776974682076616C69646174696F6E2E
		Private Sub ParseAttributeWithValidation(node As HTMLNode, attrName As String)
		  /// // Parse attribute with validation.
		  
		  SkipWhitespace
		  
		  // Check for "=".
		  If PeekChar <> "=" Then
		    // An attribute without value (boolean attribute).
		    node.AttributeValue(attrName.Lowercase) = ""
		    
		    // Validate boolean attributes.
		    Static booleanAttrs() As String = Array("checked", "disabled", "readonly", _
		    "required", "multiple", "selected", "defer", "async", "autofocus")
		    If booleanAttrs.IndexOf(attrName.Lowercase) = -1 And mStrictMode Then
		      AddError(HTMLParserException.Types.InvalidAttribute, _
		      "Attribute '" + attrName + "' should have a value", HTMLParserException.Severities.Info)
		    End If
		    Return
		  End If
		  
		  // Skip "="
		  AdvancePosition
		  
		  SkipWhitespace
		  
		  // Parse the attribute value.
		  Var attrValue As String = ParseAttributeValueWithValidation
		  node.AttributeValue(attrName.Lowercase) = DecodeHTMLEntities(attrValue)
		  
		  // Validate specific attributes.
		  ValidateAttributeValue(node.TagName, attrName.Lowercase, attrValue)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273657320612043444154412073656374696F6E2E20417373756D65732077652068617665206A75737420736B69707065642074686520223C22
		Private Sub ParseCDATA()
		  /// Parses a CDATA section. Assumes we have just skipped the "<"
		  
		  // Skip "![CDATA[".
		  mPosition = mPosition + 8
		  Var startPos As Integer = mPosition
		  Var content As String = ""
		  
		  // Look for the closing "]]>".
		  While mPosition < mLength - 2
		    If mHTML.Middle(mPosition, 3) = "]]>" Then
		      // Found the end of the CDATA section.
		      content = mHTML.Middle(startPos, mPosition - startPos)
		      
		      // Skip the "]]>".
		      mPosition = mPosition + 3
		      
		      // Create the CDATA node.
		      Var cdataNode As New HTMLNode(HTMLNode.Types.CDATA)
		      
		      // We don't decode entities in CDATA sections!.
		      cdataNode.Content = content
		      
		      mCurrentNode.AddChild(cdataNode)
		      Return
		    End If
		    
		    mPosition = mPosition + 1
		  Wend
		  
		  // This is an unclosed CDATA section - treat the rest of the document as CDATA.
		  content = mHTML.Middle(startPos, mLength - startPos)
		  Var cdataNode As New HTMLNode(HTMLNode.Types.CDATA)
		  cdataNode.Content = content
		  mCurrentNode.AddChild(cdataNode)
		  mPosition = mLength
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 506172736573206120636C6F73696E67207461672E20417373756D6573207765277665207365656E206120222F222E
		Private Sub ParseClosingTag()
		  /// Parses a closing tag. Assumes we've seen a "/".
		  
		  Var tagName As String = ParseTagName.Lowercase
		  
		  // Skip to ">".
		  While mPosition < mLength And PeekChar <> ">"
		    AdvancePosition
		  Wend
		  If PeekChar = ">" Then
		    AdvancePosition
		  End If
		  
		  If tagName = "" Then
		    AddError(HTMLParserException.Types.MalformedTag, _
		    "Empty closing tag", HTMLParserException.Severities.Error)
		    Return
		  End If
		  
		  // Check if this closing tag matches an open tag.
		  Var foundIndex As Integer = -1
		  For i As Integer = mOpenTags.LastIndex DownTo 0
		    If mOpenTags(i) = tagName Then
		      foundIndex = i
		      Exit
		    End If
		  Next
		  
		  If foundIndex = -1 Then
		    AddError(HTMLParserException.Types.UnmatchedClosingTag, _
		    "Closing tag </" + tagName + "> has no matching opening tag", _
		    HTMLParserException.Severities.Error)
		    Return
		  End If
		  
		  // Check if we're closing tags in the wrong order.
		  If foundIndex < mOpenTags.LastIndex Then
		    Var skipped() As String
		    For i As Integer = mOpenTags.LastIndex DownTo foundIndex + 1
		      skipped.Add(mOpenTags(i))
		    Next
		    Var message As String
		    If skipped.Count = 1 Then
		      message = "unclosed " + skipped(0) + " tag"
		    Else
		      message = skipped.Count.ToString + "unclosed tags (of type " + String.FromArray(skipped, " ") + ")"
		    End If
		    
		    AddError(HTMLParserException.Types.InvalidNesting, _
		    "Closing tag </" + tagName + "> found before " + message, HTMLParserException.Severities.Warning)
		  End If
		  
		  CloseTag(tagName)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 506172736573206120636F6D6D656E742E
		Private Sub ParseComment()
		  /// Parses a comment.
		  
		  mPosition = mPosition + 3 // Skip "!--"
		  Var startPos As Integer = mPosition
		  
		  While mPosition < mLength - 2
		    If mHTML.Middle(mPosition, 3) = "-->" Then
		      Var comment As String = mHTML.Middle(startPos, mPosition - startPos)
		      Var commentNode As New HTMLNode(HTMLNode.Types.Comment)
		      commentNode.Content = comment
		      mCurrentNode.AddChild(commentNode)
		      mPosition = mPosition + 3
		      Return
		    End If
		    mPosition = mPosition + 1
		  Wend
		  
		  // Unclosed comment, add what we have...
		  Var comment As String = mHTML.Middle(startPos, mLength - startPos)
		  Var commentNode As New HTMLNode(HTMLNode.Types.Comment)
		  commentNode.Content = comment
		  mCurrentNode.AddChild(commentNode)
		  mPosition = mLength
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseDocType()
		  mPosition = mPosition + 8 // Skip "!DOCTYPE"
		  SkipWhitespace()
		  
		  Var startPos As Integer = mPosition
		  While mPosition < mLength And PeekChar <> ">"
		    mPosition = mPosition + 1
		  Wend
		  
		  Var doctype As String = mHTML.Middle(startPos, mPosition - startPos).Trim
		  Var doctypeNode As New HTMLNode(HTMLNode.Types.DocType)
		  doctypeNode.Content = doctype
		  mCurrentNode.AddChild(doctypeNode)
		  
		  If PeekChar = ">" Then
		    mPosition = mPosition + 1
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 506172736573206D6978656420434441544120636F6E74656E742077697468696E20726177207465787420746167732028652E673A203C7363726970743E20616E64203C7374796C653E292E
		Private Sub ParseMixedCDATAContent(parentNode As HTMLNode, content As String)
		  /// Parses mixed CDATA content within raw text tags (e.g: <script> and <style>).
		  
		  Var pos As Integer = 0
		  Var contentLength As Integer = content.Length
		  
		  While pos < contentLength
		    Var cdataStart As Integer = content.IndexOf(pos, "<![CDATA[")
		    
		    If cdataStart = -1 Then
		      // No more CDATA sections, add the remaining as text.
		      If pos < contentLength Then
		        Var remaining As String = content.Middle(pos)
		        If remaining.Trim <> "" Then
		          Var textNode As New HTMLNode(HTMLNode.Types.Text)
		          textNode.Content = remaining
		          parentNode.AddChild(textNode)
		        End If
		      End If
		      Exit
		    End If
		    
		    // Add any text before the CDATA section.
		    If cdataStart > pos Then
		      Var beforeText As String = content.Middle(pos, cdataStart - pos)
		      If beforeText.Trim <> "" Then
		        Var textNode As New HTMLNode(HTMLNode.Types.Text)
		        textNode.Content = beforeText
		        parentNode.AddChild(textNode)
		      End If
		    End If
		    
		    // Find the end of the CDATA section.
		    Var cdataEnd As Integer = content.IndexOf(cdataStart + 9, "]]>")
		    If cdataEnd = -1 Then
		      // Unclosed CDATA - treat the rest as CDATA.
		      Var cdataContent As String = content.Middle(cdataStart + 9)
		      Var cdataNode As New HTMLNode(HTMLNode.Types.CDATA)
		      cdataNode.Content = cdataContent
		      parentNode.AddChild(cdataNode)
		      Exit
		    End If
		    
		    // Extract and add CDATA content/
		    Var cdataContent As String = content.Middle(cdataStart + 9, cdataEnd - (cdataStart + 9))
		    Var cdataNode As New HTMLNode(HTMLNode.Types.CDATA)
		    cdataNode.Content = cdataContent
		    parentNode.AddChild(cdataNode)
		    
		    pos = cdataEnd + 3 // Move past the "]]>".
		  Wend
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273657320616E206F70656E696E67207461672E20417373756D6573207765206861766520736B697070656420706173742074686520223C222E
		Private Sub ParseOpeningTag()
		  /// Parses an opening tag.
		  /// Assumes we have skipped past the "<".
		  
		  Var startLine As Integer = mLineNumber
		  Var startColumn As Integer = mColumnNumber
		  
		  Var tagName As String = ParseTagName
		  
		  If tagName = "" Then
		    AddError(HTMLParserException.Types.MalformedTag, _
		    "Empty tag name", HTMLParserException.Severities.Error)
		    Return
		  End If
		  
		  tagName = tagName.Lowercase
		  
		  // Check for deprecated tags.
		  Static deprecatedTags() As String = Array("font", "center", "marquee", _
		  "blink", "big", "strike", "tt", "frame", "frameset", "noframes")
		  If deprecatedTags.IndexOf(tagName) <> -1 Then
		    AddError(HTMLParserException.Types.DeprecatedTag, _
		    "Tag <" + tagName + "> is deprecated in HTML5", HTMLParserException.Severities.Warning)
		  End If
		  
		  // Check nesting rules.
		  If Not IsValidNesting(tagName) Then
		    AddError(HTMLParserException.Types.InvalidNesting, _
		    "Tag <" + tagName + "> cannot be nested inside <" + mCurrentNode.TagName + ">", _
		    HTMLParserException.Severities.Warning)
		  End If
		  
		  // Check if this tag should auto-close parent tags.
		  If AutoCloseTags.HasKey(tagName) Then
		    Var toClose As Dictionary = Dictionary(AutoCloseTags.Value(tagName))
		    
		    For Each entry As DictionaryEntry In toClose
		      Var closeTag As String = entry.Key
		      If mOpenTags.Count > 0 And mOpenTags(mOpenTags.LastIndex) = closeTag Then
		        CloseTag(closeTag)
		      End If
		    Next entry
		  End If
		  
		  // Create a new element node.
		  Var node As New HTMLNode(HTMLNode.Types.Element)
		  node.TagName = tagName
		  
		  // Parse attributes with validation.
		  SkipWhitespace
		  Var seenAttributes As New Dictionary
		  
		  While mPosition < mLength And PeekChar <> ">" And PeekChar <> "/"
		    Var attrName As String = ParseAttributeName
		    If attrName = "" Then
		      AdvancePosition
		      Continue
		    End If
		    
		    // Check for duplicate attributes.
		    If seenAttributes.HasKey(attrName.Lowercase) Then
		      AddError(HTMLParserException.Types.InvalidAttribute, _
		      "Duplicate attribute '" + attrName + "' in <" + tagName + ">", _
		      HTMLParserException.Severities.Warning)
		    End If
		    seenAttributes.Value(attrName.Lowercase) = True
		    
		    ParseAttributeWithValidation(node, attrName)
		    SkipWhitespace
		  Wend
		  
		  // Check for required attributes.
		  CheckRequiredAttributes(node)
		  
		  // Track IDs for duplicate checking.
		  Var id As String = node.AttributeValue("id")
		  If id <> "" Then
		    If mTrackIDs.HasKey(id) Then
		      AddError(HTMLParserException.Types.DuplicateID, _
		      "Duplicate ID '" + id + "' found", HTMLParserException.Severities.Error)
		    Else
		      mTrackIDs.Value(id) = True
		    End If
		  End If
		  
		  // Check for a self-closing tag.
		  Var isSelfClosing As Boolean = False
		  If PeekChar = "/" Then
		    isSelfClosing = True
		    AdvancePosition
		  End If
		  
		  // Skip closing ">".
		  If PeekChar() = ">" Then
		    AdvancePosition
		  Else
		    AddError(HTMLParserException.Types.MalformedTag, _
		    "Missing '>' for tag <" + tagName + ">", HTMLParserException.Severities.Error)
		  End If
		  
		  // Add node to tree
		  mCurrentNode.AddChild(node)
		  
		  // Handle void and raw text tags.
		  If RawTextTags.IndexOf(tagName) <> -1 And Not isSelfClosing Then
		    ParseRawTextContent(node, tagName)
		  ElseIf VoidTags.IndexOf(tagName) <> -1 Then
		    If Not isSelfClosing And mStrictMode Then
		      AddError(HTMLParserException.Types.MalformedTag, _
		      "Void tag <" + tagName + "> should be self-closing", HTMLParserException.Severities.Warning)
		    End If
		    node.IsSelfClosing = True
		    
		  ElseIf Not isSelfClosing Then
		    mCurrentNode = node
		    mOpenTags.Add(tagName)
		    node.IsSelfClosing = False
		    
		  Else
		    node.IsSelfClosing = True
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 5061727365732074686520726177207465787420636F6E74656E74206F662061206E6F64652028652E673A2061203C7363726970743E206F72203C7374796C653E206E6F6465292E
		Private Sub ParseRawTextContent(parentNode As HTMLNode, tagName As String)
		  /// Parses the raw text content of a node (e.g: a <script> or <style> node).
		  
		  Var startPos As Integer = mPosition
		  Var closingTag As String = "</" + tagName
		  Var content As String = ""
		  
		  // Look for the closing tag.
		  While mPosition < mLength
		    // Check if we found a potential closing tag.
		    If mHTML.Middle(mPosition, closingTag.Length).Lowercase = closingTag Then
		      // Check if it's followed by ">" or whitespace.
		      Var nextPos As Integer = mPosition + closingTag.Length
		      If nextPos >= mLength Then Exit
		      
		      Var nextChar As String = mHTML.Middle(nextPos, 1)
		      If nextChar = ">" Or nextChar = " " Or nextChar = Chr(9) Or nextChar = Chr(10) Or nextChar = Chr(13) Then
		        // Found a valid closing tag.
		        content = mHTML.Middle(startPos, mPosition - startPos)
		        
		        // Skip the closing tag.
		        mPosition = mPosition + closingTag.Length
		        While mPosition < mLength And mHTML.Middle(mPosition, 1) <> ">"
		          mPosition = mPosition + 1
		        Wend
		        
		        If mPosition < mLength Then
		          mPosition = mPosition + 1 // Skip ">".
		        End If
		        
		        Exit
		      End If
		    End If
		    
		    mPosition = mPosition + 1
		  Wend
		  
		  // If we didn't find a closing tag, use everything until the end.
		  If content = "" And mPosition >= mLength Then
		    content = mHTML.Middle(startPos, mLength - startPos)
		  End If
		  
		  // Add the content as a text node (or CDATA if it contains CDATA markers).
		  If content <> "" Then
		    // Check if the content contains CDATA sections. If so, parse them.
		    If content.IndexOf("<![CDATA[") <> -1 Then
		      ParseMixedCDATAContent(parentNode, content)
		    Else
		      Var textNode As New HTMLNode(HTMLNode.Types.Text)
		      textNode.Content = content // We don't decode entities in raw text tags (e.g: <script> and <style> nodes).
		      parentNode.AddChild(textNode)
		    End If
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 5061727365732061207461672E20417373756D65732077652068617665206A757374207365656E206120223C22206368617261637465722E
		Private Sub ParseTag()
		  /// Parses a tag.
		  /// Assumes we have just seen a "<" character.
		  
		  // Skip the "<".
		  mPosition = mPosition + 1
		  
		  If mPosition >= mLength Then Return
		  
		  // Check for CDATA section
		  If PeekString(8) = "![CDATA[" Then
		    ParseCDATA
		    Return
		  End If
		  
		  // Check for a comment.
		  If PeekString(3) = "!--" Then
		    ParseComment
		    Return
		  End If
		  
		  // Check for DOCTYPE.
		  If PeekString(8).Uppercase = "!DOCTYPE" Then
		    ParseDoctype
		    Return
		  End If
		  
		  // Check is this is a closing tag.
		  If PeekChar = "/" Then
		    mPosition = mPosition + 1
		    ParseClosingTag
		    Return
		  End If
		  
		  // Parse this opening tag.
		  ParseOpeningTag
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273657320616E642072657475726E73206120746167206E616D652E
		Private Function ParseTagName() As String
		  /// Parses and returns a tag name.
		  
		  SkipWhitespace
		  
		  Var startPos As Integer = mPosition
		  
		  While mPosition < mLength
		    Var c As String = PeekChar
		    If c = " " Or c = "/" Or c = ">" Or c = Chr(9) Or c = Chr(10) Or c = Chr(13) Then
		      Exit
		    End If
		    mPosition = mPosition + 1
		  Wend
		  
		  Return mHTML.Middle(startPos, mPosition - startPos)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 506172736573207465787420636F6E74656E742E
		Private Sub ParseText()
		  /// Parses text content.
		  
		  Var startPos As Integer = mPosition
		  
		  While mPosition < mLength And PeekChar <> "<"
		    mPosition = mPosition + 1
		  Wend
		  
		  Var t As String = mHTML.Middle(startPos, mPosition - startPos)
		  
		  If t.Trim <> "" Then
		    Var textNode As New HTMLNode(HTMLNode.Types.Text)
		    textNode.Content = DecodeHTMLEntities(t)
		    mCurrentNode.AddChild(textNode)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E73207468652063757272656E742063686172616374657220776974686F757420616476616E63696E672074686520706F736974696F6E2E2052657475726E7320616E20656D70747920737472696E6720696620776527766520726561636865642074686520656E64206F66207468652048544D4C2077652772652070617273696E672E
		Private Function PeekChar() As String
		  /// Returns the current character without advancing the position.
		  /// Returns an empty string if we've reached the end of the HTML we're parsing.
		  
		  If mPosition < mLength Then Return mHTML.Middle(mPosition, 1)
		  
		  Return ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PeekString(length As Integer) As String
		  /// Peeks at the specified number of characters without advancing the position.
		  
		  If mPosition + length <= mLength Then Return mHTML.Middle(mPosition, length)
		  
		  Return ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 52657475726E73206120737461746963206172726179207768657265206561636820656C656D656E742069732061207461672077686F7365207465787420636F6E74656E742073686F756C6420626520747265617465642061732072617720746578742E
		Protected Shared Function RawTextTags() As String()
		  /// Returns a static array where each element is a tag whose text content should be treated as raw text.
		  
		  Static rtt() As String = Array("script", "style")
		  
		  Return rtt
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function SemanticTags() As String()
		  Static hst() As String = Array("article", "aside", "details", "figcaption", _
		  "figure", "footer", "header", "main", "mark", "nav", "section", _
		  "summary", "time")
		  
		  Return hst
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 536B697073206F766572207768697465737061636520636861726163746572732E
		Private Sub SkipWhitespace()
		  /// Skips over whitespace characters.
		  
		  While mPosition < mLength
		    Var c As String = PeekChar()
		    If c <> " " And c <> Chr(9) And c <> Chr(10) And c <> Chr(13) Then
		      Exit
		    End If
		    mPosition = mPosition + 1
		  Wend
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 56616C6964617465207370656369666963206174747269627574652076616C7565732E
		Private Sub ValidateAttributeValue(tagName As String, attrName As String, value As String)
		  /// Validate specific attribute values.
		  
		  // Validate input types.
		  If tagName = "input" And attrName = "type" Then
		    Static validTypes() As String = Array("text", "password", "email", "url", _
		    "tel", "number", "range", "date", "time", "datetime-local", "month", _
		    "week", "color", "checkbox", "radio", "file", "submit", "reset", _
		    "button", "hidden", "image", "search")
		    If validTypes.IndexOf(value.Lowercase) = -1 Then
		      AddError(HTMLParserException.Types.InvalidAttribute, _
		      "Invalid input type: '" + value + "'", HTMLParserException.Severities.Warning)
		    End If
		  End If
		  
		  // Validate URLs.
		  If attrName = "href" Or attrName = "src" Or attrName = "action" Then
		    If value.IndexOf("javascript:") = 0 And mStrictMode Then
		      AddError(HTMLParserException.Types.InvalidAttribute, _
		      "JavaScript URLs are discouraged", HTMLParserException.Severities.Warning)
		    End If
		  End If
		  
		  // Validate rel attribute.
		  If attrName = "rel" And tagName = "a" Then
		    Static validRels() As String = Array("alternate", "author", "bookmark", _
		    "external", "help", "license", "next", "nofollow", "noreferrer", _
		    "noopener", "prev", "search", "tag")
		    Var rels() As String = value.Split(" ")
		    For Each rel As String In rels
		      If validRels.IndexOf(rel.Lowercase) = -1 Then
		        AddError(HTMLParserException.Types.InvalidAttribute, _
		        "Unknown rel value: '" + rel + "'", HTMLParserException.Severities.Info)
		      End If
		    Next rel
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 52657475726E73206120737461746963206172726179206F6620766F69642F73656C662D636C6F73696E6720746167732E
		Protected Shared Function VoidTags() As String()
		  /// Returns a static array of void/self-closing tags.
		  
		  Static vt() As String = Array("area", "base", "br", "col", "embed", _
		  "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr")
		  
		  Return vt
		  
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h1, Description = 4B6579203D207461672028537472696E67292C2056616C7565203D2044696374696F6E617279202865616368206B657920696E20746865204175746F436C6F7365546167732E56616C756520697320612074616720746861742073686F756C64206265206175746F2D636C6F736564206279204175746F436C6F7365546167732E4B6579292E20452E673A204966204175746F436C6F7365546167732E4B6579203D202274642220616E64204175746F436C6F7365546167732E56616C7565203D207B22746422203A204E696C2C2022746822203A204E696C7D207468656E20746865207061727365722073686F756C64206175746F2D636C6F736520616E79206F70656E202274642220616E6420227468222074616773207768656E20697420656E636F756E7465727320612022746422207461672E204E6F7465207468652056616C756520696E207468652056616C75652044696374696F6E617279206973204E696C20286E6F742075736564292E
		#tag Getter
			Get
			  Static d As Dictionary = InitialiseAutoCloseTags
			  
			  Return d
			  
			End Get
		#tag EndGetter
		Protected Shared AutoCloseTags As Dictionary
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1, Description = 4D61707320656E74697479206E616D657320746F207468656972206368617261637465722076616C756520284B6579203D20656E74697479206E616D652028537472696E67292C2056616C7565203D206368617261637465722028537472696E6729292E
		#tag Getter
			Get
			  Static d As Dictionary = InitialiseEntityMap
			  
			  Return d
			  
			End Get
		#tag EndGetter
		Protected Shared EntityMap As Dictionary
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected mColumnNumber As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mCurrentNode As HTMLNode
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mErrors() As HTMLParserException
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mHTML As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLength As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLineNumber As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mOpenTags() As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mPosition As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mRoot As HTMLNode
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mStrictMode As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h1, Description = 466F7220747261636B696E67206475706C69636174652049447320696E2074686520646F63756D656E742E
		Protected mTrackIDs As Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
