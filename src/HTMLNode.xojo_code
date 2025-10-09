#tag Class
Protected Class HTMLNode
	#tag Method, Flags = &h0
		Sub AddChild(child As HTMLNode)
		  /// Adds a child node so long as it is not Nil.
		  /// Does nothing if child is Nil.
		  
		  If child = Nil Then Return
		  
		  child.Parent = Self
		  
		  Children.Add(child)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207468652076616C7565206F66207468652072657175657374656420617474726962757465206F6E2074686973206E6F6465206F72202222206966207468652061747472696275746520646F6573206E6F742065786973742E
		Function AttributeValue(attributeName As String) As String
		  /// Returns the value of the requested attribute on this node or "" if the attribute does not exist.
		  
		  Return Attributes_.Lookup(attributeName, "")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5365747320746865207370656369666965642061747472696275746520746F20746865207061737365642076616C75652E2057696C6C206F7665727772697465206F7220637265617465206966206E65656465642E
		Sub AttributeValue(attributeName As String, Assigns value As String)
		  /// Sets the specified attribute to the passed value. Will overwrite or create if needed.
		  /// If attributeName is "" then this method does nothing.
		  
		  If attributeName = "" Then Return
		  
		  Attributes_.Value(attributeName) = value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(type As HTMLNode.Types)
		  Self.Type = type
		  Attributes_ = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub FindByAttribute(attrSpec As String, results() As HTMLNode)
		  /// Finds all nodes with the specified attribute and adds them to the passed ByRef `results()` array.
		  /// 
		  
		  // Only elements can have attributes.
		  If Self.Type <> Types.Element Then
		    For Each child As HTMLNode In Children
		      child.FindByAttribute(attrSpec, results)
		    Next child
		    Return
		  End If
		  
		  // Parse different attribute selector patterns.
		  Var matched As Boolean = False
		  
		  // Check for different operator patterns
		  If attrSpec.IndexOf("*=") <> -1 Then
		    // [attr*=value] - Contains substring.
		    Var parts() As String = attrSpec.Split("*=")
		    If parts.Count = 2 Then
		      Var attrName As String = parts(0).Trim
		      Var attrValue As String = StripQuotes(parts(1).Trim)
		      Var actualValue As String = AttributeValue(attrName)
		      If actualValue.IndexOf(attrValue) <> -1 Then
		        matched = True
		      End If
		    End If
		    
		  ElseIf attrSpec.IndexOf("^=") <> -1 Then
		    // [attr^=value] - Starts with
		    Var parts() As String = attrSpec.Split("^=")
		    If parts.Count = 2 Then
		      Var attrName As String = parts(0).Trim
		      Var attrValue As String = StripQuotes(parts(1).Trim)
		      Var actualValue As String = AttributeValue(attrName)
		      If actualValue.Left(attrValue.Length) = attrValue Then
		        matched = True
		      End If
		    End If
		    
		  ElseIf attrSpec.IndexOf("$=") <> -1 Then
		    // [attr$=value] - Ends with
		    Var parts() As String = attrSpec.Split("$=")
		    If parts.Count = 2 Then
		      Var attrName As String = parts(0).Trim
		      Var attrValue As String = StripQuotes(parts(1).Trim)
		      Var actualValue As String = AttributeValue(attrName)
		      If actualValue.Right(attrValue.Length) = attrValue Then
		        matched = True
		      End If
		    End If
		    
		  ElseIf attrSpec.IndexOf("~=") <> -1 Then
		    // [attr~=value] - Contains word (space-separated)
		    Var parts() As String = attrSpec.Split("~=")
		    If parts.Count = 2 Then
		      Var attrName As String = parts(0).Trim
		      Var attrValue As String = StripQuotes(parts(1).Trim)
		      Var actualValue As String = AttributeValue(attrName)
		      Var words() As String = actualValue.Split(" ")
		      If words.IndexOf(attrValue) <> -1 Then
		        matched = True
		      End If
		    End If
		    
		  ElseIf attrSpec.IndexOf("|=") <> -1 Then
		    // [attr|=value] - Exact or starts with value- (for language codes)
		    Var parts() As String = attrSpec.Split("|=")
		    If parts.Count = 2 Then
		      Var attrName As String = parts(0).Trim
		      Var attrValue As String = StripQuotes(parts(1).Trim)
		      Var actualValue As String = AttributeValue(attrName)
		      If actualValue = attrValue Or actualValue.Left(attrValue.Length + 1) = attrValue + "-" Then
		        matched = True
		      End If
		    End If
		    
		  ElseIf attrSpec.IndexOf("!=") <> -1 Then
		    // [attr!=value] - Not equal (non-standard but useful)
		    Var parts() As String = attrSpec.Split("!=")
		    If parts.Count = 2 Then
		      Var attrName As String = parts(0).Trim
		      Var attrValue As String = StripQuotes(parts(1).Trim)
		      If AttributeValue(attrName) <> attrValue Then
		        matched = True
		      End If
		    End If
		    
		  ElseIf attrSpec.IndexOf("=") <> -1 Then
		    // [attr=value] - Exact match
		    Var parts() As String = attrSpec.Split("=")
		    If parts.Count = 2 Then
		      Var attrName As String = parts(0).Trim
		      Var attrValue As String = StripQuotes(parts(1).Trim)
		      If AttributeValue(attrName) = attrValue Then
		        matched = True
		      End If
		    End If
		    
		  Else
		    // [attr] - Just checking for attribute existence
		    If Attributes_.HasKey(attrSpec.Trim) Then
		      matched = True
		    End If
		  End If
		  
		  If matched Then
		    results.Add(Self)
		  End If
		  
		  // Recursively check children.
		  For Each child As HTMLNode In Children
		    child.FindByAttribute(attrSpec, results)
		  Next child
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 46696E647320616C6C206E6F6465732077686F736520636C617373206E616D652069732060636C6173734E616D656020616E642061646473207468656D20746F20746865207061737365642042795265662060726573756C74732829602061727261792E
		Private Sub FindByClassName(className As String, ByRef results() As HTMLNode)
		  /// Finds all nodes whose class name is `className` and adds them to the passed ByRef `results()` array.
		  
		  If Self.Type = Types.Element Then
		    Var classAttr As String = AttributeValue("class")
		    Var classes() As String = classAttr.Split(" ")
		    If classes.IndexOf(className) <> -1 Then
		      results.Add(Self)
		    End If
		  End If
		  
		  For Each child As HTMLNode In Children
		    child.FindByClassName(className, results)
		  Next child
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 46696E647320616C6C206E6F6465732077686F7365206964206D6174636865732074686520706173736564206069646020616E642061646473207468656D20746F20746865207061737365642042795265662060726573756C74732829602061727261792E
		Private Sub FindByID(id As String, results() As HTMLNode)
		  /// Finds all nodes whose id matches the passed `id` and adds them to the passed ByRef `results()` array.
		  
		  If Self.Type = Types.Element And AttributeValue("id") = id Then
		    results.Add(Self)
		  End If
		  
		  For Each child As HTMLNode In Children
		    child.FindByID(id, results)
		  Next child
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 46696E647320616C6C206E6F6465732077686F7365206E616D6520697320607461674E616D656020616E642061646473207468656D20746F20746865207061737365642042795265662060726573756C74732829602061727261792E
		Private Sub FindByTagName(tagName As String, ByRef results() As HTMLNode)
		  /// Finds all nodes whose name is `tagName` and adds them to the passed ByRef `results()` array.
		  
		  If Type = Types.Element And Self.TagName.Lowercase = tagName.Lowercase Then
		    results.Add(Self)
		  End If
		  
		  For Each child As HTMLNode In Children
		    child.FindByTagName(tagName, results)
		  Next child
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 46696E647320616E642072657475726E732074686520666972737420616E636573746F72207769746820676976656E2074686520746167206E616D65206F72204E696C206966206E6F6E6520666F756E642E
		Function GetAncestor(tagName As String) As HTMLNode
		  /// Finds and returns the first ancestor with given the tag name or Nil if none found.
		  
		  Var current As HTMLNode = Parent
		  While current <> Nil
		    If current.Type = HTMLNode.Types.Element And current.TagName.Lowercase = tagName.Lowercase Then
		      Return current
		    End If
		    current = current.Parent
		  Wend
		  
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320616C6C20656C656D656E747320696E2074686973206E6F64652077686F736520746167206D61746368657320746865207061737365642076616C75652E
		Function GetElementsByTagName(tagName As String) As HTMLNode()
		  /// Returns all elements in this node whose tag matches the passed value.
		  
		  Var results() As HTMLNode
		  
		  FindByTagName(tagName.Lowercase, results)
		  
		  Return results
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746865206669727374206368696C64206F662074686973206E6F6465206F72204E696C20696620746865726520617265206E6F206368696C6472656E2E
		Function GetFirstChild() As HTMLNode
		  /// Returns the first child of this node or Nil if there are no children.
		  
		  If Children.Count > 0 Then Return Children(0)
		  
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetInnerText() As String
		  Var result As String
		  
		  If Self.Type = HTMLNode.Types.Text Then
		    
		    Return Self.Content
		    
		  ElseIf Self.Type = HTMLNode.Types.Element Then
		    
		    For Each child As HTMLNode In Children
		      result = result + child.GetInnerText
		    Next child
		    
		  End If
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746865206C617374202866696E616C29206368696C64206F662074686973206E6F6465206F72204E696C20696620746865726520617265206E6F206368696C6472656E2E
		Function GetLastChild() As HTMLNode
		  /// Returns the last (final) child of this node or Nil if there are no children.
		  
		  If Children.Count > 0 Then Return Children(Children.LastIndex)
		  
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746865206E657874207369626C696E67206E6F6465206F72204E696C206966207468657265206973206E6F6E652E
		Function GetNextSibling() As HTMLNode
		  /// Returns the next sibling node or Nil if there is none.
		  
		  If Parent = Nil Then Return Nil
		  
		  Var myIndex As Integer = Parent.Children.IndexOf(Self)
		  If myIndex >= 0 And myIndex < parent.Children.LastIndex Then
		    Return parent.Children(myIndex + 1)
		  End If
		  
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207465787420776974682070726F70657220776869746573706163652068616E646C696E672E
		Function GetNormalisedText() As String
		  /// Returns text with proper whitespace handling.
		  
		  If Self.Type = HTMLNode.Types.Text Then
		    // Check if the parent is a <pre> tag.
		    If Self.Parent <> Nil And Self.Parent.TagName = "pre" Then
		      Return Content // Preserve whitespace in <pre> tags.
		    Else
		      // Normalise whitespace.
		      Return NormaliseWhitespace(Content)
		    End If
		    
		  ElseIf Self.Type = HTMLNode.Types.Element Then
		    Var result As String
		    Var needsSpace As Boolean = False
		    
		    For Each child As HTMLNode In Children
		      Var childText As String = child.GetNormalisedText
		      
		      If childText <> "" Then
		        If needsSpace And Not IsWhitespace(childText.Left(1)) Then
		          result = result + " "
		        End If
		        result = result + childText
		        needsSpace = child.IsBlockElement
		      End If
		    Next child
		    
		    Return result.Trim
		  End If
		  
		  Return ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207468652070726576696F7573207369626C696E67206F72204E696C20696620746865726520617265206E6F207369626C696E6773206F72207468697320697320746865206669727374206368696C642E
		Function GetPreviousSibling() As HTMLNode
		  /// Returns the previous sibling or Nil if there are no siblings or this is the first child.
		  
		  If parent = Nil Then Return Nil
		  
		  Var myIndex As Integer = parent.Children.IndexOf(Self)
		  If myIndex > 0 Then Return parent.Children(myIndex - 1)
		  
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 44657465726D696E657320696620746865207061737365642063686172616374657220697320776869746573706163652E2049662060636861722E4C656E67746860203C3E2031207468656E2077652072657475726E2046616C73652E
		Protected Function IsWhitespace(char As String) As Boolean
		  /// Determines if the passed character is whitespace.
		  /// If `char.Length` <> 1 then we return False.
		  
		  // Return False for anything that isn’t a single character.
		  If char.Length <> 1 Then Return False
		  
		  // Xojo’s built‑in Trim() removes the Unicode whitespace chars:
		  // space, tab (U+0009), line‑feed (U+000A) and carriage‑return (U+000D),
		  // so we can simply ask whether trimming leaves an empty string.
		  Return char.Trim = ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5265706C6163657320616C6C20776869746573706163652073657175656E636573207769746820612073696E676C652073706163652E
		Function NormaliseWhitespace(s As String) As String
		  /// Replaces all whitespace sequences with a single space.
		  
		  Var result As String = s
		  
		  // Replace tabs and newlines with spaces.
		  result = result.ReplaceAll(Chr(9), " ")
		  result = result.ReplaceAll(Chr(10), " ")
		  result = result.ReplaceAll(Chr(13), " ")
		  
		  // Collapse multiple spaces.
		  While result.IndexOf("  ") <> -1
		    result = result.ReplaceAll("  ", " ")
		  Wend
		  
		  Return result.Trim
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E73207468652074797065206F662073656C6563746F722074686973206973206173206120737472696E672028652E672E202223636F6E74656E7422206973206F66207479706520226964222C20222E626164676522206973206F6620747970652022636C61737322292E20537570706F727465642073656C6563746F722074797065733A20226964222C2022636C617373222C2022617474726962757465222028652E672E205B6E616D655D29206F72206A7573742067656E657269632022746167222E
		Private Function ParseSelector(theSelector As String) As String()
		  /// Returns the type of selector this is as a string (e.g. "#content" is of type "id", ".badge" is of type "class").
		  /// Supported selector types: "id", "class", "attribute" (e.g. [name]) or just generic "tag".
		  
		  Var result() As String
		  
		  theSelector = theSelector.Trim
		  If theSelector = "" Then Return result
		  
		  If theSelector.Left(1) = "#" Then
		    result.Add("id")
		    result.Add(theSelector.Middle(1))
		  ElseIf theSelector.Left(1) = "." Then
		    result.Add("class")
		    result.Add(theSelector.Middle(1))
		  ElseIf theSelector.Left(1) = "[" And theSelector.Right(1) = "]" Then
		    result.Add("attribute")
		    result.Add(theSelector.Middle(1, theSelector.Length - 2))
		  Else
		    result.Add("tag")
		    result.Add(theSelector.Lowercase)
		  End If
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function QuerySelector(theSelector As String) As HTMLNode
		  // Returns the first matching node.
		  Var results() As HTMLNode = QuerySelectorAll(theSelector)
		  
		  If results.Count > 0 Then Return results(0)
		  
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 46696E647320616C6C206E6F646573207769746820746865206D61746368696E672073656C6563746F722E
		Function QuerySelectorAll(theSelector As String) As HTMLNode()
		  /// Finds all nodes with the matching selector.
		  ///
		  /// Example usage:
		  /// 1. Has attribute (any value). Find all elements with an href attribute
		  ///      Var links() As HTMLNode = doc.QuerySelectorAll("[href]")
		  ///
		  /// 2. Exact match. Find all inputs with type="text"
		  ///      Var textInputs() As HTMLNode = doc.QuerySelectorAll("[type=text]")
		  ///    Also works with quotes:
		  ///      Var textInputs2() As HTMLNode = doc.QuerySelectorAll("[type='text']")
		  ///      Var textInputs3() As HTMLNode = doc.QuerySelectorAll("[type=""text""]")
		  ///
		  /// 3. Contains substring. Find all links that contain "example.com" anywhere in the href:
		  ///      Var exampleLinks() As HTMLNode = doc.QuerySelectorAll("[href*=example.com]")
		  ///
		  /// 4. Starts with. Find all links that start with "https://"
		  ///      Var httpsLinks() As HTMLNode = doc.QuerySelectorAll("[href^=https://]")
		  ///    Find all IDs that start with "user-"
		  ///      Var userElements() As HTMLNode = doc.QuerySelectorAll("[id^=user-]")
		  ///
		  /// 5. Ends with. Find all images with src ending in ".png"
		  ///      Var pngImages() As HTMLNode = doc.QuerySelectorAll("[src$=.png]")
		  ///    Find all links ending with ".pdf"
		  ///      Var pdfLinks() As HTMLNode = doc.QuerySelectorAll("[href$=.pdf]")
		  ///
		  /// 6. Contains word (space-separated). Find all elements with class containing "active" as a complete word:
		  ///    This would match class="btn active" but not class="inactive"
		  ///      Var activeElements() As HTMLNode = doc.QuerySelectorAll("[class~=active]")
		  ///
		  /// 7. Language/prefix match. Find all elements with lang="en" or lang="en-US" or lang="en-GB" etc:
		  ///      Var englishElements() As HTMLNode = doc.QuerySelectorAll("[lang|=en]")
		  ///
		  /// 8. Not equal (custom extension). Find all inputs that are NOT text type:
		  ///      Var nonTextInputs() As HTMLNode = doc.QuerySelectorAll("[type!=text]")
		  
		  #Pragma Warning "TODO: Test"
		  #Pragma Warning "TODO: Add more complex selector support from Claude chat"
		  
		  Var results() As HTMLNode
		  Var parts() As String = ParseSelector(theSelector)
		  
		  // A simple implementation for basic selectors.
		  If parts.Count = 0 Then Return results
		  
		  Var selectorType As String = parts(0)
		  Var selectorValue As String = If(parts.Count > 1, parts(1), "")
		  
		  Select Case selectorType
		  Case "tag"
		    // Tag selector (e.g., "div").
		    FindByTagName(selectorValue, results)
		    
		  Case "class"
		    // Class selector (e.g., ".myclass").
		    FindByClassName(selectorValue, results)
		    
		  Case "id"
		    // ID selector (e.g., "#myid").
		    FindByID(selectorValue, results)
		    
		  Case "attribute"
		    // Attribute selector (e.g., "[href]" or "[type=text]").
		    FindByAttribute(selectorValue, results)
		  End Select
		  
		  Return results
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 48656C70657220746F2072656D6F76652071756F7465732066726F6D206174747269627574652076616C7565732E
		Private Function StripQuotes(value As String) As String
		  /// Helper to remove quotes from attribute values.
		  
		  value = value.Trim
		  
		  If value.Length >= 2 Then
		    Var firstChar As String = value.Left(1)
		    Var lastChar As String = value.Right(1)
		    If (firstChar = """" And lastChar = """") Or (firstChar = "'" And lastChar = "'") Then
		      Return value.Middle(1, value.Length - 2)
		    End If
		  End If
		  
		  Return value
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73206120737472696E6720726570726573656E746174696F6E206F662074686973206E6F64652C20746F207468652073706563696669656420696E64656E746174696F6E206C6576656C2E
		Function ToString(indent As Integer = 0) As String
		  /// Returns a string representation of this node, to the specified indentation level.
		  
		  // Build the indent string.
		  Var spaces As String = ""
		  For i As Integer = 1 To indent * 2
		    spaces = spaces + " "
		  Next i
		  
		  Var result As String
		  
		  Select Case Self.Type
		  Case HTMLNode.Types.CDATA
		    result = spaces + "[CDATA: " + Content + "]" + EndOfLine
		    
		  Case HTMLNode.Types.Comment
		    result = spaces + "<!-- " + Content + " -->" + EndOfLine
		    
		  Case HTMLNode.Types.DocType
		    result = spaces + "<!DOCTYPE " + Content + ">" + EndOfLine
		    
		  Case HTMLNode.Types.Text
		    result = spaces + "[TEXT: " + Content.ReplaceAll(EndOfLine, " ") + "]" + EndOfLine
		    
		  Case HTMLNode.Types.Element
		    // <elementName
		    result = spaces + "<" + TagName
		    
		    // Attributes (e.g: id="something"
		    For Each key As Variant In Attributes_.Keys
		      result = result + " " + key.StringValue + "=""" + Attributes_.Value(key).StringValue + """"
		    Next key
		    
		    // Close the element tag.
		    result = result + ">" + EndOfLine
		    
		    // Recurse into each child node.
		    For Each child As HTMLNode In Children
		      result = result + child.ToString(indent + 1)
		    Next child
		    
		    // If this isn't a self-closing tag we need to close it.
		    If Not IsSelfClosing Then
		      result = result + spaces + "</" + TagName + ">" + EndOfLine
		    End If
		  End Select
		  
		  Return result
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Attributes_ As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Children() As HTMLNode
	#tag EndProperty

	#tag Property, Flags = &h0
		Content As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 547275652069662074686973206E6F6465206973206120626C6F636B20656C656D656E742028652E672E203C6469763E2C203C703E292E
		#tag Getter
			Get
			  Return Self.Type = Types.Element And HTMLParser.BlockTags.IndexOf(TagName) <> -1
			  
			End Get
		#tag EndGetter
		IsBlockElement As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Self.Type = Types.Element And HTMLParser.InlineTags.IndexOf(TagName) <> -1
			  
			End Get
		#tag EndGetter
		IsInlineElement As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		IsSelfClosing As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Self.Type = Types.Element And HTMLParser.SemanticTags.IndexOf(TagName) <> -1
			  
			End Get
		#tag EndGetter
		IsSemantic As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected mParent As WeakRef
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mParent = Nil Or mParent.Value = Nil Then
			    Return Nil
			  Else
			    Return HTMLNode(mParent.Value)
			  End If
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value <> Nil Then
			    mParent = New WeakRef(value)
			  End If
			  
			End Set
		#tag EndSetter
		Parent As HTMLNode
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		TagName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As HTMLNode.Types
	#tag EndProperty


	#tag Enum, Name = Types, Type = Integer, Flags = &h0
		CDATA
		  Comment
		  DocType
		  Element
		Text
	#tag EndEnum


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
			Name="Type"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
