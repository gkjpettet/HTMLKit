#tag Class
Protected Class HTMLNode
	#tag Method, Flags = &h0
		Sub AddChild(child As HTMLNode)
		  /// Adds a child node so long as it is not Nil.
		  /// Does nothing if child is Nil.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If child = Nil Then Return
		  
		  child.Parent = Self
		  
		  Children.Add(child)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 46696E647320616E642072657475726E732074686520666972737420616E636573746F72207769746820676976656E2074686520746167206E616D65206F72204E696C206966206E6F6E6520666F756E642E
		Function Ancestor(tagName As String) As HTMLNode
		  /// Finds and returns the first ancestor with given the tag name or Nil if none found.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var tagNameLowerCase As String = tagName.Lowercase
		  
		  Var current As HTMLNode = Parent
		  While current <> Nil
		    If current.Type = HTMLNode.Types.Element And current.TagName.Lowercase = tagNameLowerCase Then
		      Return current
		    End If
		    current = current.Parent
		  Wend
		  
		  Return Nil
		  
		End Function
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

	#tag Method, Flags = &h0, Description = 52657475726E7320616C6C20656C656D656E747320696E2074686973206E6F64652077686F736520746167206D61746368657320746865207061737365642076616C75652E
		Function ElementsByTagName(tagName As String) As HTMLNode()
		  /// Returns all elements in this node whose tag matches the passed value.
		  
		  Var results() As HTMLNode
		  
		  FindByTagName(tagName.Lowercase, results)
		  
		  Return results
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 54616B6573206120435353E280917374796C652073656C6563746F7220737472696E672028652E672E206469765B636C6173733D22666F6F225D5B646174612D69643D355D2920616E642065787472616374732074686520746578742028636F6E646974696F6E292074686174206170706561727320696E7369646520656163682070616972206F662073717561726520627261636B6574732E20546865736520636F6E646974696F6E73206172652072657475726E656420617320616E2061727261792E
		Private Function ExtractBracketedConditions(theSelector As String) As String()
		  /// Takes a CSS‑style selector string (e.g. div[class="foo"][data-id=5]) and extracts the text (condition) that appears 
		  /// inside each pair of square brackets. These conditions are returned as an array.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var conditions() As String
		  Var chars() As String = theSelector.Characters
		  
		  Var inBracket As Boolean = False
		  Var currentCondition As String = ""
		  
		  For Each char As String In chars
		    If char = "[" Then
		      inBracket = True
		      currentCondition = ""
		      
		    ElseIf char = "]" Then
		      If inBracket And currentCondition <> "" Then
		        conditions.Add(currentCondition)
		      End If
		      inBracket = False
		      currentCondition = ""
		      
		    ElseIf inBracket Then
		      currentCondition = currentCondition + char
		    End If
		  Next char
		  
		  Return conditions
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 48656C70657220746F2066696E6420616C6C20656C656D656E74732028666F7220756E6976657273616C2073656C6563746F72292E
		Private Sub FindAllElements(results() As HTMLNode)
		  /// Helper to find all elements (for universal selector).
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If Type = Types.Element Then results.Add(Self)
		  
		  For Each child As HTMLNode In Children
		    child.FindAllElements(results)
		  Next child
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub FindByAttribute(attrSpec As String, results() As HTMLNode)
		  /// Finds all nodes with the specified attribute and adds them to the passed ByRef `results()` array.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If Type = Types.Element And Self.TagName.Lowercase = tagName.Lowercase Then
		    results.Add(Self)
		  End If
		  
		  For Each child As HTMLNode In Children
		    child.FindByTagName(tagName, results)
		  Next child
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 5472617665727365732074686973206E6F64652C206C6F6F6B696E6720666F7220656C656D656E74206E6F646573207468617420736174697366793A20616E206F7074696F6E616C20746167206E616D6520616E642061206C697374206F6620617474726962757465E2809162617365642073656C6563746F7220636F6E646974696F6E73204576657279206E6F64652074686174206D61746368657320616C6C20637269746572696120697320617070656E64656420746F2074686520427952656620726573756C74732061727261792E
		Private Sub FindComplexMatch(tagName As String, conditions() As String, ByRef results() As HTMLNode)
		  /// Traverses this node, looking for element nodes that satisfy:
		  /// an optional tag name and a list of attribute‑based selector conditions
		  /// Every node that matches all criteria is appended to the ByRef results array.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If Type = Types.Element Then
		    Var matched As Boolean = True
		    
		    // Check tag name if specified.
		    If tagName <> "" And TagName.Lowercase <> tagName.Lowercase Then
		      matched = False
		    End If
		    
		    // Check all attribute conditions.
		    If matched Then
		      For Each condition As String In conditions
		        If Not MatchesAttributeCondition(condition) Then
		          matched = False
		          Exit
		        End If
		      Next condition
		    End If
		    
		    If matched Then
		      results.Add(Self)
		    End If
		  End If
		  
		  // Check children.
		  For Each child As HTMLNode In Children
		    child.FindComplexMatch(tagName, conditions, results)
		  Next child
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746865206669727374206368696C64206F662074686973206E6F6465206F72204E696C20696620746865726520617265206E6F206368696C6472656E2E
		Function FirstChild() As HTMLNode
		  /// Returns the first child of this node or Nil if there are no children.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If Children.Count > 0 Then Return Children(0)
		  
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 412073696E676C65E280916E6F64652076657273696F6E206F662060517565727953656C6563746F72416C6C2829602E2055736566756C207768656E20796F75206B6E6F77207468652073656C6563746F722073686F756C642072657475726E206174206D6F7374206F6E65206E6F64652028652E672E20616E2049442073656C6563746F722920616E6420796F7520646F6EE28099742077616E7420746F20616C6C6F6361746520616E20617272617920666F7220616C6C206D6174636865732E204D61792072657475726E204E696C2E
		Function FirstNodeWithSelector(theSelector As String) As HTMLNode
		  /// A single‑node version of `NodesWithSelector()`.
		  /// Useful when you know the selector should return at most one node (e.g. an ID selector) and you don’t want to allocate 
		  /// an array for all matches.
		  /// May return Nil.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var results() As HTMLNode = NodesWithSelector(theSelector)
		  
		  If results.Count > 0 Then Return results(0)
		  
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732074686520636F6E636174656E617465642072617720746578742074686174206C69657320696E736964652074686973206E6F64652C2069676E6F72696E6720616E79206D61726B75702E20557365207768656E20796F75206E6565642074686520706C61696E207465787475616C207061796C6F6164206F662061207375627472656520776974686F757420616E792077686974657370616365206E6F726D616C69736174696F6E206F7220626C6F636BE28091656C656D656E742073706163696E67206C6F6769632028666F7220746861742073656520604765744E6F726D616C6973656454657874282960292E
		Function InnerText() As String
		  /// Returns the concatenated raw text that lies inside this node, ignoring any markup.
		  /// Use when you need the plain textual payload of a subtree without any whitespace normalisation 
		  /// or block‑element spacing logic (for that see `GetNormalisedText()`).
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var result As String
		  
		  If Self.Type = HTMLNode.Types.Text Then
		    
		    Return Self.Content
		    
		  ElseIf Self.Type = HTMLNode.Types.Element Then
		    
		    For Each child As HTMLNode In Children
		      result = result + child.InnerText
		    Next child
		    
		  End If
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 44657465726D696E657320696620746865207061737365642063686172616374657220697320776869746573706163652E2049662060636861722E4C656E67746860203C3E2031207468656E2077652072657475726E2046616C73652E
		Protected Function IsWhitespace(char As String) As Boolean
		  /// Determines if the passed character is whitespace.
		  /// If `char.Length` <> 1 then we return False.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  // Return False for anything that isn’t a single character.
		  If char.Length <> 1 Then Return False
		  
		  // Xojo’s built‑in Trim() removes the Unicode whitespace chars:
		  // space, tab (U+0009), line‑feed (U+000A) and carriage‑return (U+000D),
		  // so we can simply ask whether trimming leaves an empty string.
		  Return char.Trim = ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746865206C617374202866696E616C29206368696C64206F662074686973206E6F6465206F72204E696C20696620746865726520617265206E6F206368696C6472656E2E
		Function LastChild() As HTMLNode
		  /// Returns the last (final) child of this node or Nil if there are no children.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If Children.Count > 0 Then Return Children(Children.LastIndex)
		  
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 546869732075736573207468652073616D65206C6F6769632041732046696E644279417474726962757465206275742072657475726E73206120626F6F6C65616E20696E7374656164206F6620616464696E6720746F20726573756C74732E
		Private Function MatchesAttributeCondition(condition As String) As Boolean
		  /// This uses the same logic As FindByAttribute but returns a boolean instead of adding to results.
		  
		  If condition.Contains("*=") Then
		    Var parts() As String = condition.Split("*=")
		    If parts.Count = 2 Then
		      Var attrName As String = parts(0).Trim
		      Var attrValue As String = StripQuotes(parts(1).Trim)
		      Return AttributeValue(attrName).Contains(attrValue)
		    End If
		    
		  ElseIf condition.Contains("=") Then
		    Var parts() As String = condition.Split("=")
		    If parts.Count = 2 Then
		      Var attrName As String = parts(0).Trim
		      Var attrValue As String = StripQuotes(parts(1).Trim)
		      Return AttributeValue(attrName) = attrValue
		    End If
		  Else
		    // Just checking for existence.
		    Return Attributes_.HasKey(condition.Trim)
		  End If
		  
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MatchesSelector(node As HTMLNode, theSelector As String) As Boolean
		  /// Helper method to check if a node matches a simple selector.
		  
		  If node.Type <> Types.Element Then Return False
		  
		  theSelector = theSelector.Trim
		  
		  // ID selector.
		  If theSelector.Left(1) = "#" Then
		    Return node.AttributeValue("id") = theSelector.Middle(1)
		  End If
		  
		  // Class selector.
		  If theSelector.Left(1) = "." Then
		    Var className As String = theSelector.Middle(1)
		    Var classes() As String = node.AttributeValue("class").Split(" ")
		    Return classes.IndexOf(className) <> -1
		  End If
		  
		  // Attribute selector.
		  If theSelector.Left(1) = "[" And theSelector.Right(1) = "]" Then
		    Var attrSpec As String = theSelector.Middle(1, theSelector.Length - 2)
		    Return MatchesAttributeCondition(attrSpec)
		  End If
		  
		  // Tag selector.
		  Return node.TagName.Lowercase = theSelector.Lowercase
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746865206E657874207369626C696E67206E6F6465206F72204E696C206966207468657265206973206E6F6E652E
		Function NextSibling() As HTMLNode
		  /// Returns the next sibling node or Nil if there is none.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If Parent = Nil Then Return Nil
		  
		  Var myIndex As Integer = Parent.Children.IndexOf(Self)
		  If myIndex >= 0 And myIndex < parent.Children.LastIndex Then
		    Return parent.Children(myIndex + 1)
		  End If
		  
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 46696E647320616C6C206E6F646573207769746820746865206D61746368696E672073656C6563746F722E
		Function NodesWithSelector(theSelector As String) As HTMLNode()
		  /// Finds all nodes with the matching selector.
		  ///
		  /// Example usage:
		  /// 1. Has attribute (any value). Find all elements with an href attribute
		  ///      Var links() As HTMLNode = doc.NodesWithSelector("[href]")
		  ///
		  /// 2. Exact match. Find all inputs with type="text"
		  ///      Var textInputs() As HTMLNode = doc.NodesWithSelector("[type=text]")
		  ///    Also works with quotes:
		  ///      Var textInputs2() As HTMLNode = doc.NodesWithSelector("[type='text']")
		  ///      Var textInputs3() As HTMLNode = doc.NodesWithSelector("[type=""text""]")
		  ///
		  /// 3. Contains substring. Find all links that contain "example.com" anywhere in the href:
		  ///      Var exampleLinks() As HTMLNode = doc.NodesWithSelector("[href*=example.com]")
		  ///
		  /// 4. Starts with. Find all links that start with "https://"
		  ///      Var httpsLinks() As HTMLNode = doc.NodesWithSelector("[href^=https://]")
		  ///    Find all IDs that start with "user-"
		  ///      Var userElements() As HTMLNode = doc.NodesWithSelector("[id^=user-]")
		  ///
		  /// 5. Ends with. Find all images with src ending in ".png"
		  ///      Var pngImages() As HTMLNode = doc.NodesWithSelector("[src$=.png]")
		  ///    Find all links ending with ".pdf"
		  ///      Var pdfLinks() As HTMLNode = doc.NodesWithSelector("[href$=.pdf]")
		  ///
		  /// 6. Contains word (space-separated). Find all elements with class containing "active" as a complete word:
		  ///    This would match class="btn active" but not class="inactive"
		  ///      Var activeElements() As HTMLNode = doc.NodesWithSelector("[class~=active]")
		  ///
		  /// 7. Language/prefix match. Find all elements with lang="en" or lang="en-US" or lang="en-GB" etc:
		  ///      Var englishElements() As HTMLNode = doc.NodesWithSelector("[lang|=en]")
		  ///
		  /// 8. Not equal (custom extension). Find all inputs that are NOT text type:
		  ///      Var nonTextInputs() As HTMLNode = doc.NodesWithSelector("[type!=text]")
		  
		  Var results() As HTMLNode
		  theSelector = theSelector.Trim
		  
		  // Check for pseudo-selectors first
		  If theSelector.IndexOf(":") <> -1 Then
		    Return QueryPseudoSelector(theSelector)
		  End If
		  
		  // Handle combinators in order of precedence
		  If theSelector.IndexOf(",") <> -1 Then
		    // Multiple selectors
		    Return QueryMultipleSelectors(theSelector)
		  ElseIf theSelector.IndexOf(" > ") <> -1 Or theSelector.IndexOf(">") <> -1 Then
		    // Child selector
		    Return QueryChildSelector(theSelector)
		  ElseIf theSelector.IndexOf(" + ") <> -1 Or theSelector.IndexOf("+") <> -1 Then
		    // Adjacent sibling
		    Return QueryAdjacentSiblingSelector(theSelector)
		  ElseIf theSelector.IndexOf(" ~ ") <> -1 Or theSelector.IndexOf("~") <> -1 Then
		    // General sibling
		    Return QueryGeneralSiblingSelector(theSelector)
		  ElseIf theSelector.IndexOf(" ") <> -1 Then
		    // Descendant selector (space)
		    Return QueryDescendantSelector(theSelector)
		  End If
		  
		  // Handle multiple attributes like input[type=text][required]
		  If theSelector.IndexOf("[") <> -1 And theSelector.CountFields("[") > 2 Then
		    Return QueryComplexSelector(theSelector)
		  End If
		  
		  // Simple selector
		  Var parts() As String = ParseSelector(theSelector)
		  If parts.Count = 0 Then Return results
		  
		  Var selectorType As String = parts(0)
		  Var selectorValue As String = If(parts.Count > 1, parts(1), "")
		  
		  Select Case selectorType
		  Case "tag"
		    FindByTagName(selectorValue, results)
		  Case "class"
		    FindByClassName(selectorValue, results)
		  Case "id"
		    FindByID(selectorValue, results)
		  Case "attribute"
		    FindByAttribute(selectorValue, results)
		  End Select
		  
		  Return results
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207465787420776974682070726F70657220776869746573706163652068616E646C696E672E
		Function NormalisedText() As String
		  /// Returns text with proper whitespace handling.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If Self.Type = HTMLNode.Types.Text Then
		    // Check if the parent is a <pre> tag.
		    If Self.Parent <> Nil And Self.Parent.TagName = "pre" Then
		      Return Content // Preserve whitespace in <pre> tags.
		    Else
		      // Normalise whitespace.
		      Return NormaliseWhitespace(Content)
		    End If
		    
		  ElseIf Self.Type = HTMLNode.Types.Element Then
		    Var result() As String
		    Var needsSpace As Boolean = False
		    
		    For Each child As HTMLNode In Children
		      Var childText As String = child.NormalisedText
		      
		      If childText <> "" Then
		        If needsSpace And Not IsWhitespace(childText.Left(1)) Then
		          result.Add(" ")
		        End If
		        result.Add(childText)
		        needsSpace = child.IsBlockElement
		      End If
		    Next child
		    
		    Return String.FromArray(result, "").Trim
		  End If
		  
		  Return ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5265706C6163657320616C6C20776869746573706163652073657175656E636573207769746820612073696E676C652073706163652E
		Function NormaliseWhitespace(s As String) As String
		  /// Replaces all whitespace sequences with a single space.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  Var result As String = s
		  
		  // Replace tabs and newlines with spaces.
		  result = result.ReplaceAll(TAB, " ")
		  result = result.ReplaceAll(EndOfLine.UNIX, " ")
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
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

	#tag Method, Flags = &h0, Description = 52657475726E73207468652070726576696F7573207369626C696E67206F72204E696C20696620746865726520617265206E6F207369626C696E6773206F72207468697320697320746865206669727374206368696C642E
		Function PreviousSibling() As HTMLNode
		  /// Returns the previous sibling or Nil if there are no siblings or this is the first child.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
		  If parent = Nil Then Return Nil
		  
		  Var myIndex As Integer = parent.Children.IndexOf(Self)
		  If myIndex > 0 Then Return parent.Children(myIndex - 1)
		  
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 48616E646C65732061646A6163656E74207369626C696E672073656C6563746F72732028652E672E2C20226831202B207022202D207020696D6D6564696174656C79206166746572206831292E
		Private Function QueryAdjacentSiblingSelector(theSelector As String) As HTMLNode()
		  /// Handles adjacent sibling selectors (e.g., "h1 + p" - p immediately after h1).
		  
		  Var results() As HTMLNode
		  Var parts() As String = theSelector.Split("+")
		  
		  If parts.Count <> 2 Then
		    Return results
		  End If
		  
		  Var firstSelector As String = parts(0).Trim
		  Var secondSelector As String = parts(1).Trim
		  
		  // Find all elements matching the first selector.
		  Var firstMatches() As HTMLNode = NodesWithSelector(firstSelector)
		  
		  For Each node As HTMLNode In firstMatches
		    Var nextSibling As HTMLNode = node.NextSibling
		    If nextSibling <> Nil And MatchesSelector(nextSibling, secondSelector) Then
		      If results.IndexOf(nextSibling) = -1 Then
		        results.Add(nextSibling)
		      End If
		    End If
		  Next node
		  
		  Return results
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 48616E646C6573206368696C642073656C6563746F72732028652E672E2C2022646976203E207022202D206469726563742070206368696C6472656E206F6620646976292E
		Private Function QueryChildSelector(theSelector As String) As HTMLNode()
		  /// Handles child selectors (e.g., "div > p" - direct p children of div).
		  
		  Var results() As HTMLNode
		  Var parts() As String = theSelector.Split(">")
		  
		  If parts.Count < 2 Then
		    Return NodesWithSelector(theSelector)
		  End If
		  
		  // Clean and trim parts.
		  For i As Integer = 0 To parts.LastIndex
		    parts(i) = parts(i).Trim
		  Next i
		  
		  // Start with the first selector.
		  Var currentMatches() As HTMLNode = NodesWithSelector(parts(0))
		  
		  // For each subsequent selector, find direct children only.
		  For i As Integer = 1 To parts.LastIndex
		    Var nextMatches() As HTMLNode
		    
		    For Each parent As HTMLNode In currentMatches
		      // Only check direct children.
		      For Each child As HTMLNode In parent.Children
		        If MatchesSelector(child, parts(i)) Then
		          If nextMatches.IndexOf(child) = -1 Then
		            nextMatches.Add(child)
		          End If
		        End If
		      Next child
		    Next parent
		    
		    currentMatches = nextMatches
		  Next
		  
		  Return currentMatches
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E7320616E206172726179206F6620616C6C206E6F64657320696E207468652063757272656E7420747265652074686174207361746973667920746865207061737365642073656C6563746F722E2048616E646C65732073656C6563746F7273207468617420636F6D62696E65206120746167206E616D652077697468206F6E65206F72206D6F72652061747472696275746520627261636B6574732C20737563682061733A20615B687265665D20696E7075745B747970653D746578745D5B72657175697265645D
		Private Function QueryComplexSelector(theSelector As String) As HTMLNode()
		  /// Returns an array of all nodes in the current tree that satisfy the passed selector.
		  /// Handles selectors that combine a tag name with one or more attribute brackets, such as:
		  ///   a[href]
		  ///   input[type=text][required]
		  
		  Var results() As HTMLNode
		  
		  // Extract tag name (everything before first [).
		  Var tagName As String = ""
		  Var firstBracket As Integer = theSelector.IndexOf("[")
		  
		  If firstBracket > 0 Then
		    tagName = theSelector.Left(firstBracket).Trim
		  ElseIf firstBracket = -1 Then
		    // No brackets at all.
		    Return NodesWithSelector(theSelector)
		  End If
		  
		  // Extract all conditions.
		  Var conditions() As String = ExtractBracketedConditions(theSelector)
		  
		  If conditions.Count = 0 And tagName <> "" Then
		    // Just a tag name, no attributes.
		    FindByTagName(tagName, results)
		    Return results
		  End If
		  
		  // Find nodes matching all conditions.
		  FindComplexMatch(tagName, conditions, results)
		  
		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 48616E646C65732064657363656E64616E742073656C6563746F72732028652E672E2C2022646976207022202D20616C6C207020656C656D656E747320696E7369646520646976292E
		Private Function QueryDescendantSelector(theSelector As String) As HTMLNode()
		  /// Handles descendant selectors (e.g., "div p" - all p elements inside div).
		  
		  Var results() As HTMLNode
		  Var parts() As String = theSelector.Split(" ")
		  
		  // Clean up parts (remove empty strings from multiple spaces).
		  Var cleanParts() As String
		  For Each part As String In parts
		    part = part.Trim
		    If part <> "" Then
		      cleanParts.Add(part)
		    End If
		  Next part
		  
		  If cleanParts.Count < 2 Then
		    // Not a valid descendant selector.
		    Return NodesWithSelector(theSelector)
		  End If
		  
		  // Start with the first selector.
		  Var currentMatches() As HTMLNode = NodesWithSelector(cleanParts(0))
		  
		  // For each subsequent selector, find descendants.
		  For i As Integer = 1 To cleanParts.LastIndex
		    Var nextMatches() As HTMLNode
		    
		    For Each parent As HTMLNode In currentMatches
		      Var descendants() As HTMLNode = parent.NodesWithSelector(cleanParts(i))
		      For Each descendant As HTMLNode In descendants
		        // Avoid duplicates.
		        If nextMatches.IndexOf(descendant) = -1 Then
		          nextMatches.Add(descendant)
		        End If
		      Next descendant
		    Next parent
		    
		    currentMatches = nextMatches
		  Next i
		  
		  Return currentMatches
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 48616E646C65732067656E6572616C207369626C696E672073656C6563746F722028652E672E2C20226831207E207022202D20616C6C2070207369626C696E6773206166746572206831292E
		Private Function QueryGeneralSiblingSelector(theSelector As String) As HTMLNode()
		  /// Handles general sibling selector (e.g., "h1 ~ p" - all p siblings after h1).
		  
		  Var results() As HTMLNode
		  Var parts() As String = theSelector.Split("~")
		  
		  If parts.Count <> 2 Then
		    Return results
		  End If
		  
		  Var firstSelector As String = parts(0).Trim
		  Var secondSelector As String = parts(1).Trim
		  
		  // Find all elements matching the first selector.
		  Var firstMatches() As HTMLNode = NodesWithSelector(firstSelector)
		  
		  For Each node As HTMLNode In firstMatches
		    // Get all following siblings.
		    Var sibling As HTMLNode = node.NextSibling
		    While sibling <> Nil
		      If MatchesSelector(sibling, secondSelector) Then
		        If results.IndexOf(sibling) = -1 Then
		          results.Add(sibling)
		        End If
		      End If
		      sibling = sibling.NextSibling
		    Wend
		  Next node
		  
		  Return results
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 48616E646C6573206D756C7469706C652073656C6563746F72732028652E672E2C20226469762C20702C207370616E22202D20616C6C207468726565207479706573292E
		Private Function QueryMultipleSelectors(theSelector As String) As HTMLNode()
		  /// Handles multiple selectors (e.g., "div, p, span" - all three types).
		  
		  Var results() As HTMLNode
		  Var parts() As String = theSelector.Split(",")
		  
		  For Each part As String In parts
		    part = part.Trim
		    If part <> "" Then
		      Var matches() As HTMLNode = NodesWithSelector(part)
		      For Each match As HTMLNode In matches
		        // Avoid duplicates.
		        If results.IndexOf(match) = -1 Then
		          results.Add(match)
		        End If
		      Next match
		    End If
		  Next part
		  
		  Return results
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function QueryPseudoSelector(theSelector As String) As HTMLNode()
		  Var results() As HTMLNode
		  Var colonPos As Integer = theSelector.IndexOf(":")
		  
		  If colonPos = -1 Then Return results
		  
		  Var baseSelector As String = theSelector.Left(colonPos).Trim
		  Var pseudo As String = theSelector.Middle(colonPos + 1).Trim
		  
		  // Get base matches first.
		  Var baseMatches() As HTMLNode
		  If baseSelector = "" Then
		    // Universal selector.
		    FindAllElements(baseMatches)
		  Else
		    baseMatches = NodesWithSelector(baseSelector)
		  End If
		  
		  // Apply pseudo-selector filter.
		  Select Case pseudo.Lowercase
		  Case "first-child"
		    For Each node As HTMLNode In baseMatches
		      Var parent As HTMLNode = node.Parent()
		      If parent <> Nil And parent.FirstChild = node Then
		        results.Add(node)
		      End If
		    Next node
		    
		  Case "last-child"
		    For Each node As HTMLNode In baseMatches
		      Var parent As HTMLNode = node.Parent
		      If parent <> Nil And parent.LastChild = node Then
		        results.Add(node)
		      End If
		    Next node
		    
		  Case "empty"
		    For Each node As HTMLNode In baseMatches
		      If node.Children.Count = 0 And node.InnerText.Trim = "" Then
		        results.Add(node)
		      End If
		    Next node
		    
		  Case "not-empty"
		    For Each node As HTMLNode In baseMatches
		      If node.Children.Count > 0 Or node.InnerText.Trim <> "" Then
		        results.Add(node)
		      End If
		    Next node
		  End Select
		  
		  // Handle :nth-child(n)
		  If pseudo.Left(10) = "nth-child(" And pseudo.Right(1) = ")" Then
		    Var nthValue As String = pseudo.Middle(10, pseudo.Length - 11)
		    Var n As Integer = nthValue.ToInteger
		    
		    If n > 0 Then
		      For Each node As HTMLNode In baseMatches
		        Var parent As HTMLNode = node.Parent
		        If parent <> Nil Then
		          Var index As Integer = parent.Children.IndexOf(node)
		          If index = n - 1 Then // nth-child is 1-based
		            results.Add(node)
		          End If
		        End If
		      Next node
		    End If
		  End If
		  
		  Return results
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 48656C70657220746F2072656D6F76652071756F7465732066726F6D206174747269627574652076616C7565732E
		Private Function StripQuotes(value As String) As String
		  /// Helper to remove quotes from attribute values.
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
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
		  
		  #Pragma StackOverflowChecking False
		  #Pragma DisableBoundsChecking
		  #Pragma NilObjectChecking False
		  
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
		    result = spaces + "" + Content.ReplaceAll(EndOfLine, " ") + EndOfLine
		    
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


	#tag Property, Flags = &h0, Description = 6B6579203D20617474726962757465206E616D652028537472696E67292C2056616C7565203D206174747269627574652076616C75652028537472696E67292E
		Attributes_ As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 54686973206E6F64652773206368696C6472656E2E204D617920626520656D7074792E
		Children() As HTMLNode
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 54686973206E6F64652773207465787420636F6E74656E742E20446F206E6F74206D6F64696679206469726563746C79202D2075736520604164644368696C6428296020696620796F752764206C696B6520746F2061646420746F20746869732E
		Content As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 547275652069662074686973206E6F64652068617320616E79206368696C6472656E2E
		#tag Getter
			Get
			  Return Children.Count > 0
			End Get
		#tag EndGetter
		HasChildren As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 547275652069662074686973206E6F6465206973206120626C6F636B20656C656D656E742028652E672E203C6469763E2C203C703E292E20436F6D707574656420285472756520696620697473206E616D65206170706561727320696E206048544D4C5061727365722E426C6F636B5461677360292E
		#tag Getter
			Get
			  Return Self.Type = Types.Element And HTMLParser.BlockTags.IndexOf(TagName) <> -1
			  
			End Get
		#tag EndGetter
		IsBlockElement As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 54727565207768656E20746865206E6F646520697320616E20656C656D656E7420616E642069747320746167206E616D65206170706561727320696E206048544D4C5061727365722E496E6C696E6554616773602E
		#tag Getter
			Get
			  Return Self.Type = Types.Element And HTMLParser.InlineTags.IndexOf(TagName) <> -1
			  
			End Get
		#tag EndGetter
		IsInlineElement As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0, Description = 5365742062792074686520706172736572207768656E207468697320656C656D656E74206973207772697474656E20617320612073656C66E28091636C6F73696E67207461672028652E672E20603C62722F3E602C20603C696D6720E280A6202F3E602C20657463292E
		IsSelfClosing As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 547275652069662074686973206E6F646520697320616E20656C656D656E742077686F736520746167206E616D65206973206C697374656420696E206048544D4C5061727365722E53656D616E74696354616773602E20496E6469636174657320746861742074686520656C656D656E742063617272696573206D65616E696E67206265796F6E6420707572652070726573656E746174696F6E2E
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

	#tag ComputedProperty, Flags = &h0, Description = 546865206C6F676963616C20706172656E74206F662074686973206E6F646520696E2074686520747265652E20496E7465726E616C6C792073746F7265642061732061205765616B5265662028606D506172656E74602920736F20746861742063697263756C6172207265666572656E63657320646F206E6F74206B656570206F626A6563747320616C69766520756E696E74656E74696F6E616C6C792E2053657474696E67207468652070726F7065727479206175746F6D61746963616C6C792077726170732074686520737570706C696564206E6F646520696E206120605765616B526566602E2047657474696E672069742072657475726E73204E696C206966207468657265206973206E6F20706172656E74206F7220746865207765616B207265666572656E636520686173206265656E20636C65617265642E
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

	#tag Property, Flags = &h0, Description = 5468697320656C656D656E74732773206E616D652028652E672E2C2022646976222C20226122292E204974206973206F6E6C79206D65616E696E6766756C207768656E206054797065203D2054797065732E456C656D656E74602E20466F72206E6F6EE28091656C656D656E74206E6F64657320697420737461797320656D7074792E
		TagName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As HTMLNode.Types
	#tag EndProperty


	#tag Constant, Name = TAB, Type = String, Dynamic = False, Default = \"\t", Scope = Protected, Description = 54686520686F72697A6F6E74616C2074616220636861726163746572202826753039292E
	#tag EndConstant


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
			Type="HTMLNode.Types"
			EditorType="Enum"
			#tag EnumValues
				"0 - CDATA"
				"1 - Comment"
				"2 - DocType"
				"3 - Element"
				"4 - Text"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Content"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsBlockElement"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsInlineElement"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsSelfClosing"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsSemantic"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TagName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
