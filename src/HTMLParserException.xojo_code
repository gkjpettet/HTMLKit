#tag Class
Protected Class HTMLParserException
Inherits RuntimeException
	#tag Method, Flags = &h0
		Sub Constructor(type As HTMLParserException.Types, line As Integer, column As Integer, message As String, severity As HTMLParserException.Severities = HTMLParserException.Severities.Warning)
		  // Calling the overridden superclass constructor.
		  Super.Constructor(message)
		  
		  Self.Type = type
		  Self.Line = line
		  Self.Column = column
		  Self.Severity = severity
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 52657475726E732074686520706173736564207365766572697479206173206120737472696E672E
		Protected Function SeverityToString(sev As HTMLParserException.Severities) As String
		  /// Returns the passed severity as a string.
		  
		  Select Case sev
		  Case HTMLParserException.Severities.Error
		    Return "Error"
		    
		  Case HTMLParserException.Severities.Info
		    Return "Info"
		    
		  Case HTMLParserException.Severities.Warning
		    Return "Warning"
		    
		  Else
		    Raise New InvalidArgumentException("Unknown HTMLParserException severity.")
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73206120737472696E6720726570726573656E746174696F6E206F6620746869732070617273696E6720657863657074696F6E2E
		Function ToString() As String
		  /// Returns a string representation of this parsing exception.
		  
		  Var typeStr As String
		  Select Case Type
		  Case HTMLParserException.Types.InvalidNesting
		    typeStr = "Invalid Nesting"
		    
		  Case HTMLParserException.Types.DeprecatedTag
		    typeStr = "Deprecated Tag"
		    
		  Case HTMLParserException.Types.DuplicateID
		    typeStr = "Duplicate ID"
		    
		  Case HTMLParserException.Types.InvalidAttribute
		    typeStr = "Invalid Attribute"
		    
		  Case HTMLParserException.Types.InvalidCharacter
		    typeStr = "Invalid Character"
		    
		  Case HTMLParserException.Types.MalformedTag
		    typeStr = "Malformed Tag"
		    
		  Case HTMLParserException.Types.MissingRequiredAttribute
		    typeStr = "Missing Required Attribute"
		    
		  Case HTMLParserException.Types.UnclosedCDATA
		    typeStr = "Unclosed CDATA"
		    
		  Case HTMLParserException.Types.UnmatchedClosingTag
		    typeStr = "Unmatched Closing Tag"
		    
		  Case HTMLParserException.Types.UnclosedComment
		    typeStr = "Unclosed Comment"
		    
		  Case HTMLParserException.Types.UnclosedQuote
		    typeStr = "Unclosed Quote"
		    
		  Case HTMLParserException.Types.UnclosedTag
		    typeStr = "Unclosed Tag"
		    
		  Else
		    Raise New UnsupportedOperationException("HTMLParserException.ToString: Unknown HTMLParserException Type")
		  End Select
		  
		  Return "[" + SeverityString.Uppercase + "] " + typeStr + " at line " + _
		  Line.ToString + ", column " + Column.ToString + ": " + Message
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Column As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 4120736E6970706574206F6620746578742061726F756E6420746865206572726F722E
		Context As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Line As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		Severity As HTMLParserException.Severities = HTMLParserException.Severities.Warning
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 52657475726E73207468697320657863657074696F6E2773207365766572697479206173206120737472696E672E
		#tag Getter
			Get
			  Return SeverityToString(Self.Severity)
			  
			End Get
		#tag EndGetter
		SeverityString As String
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		TagName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As HTMLParserException.Types
	#tag EndProperty


	#tag Enum, Name = Severities, Type = Integer, Flags = &h0
		Warning
		  Info
		Error
	#tag EndEnum

	#tag Enum, Name = Types, Type = Integer, Flags = &h0
		UnclosedTag
		  UnmatchedClosingTag
		  MalformedTag
		  InvalidAttribute
		  UnclosedComment
		  UnclosedCDATA
		  DuplicateID
		  InvalidNesting
		  MissingRequiredAttribute
		  DeprecatedTag
		  InvalidCharacter
		UnclosedQuote
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="ErrorNumber"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Message"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
