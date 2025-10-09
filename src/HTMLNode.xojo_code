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
		    
		  Case HTMLNode.Types.Comment
		    result = spaces + "<!-- " + Content + " -->" + EndOfLine
		    
		  Case HTMLNode.Types.DocType
		    result = spaces + "<!DOCTYPE " + Content + ">" + EndOfLine
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

	#tag Property, Flags = &h0
		IsSelfClosing As Boolean
	#tag EndProperty

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
