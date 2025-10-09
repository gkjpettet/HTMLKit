#tag Class
Protected Class HTMLParser
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

	#tag Method, Flags = &h21, Description = 4465636F6465732048544D4C20656E7469746965732077697468696E2060736020746F2074686569722061637475616C2076616C75657320616E642072657475726E732061206E657720737472696E6720776974682074686520656E746974696573206465636F6465642E
		Private Function DecodeHTMLEntities(s As String) As String
		  /// Decodes HTML entities within `s` to their actual values and returns a new string with the entities decoded.
		  
		  #Pragma Warning "TODO: Make this more robust"
		  
		  Var result As String = s
		  
		  // Common HTML entities
		  result = result.ReplaceAll("&amp;", "&")
		  result = result.ReplaceAll("&lt;", "<")
		  result = result.ReplaceAll("&gt;", ">")
		  result = result.ReplaceAll("&quot;", """")
		  result = result.ReplaceAll("&apos;", "'")
		  result = result.ReplaceAll("&nbsp;", " ")
		  
		  Return result
		  
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

	#tag Method, Flags = &h0
		Function Parse(html As String) As HTMLNode
		  // Initialise.
		  mHTML = html
		  mPosition = 0
		  mLength = html.Length
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
		  
		  // Close any remaining open tags.
		  While mOpenTags.Count > 0
		    CloseTag(mOpenTags(mOpenTags.LastIndex))
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

	#tag Method, Flags = &h21, Description = 506172736573206120636C6F73696E67207461672E20417373756D6573207765277665207365656E206120222F222E
		Private Sub ParseClosingTag()
		  /// Parses a closing tag. Assumes we've seen a "/".
		  
		  Var tagName As String = ParseTagName.Lowercase
		  
		  // Skip to ">".
		  While mPosition < mLength And PeekChar <> ">"
		    mPosition = mPosition + 1
		  Wend
		  If PeekChar = ">" Then
		    mPosition = mPosition + 1
		  End If
		  
		  If tagName = "" Then Return
		  
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

	#tag Method, Flags = &h21, Description = 50617273657320616E206F70656E696E67207461672E20417373756D6573207765206861766520736B697070656420706173742074686520223C222E
		Private Sub ParseOpeningTag()
		  /// Parses an opening tag.
		  /// Assumes we have skipped past the "<".
		  
		  Var tagName As String = ParseTagName
		  
		  If tagName = "" Then Return
		  
		  tagName = tagName.Lowercase
		  
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
		  
		  // Parse any attributes.
		  SkipWhitespace
		  While mPosition < mLength And PeekChar <> ">" And PeekChar <> "/"
		    ParseAttribute(node)
		    SkipWhitespace
		  Wend
		  
		  // Check for a self-closing tag.
		  Var isSelfClosing As Boolean = False
		  If PeekChar = "/" Then
		    isSelfClosing = True
		    mPosition = mPosition + 1
		  End If
		  
		  // Skip the closing ">".
		  If PeekChar = ">" Then
		    mPosition = mPosition + 1
		  End If
		  
		  // Add the node to the tree.
		  mCurrentNode.AddChild(node)
		  
		  // Check if this is a void tag.
		  If VoidTags.IndexOf(tagName) <> -1 Then
		    node.IsSelfClosing = True
		  ElseIf Not isSelfClosing Then
		    // Set as the current node if not self-closing.
		    mCurrentNode = node
		    mOpenTags.Add(tagName)
		    node.IsSelfClosing = False
		  Else
		    node.IsSelfClosing = True
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

	#tag Property, Flags = &h1
		Protected mCurrentNode As HTMLNode
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mHTML As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLength As Integer
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
