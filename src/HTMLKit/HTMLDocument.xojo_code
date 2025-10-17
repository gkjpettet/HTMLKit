#tag Class
Protected Class HTMLDocument
	#tag Method, Flags = &h21, Description = 4164647320612070617273696E67206572726F722E20496E20737472696374206D6F64652C2077652072616973652074686520657863657074696F6E20696E206164646974696F6E20746F206C6F6767696E672069742E
		Private Sub AddError(errorType As HTMLException.Types, message As String, severity As HTMLException.Severities = HTMLException.Severities.Warning)
		  /// Adds a parsing error.
		  /// In strict mode, we raise the exception in addition to logging it.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var e As New HTMLException(errorType, mLineNumber, mColumnNumber, message, severity)
		  
		  // Add a context snippet.
		  Var contextStart As Integer = Max(0, mPosition - 30)
		  Var contextEnd As Integer = Min(mCharsCount, mPosition + 30)
		  e.Context = SubString(contextStart, contextEnd - contextStart)
		  
		  mIssues.Add(e)
		  
		  // In strict mode, errors are fatal.
		  If mStrictMode And severity = HTMLException.Severities.Error Then
		    Raise e
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 416476616E6365732074686520706F736974696F6E203120706C61636520616E642075706461746573206C696E65206E756D6265727320616E6420636F6C756D6E20706F736974696F6E732E
		Private Sub Advance()
		  /// Advances the position 1 place and updates line numbers and column positions.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If mPosition <= mCharsLastIndex Then
		    If mChars(mPosition) = EndOfLine.UNIX Then
		      mLineNumber = mLineNumber + 1
		      mColumnNumber = 1
		    Else
		      mColumnNumber = mColumnNumber + 1
		    End If
		    mPosition = mPosition + 1
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 416476616E6365732074686520706F736974696F6E2074686520737065636966696564206E756D626572206F6620706C6163657320616E642075706461746573206C696E65206E756D6265727320616E6420636F6C756D6E20706F736974696F6E732E
		Private Sub AdvancePosition(places As Integer)
		  /// Advances the position the specified number of places and updates line numbers and column positions.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  For i As Integer = 1 To places
		    Advance
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Select Case node.TagName
		  Case "img"
		    If node.AttributeValue("src") = "" Then
		      AddError(HTMLException.Types.MissingRequiredAttribute, _
		      "<img> tag missing required `src` attribute", HTMLException.Severities.Error)
		    End If
		    If node.AttributeValue("alt") = "" And mStrictMode Then
		      AddError(HTMLException.Types.MissingRequiredAttribute, _
		      "<img> tag missing `alt` attribute for accessibility", HTMLException.Severities.Warning)
		    End If
		    
		  Case "a"
		    If TrackWarningsAndInfo Or mStrictMode Then
		      If node.AttributeValue("href") = "" And node.AttributeValue("name") = "" Then
		        AddError(HTMLException.Types.MissingRequiredAttribute, _
		        "<a> tags should normally have `href` or `name` attributes", HTMLException.Severities.Info)
		      End If
		    End If
		    
		  Case "form"
		    If node.AttributeValue("action") = "" And mStrictMode Then
		      AddError(HTMLException.Types.MissingRequiredAttribute, _
		      "<form> tag missing `action` attribute", HTMLException.Severities.Info)
		    End If
		    
		  Case "label"
		    If node.AttributeValue("for") = "" And mStrictMode Then
		      AddError(HTMLException.Types.MissingRequiredAttribute, _
		      "<label> tag should have `for` attribute", HTMLException.Severities.Info)
		    End If
		  End Select
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 436C6F736573207468652074616720776974682074686520706173736564206E616D652E
		Private Sub CloseTag(tagName As String)
		  /// Closes the tag with the passed name.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  // Forward declare variables so we don't do it on every iteration of the loop.
		  Var result As String = s
		  Var pos As Integer = 0
		  Var ampPos, semiPos, charCode As Integer
		  Var entity As String
		  
		  While pos < result.Length
		    ampPos = result.IndexOf(pos, "&#")
		    If ampPos = -1 Then Exit
		    
		    semiPos = result.IndexOf(ampPos, ";")
		    If semiPos = -1 Or semiPos > ampPos + 8 Then
		      pos = ampPos + 1
		      Continue
		    End If
		    
		    entity = result.Middle(ampPos + 2, semiPos - ampPos - 2)
		    charCode = 0
		    
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

	#tag Method, Flags = &h0, Description = 52657475726E73205472756520696620616E79206572726F727320286E6F74207761726E696E6773206F7220696E666F29206F6363757272656420647572696E672070617273696E672E
		Function HasErrors() As Boolean
		  /// Returns True if any errors (not warnings or info) occurred during parsing.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  For Each e As HTMLException In mIssues
		    If e = Nil Then Continue
		    
		    If e.Severity = HTMLException.Severities.Error Then
		      Return True
		    End If
		  Next e
		  
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73205472756520696620616E7920696E666F726D6174696F6E2069737375657320286E6F74206572726F7273206F72207761726E696E677329206F6363757272656420647572696E672070617273696E672E
		Function HasInfo() As Boolean
		  /// Returns True if any information issues (not errors or warnings) occurred during parsing.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  For Each e As HTMLException In mIssues
		    If e = Nil Then Continue
		    
		    If e.Severity = HTMLException.Severities.Info Then
		      Return True
		    End If
		  Next e
		  
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73205472756520696620616E792069737375657320286572726F72732C207761726E696E6773206F7220696E666F29206F6363757272656420647572696E672070617273696E672E
		Function HasIssues() As Boolean
		  /// Returns True if any issues (errors, warnings or info) occurred during parsing.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Return mIssues.Count > 0
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73205472756520696620616E79207761726E696E677320286E6F74206572726F7273206F7220696E666F29206F6363757272656420647572696E672070617273696E672E
		Function HasWarnings() As Boolean
		  /// Returns True if any warnings (not errors or info) occurred during parsing.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  For Each e As HTMLException In mIssues
		    If e = Nil Then Continue
		    
		    If e.Severity = HTMLException.Severities.Warning Then
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

	#tag Method, Flags = &h0, Description = 52657475726E7320616E792070617273696E672069737375657320286572726F72732C207761726E696E677320616E6420696E666F292074686174206F636375727265642E
		Function Issues() As HTMLException()
		  /// Returns any parsing issues (errors, warnings and info) that occurred.
		  
		  Return mIssues
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E732054727565206966207468652063757272656E74206E6F6465206973206E657374656420696E20612076616C6964206D616E6E65722E
		Private Function IsValidNesting(tagName As String) As Boolean
		  /// Returns True if the current node is nested in a valid manner.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
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

	#tag Method, Flags = &h0, Description = 5061727365732048544D4C20696E746F20612074726565206F662048544D4C206E6F6465732E
		Sub Parse(html As String)
		  /// Parses HTML into a tree of HTML nodes.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  // Standardise the HTML to have UNIX line endings.
		  mHTML = html.ReplaceLineEndings(EndOfLine.UNIX)
		  
		  // Split the HTML into characters for faster processing.
		  mChars = mHTML.Characters
		  
		  mPosition = 0
		  mLength = mHTML.Length
		  mCharsLastIndex = mChars.LastIndex
		  mCharsCount = mChars.Count
		  mLineNumber = 1
		  mColumnNumber = 1
		  mIssues.ResizeTo(-1)
		  mTrackIDs.RemoveAll
		  
		  mRoot = New HTMLNode(HTMLNode.Types.Element)
		  mRoot.TagName = "document"
		  mRoot.Type = HTMLNode.Types.Root
		  mCurrentNode = mRoot
		  mOpenTags.ResizeTo(-1)
		  
		  // Quickly check for the presence of CDATA sections, HTML comments or Doctype.
		  // If we know these are absent we can skip some checks in `ParseTag()`.
		  hasCDATA = mHTML.Contains("<![CDATA[")
		  hasHTMLComments = mHTML.Contains("!--")
		  hasDocType = mHTML.Contains("<!DOCTYPE ")
		  seenDocType = False
		  
		  Var char As String
		  While mPosition <= mCharsLastIndex
		    char = PeekChar
		    If char = "<" Then
		      ParseTag
		    ElseIf char = "" Then
		      Exit
		    Else
		      ParseText
		    End If
		  Wend
		  
		  // Check for unclosed tags and close any that remain.
		  While mOpenTags.Count > 0
		    Var tagName As String = mOpenTags(mOpenTags.LastIndex)
		    AddError(HTMLException.Types.UnclosedTag, _
		    "Tag <" + tagName + "> was not closed", HTMLException.Severities.Error)
		    CloseTag(tagName)
		  Wend
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273657320616E206174747269627574652E
		Private Sub ParseAttribute(node As HTMLNode)
		  /// Parses an attribute.
		  
		  SkipWhitespace
		  
		  // Parse the attribute's name.
		  Var attrName As String = ParseAttributeName
		  If attrName = "" Then
		    Advance
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
		  Advance
		  
		  SkipWhitespace
		  
		  // Parse the attribute's value.
		  Var attrValue As String = ParseAttributeValue
		  node.AttributeValue(attrName.Lowercase) = DecodeHTMLEntities(attrValue)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273657320616E642072657475726E7320616E206174747269627574652773206E616D652E
		Private Function ParseAttributeName() As String
		  /// Parses and returns an attribute's name.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var startPos As Integer = mPosition
		  
		  While mPosition < mCharsCount
		    Var c As String = PeekChar
		    Select Case c
		    Case "=", " ", "/", ">", "<", TAB, EndOfLine.UNIX
		      Exit
		    End Select
		    Advance
		  Wend
		  
		  Return SubString(startPos, mPosition - startPos)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273657320616E642072657475726E7320616E2061747472696275746527732076616C75652E
		Private Function ParseAttributeValue() As String
		  /// Parses and returns an attribute's value.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var quote As String = PeekChar
		  
		  If quote = """" Or quote = "'" Then
		    // This is a quoted value.
		    Advance
		    Var startPos As Integer = mPosition
		    
		    While mPosition < mCharsCount And PeekChar <> quote
		      Advance
		    Wend
		    
		    Var value As String = SubString(startPos, mPosition - startPos)
		    
		    If PeekChar = quote Then Advance
		    
		    Return value
		    
		  Else
		    // This is a non-quoted value.
		    Var startPos As Integer = mPosition
		    
		    While mPosition < mCharsCount
		      Var c As String = PeekChar
		      If c = " " Or c = ">" Or c = TAB Or c = EndOfLine.UNIX Then
		        Exit
		      End If
		      Advance
		    Wend
		    
		    Return SubString(startPos, mPosition - startPos)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 5061727365206174747269627574652076616C756520776974682071756F74652076616C69646174696F6E2E
		Private Function ParseAttributeValueWithValidation() As String
		  /// Parse attribute value with quote validation.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var quote As String = PeekChar
		  Var startLine As Integer = mLineNumber
		  Var startColumn As Integer = mColumnNumber
		  
		  If quote = """" Or quote = "'" Then
		    // Quoted value.
		    Advance
		    Var startPos As Integer = mPosition
		    Var foundClosingQuote As Boolean = False
		    
		    While mPosition < mCharsCount
		      If PeekChar() = quote Then
		        foundClosingQuote = True
		        Exit
		      End If
		      Advance
		    Wend
		    
		    Var value As String = SubString(startPos, mPosition - startPos)
		    
		    If foundClosingQuote Then
		      Advance // Skip the closing quote.
		    Else
		      AddError(HTMLException.Types.UnclosedQuote, _
		      "Unclosed quote in attribute value", HTMLException.Severities.Error)
		    End If
		    
		    Return value
		  Else
		    // Unquoted value.
		    If mStrictMode Then
		      AddError(HTMLException.Types.InvalidAttribute, _
		      "Attribute values should be quoted", HTMLException.Severities.Warning)
		    End If
		    
		    Var startPos As Integer = mPosition
		    While mPosition < mCharsCount
		      Var c As String = PeekChar
		      If c = " " Or c = ">" Or c = TAB Or c = EndOfLine.UNIX Then
		        Exit
		      End If
		      Advance
		    Wend
		    
		    Return SubString(startPos, mPosition - startPos)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 50617273652061747472696275746520776974682076616C69646174696F6E2E
		Private Sub ParseAttributeWithValidation(node As HTMLNode, attrName As String)
		  /// Parse attribute with validation.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Static booleanAttrs() As String = Array("checked", "disabled", "readonly", _
		  "required", "multiple", "selected", "defer", "async", "autofocus")
		  
		  SkipWhitespace
		  
		  // Check for "=".
		  If PeekChar <> "=" Then
		    // An attribute without value (boolean attribute).
		    node.AttributeValue(attrName.Lowercase) = ""
		    
		    // Validate boolean attributes.
		    If booleanAttrs.IndexOf(attrName.Lowercase) = -1 And mStrictMode Then
		      AddError(HTMLException.Types.InvalidAttribute, _
		      "Attribute '" + attrName + "' should have a value", HTMLException.Severities.Info)
		    End If
		    Return
		  End If
		  
		  // Skip "="
		  Advance
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  // Skip "![CDATA[".
		  AdvancePosition(8)
		  Var startPos As Integer = mPosition
		  Var content As String = ""
		  
		  // Look for the closing "]]>".
		  While mPosition < mCharsCount - 2
		    If SubString(mPosition, 3) = "]]>" Then
		      // Found the end of the CDATA section.
		      content = SubString(startPos, mPosition - startPos)
		      
		      // Skip the "]]>".
		      AdvancePosition(3)
		      
		      // Create the CDATA node.
		      Var cdataNode As New HTMLNode(HTMLNode.Types.CDATA)
		      
		      // We don't decode entities in CDATA sections!.
		      cdataNode.Content = content
		      
		      mCurrentNode.AddChild(cdataNode)
		      Return
		    End If
		    
		    Advance
		  Wend
		  
		  // This is an unclosed CDATA section - treat the rest of the document as CDATA.
		  content = SubString(startPos, mCharsCount - startPos)
		  Var cdataNode As New HTMLNode(HTMLNode.Types.CDATA)
		  cdataNode.Content = content
		  mCurrentNode.AddChild(cdataNode)
		  ' mPosition = mLength
		  mPosition = mCharsCount
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 506172736573206120636C6F73696E67207461672E20417373756D6573207765277665207365656E206120222F222E
		Private Sub ParseClosingTag()
		  /// Parses a closing tag. Assumes we've seen a "/".
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var tagName As String = ParseTagName.Lowercase
		  
		  // Skip to ">".
		  While mPosition < mCharsCount And PeekChar <> ">"
		    Advance
		  Wend
		  If PeekChar = ">" Then
		    Advance
		  End If
		  
		  If tagName = "" Then
		    AddError(HTMLException.Types.MalformedTag, _
		    "Empty closing tag", HTMLException.Severities.Error)
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
		    AddError(HTMLException.Types.UnmatchedClosingTag, _
		    "Closing tag </" + tagName + "> has no matching opening tag", _
		    HTMLException.Severities.Error)
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
		    
		    If TrackWarningsAndInfo Or mStrictMode Then
		      AddError(HTMLException.Types.InvalidNesting, _
		      "Closing tag </" + tagName + "> found before " + message, HTMLException.Severities.Warning)
		    End If
		  End If
		  
		  CloseTag(tagName)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 506172736573206120636F6D6D656E742E
		Private Sub ParseComment()
		  /// Parses a comment.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  AdvancePosition(3) // Skip "!--"
		  Var startPos As Integer = mPosition
		  
		  While mPosition < mCharsCount - 2
		    If SubString(mPosition, 3) = "-->" Then
		      Var comment As String = SubString(startPos, mPosition - startPos)
		      Var commentNode As New HTMLNode(HTMLNode.Types.Comment)
		      commentNode.Content = comment
		      mCurrentNode.AddChild(commentNode)
		      AdvancePosition(3)
		      Return
		    End If
		    Advance
		  Wend
		  
		  // Unclosed comment, add what we have...
		  Var comment As String = SubString(startPos, mCharsCount - startPos)
		  Var commentNode As New HTMLNode(HTMLNode.Types.Comment)
		  commentNode.Content = comment
		  mCurrentNode.AddChild(commentNode)
		  ' mPosition = mLength
		  mPosition = mCharsCount
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 506172736573206120446F6374797065206E6F64652E
		Private Sub ParseDocType()
		  /// Parses a Doctype node.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  AdvancePosition(8) // Skip "!DOCTYPE"
		  SkipWhitespace
		  
		  Var startPos As Integer = mPosition
		  While mPosition < mCharsCount And PeekChar <> ">"
		    Advance
		  Wend
		  
		  Var doctype As String = SubString(startPos, mPosition - startPos).Trim
		  Var doctypeNode As New HTMLNode(HTMLNode.Types.DocType)
		  doctypeNode.Content = doctype
		  mCurrentNode.AddChild(doctypeNode)
		  
		  If PeekChar = ">" Then Advance
		  
		  seenDocType = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 506172736573206D6978656420434441544120636F6E74656E742077697468696E20726177207465787420746167732028652E673A203C7363726970743E20616E64203C7374796C653E292E
		Private Sub ParseMixedCDATAContent(parentNode As HTMLNode, content As String)
		  /// Parses mixed CDATA content within raw text tags (e.g: <script> and <style>).
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Static deprecatedTags() As String = Array("font", "center", "marquee", _
		  "blink", "big", "strike", "tt", "frame", "frameset", "noframes")
		  
		  Var startLine As Integer = mLineNumber
		  Var startColumn As Integer = mColumnNumber
		  
		  Var tagName As String = ParseTagName
		  
		  If tagName = "" Then
		    AddError(HTMLException.Types.MalformedTag, _
		    "Empty tag name", HTMLException.Severities.Error)
		    Return
		  End If
		  
		  tagName = tagName.Lowercase
		  
		  // Check for deprecated tags.
		  If TrackWarningsAndInfo or mStrictMode Then
		    If deprecatedTags.IndexOf(tagName) <> -1 Then
		      AddError(HTMLException.Types.DeprecatedTag, _
		      "Tag <" + tagName + "> is deprecated in HTML5", HTMLException.Severities.Warning)
		    End If
		  End If
		  
		  // Check nesting rules.
		  If TrackWarningsAndInfo Or mStrictMode Then
		    If Not IsValidNesting(tagName) Then
		      AddError(HTMLException.Types.InvalidNesting, _
		      "Tag <" + tagName + "> cannot be nested inside <" + mCurrentNode.TagName + ">", _
		      HTMLException.Severities.Warning)
		    End If
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
		  
		  // Store a reference if this if it's the <head> or <body> element.
		  Select Case tagName
		  Case "head"
		    // If the document contains more than one <head>, we’ll keep the first but raise it as an error.
		    If mHead = Nil Then
		      mHead = node
		    Else
		      AddError(HTMLException.Types.InvalidStructure, "<head> encountered but the document already contains a <head> element.", _
		      HTMLException.Severities.Error)
		    End If
		  Case "body"
		    // If the document contains more than one <body>, we’ll keep the first but raise it as an error.
		    If mBody = Nil Then
		      mBody = node
		    Else
		      AddError(HTMLException.Types.InvalidStructure, "<body> encountered but the document already contains a <body> element.", _
		      HTMLException.Severities.Error)
		    End If
		  End Select
		  
		  // Parse attributes with validation.
		  SkipWhitespace
		  Var seenAttributes As New Dictionary
		  Var prematureTagFound As Boolean = False
		  While mPosition < mCharsCount And PeekChar <> ">" And PeekChar <> "/"
		    If PeekChar = "<" Then
		      AddError(HTMLException.Types.MalformedTag, _
		      "Missing `>` for tag <" + tagName + "> before a new tag was encountered", HTMLException.Severities.Error)
		      prematureTagFound = True
		      Exit
		    End If
		    
		    Var attrName As String = ParseAttributeName
		    If attrName = "" Then
		      Advance
		      Continue
		    End If
		    
		    // Check for duplicate attributes.
		    If TrackWarningsAndInfo Or mStrictMode Then
		      If seenAttributes.HasKey(attrName.Lowercase) Then
		        AddError(HTMLException.Types.InvalidAttribute, _
		        "Duplicate attribute '" + attrName + "' in <" + tagName + ">", _
		        HTMLException.Severities.Warning)
		      End If
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
		      AddError(HTMLException.Types.DuplicateID, _
		      "Duplicate ID '" + id + "' found", HTMLException.Severities.Error)
		    Else
		      mTrackIDs.Value(id) = True
		    End If
		  End If
		  
		  // Check for a self-closing tag.
		  Var isSelfClosing As Boolean = False
		  If PeekChar = "/" Then
		    isSelfClosing = True
		    Advance
		  End If
		  
		  // Skip closing ">".
		  If Not prematureTagFound Then
		    If PeekChar = ">" Then
		      Advance
		    Else
		      AddError(HTMLException.Types.MalformedTag, _
		      "Missing '>' for tag <" + tagName + ">", HTMLException.Severities.Error)
		    End If
		  End If
		  
		  // Add node to tree
		  mCurrentNode.AddChild(node)
		  
		  // Handle void and raw text tags.
		  If RawTextTags.IndexOf(tagName) <> -1 And Not isSelfClosing Then
		    ParseRawTextContent(node, tagName)
		  ElseIf VoidTags.IndexOf(tagName) <> -1 Then
		    If Not isSelfClosing And mStrictMode Then
		      AddError(HTMLException.Types.MalformedTag, _
		      "Void tag <" + tagName + "> should be self-closing", HTMLException.Severities.Warning)
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var startPos As Integer = mPosition
		  Var closingTag As String = "</" + tagName
		  Var content As String = ""
		  
		  // Look for the closing tag.
		  While mPosition < mCharsCount
		    // Check if we found a potential closing tag.
		    If SubString(mPosition, closingTag.Length).Lowercase = closingTag Then
		      // Check if it's followed by ">" or whitespace.
		      Var nextPos As Integer = mPosition + closingTag.Length
		      If nextPos >= mCharsCount Then Exit
		      
		      Var nextChar As String = mChars(nextPos)
		      If nextChar = ">" Or nextChar = " " Or nextChar = TAB Or nextChar = EndOfLine.UNIX Then
		        // Found a valid closing tag.
		        content = SubString(startPos, mPosition - startPos)
		        
		        // Skip the closing tag.
		        AdvancePosition(closingTag.Length)
		        While mPosition < mCharsCount And SubString(mPosition, 1) <> ">"
		          Advance
		        Wend
		        
		        // Skip ">".
		        If mPosition < mCharsCount Then Advance
		        
		        Exit
		      End If
		    End If
		    
		    Advance
		  Wend
		  
		  // If we didn't find a closing tag, use everything until the end.
		  If content = "" And mPosition >= mCharsCount Then
		    content = SubString(startPos, mCharsCount - startPos)
		  End If
		  
		  If content <> "" Then
		    Var textNode As New HTMLNode(HTMLNode.Types.Text)
		    textNode.Content = content // We don't decode entities in raw text tags (e.g: <script> and <style> nodes).
		    parentNode.AddChild(textNode)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 5061727365732061207461672E20417373756D65732077652068617665206A757374207365656E206120223C22206368617261637465722E
		Private Sub ParseTag()
		  /// Parses a tag.
		  /// Assumes we have just seen a "<" character.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  // Skip the "<".
		  Advance
		  
		  If mPosition >= mCharsCount Then Return
		  
		  // Check for CDATA section
		  If hasCDATA Then
		    If SubString(mPosition, 8) = "![CDATA[" Then
		      ParseCDATA
		      Return
		    End If
		  End If
		  
		  // Check for a comment.
		  If hasHTMLComments Then
		    If SubString(mPosition, 3) = "!--" Then
		      ParseComment
		      Return
		    End If
		  End If
		  
		  // Check for DOCTYPE.
		  If hasDocType And Not seenDocType Then
		    If SubString(mPosition, 8) = "!DOCTYPE" Then
		      ParseDoctype
		      Return
		    End If
		  End If
		  
		  // Check is this is a closing tag.
		  If PeekChar = "/" Then
		    Advance
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  SkipWhitespace
		  
		  Var startPos As Integer = mPosition
		  
		  While mPosition < mCharsCount
		    Var c As String = PeekChar
		    If c = " " Or c = "/" Or c = ">" Or c = TAB Or c = EndOfLine.UNIX Then
		      Exit
		    End If
		    Advance
		  Wend
		  
		  Return SubString(startPos, mPosition - startPos)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 506172736573207465787420636F6E74656E742E
		Private Sub ParseText()
		  /// Parses text content.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var startPos As Integer = mPosition
		  
		  While mPosition <= mCharsLastIndex And mChars(mPosition) <> "<" And mChars(mPosition) <> ""
		    Advance
		  Wend
		  
		  Var t As String = SubString(startPos, mPosition - startPos)
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If mPosition <= mCharsLastIndex Then Return mChars(mPosition)
		  
		  Return ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PeekString(length As Integer) As String
		  /// Peeks at the specified number of characters without advancing the position.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If mPosition + length <= mCharsCount Then Return SubString(mPosition, length)
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  While mPosition <= mCharsLastIndex
		    Var c As String = mChars(mPosition)
		    If c <> " " And c <> TAB And c <> EndOfLine.UNIX Then Exit
		    Advance
		  Wend
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E73206120737472696E672066726F6D20746865206D436861727320617272617920626567696E6E696E6720617420607374617274506F736020666F7220606C656E6774686020636861726163746572732E2052657475726E732022222069662062616420706172616D65746572732E2052657475726E732066726F6D20607374617274506F736020746F2074686520656E64206F662074686520617272617920696620606C656E6774686020697320746F6F2067726561742E
		Private Function SubString(startPos As Integer, length As Integer) As String
		  /// Returns a string from the mChars array beginning at `startPos` for `length` characters.
		  /// Returns "" if bad parameters.
		  /// Returns from `startPos` to the end of the array if `length` is too great.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If startPos < 0 Or startPos >= mChars.Count Or length <= 0 Then Return ""
		  
		  Var endPos As Integer = Min(startPos + length, mChars.Count)
		  Var actualLength As Integer = endPos - startPos
		  
		  If actualLength <= 0 Then Return ""
		  
		  ' Extract the slice of characters.
		  Var chars() As String
		  chars.ResizeTo(actualLength - 1)
		  For i As Integer = 0 To chars.LastIndex
		    chars(i) = mChars(startPos + i)
		  Next
		  
		  Return String.FromArray(chars, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 56616C6964617465207370656369666963206174747269627574652076616C7565732E
		Private Sub ValidateAttributeValue(tagName As String, attrName As String, value As String)
		  /// Validate specific attribute values.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Static validTypes() As String = Array("text", "password", "email", "url", _
		  "tel", "number", "range", "date", "time", "datetime-local", "month", _
		  "week", "color", "checkbox", "radio", "file", "submit", "reset", _
		  "button", "hidden", "image", "search")
		  
		  // Validate input types.
		  If TrackWarningsAndInfo Or mStrictMode Then
		    If tagName = "input" And attrName = "type" Then
		      If validTypes.IndexOf(value.Lowercase) = -1 Then
		        AddError(HTMLException.Types.InvalidAttribute, _
		        "Invalid input type: '" + value + "'", HTMLException.Severities.Warning)
		      End If
		    End If
		  End If
		  
		  // Validate URLs.
		  If attrName = "href" Or attrName = "src" Or attrName = "action" Then
		    If value.IndexOf("javascript:") = 0 And mStrictMode Then
		      AddError(HTMLException.Types.InvalidAttribute, _
		      "JavaScript URLs are discouraged", HTMLException.Severities.Warning)
		    End If
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

	#tag ComputedProperty, Flags = &h0, Description = 52657475726E7320746865203C626F64793E20656C656D656E742E204D6179206265204E696C2E
		#tag Getter
			Get
			  Return mBody
			  
			  
			End Get
		#tag EndGetter
		Body As HTMLNode
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

	#tag Property, Flags = &h1, Description = 547275652069662074686520646F63756D656E7420636F6E7461696E73206174206C65617374206F6E6520434441544120737472696E672028223C215B43444154415B22292E
		Protected hasCDATA As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h1, Description = 547275652069662074686520737472696E6720223C21444F43545950452022206F636375727320696E2074686520646F63756D656E74206174206C65617374206F6E63652E
		Protected hasDocType As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h1, Description = 547275652069662074686520646F63756D656E7420686173206174206C65617374206F6E652048544D4C20636F6D6D656E742E
		Protected hasHTMLComments As Boolean = False
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 52657475726E7320746865203C686561643E20656C656D656E742E204D6179206265204E696C2E
		#tag Getter
			Get
			  Return mHead
			  
			End Get
		#tag EndGetter
		Head As HTMLNode
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected mBody As HTMLNode
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mChars() As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mCharsCount As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mCharsLastIndex As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mColumnNumber As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mCurrentNode As HTMLNode
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mHead As HTMLNode
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mHTML As String
	#tag EndProperty

	#tag Property, Flags = &h1, Description = 53746F72657320616E792069737375657320286572726F72732C207761726E696E6773206F7220696E666F726D6174696F6E206D65737361676573292E
		Protected mIssues() As HTMLException
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

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mRoot
			  
			End Get
		#tag EndGetter
		Root As HTMLNode
	#tag EndComputedProperty

	#tag Property, Flags = &h1, Description = 547275652069662074686520446F635479706520686173206265656E2070726F63657373656420696E207468697320646F63756D656E742E
		Protected seenDocType As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 49662054727565207468656E20746865207061727365722077696C6C20747261636B2048544D4C20666F726D617474696E67207761726E696E677320616E6420696E666F726D6174696F6E206D657373616765732E2049676E6F72656420696E20737472696374206D6F64652E
		TrackWarningsAndInfo As Boolean = True
	#tag EndProperty


	#tag Constant, Name = TAB, Type = String, Dynamic = False, Default = \"\t", Scope = Protected, Description = 54686520686F72697A6F6E74616C2074616220636861726163746572202826753039292E
	#tag EndConstant


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
		#tag ViewProperty
			Name="TrackWarningsAndInfo"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
